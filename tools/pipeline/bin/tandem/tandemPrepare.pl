#!/usr/bin/perl -w

#-----------------------------------------------------------------#
# tandemPrepare.pl
#
#	Given a tandem.xml file, prepares a directory for
#	X!Tandem processing.
#
#-----------------------------------------------------------------#

use strict;
use Getopt::Long;
use File::Basename;
use Cwd;

use lib Cwd::abs_path(dirname($0) . '/..');

use Pipe::TandemUtils;

main();

sub printUsage
{
	my $cmd_name;
	($cmd_name) = fileparse($0);

	die "Usage: $cmd_name [options] <tandem xml file>\n" .
		"	- tandem xml file - file with pipeline tandem.xml\n" .
		"	--i=<input file> - Input file for X!Tandem\n" .
		"	--f=<fasta root> - Unix root for relative path FASTA files\n";
}


sub main
{
	my $fastaRoot = "";
	my $inputFile = "input.dta";

	my $ret = GetOptions(
		"h|?!"                   => sub{ printUsage() ; exit 0 },
		"f|fasta-root=s"         => \$fastaRoot,
		"i|input-file=s"         => \$inputFile,
	);

	my $paramFile = shift(@ARGV);

	if ($ret == 0 || !defined($paramFile))
	{
		printUsage();
	}

	my $analysisDir = Cwd::abs_path(dirname($paramFile)) . "/";
	my $paramPrepFile = $analysisDir . "input.xml";
	my $taxonPath = $analysisDir . "taxonomy.xml";

	my %props = loadTandemInputXML($paramFile);

	# Transfer all non-pipeline properties to new map.
	my %propsNew = ();
	my $name;
	foreach $name (keys(%props))
	{
#		next if ($name =~ /^pipeline,/);
		$propsNew{$name} = $props{$name};
	}


	my $database = $props{"pipeline, database"};
	if (defined($database) && $database ne "")
	{
		writeSimpleTaxonXML($taxonPath, $fastaRoot, split(/:/, $database));
		$propsNew{"list path, taxonomy information"} = $taxonPath;
		$propsNew{"protein, taxon"} = "sequences";
	}

	if (!defined($props{"list path, default parameters"}))
	{
		$propsNew{"list path, default parameters"} = dirname($0) . "/default_input.xml";
	}

	my $threads = $props{"spectrum, threads"};
	if (!defined($threads) || $threads eq "")
	{	$threads = 4; }
	$propsNew{"spectrum, threads"} = $threads;
	$propsNew{"spectrum, path"} = $inputFile;
	# Force dta for .dta files, since X!Tandem has trouble recognizing
	# dta format sometimes.
	$propsNew{"spectrum, path type"} = "dta" if ($inputFile =~ /\.dta$/);
	$propsNew{"output, path"} = "output.xml";

	writeTandemInputXML($paramPrepFile, %propsNew);
}

