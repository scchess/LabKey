#!/usr/bin/perl -w

#-----------------------------------------------------------------#
# tandemPostProcess.pl
#
#	Given a .xtan.xml file, fixes up input path.
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

	die "Usage: $cmd_name [options] <tandem output xml file> <local input path>\n" .
		"	- tandem output xml file - file with pipeline tandem.xml\n" .
		"	- local input path - correct local path to input file\n";
}


sub main
{
	my $ret = 1;

	my $outputFile = shift(@ARGV);
	my $localPath = shift(@ARGV);

	if ($ret == 0 || !defined($outputFile) || !defined($localPath))
	{
		printUsage();
	}

	my $outputFileTemp = $outputFile . ".tmp";
	my $outputFileBackup = $outputFile . ".bak";

	open(OUT, $outputFile) || die "ERROR: Failed to open $outputFile.\n";
	open(TMP, ">" . $outputFileTemp) || die "ERROR: Failed to open temp file.\n";

	while(<OUT>)
	{
		s/(<note type="input" label="spectrum, path">)[^<]*/$1$localPath/;
		print TMP;
	}

	close(OUT);
	close(TMP);

	system("mv", $outputFile, $outputFileBackup);
	system("mv", $outputFileTemp, $outputFile);
	unlink($outputFileBackup);
}

