#!/usr/bin/perl -w

#-----------------------------------------------------------------#
# mascotPrepare.pl
#
#	Given a mascot.xml file, prepares a directory for
#	Mascot processing.
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

	die "Usage: $cmd_name [options] <mascot xml file>\n" .
		"	- mascot xml file - file with pipeline mascot.xml\n" .
		"	--i=<input file> - Input file for Mascot\n" .
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
	#we do not need this for Mascot
	#my $taxonPath = $analysisDir . "taxonomy.xml";

	my %props = loadTandemInputXML($paramFile);

	my $database = $props{"pipeline, database"};

	my $defaultParamFile = $props{"list path, default parameters"};
	if (!defined($defaultParamFile))
	{
		$defaultParamFile = dirname($0) . "/mascot_default_input.xml";
	}

	my %propsDefault = loadTandemInputXML($defaultParamFile);

	# Transfer all all properties to default map
	my $name;
	foreach $name (keys(%props))
	{
		$propsDefault{$name} = $props{$name};
	}
	$propsDefault{"list path, default parameters"} = $defaultParamFile;
	#$propsDefault{"search, db"} = $props{"pipeline, database"};
	#$propsDefault{"search, useremail"} = $props{"pipeline, email address"};
	#$propsDefault{"search, username"} = "CPAS Cluster User";
	#$propsDefault{"output, path"} = "output.xml";

	writeTandemInputXML($paramPrepFile, %propsDefault);
}


