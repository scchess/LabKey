package Pipe::TandemUtils;

use strict;
use File::Basename;

use XML::DOM;
use XML::Writer;
use IO::File;

BEGIN
{
	use Exporter;

	@Pipe::TandemUtils::ISA       = qw(Exporter);
	@Pipe::TandemUtils::EXPORT    = qw(loadTandemInputXML
						writeTandemInputXML
						writeSimpleTaxonXML
						getQuantitationCmd
						isFractions
						isSamples);
	@Pipe::TandemUtils::EXPORT_OK = qw();
}

my $bin_dir = dirname($0) . '/';

#-----------------------------------------------------------------#
# loadTandemInputXML(<input file>)
#	Loads a tandem input XML file into name-value pair map.
#	

sub loadTandemInputXML
{
	my $inputFile = shift();
	my %props = ();
	
	my $parser = new XML::DOM::Parser;
	my $doc = eval { $parser->parsefile($inputFile) };

	if (!$@)
	{
		my $notes = $doc->getElementsByTagName("note");
		my $len = $notes->getLength();

		for (my $i = 0; $i < $len; $i++)
		{
			my $note = $notes->item($i);
			my $type = $note->getAttribute("type");
			next if ($type ne "input");

			my $label = $note->getAttribute("label");
			next if ($label eq "");

			my @children = $note->getChildNodes();
			next if ($#children < 0);

			my $value = $children[0];
			next if ($value->getNodeName() ne "#text");

			$props{$label} = $value->getNodeValue();
		}

		$doc->dispose();
	}

	return %props;
}

#-----------------------------------------------------------------#
# writeTandemInputXML(<output file>, <property map>)
#	Writes a X!Tandem input XML file from a property map.
#	

sub writeTandemInputXML
{
	my $outputFile = shift();
	my %props = @_;

	#TODO: Error handling.
	my $output = new IO::File(">$outputFile");
	my $writer = new XML::Writer(OUTPUT => $output,
				DATA_MODE => 1,
				DATA_INDENT => 2);
	$writer->xmlDecl();
	$writer->startTag("bioml");

	my $name;
	foreach $name (sort(keys(%props)))
	{
		next if (!defined($props{$name}));

		$writer->startTag("note",
				"type" => "input",
				"label" => $name);
		$writer->characters($props{$name});
		$writer->endTag("note");
	}

	$writer->endTag("bioml");
	$writer->end();
	$output->close();
}

#-----------------------------------------------------------------#
# writeSimpleTaxonXML(<output file>,<fasta path>,<file list>)
#	Writes out a simple X!Tandem taxonomy file with a
#	single taxon, and a list of files.
#	

sub writeSimpleTaxonXML
{
	my $outputFile = shift();
	my $fastaPath = shift();
	$fastaPath .= '/' if ($fastaPath !~ /\/$/);
	my @files = @_;

	if (open(OUT, ">$outputFile"))
	{
		print OUT "<?xml version=\"1.0\"?>\n";
		print OUT "<bioml label=\"x! taxon-to-file matching list\">\n";
		print OUT "	<taxon label=\"sequences\">\n";

		for (my $i = 0; $i <= $#files; $i++)
		{
			my $file = $files[$i];

			# if relative path, prepend the fasta root
			$file = $fastaPath . $file if ($file !~ /^\//);

			print OUT "		<file format=\"peptide\" URL=\""
				. $file . "\"/>\n";
		}

		print OUT "	</taxon>\n";
		print OUT "</bioml>\n";

		close(OUT);
	}
}

#-----------------------------------------------------------------#
# getQuantitationCmd(<def properties>[,<xml dir>])
#	Returns a XPressPeptideParser command line based on
#       the properties from a tandem.xml file.
#
#	TODO: Log parameter errors.

sub getQuantitationCmd
{
	my $defProps = shift();
	my $xmlDir = shift();

	my $cmd;

	my $qType = $defProps->{"pipeline quantitation, algorithm"};
	if (!defined($qType) || $qType eq "")
	{	return $cmd; }
	if ($qType !~ /xpress/i && $qType !~ /q3/i)
	{
		#TODO: ERROR
		return $cmd;
	}

	$cmd = "";
	my $labelParam = $defProps->{"pipeline quantitation, residue label mass"};
	if (defined($labelParam) && $labelParam =~ /@/)
	{
		my @labels = split(/,/, $labelParam);
		my $label;
		foreach $label (@labels)
		{
			my ($mass,$aa) = split(/@/, $label);
			$mass =~ s/^\s*//;
			$mass =~ s/\s*$//;
			$aa =~ s/^\s*//;
			$aa =~ s/\s*$//;
			$cmd .= " -n" . $aa . "," . $mass;
		}
	}

	my $tol = $defProps->{"pipeline quantitation, mass tolerance"};
	if (defined($tol) && $tol ne '')
	{	$cmd .= " -m" . $tol; }

	my $fix = $defProps->{"pipeline quantitation, fix"};
	if (defined($fix))
	{
		if ($fix =~ /heavy/i)
		{	$cmd .= " -H"; }
		elsif ($fix =~ /light/i)
		{	$cmd .= " -L"; }
	}

	my $ref = $defProps->{"pipeline quantitation, fix elution reference"};
	if (defined($ref))
	{
		my $refFlag = "-f";
		if ($ref =~ /peak/i)
		{	$refFlag = "-F"; }
		my $diff = $defProps->{"pipeline quantitation, fix elution difference"};
		if (defined($diff))
		{	$cmd .= " " . $refFlag . $diff; }
	}

	my $type = $defProps->{"pipeline quantitation, metabolic search type"};
	if (defined($type))
	{
		$cmd .= " -M" if $type =~ /normal/i;
		$cmd .= " -N" if $type =~ /heavy/i;
	}


	if (defined($xmlDir))
	{
		$cmd .= " -d\\\"" . $xmlDir . "\\\"";
	}

	if ($qType =~ /xpress/i)
	{
		$cmd = " -X\"" . $cmd . "\"";
	}
	else
	{
		my $minPP = $defProps->{"pipeline quantitation, min peptide prophet"};
		if (defined($minPP))
		{	$cmd .= " --minPeptideProphet=" . $minPP; }
		my $maxDelta = $defProps->{"pipeline quantitation, max fractional delta mass"};
		if (defined($maxDelta))
		{	$cmd .= " --maxFracDeltaMass=" . $maxDelta; }
		my $compatQ3 = $defProps->{"pipeline quantitation, q3 compat"};
		if (defined($compatQ3) && $compatQ3 =~ /yes/i)
		{	$cmd .= " --compat"; }

		$cmd = "-C1\"java -client -Xmx256M -jar " . $bin_dir . "msInspect/viewerApp.jar --q3 " . $cmd . "\" -C2Q3ProteinRatioParser";
	}

	return $cmd;
}

#-----------------------------------------------------------------#
# isFractions(<analysis type>)
#	Returns true if the analysis type is fractions.

sub isFractions
{
	my $analysisType = shift();

	return defined($analysisType) &&
		($analysisType =~ /^Fractions$/i ||
		$analysisType =~ /^Both$/i);
}

#-----------------------------------------------------------------#
# isSamples(<analysis type>)
#	Returns true if the analysis type is not fractions,
#	since the samples type is the default.

sub isSamples
{
	my $analysisType = shift();

	return !defined($analysisType) ||
		$analysisType =~ /^Samples$/i ||
		$analysisType =~ /^Both$/i;
}	

1;

