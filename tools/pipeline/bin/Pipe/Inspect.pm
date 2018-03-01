package Pipe::Inspect;

use strict;
use File::Basename;

use Pipe::Params;
use Pipe::Convert;
use Pipe::Utils;
use Pipe::Web;

BEGIN
{
	use Exporter;

	@Pipe::Inspect::ISA       = qw(Exporter);
	@Pipe::Inspect::EXPORT    = qw();
	@Pipe::Inspect::EXPORT_OK = qw();
}

our $analysisFilename = "inspect.def";
our $analysisDirname = "inspect";
our $providerName = "msInspect (Cluster)";

my $bin_dir = dirname($0) . '/';
my $inspectQueue = "inspect";

#-----------------------------------------------------------------#
# analyze(<rood directory>,<directory path>)
#	Process a single directory containing an inspect.def file.

sub analyze
{
	my $analysisRoot = shift();
	my $analysisDir = shift();

	my $status = "ERROR";

	my $logFile = getLogFile($analysisDir);
	my $statusFile = getStatusFile($analysisDir);
	my $defFile = $analysisDir . $analysisFilename;
	my %defProps = loadDefFile($defFile);

	my @defKeys = keys(%defProps);
	if ($#defKeys < 0)
	{
		writeLog($logFile, "ERROR: Invalid def file $defFile.\n");
		setStatus($statusFile, $status, "type=def");
		return $status;
	}

	my $emailAddress = $defProps{"EmailAddress"};
	if (defined($emailAddress) && $emailAddress !~ /\@/)
	{	$emailAddress .= '@fhcrc.org'; }
	
	my $strategy = $defProps{"Strategy"};
	if (!defined($strategy) || $strategy eq "")
	{
		writeLog($logFile, "ERROR: Strategy property required in def file $defFile.\n");
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=def");
		return $status;
	}
	my $inspectVersion = $defProps{"Version"};
	if (!defined($inspectVersion) || $inspectVersion eq "")
	{
		writeLog($logFile, "ERROR: Version property required in def file $defFile.\n");
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=def");
		return $status;
	}
	elsif (!-f getInspectJar($inspectVersion))
	{
		my @inspectJars = getInspectJars();
		writeLog($logFile, "ERROR: msInspect version $inspectVersion not found.\n" .
			"	Try one of the following:\n" .
			"		" . join("\n		", @inspectJars) . "\n");
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=version");
		return $status;
	}
	
	my $rawDir = $defProps{"DataPath"};
	my $xmlDir = $defProps{"XMLPath"};
	my $filterInclude = $defProps{"FilterInclude"};
	my $filterExclude = $defProps{"FilterExclude"};
	my $xmlExt = $defProps{"XMLExt"};

	if (!defined($rawDir))
	{
		$rawDir = $analysisRoot;
		if (-d $analysisRoot . "raw/")
		{	$rawDir = $analysisRoot . "raw/"; }

		if (!defined($xmlDir))
		{
			$xmlDir = $analysisRoot;
			if (-d $analysisRoot . "xml/")
			{
				$xmlDir = $analysisRoot . "xml/";
				if (defined($xmlExt) && $xmlExt ne "")
				{	$xmlDir .= $xmlExt . "/"; }
			}
		}
		else
		{	$xmlDir = getAbsolutePath($analysisDir, $xmlDir); }
	}
	else
	{
		$rawDir = getAbsolutePath($analysisDir, $rawDir);
		
		if (!defined($xmlDir))
		{	$xmlDir = $rawDir; }
		else
		{	$xmlDir = getAbsolutePath($analysisDir, $xmlDir); }
	}

	if (! -d $rawDir && ! -d $xmlDir)
	{
		writeLog($logFile, "LOG: Failed to find data at $rawDir.\n");
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=no dir");
		return $status;
	}

	my @analysisList = getAnalysisList($filterInclude, $filterExclude,
		$xmlDir, ".mzXML",
		$rawDir, ".raw");

	if ($#analysisList < 0)
	{
		writeLog($logFile, "ERROR: No files found to analyze.\n");
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=no data");
		return $status;
	}

	$status = "PROCESSED_FILES";
	my $basename;
	foreach $basename (@analysisList)
	{
		my $status_file = analyzeFile($basename,
						$analysisDir,
						$rawDir,
						$xmlDir,
						\%defProps);

		if ($status_file ne "COMPLETE")
		{	$status = "PROCESSING_FILES"; }
	}

	if ($status eq "PROCESSING_FILES")
	{
		if ($status ne getStatus($statusFile))
		{
			setStatusEx($statusFile, $providerName, $emailAddress,
				$status);
		}
	}
	elsif ($status eq "PROCESSED_FILES")
	{
		$status = "COMPLETE";
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status);
	}

	if ($status eq "COMPLETE")
	{
		# Send email to user in inspect.def file.

		sendCompleteMail($emailAddress, $analysisDir, $logFile);

		# Remove status file, and rename log.

		writeLog($logFile, "LOG: msInspect processing completed successfully.\n");
		completeAnalysis($analysisDir);
	}

	return $status;
}

sub analyzeFile
{
	my $basename = shift();
	my $analysisDir = shift();
	my $rawDir = shift();
	my $xmlDir = shift();
	my $defProps = shift();

	my $emailAddress = $defProps->{"EmailAddress"};
	if (defined($emailAddress) && $emailAddress !~ /\@/)
	{	$emailAddress .= '@fhcrc.org'; }
	
	my $xmlExt = normalizeExt($defProps->{"XMLExt"});
	my $featuresExt = normalizeExt($defProps->{"FeaturesExt"});

	my $fileType = "masslynx";
	my $rawFile = $rawDir . $basename . ".raw";
	if (! -d $rawFile)
	{
		$fileType = "thermo";
		if (! -f $rawFile)
		{	$rawFile =~ s/\.raw$/.RAW/; }
	}

	my $xmlFile = $xmlDir . $basename . $xmlExt . ".mzXML";
	my $featureFile = $analysisDir . $basename . $featuresExt . ".features.tsv";

	my $statusFile = getStatusFile($analysisDir, $basename);
	my $logFile = getLogFile($analysisDir);

	my $status = getStatus($statusFile);

	if ($status eq "UNKNOWN")
	{
		if (-f $featureFile)
		{
			$status = "PROCESSED";
		}
		elsif (-f $xmlFile)
		{
			$status = "CONVERTED";
		}
		else
		{
			$status = "STARTING";
		}

		setStatusEx($statusFile, $providerName, $emailAddress,
			$status);
	}

	if ($status eq "STARTING" || $status eq "REQUESTING")
	{
		if (! -d $xmlDir)
		{
			mkdir($xmlDir);
			# mode param for mkdir doesn't work.
			chmod(02775, $xmlDir);
		}

		if ($convertServer eq "")
		{
			writeLog($logFile, "ERROR: Missing mzXML file.  " .
				"Specify a conversion server.\n");
			$status = "ERROR";
			setStatus($statusFile, $status, "type=convert server");
		}
		elsif (setStatus($statusFile, "REQUESTING"))
		{
			writeLog($logFile, "LOG: Converting $basename\n");

			my %params = ();
			my $recalParams = $defProps->{"RecalibrateParams"};
			if (defined($recalParams))
			{	$params{"recalParams"} = $recalParams; }

			startConversion($convertServer,
					$rawFile,
					$xmlFile,
					$fileType,
					$statusFile,
					$logFile,
					%params);
		}
	}
	elsif ($status eq "CONVERTING")
	{
		writeLog($logFile, "LOG: Checking conversion status $basename\n");

		$status = getConversionStatus($convertServer,
						$rawFile,
						$statusFile,
						$logFile);

		if ($status eq "CONVERTED")
		{
			$status = analyzeFile($basename,
						$analysisDir,
						$rawDir,
						$xmlDir,
						$defProps);
		}
	}
	elsif ($status eq "CONVERTED")
	{
		writeLog($logFile, "LOG: Running msInspect for $basename\n");

		$status = startInspect($basename,
					$analysisDir,
					$featuresExt,
					$xmlDir,
					$xmlExt,
					$defProps,
					$statusFile,
					$logFile);

		if ($status ne "PROCESSING")
		{
			writeLog($logFile, "ERROR: Failed to start msInspect analysis.\n");
			$status = "ERROR";
			setStatus($statusFile, $status, "type=job start");
			unlink($statusFile);	# Allow infinite retry
		}
	}
	elsif ($status =~ /^PROCESSING->jobid=(.*)$/)
	{
		writeLog($logFile, "LOG: Checking job status $basename\n");

		# Check  to make sure the job is in fact still running.
		my $jobid = $1;
		if (!$schedulerI->isJobRunning($jobid, $logFile))
		{
			$schedulerI->publishOutput($analysisDir, 1, $basename, "inspect");

			$status = "ERROR";
			setStatus($statusFile, $status, "type=job failure");
		}
	}
	elsif ($status eq "PROCESSED")
	{
		$schedulerI->publishOutput($analysisDir, 0, $basename, "inspect");

		# Some day data may get uploaded to the web site,
		# but for now, the job is complete after processing.

		$status = "COMPLETE";
		setStatus($statusFile, $status);
	}
	elsif ($status ne "COMPLETE")
	{
		writeLog($logFile, "ERROR: Status=\"$status\"\n".
					"	in $statusFile.\n");
	}

	return $status;
}

#-----------------------------------------------------------------#
# startInspect(<basename>,<analysis dir>,<features ext>,
#		<xml dir>,<xml ext>,<def properties>,
#		<status file>,<log file>)
#	Starts msInspect running on a specific file.

sub startInspect
{
	my $basename = shift();
	my $analysisDir = shift();
	my $featuresExt = shift();
	my $xmlDir = shift();
	my $xmlExt = shift();
	my $defProps = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my @jobs;

	my $status = "CONVERTED";

	my $inspectFile = $analysisDir . $basename . $featuresExt . ".features.tsv";

	# Create PBS jobs based on files present.
	# Fail if the first job submitted fails, but succeed
	# if any job is successfully submitted to avoid looping
	# and filling the queue with partial jobs on the same
	# file.

	if (-f $inspectFile)
	{	return $status; }

	push(@jobs, createInspectJob($basename,
				$analysisDir,
				$featuresExt,
				$xmlDir,
				$xmlExt,
				$defProps,
				$statusFile,
				$logFile));

	if ($jobs[0] eq "")
	{	return $status; }

	$status = "PROCESSING";
	setStatus($statusFile, $status, "jobid=" . $jobs[$#jobs]);

	writeLog($logFile, "LOG: Sleeping 2 seconds for job scheduler.\n", 2);
	sleep 2;

	return $status;
}

#-------------------------------------------------------------------#
# createInspectJob(<basename>,<analysis dir>,<features ext>,
#			<xml dir>,<xml ext>,<def properties>,
#			<status file>, <log file>)
#	Creates a cluster job for running msInspect creation.

sub createInspectJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $featuresExt = shift();
	my $xmlDir = shift();
	my $xmlExt = shift();
	my $defProps = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $strategy = $defProps->{"Strategy"};
	my $inspectVersion = $defProps->{"Version"};
	my $startScan = $defProps->{"Start"};
	my $countScans = $defProps->{"Count"};
	my $minMz = $defProps->{"MinMz"};
	my $maxMz = $defProps->{"MaxMz"};
	my $dumpWindow = $defProps->{"DumpWindow"};

	my $jobname = $basename . ".inspect";
	my $xmlFile = $basename . $xmlExt . ".mzXML" ;
	my $inspectFile = $xmlFile . ".inspect";
	my $featuresFile = $basename . $featuresExt . ".features.tsv" ;
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "" ;

	if( ! -f $xmlDir . $xmlFile )
	{
		writeLog($logFile, "ERROR: No file $xmlFile.\n");
		return "";
	}

	$script .= "mkdir " . $tmpdir . " || exit \$?\n";

	$script .= "pushd " . $schedulerI->getJobPath($xmlDir) . " || exit \$?\n";
	my $files = $xmlFile;
	if (-f $xmlDir . $inspectFile) {
		$files .=  " " . $inspectFile;
	}
	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";

	my $cmd = join " ", (
			"java",
			"-client",
			"-Xmx512m",
			"-jar",
			getInspectJar($inspectVersion),
			"--findPeptides",
			"--out=\"" . $featuresFile . "\"",
			"--strategy=" . $strategy
		);

	$cmd .= " --start=" . $startScan if (defined($startScan) && $startScan ne "");
	$cmd .= " --count=" . $countScans if (defined($countScans) && $countScans ne "");
	$cmd .= " --minMz=" . $minMz if (defined($minMz) && $minMz ne "");
	$cmd .= " --maxMz=" . $maxMz if (defined($maxMz) && $maxMz ne "");
	$cmd .= " --dumpWindow=" . $dumpWindow if (defined($dumpWindow) && $dumpWindow ne "");

	$cmd .=	" \"" . $xmlFile . "\"";

	$script .= $cmd . " || exit \$?\n" ;

	$script .= "rm " . $xmlFile . "\n" ;
	$script .= "popd || exit \$?\n" ;

	# Copy .inspect next to original .mzXML for future use
	$script .= "syncp.pl " . $tmpdir . $inspectFile . " . || exit \$?\n" ;
	$script .= "rm " . $tmpdir . $inspectFile . " || exit \$?\n" ;

	$script .= "popd || exit \$?\n" ;
	$script .= "syncp.pl " . $tmpdir . "* . || exit \$?\n" ;
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n" ;

	$script .= "echo PROCESSED > " . $statusFile . "\n";

	my %jobProps = (queue => $inspectQueue);

	return $schedulerI->submitJobScript($analysisDir, $jobname, \%jobProps,
				$script, $logFile);
}

#-----------------------------------------------------------------#
# sendCompleteMail(<email>,<analysis dir>,<logfile>)
#	Sends completion mail for given processing path.

sub sendCompleteMail
{
	my $emailAddress = shift();
	my $analysisDir = shift();
	my $logFile = shift();

	if (!defined($emailAddress) || $emailAddress eq "")
	{	return; }

	writeLog($logFile, "LOG: Sending complete email to $emailAddress\n");

	if (open(MAIL, "| mailx -v -s \"msInspect analysis complete\" $emailAddress >/dev/null 2>/dev/null"))
	{
		print MAIL "msInspect analysis complete\n";
		print MAIL "DIRECTORY: $analysisDir\n";

		close(MAIL);
	}
}

#-----------------------------------------------------------------#
# getInspectJar(<version>)
#	Gets a specific version of viewerApp.jar.

sub getInspectJar
{
	my $inspectVersion = shift();
	my $inspectJar = $bin_dir . "msInspect/viewerApp";
	$inspectJar .= "." . $inspectVersion
		if (defined($inspectVersion) && $inspectVersion ne "");
	$inspectJar .= ".jar";

	return $inspectJar;
}

#-----------------------------------------------------------------#
# getInspectJars()
#	Gets a list of all available msInspect jars.

sub getInspectJars
{
	my @inspectJars = ();
	if (opendir(DIR, $bin_dir . "msInspect/"))
	{
		@inspectJars = sort(grep(/\.\d+\.jar$/, readdir(DIR)));
		closedir(DIR);
	}

	return @inspectJars;
}

#-----------------------------------------------------------------#
# normalizeExt(<ext string>)
#	Makes sure an extension is either "" or starts with "."

sub normalizeExt
{
	my $ext = shift();
	if (!defined($ext))
	{	$ext = ""; }
	elsif ($ext ne "" && substr($ext, 0, 1) ne ".")
	{	$ext = "." . $ext; }

	return $ext;
}

1;
