package Pipe::Interact;

use strict;
use File::Basename;
use Carp;

use Pipe::Params;

BEGIN
{
	use Exporter;

	@Pipe::Interact::ISA       = qw(Exporter);
	@Pipe::Interact::EXPORT    = qw(pushToInteract);
	@Pipe::Interact::EXPORT_OK = qw();
}

my $lyceum_dir = "/data/users/";
my $shared_dir = "/shared/biotech/";

my $bin_dir = dirname($0);

#-----------------------------------------------------------------#
# pushToInteract(<analysis dir>,<log file>)
#	Pushes interact files to interact server location.

sub pushToInteract
{
	my $analysisDir = shift();
	my $logFile = shift();

	if ($analysisDir !~ /^$dirRoot/)
	{	carp "ERROR: pushToInteract called with bad path $analysisDir."; }

	my $prefixLen = length($dirRoot);
	prefixLen++ unless $dirRoot =~ /\/$/;

	my $relpath = substr($analysisDir, $prefixLen);
	my @relparts = split(/\//, $relpath);
	
	if ($relparts[0] =~ /^[a-zA-Z]$/)
	{	splice(@relparts, 0, 1); } # remove alpha char

	my $sharedpath = $shared_dir . join("/", @relparts);

	splice(@relparts, $pruneLevel, 1) if ($pruneLevel != -1); # remove mass_spec

	my $lycpath = $lyceum_dir . join("/", @relparts);

	writeLog($logFile, "LOG: Copy comet files from $analysisDir to $lycpath.\n");

	system($bin_dir . "cometPush.pl", "--g=comet", $analysisDir, $lycpath, $sharedpath);
}

1;
