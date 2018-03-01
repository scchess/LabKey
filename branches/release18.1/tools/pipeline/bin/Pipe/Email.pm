package Pipe::Email;

use strict;

use Pipe::Utils;

BEGIN
{
	use Exporter;

	@Pipe::Email::ISA       = qw(Exporter);
	@Pipe::Email::EXPORT    = qw(sendDatabaseError
					sendClusterFailure);
	@Pipe::Email::EXPORT_OK = qw();
}

#-----------------------------------------------------------------#
# sendDatabaseError(<email>,<analysis directory>,<analysis filename>,
#			<database file>,<logfile>)
#	Sends error message about invalid database path.

sub sendDatabaseError
{
	my $emailAddress = shift();
	my $analysisDir = shift();
	my $analysisFilename = shift();
	my $databaseFile = shift();
	my $logFile = shift();

	if (!defined($databaseFile))
	{	$databaseFile = ""; }

	writeLog($logFile, "ERROR: Missing database $databaseFile\n");

	if (!defined($emailAddress) || $emailAddress eq "")
	{	return; }

	writeLog($logFile, "LOG: Sending database error email to $emailAddress\n");

	if (open(MAIL, "| mailx -v -s \"ERROR: Pipeline analysis failure\" $emailAddress >/dev/null 2>/dev/null"))
	{
		print MAIL "Pipeline analysis failure\n";
		print MAIL "DIRECTORY: $analysisDir\n";
		print MAIL "DATABASE: $databaseFile\n";
		print MAIL "MESSAGE: Database not found. Removing $analysisFilename.\n";
		print MAIL "SOLUTION: Fix local $analysisFilename, and re-run push command.\n";

		close(MAIL);
	}
	else
	{
		writeLog($logFile, "ERROR: Failed to open email.\n");
	}
}

#-----------------------------------------------------------------#
# sendClusterFailure(<email>,<analysis directory>,<cluster log>,
#			<logfile>)
#	Sends error message about failure in cluster.

sub sendClusterFailure
{
	my $emailAddress = shift();
	my $analysisDir = shift();
	my $clusterLog = shift();
	my $logFile = shift();

	if (!defined($emailAddress) || $emailAddress eq "")
	{	return; }

	writeLog($logFile, "LOG: Sending cluster failure email to $emailAddress\n");

	if (open(MAIL, "| mailx -v -s \"ERROR: Pipeline cluster failure\" $emailAddress >/dev/null 2>/dev/null"))
	{
		print MAIL "Pipeline cluster processing failure\n";
		print MAIL "DIRECTORY: $analysisDir\n";
		print MAIL "MESSAGE: See log below.\n\n";

		if (!open(LOG, $clusterLog))
		{
			print MAIL "Failed to open log.\n";
		}
		else
		{
			while(<LOG>)
			{
				print MAIL;
			}
			close(LOG);
		}
		close(MAIL);
	}
	else
	{
		writeLog($logFile, "ERROR: Failed to open email.\n");
	}
}

1;

