#!/usr/bin/perl -w

#-----------------------------------------------------------------#
# pipe.pl
#
# This script descends a directory tree looking for sub-directories
# with .def files, and no pipe.log file.  When it finds such
# a directory, it starts an analysis pipe-line for the specific
# type of def file.
#
#-----------------------------------------------------------------#

use strict;
use File::Basename;
use Cwd;
use Fcntl qw(:DEFAULT :flock);

use lib Cwd::abs_path(dirname($0));

use Pipe::Params;
use Pipe::Utils;
use Pipe::Scheduler::SchedulerFactory;

use Pipe::Comet;
use Pipe::Inspect;
use Pipe::Tandem;
use Pipe::Mascot;

use vars qw(%analysisMap);

#
# Analysis map
#

%analysisMap = (
	$Pipe::Comet::analysisFilename =>
		{ directory => $Pipe::Comet::analysisDirname,
		  analyze => \&Pipe::Comet::analyze },
	$Pipe::Inspect::analysisFilename =>
		{ directory => $Pipe::Inspect::analysisDirname,
		  analyze => \&Pipe::Inspect::analyze },
	$Pipe::Tandem::analysisFilename =>
		{ directory => $Pipe::Tandem::analysisDirname,
		  analyze => \&Pipe::Tandem::analyze },
	$Pipe::Mascot::analysisFilename =>
		{ directory => $Pipe::Mascot::analysisDirname,
		  analyze => \&Pipe::Mascot::analyze }
);


loadParams(dirname($0) . "/params.xml");

# for quick fix only, should pass to each analyzer after instantiating
$schedulerI = Pipe::Scheduler::SchedulerFactory->getScheduler(
	$scheduler, 
	'-JOBQUEUE'=>$queueName, 
	'-CLUSTERFAILUREEMAIL'=>$clusterFailureEmail,
	'-DEBUGLEVEL'=>$DEBUG,
	'-SUBDIRWORK'=>$subdirWork);

# Search the root directory for work to do.
while (processDirLocked($dirRoot) || $infinite)
{
	last if (!$loopTime);

	print ("Waiting $loopTime seconds...\n\n") if $DEBUG > 0;
	sleep($loopTime);

	$schedulerI->resetJobStatus();
}


#-----------------------------------------------------------------#
# processDirLocked(<directory path>)
#	Lock the root directory before processing everything else.
#       This ensures that a second call does not run into the
#       first, and cause duplicate handling.

sub processDirLocked
{
	my $directory = shift();
	my $lockFile = $dirRoot . "pipe.lock";
	sysopen(L_FILE, $lockFile, O_RDWR | O_CREAT)   
		|| die "Failed to open $lockFile: $!";
	my $sec;
	for ($sec = 0; $sec < 300; $sec += 5)
	{
		last if flock(L_FILE, LOCK_EX);

		sleep(5);
	}

	if ($sec >= 300)
	{	die "Failed to lock $lockFile: $!"; }

	my $ret = processDir($directory, 0);

	close(L_FILE);

	return $ret;
}


#-----------------------------------------------------------------#
# processDir(<directory path>,<level>)
#	Descend a directory tree looking for directories
#	that contain analysis definition files defined in
#	analysisMap, and which have not completed analysis.
#	For each such directory the appropriate analysis
#	pipe-line is pushed.

sub processDir
{
	my $directory = shift();
	my $level = shift();
	my $analyzed = 0;
	my ($root, $file, $temp);

	if ($level == $pruneLevel)
	{
		$directory .= $pruneName . '/';
		if (-d $directory)
		{	$analyzed += processDir($directory, $level + 1); }
		return $analyzed;
	}

	if (!opendir(DIR, $directory))
	{
		print "DEBUG: $directory - $!\n" if $DEBUG >= 4;
		return $analyzed;
	}

	my @files = sort(readdir(DIR));
	closedir(DIR);

	my $analysisDir = 0;

	foreach $file (@files)
	{
		if (defined($analysisMap{$file}))
		{
			if (isAnalysisComplete($directory, @files))
			{
				$analysisDir = 1;
				print "DEBUG: $directory - analysis complete.\n" if $DEBUG >= 4;
			}
			else
			{
				$analysisDir = processAnalysisDir($directory, $analysisMap{$file});
				$analyzed += $analysisDir;
			}
		}
	}

	# Don't descend further into analysis directories.
	if ($analysisDir == 0)
	{
		foreach $file (@files)
		{
			next if $file eq ".";
			next if $file eq "..";

			my $path = $directory . $file . '/';
			if (-d $path)
			{	$analyzed += processDir($path, $level + 1); }
		}
	}

	return $analyzed;
}

#-----------------------------------------------------------------#
# processAnalysisDir(<directory path>,<filename>)
#	Pushes analysis pipeline for any directory containing
#	an analysis file, for which analysis is not complete.

sub processAnalysisDir
{
	my $directory = shift();
	my $analysisProps = shift();
	my $analyzed = 0;

	my $analysisDir = $analysisProps->{"directory"};
	# Look for <data-root>/<analysis-name>/<protocol>/
	$directory .= "/" if $directory !~ /\/$/;
	if ($directory =~ /^(.*\/)$analysisDir\/[^\/]+\/$/)
	{
		my $root = $1;

		print "DEBUG: $directory - processing.\n" if $DEBUG >= 1;
		my $logFile = getLogFile($directory);
		writeLog($logFile, "\n" . getTimeStamp() . "\n\n", 5);	# logfile only

		my $analysisFunc = $analysisProps->{"analyze"};
		my $status = &$analysisFunc($root, $directory);

		if ($status ne "COMPLETE")
		{	$analyzed++; }
	}

	return $analyzed;
}
