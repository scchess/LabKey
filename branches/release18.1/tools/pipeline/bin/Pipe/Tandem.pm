package Pipe::Tandem;

use strict;
use File::Basename;

use Pipe::Params;
use Pipe::Convert;
use Pipe::Email;
use Pipe::TandemUtils;
use Pipe::Utils;
use Pipe::Web;

BEGIN
{
	use Exporter;

	@Pipe::Tandem::ISA       = qw(Exporter);
	@Pipe::Tandem::EXPORT    = qw();
	@Pipe::Tandem::EXPORT_OK = qw();
}

our $analysisFilename = "tandem.xml";
our $analysisDirname = "xtandem";
our $providerName = "X!Tandem (Cluster)";

my $bin_dir = dirname($0) . '/';
my $tandemNodesDefault = 1;
my $tandemQueue = "xtandem";

my $mzXMLBug = 0;
my $pepXMLCompare = 0;

#-----------------------------------------------------------------#
# analyze(<rood directory>,<directory path>)
#	Process a single directory containing a tandem.xml file.
#

sub analyze
{
	my $analysisRoot = shift();
	my $analysisDir = shift();

	my $status = "ERROR";

	my $logFile = getLogFile($analysisDir);
	my $statusFile = getStatusFile($analysisDir);
	my $defFile = $analysisDir . $analysisFilename;
	my %defProps = loadTandemInputXML($defFile);

	my @defKeys = keys(%defProps);
	if ($#defKeys < 0)
	{
		writeLog($logFile, "ERROR: Invalid tandem.xml file $defFile.\n");
		if (!-f $statusFile)
		{
			setStatus($statusFile, $status, "type=parameters");
		}
		return $status;
	}

	$webContainerCurrent = $defProps{"pipeline, load folder"};
	
	my $scoringAlgorithm = $defProps{"scoring, algorithm"};
	my $runProphet = 0;
	if (defined($scoringAlgorithm) && $scoringAlgorithm eq "comet")
	{	$runProphet = 1; }
	$runProphet = 1;
	my $databaseFile = $defProps{"pipeline, database"};
	if (defined($databaseFile) && $databaseFile !~ /^\//)
	{	$databaseFile = $fastaRoot . $databaseFile; }
	my $emailAddress = $defProps{"pipeline, email address"};
	if (defined($emailAddress) && $emailAddress !~ /\@/)
	{	$emailAddress .= '@fhcrc.org'; }

	if (!defined($databaseFile) || ! -f $databaseFile)
	{
		sendDatabaseError($emailAddress,
					$analysisDir,
					$analysisFilename,
					$databaseFile,
					$logFile);
		unlink($defFile . ".err");
		system("mv", $defFile, $defFile . ".err");

		unlink($statusFile . ".err");
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=database");
		$webContainerCurrent = "";
		return $status;
	}
	# Try to open and read the first line of the database.
	elsif (!open(DB, $databaseFile) || !<DB>)
	{
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=database permissions");
		$webContainerCurrent = "";
		return $status;
	}
	close(DB);


	my $rawDir = $defProps{"pipeline, data path"};
	my $xmlDir = $defProps{"pipeline, xml path"};
	my $filterInclude = $defProps{"pipeline, filter include"};
	my $filterExclude = $defProps{"pipeline, filter exclude"};

	if (!defined($rawDir))
	{
		$rawDir = $analysisRoot;
		if (-d $analysisRoot . "raw/")
		{	$rawDir = $analysisRoot . "raw/"; }

		if (!defined($xmlDir))
		{
			$xmlDir = $analysisRoot;
			if (-d $analysisRoot . "xml/")
			{	$xmlDir = $analysisRoot . "xml/"; }
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
		$webContainerCurrent = "";
		return $status;
	}

	my @analysisList = getAnalysisList($filterInclude, $filterExclude,
		$xmlDir, ".mzXML",
		$rawDir, ".RAW");

	if ($#analysisList < 0)
	{
		writeLog($logFile, "ERROR: No files found to analyze.\n");
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=no data");
		$webContainerCurrent = "";
		return $status;
	}

	my $analysisType = $defProps{"pipeline, data type"};
	if (!defined($analysisType))
	{
		if (-f $xmlDir . "all.xar.xml" ||
			-f $xmlDir . "xars/all.xar.xml")
		{	$analysisType = "Fractions"; }
		else
		{	$analysisType = "Samples"; }
	}
	# If there is only 1 file, then ignore "Fractions".
	if ($#analysisList == 0)
	{	$analysisType = "Samples"; }

	$status = "PROCESSED_FILES";
	my $basename;
	foreach $basename (@analysisList)
	{
		my $status_file = analyzeFile($basename,
						$analysisType,
						$analysisDir,
						$rawDir,
						$xmlDir,
						\%defProps);

		if ($status_file ne "COMPLETE")
		{	$status = "PROCESSING_FILES"; }
	}

	my $logPermissive = 0;

	if ($status eq "PROCESSED_FILES")
	{
		if (isFractions($analysisType))
		{
			my $statusCurrent = getStatus($statusFile);
			if ($statusCurrent eq "UNKNOWN" ||
				$statusCurrent eq "PROCESSING_FILES")
			{
				if (-f $analysisDir . "all.pep.xml")
				{
					if ($runProphet && -f $analysisDir . "all.prot.xml")
					{
						$status = "PROCESSED";
						$logPermissive = 1 if $statusCurrent eq "UNKNOWN";
					}
					else
					{
						$status = "ERROR";
						unlink($analysisDir . "all.pep.xml");
					}
				}

				setStatusEx($statusFile,
						$providerName,
						$emailAddress,
						$status);
			}
			else
			{
				$status = $statusCurrent;
			}
		}
		else
		{
			my $statusInfo;
			$status = "COMPLETE";
			setStatusEx($statusFile, $providerName, $emailAddress,
				$status, $statusInfo, 0);
		}
	}

	if ($status eq "PROCESSING_FILES")
	{
		if ($status ne getStatus($statusFile))
		{
			my $statusInfo;
			my $statusWeb = 0;
			if (isFractions($analysisType))
			{	$statusWeb = 1; }
			
			setStatusEx($statusFile, $providerName, $emailAddress,
				$status, $statusInfo, $statusWeb);
		}
	}
	elsif ($status eq "PROCESSED_FILES")
	{
		writeLog($logFile, "LOG: Starting Prophet analysis.\n");

		my $tppVersion = $defProps{"pipeline tpp, version"};
		my $minProphet = $defProps{"pipeline prophet, min probability"};
		if (!defined($minProphet))
		{	$minProphet = $minProphetDefault; }
		my $accurateMassParam = $defProps{"pipeline prophet, accurate mass"};
		my $hasAccurateMass = (defined($accurateMassParam) && $accurateMassParam =~ /yes/i);
		my $multiInstrumentParam = $defProps{"pipeline prophet, allow multiple instruments"};
		my $hasMultiInstrument = (defined($multiInstrumentParam) && $multiInstrumentParam =~ /yes/i);
		my $xpressCmd = getQuantitationCmd(\%defProps, $xmlDir);
		
		$status = startProphet($analysisDir,
					$xmlDir,
					$tppVersion,
					$runProphet,
					$minProphet,
					$hasAccurateMass,
					$hasMultiInstrument,
					$xpressCmd,
					$statusFile,
					$logFile);

		if ($status ne "PROCESSING")
		{
			writeLog($logFile, "ERROR: Failed to start Prophet analysis.\n");
			$status = "ERROR";
			setStatus($statusFile, $status, "type=job start");
			unlink($statusFile);	# allow infinite retry
		}
	}
	elsif ($status =~ /^PROCESSING->jobid=(.*)$/)
	{
		writeLog($logFile, "LOG: Checking Prophet job status.\n");

		# Check  to make sure the job is in fact still running.
		my $jobid = $1;
		if (!$schedulerI->isJobRunning($jobid, $logFile))
		{
			$schedulerI->publishOutput($analysisDir, 1, "all", "prophet");

			$status = "ERROR";
			setStatus($statusFile, $status, "type=job failure");
		}
	}
	elsif ($status eq "PROCESSED")
	{
		my @stats = stat($statusFile);
		$logPermissive = 1 if time() - $stats[9] > 2*60;
		if ($schedulerI->publishOutput($analysisDir,
				$logPermissive, "all", "prophet"))
		{
			my $upload = $defProps{"pipeline, load"};
			if ($webServer ne "" &&
				(!defined($upload) || $upload !~ /no/i))
			{
				writeLog($logFile, "LOG: Uploading data to web server.\n");

				my $experiment = defined($defProps{"pipeline, protocol name"});
				$status = startMS2Upload($webServer,
						"",
						$xmlDir,
						$analysisDir,
						"all.pep.xml",
						$experiment,
						$statusFile,
						$logFile);
			}
			else
			{
				$status = "COMPLETE";
				setStatus($statusFile, $status);
			}
		}
	}
	elsif ($status =~ /LOADING->run=([0-9]*)/)
	{
		my $runid = $1;

		writeLog($logFile, "LOG: Checking upload status for run $runid.\n"); 

		$status = getMS2UploadRunStatus($webServer,
						$runid,
						$statusFile,
						$logFile);
	}
	elsif ($status ne "COMPLETE")
	{
		if ($status ne "ERROR")
		{
			writeLog($logFile, "LOG: Status=\"$status\".\n");
		}
		else
		{
			writeLog($logFile, "ERROR: Status=\"$status\"\n".
						"	in $statusFile.\n");
		}
	}

	if ($status eq "COMPLETE")
	{
		# Send email to user in tandem.xml file.

		sendCompleteMail($emailAddress, $analysisDir, $logFile);

		# Remove status file, and rename log.

		writeLog($logFile, "LOG: X!Tandem processing completed successfully.\n");
		completeAnalysis($analysisDir);
	}

	$webContainerCurrent = "";
	return $status;
}

sub analyzeFile
{
	my $basename = shift();
	my $analysisType = shift();
	my $analysisDir = shift();
	my $rawDir = shift();
	my $xmlDir = shift();
	my $defProps = shift();

	my $emailAddress = $defProps->{"pipeline, email address"};
	if (defined($emailAddress) && $emailAddress !~ /\@/)
	{	$emailAddress .= '@fhcrc.org'; }
	my $useDTAParam = $defProps->{"pipeline, use dta files"};
	my $useDTAs = (defined($useDTAParam) && $useDTAParam =~ /yes/i);

	my $fileType = "thermo";
	my $rawFile = $rawDir . $basename . ".RAW";
	if (! -f $rawFile)
	{
		$rawFile =~ s/\.RAW$/.raw/;
		if (-d $rawFile)
		{	$fileType = "masslynx"; }
	}

	my $xmlFile = $xmlDir . $basename . ".mzXML";
	my $statusFile = getStatusFile($analysisDir, $basename);
	my $logFileBranched = getLogFile($analysisDir, $basename);
	my $logFile = getLogFile($analysisDir);
	my $logPermissive = 0;

	if (! -f $logFileBranched)
	{
		writeLog($logFileBranched,
			"X!Tandem search for " . $basename . ".mzXML\n" .
			"=======================================\n", 20);
	}

	my $status = getStatus($statusFile);

	if ($status eq "UNKNOWN")
	{
		$logPermissive = 1;
		if ((!isSamples($analysisType) ||
				-f $analysisDir . $basename . ".pep.xml") &&
			(!isFractions($analysisType) ||
				-f $analysisDir . $basename . ".fract.xml" ||
				-f $analysisDir . "all.pep.xml"))

		{
			if (isSamples($analysisType))
			{	$status = "PROCESSED"; }
			else
			{	$status = "COMPLETE"; }
		}
		elsif (-e $xmlFile)
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

			startConversion($convertServer,
					$rawFile,
					$xmlFile,
					$fileType,
					$statusFile,
					$logFile);
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
						$analysisType,
						$analysisDir,
						$rawDir,
						$xmlDir,
						$defProps);
		}
	}
	elsif ($status eq "CONVERTED")
	{
		writeLog($logFile, "LOG: Running X!Tandem for $basename\n");

		my $tandemVersion = $defProps->{"pipeline tandem, version"};
		my $scoreExact = 0;
		my $scoring = $defProps->{"pipeline, scoring"};
		if (defined($scoring) && $scoring eq "exact")
		{	$scoreExact = 1; }
		my $tppVersion = $defProps->{"pipeline tpp, version"};
		my $runProphet = 0;
		my $minProphet = $defProps->{"pipeline prophet, min probability"};
		if (!defined($minProphet))
		{	$minProphet = $minProphetDefault; }
		my $accurateMassParam = $defProps->{"pipeline prophet, accurate mass"};
		my $hasAccurateMass = (defined($accurateMassParam) && $accurateMassParam =~ /yes/i);
		my $multiInstrumentParam = $defProps->{"pipeline prophet, allow multiple instruments"};
		my $hasMultiInstrument = (defined($multiInstrumentParam) && $multiInstrumentParam =~ /yes/i);
		my $xpressCmd;
		if (isSamples($analysisType))
		{
			my $scoringAlgorithm = $defProps->{"scoring, algorithm"};
			if (defined($scoringAlgorithm) && $scoringAlgorithm eq "comet")
			{	$runProphet = 1; }
			$runProphet = 1;
			$xpressCmd = getQuantitationCmd($defProps, $xmlDir);
		}
		my $hasFractions = isFractions($analysisType);
		my $tandemNodes = $defProps->{"pipeline, nodes"};
		if (!defined($tandemNodes))
		{	$tandemNodes = $tandemNodesDefault; }
		my $filterDTA = $defProps->{"pipeline, dta filter args"};

		$status = startTandem($basename,
					$analysisDir,
					$xmlDir,
					$tandemVersion,
					$scoreExact,
					$tandemNodes,
					$tppVersion,
					$runProphet,
					$minProphet,
					$hasAccurateMass,
					$hasMultiInstrument,
					$hasFractions,
					$useDTAs,
					$filterDTA,
					$xpressCmd,
					$statusFile,
					$logFile);

		if ($status ne "PROCESSING" && $status ne "ERROR")
		{
			writeLog($logFile, "ERROR: Failed to start X!Tandem analysis.\n");
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
		my @jobs = split(/,/, $jobid);
		if (!$schedulerI->isJobRunning(@jobs, $logFile))
		{
			my @outList = ("tandem", "summary");
			unshift(@outList, "createdta") if $useDTAs;

			$schedulerI->publishOutput($analysisDir, 1, $basename, 
				@outList);

			$status = "ERROR";
			setStatus($statusFile, $status, "type=job failure");
		}
	}
	elsif ($status eq "PROCESSED")
	{
		my @outList = ("tandem", "summary");
		unshift(@outList, "createdta") if $useDTAs;

		my @stats = stat($statusFile);
		$logPermissive = 1 if time() - $stats[9] > 2*60;
		if ($schedulerI->publishOutput($analysisDir,
				$logPermissive, $basename, @outList))
		{
			my $upload = $defProps->{"pipeline, load"};
			if (isSamples($analysisType) && $webServer ne "" &&
				(!defined($upload) || $upload !~ /no/i))
			{
				writeLog($logFile, "LOG: Uploading $basename data to web server.\n");

				my $experiment = defined($defProps->{"pipeline, protocol name"});
				$status = startMS2Upload($webServer,
						$basename,
						$xmlDir,
						$analysisDir,
						$basename . ".pep.xml",
						$experiment,
						$statusFile,
						$logFile);
			}
			else
			{
				$status = "COMPLETE";
				setStatus($statusFile, $status);
			}
		}
	}
	elsif ($status =~ /LOADING->run=([0-9]*)/)
	{
		my $runid = $1;

		writeLog($logFile, "LOG: Checking $basename upload status for run $runid.\n"); 

		$status = getMS2UploadRunStatus($webServer,
						$runid,
						$statusFile,
						$logFile);
	}
	elsif ($status ne "COMPLETE")
	{
		if ($status ne "ERROR")
		{
			writeLog($logFile, "LOG: $basename : Status=\"$status\"\n");
		}
		else
		{
			writeLog($logFile, "ERROR: Status=\"$status\"\n".
						"	in $statusFile.\n");
		}
	}

	return $status;
}

#-----------------------------------------------------------------#
# startTandem(<basename>,<analysis dir>,<xml dir>,<cluster nodes>,
#		<run prophet>,<dta filter>,<status file>,<log file>)
#	Starts X!Tandem running on a specific file.

sub startTandem
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $tandemVersion = shift();
	my $scoreExact = shift();
	my $tandemNodes = shift();
	my $tppVersion = shift();
	my $runProphet = shift();
	my $minProphet = shift();
	my $hasAccurateMass = shift();
	my $hasMultiInstrument = shift();
	my $hasFractions = shift();
	my $useDTAs = shift();
	my $filterDTA = shift();
	my $xpressCmd = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my @jobs;

	my $status = "CONVERTED";

	my $dtaFile = $analysisDir . $basename . ".dta";
	my $dtaGzFile = $analysisDir. $basename . ".pep.tgz";
	my $tandemFile = $analysisDir . $basename . ".xtan.xml";

	# Create PBS jobs based on files present.
	# Fail if the first job submitted fails, but succeed
	# if any job is successfully submitted to avoid looping
	# and filling the queue with partial jobs on the same
	# file.

	if (! -f $tandemFile)
	{
		if (($useDTAs && ! -f $dtaFile) ||
			($mzXMLBug && ! -f $dtaGzFile))
		{
			push(@jobs, createDTAJob($basename,
						$analysisDir,
						$xmlDir,
						$scoreExact,
						$useDTAs,
						$filterDTA,
						$logFile));

			if ($jobs[0] eq "")
			{	return $status; }
		}

		if (! -z $dtaFile)
		{
			push(@jobs, createTandemJob($basename,
						$analysisDir,
						$xmlDir,
						$tandemVersion,
						$useDTAs,
						$scoreExact,
						$tandemNodes,
						$logFile,
						@jobs));
		}
		else
		{
			writeLog($logFile, "ERROR: No scan data found for $basename.\n");
			$status = "ERROR";
			setStatus($statusFile, $status, "type=no scan data");
			return $status;
		}

		if ($jobs[0] eq "")
		{	return $status; }
	}

	if ($#jobs < 0 || $jobs[$#jobs] ne "")
	{
		push(@jobs, createPostTandemJob($basename,
					$analysisDir,
					$xmlDir,
					$tppVersion,
					$scoreExact,
					$runProphet,
					$minProphet,
					$hasAccurateMass,
					$hasMultiInstrument,
					$hasFractions,
					$xpressCmd,
					$statusFile,
					$logFile,
					@jobs));

		if ($jobs[0] eq "")
		{	return $status; }
	}

	if ($#jobs >= 0 && $jobs[$#jobs] eq "")
	{	pop(@jobs); }

	$status = "PROCESSING";
	setStatus($statusFile, $status, "jobid=" . join(",", @jobs));

	writeLog($logFile, "LOG: Sleeping 2 seconds for job scheduler.\n", 2);
	sleep 2;

	return $status;
}

#-----------------------------------------------------------------#
# startProphet(<analysis dir>,<run prophet>,<status file>,<log file>)
#	Starts Peptide Prophet running on a directory of X!Tandem
#	results.

sub startProphet
{
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $tppVersion = shift();
	my $runProphet = shift();
	my $minProphet = shift();
	my $hasAccurateMass = shift();
	my $hasMultiInstrument = shift();
	my $xpressCmd = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $status = "PROCESSED_FILES";

	my $jobid = createProphetJob($analysisDir,
					$xmlDir,
					$tppVersion,
					$runProphet,
					$minProphet,
					$hasAccurateMass,
					$hasMultiInstrument,
					$xpressCmd,
					$statusFile,
					$logFile);

	if (defined($jobid) && $jobid ne "")
	{
		$status = "PROCESSING";
		setStatus($statusFile, $status, "jobid=" . $jobid);
	}

	return $status;
}

#-------------------------------------------------------------------#
# createDTAJob(<basename>,<analysis dir>,<xml dir>,<dta filter>,<log file>)
#	Creates a cluster job for DTA creation.

sub createDTAJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $scoreExact = shift();
	my $useDTAs = shift();
	my $filterDTA = shift();
	my $logFile = shift();

	my $jobname = $basename . ".createdta";
	my $xmlFile = $basename . ".mzXML";
	my $dtaTarFile = $basename . ".pep.tar";
	my $dtaZipFile = $basename . ".pep.tgz";
	my $dtaFile = $basename . ".dta";
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	if(! -f $xmlDir . $xmlFile)
	{
		writeLog($logFile, "ERROR: No file $xmlFile.\n");
		return "";
	}

	$script .= "PATH=" . $bin_dir . "tpp/bin:" . $bin_dir . "tandem:" . $bin_dir . "usr/local/bin:\${PATH}\n";
	$script .= "mkdir " . $tmpdir . " || exit \$?\n";

	my $files = join " ", ("tandem.xml", $schedulerI->getJobPath($xmlDir) . $xmlFile); 

	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";
	$script .= "mkdir " . $basename . " || exit \$?\n";
	$script .= "cd " . $basename . " || exit \$?\n";
	$script .= "cp ../tandem.xml . || exit \$?\n";

	# Build DTA creation command

 	my $cmd = join " ", ("MzXML2Search" ,
				"-dta",
				"-T4094.0",
				"-B600.0",
				"-O.");
	if (!$scoreExact)
	{	$cmd .= " -p"; }

	$cmd .= " ../" . $xmlFile;

	$script .= $cmd . " || exit \$?\n";

	# Filter DTAs if filter args supplied.
	if (defined($filterDTA) && $filterDTA ne "")
	{
		$script .= "dtafilter -A -V " . $filterDTA . " || exit \$?\n";
	}

	# Create .dta.tar file from created dtas
	$script .= "find . -name \"*.dta\" -o -name tandem.xml | " .
			"sed \"s/\\.\\///\" > worklist.tmp || exit \$?\n";

	$script .= "tar c --files-from=worklist.tmp -f ../" . $dtaTarFile . " || exit \$?\n";
	$script .= "joindta.pl --l=1 . ../" . $dtaFile . " || exit \$?\n" if $useDTAs;

	$script .= "cd ..\n";
	$script .= "rm -rf $basename  || exit \$?\n";
	$script .= "gzip " . $dtaTarFile . " || exit \$?\n";
	$script .= "mv " . $dtaTarFile . ".gz " . $dtaZipFile . " || exit \$?\n";
	$script .= "popd || exit \$?\n";
	$files = $tmpdir . $dtaZipFile;
	$files .= " " .	$tmpdir . $dtaFile if $useDTAs;
	$script .= "syncp.pl " . $files . " . || exit \$?\n";
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n";

	my %jobProps = (queue => $tandemQueue);

	return $schedulerI->submitJobScript($analysisDir, $jobname, \%jobProps,
				$script, $logFile);
}

#-------------------------------------------------------------------#
# createTandemJob(<basename>,<analysis dir>,<xml dir>,<nodes>,<log file>,<jobs>)
#	Submits a X!Tandem processing job to the cluster.

sub createTandemJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $tandemVersion = shift();
	my $useDTAs = shift();
	my $scoreExact = shift();
	my $nodes = shift();
	my $logFile = shift();
	my @jobs = @_;

	my $jobname = $basename . ".tandem";
	my $dtaFile = $basename . ".dta";
	my $tandemFile = $basename . ".xtan.xml";
	my $xmlFilename = $basename . ".mzXML";
	my $nodeFile = $schedulerI->getJobNodeFile();
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	$script .= "PATH=" . getVerDir($bin_dir . "tandem", $tandemVersion) . ":" . $bin_dir . "usr/local/bin:\${PATH}\n";
	$script .= "mkdir " . $tmpdir . " || exit \$?\n";

	my $inputFilename = $xmlFilename;
	my $inputFile = $xmlDir . $xmlFilename;
	if ($useDTAs)
	{
		$inputFilename = $dtaFile;
		$inputFile = $dtaFile;
	}
	my $files = join " ", ($analysisFilename,
				$inputFile);
	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";

	$script .= "pushd " . $tmpdir . " || exit \$?\n";

	$script .= "tandemPrepare.pl";
	$script .= " --i=" . $inputFilename; 
	$script .= " --f=" . $fastaRoot;
	$script .= " " . $analysisFilename . " || exit \$?\n";
	if ($scoreExact)
	{	$script .= "tandem_exact.exe input.xml || exit \$?\n"; }
	else
	{	$script .= "tandem.exe input.xml || exit \$?\n"; }

	$script .= "mv output*.xml " . $tandemFile . " || exit \$?\n";

	if (!$useDTAs)
	{
		$script .= "tandemPostProcess.pl " . $tandemFile . " ";
		$script .= getRelativePath($analysisDir, $inputFile);
		$script .= " || exit \$?\n";
	}

	$script .= "popd || exit \$?\n";
	$script .= "syncp.pl " . $tmpdir . $tandemFile . " . || exit \$?\n";
	if ($useDTAs)
	{
		$script .= "rm " . $dtaFile . "\n";
	}
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n";

	my %jobProps = (queue => $tandemQueue,
			nodes => $nodes,
			walltime => "48:00:00");

	return $schedulerI->submitJobScript($analysisDir,
				$jobname,
				\%jobProps,
				$script,
				$logFile,
				@jobs);
}

#-------------------------------------------------------------------#
# createPostTandemJob(<basename>,<output dir>,<run prophet>,
#			<status file>,<log file>,<jobs>)
#	Submits a post-X!Tandem processing job to the cluster.

sub createPostTandemJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $tppVersion = shift();
	my $scoreExact = shift();
	my $runProphet = shift();
	my $minProphet = shift();
	my $hasAccurateMass = shift();
	my $hasMultiInstrument = shift();
	my $hasFractions = shift();
	my $xpressCmd = shift();
	my $statusFile = shift();
	my $logFile = shift();
	my @jobs = @_;

	# Strip path from status file, since it must be in the output
	# directory, and the job script will 'cd' there.
	($statusFile) = fileparse($statusFile, "");

	my $jobname = $basename . ".summary";
	my $xmlFile = $basename . ".mzXML";
	my $xmlXPressFile = $basename . ".pep.mzXML";
	my $tandemFile = $basename . ".xtan.xml";
	my $pepXmlFile = $basename . ".pep.xml";
	my $pepXmlFractFile = $basename . ".fract.xml";
	my $pepXmlOrigFile = $basename . ".orig.xml";
	my $pepXmlCompareFile = $basename . ".cmp.xml";
	my $protXmlIntFile = $basename . ".pep-prot.xml";
	my $protXmlFile = $basename . ".prot.xml";
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	$script .= "PATH=" . getVerDir($bin_dir . "tpp", $tppVersion, "bin") . ":" . $bin_dir . "usr/local/bin:\${PATH}\n";
	$script .= "mkdir " . $tmpdir . " || exit \$?\n";
	
	my $files = join " ", ($tandemFile,
				$schedulerI->getJobPath($xmlDir) . $xmlFile);

	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";

	if ($scoreExact)
	{	$script .= "Tandem2XML_exact " . $tandemFile . " " . $pepXmlFile . " || exit \$?\n"; }
	else
	{	$script .= "Tandem2XML " . $tandemFile . " " . $pepXmlFile . " || exit \$?\n"; }

	# Tandem2XML will not generate correct base_name, if output originally to
	# .orig.xml

	$script .= "mv " . $pepXmlFile . " " . $pepXmlOrigFile . " || exit \$?\n";

	my @fileList = ();

	if (isDebugLevel(3))
	{
		push(@fileList, $tmpdir . $pepXmlOrigFile);

		if ($pepXMLCompare)
		{
			$script .= "normalPepXml.pl " . $pepXmlOrigFile . " || exit \$?\n";
			push(@fileList, $tmpdir . $pepXmlCompareFile);
		}
	}

	if ($hasFractions && ! -f $analysisDir . $pepXmlFractFile)
	{
		$script .= "cp " . $pepXmlOrigFile . " " . $pepXmlFractFile . " || exit \$?\n";
		push(@fileList, $tmpdir . $pepXmlFractFile);
	}

	my @interactOpts = ( );

	if (defined($xpressCmd) && $xpressCmd ne '')
	{
		push(@interactOpts, $xpressCmd);
	}

	if ($runProphet)
	{
		my $prophetOpt = "-Opt";
		$prophetOpt .= "w" if $hasMultiInstrument;
		$prophetOpt .= "A" if $hasAccurateMass;
		push(@interactOpts, $prophetOpt);
		push(@interactOpts, "-nR");
		push(@interactOpts, "-p" . $minProphet);
		if (!defined($tppVersion) || $tppVersion ne "2.9.9")
		{	push(@interactOpts, "-x20"); }
	}
	elsif ($#interactOpts >= 0)
	{
		push(@interactOpts, "-nP");
	}

	if ($#interactOpts >= 0 && ! -f $analysisDir . $pepXmlFile)
	{
		push(@interactOpts, "-N" . $pepXmlFile);

		$script .= "xinteract " . join(" ", @interactOpts) . " " . $pepXmlOrigFile . " || exit \$?\n";

		push(@fileList, $tmpdir . $pepXmlFile);
		if ($runProphet)
		{
			$script .= "mv " . $protXmlIntFile . " " . $protXmlFile . " || exit \$?\n";
			push(@fileList, $tmpdir . $protXmlFile);
			#push(@fileList, $tmpdir . $protXmlIntFile);
		}
	}

	$script .= "popd || exit \$?\n";
	$script .= "syncp.pl " . join(" ", @fileList) . " . || exit \$?\n";
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n";

	$script .= "echo PROCESSED > " . $statusFile . "\n";

	my %jobProps = (queue => $tandemQueue);

	return $schedulerI->submitJobScript($analysisDir,
				$jobname,
				\%jobProps,
				$script,
				$logFile,
				@jobs);
}


#-------------------------------------------------------------------#
# createProphetJob(<analysis dir>,<run prophet>,<status file>,<log file>)

sub createProphetJob
{
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $tppVersion = shift();
	my $runProphet = shift();
	my $minProphet = shift();
	my $hasAccurateMass = shift();
	my $hasMultiInstrument = shift();
	my $xpressCmd = shift();
	my $statusFile = shift();
	my $logFile = shift();

	# Strip path from status file, since it must be in the output
	# directory, and the job script will 'cd' there.
	($statusFile) = fileparse($statusFile, "");

	my $jobname = "all.prophet";
	my $script = "";

	$script .= "PATH=" . getVerDir($bin_dir . "tpp", $tppVersion, "bin") . ":\${PATH}\n";
	$script .= "rm all.pep.xml\n";

	my @interactOpts = ();

	if (defined($xpressCmd) && $xpressCmd ne '')
	{
		push(@interactOpts, $xpressCmd);
	}

	if ($runProphet)
	{
		my $prophetOpt = "-Opt";
		$prophetOpt .= "w" if $hasMultiInstrument;
		$prophetOpt .= "A" if $hasAccurateMass;
		push(@interactOpts, $prophetOpt);
		push(@interactOpts, "-nR");
		push(@interactOpts, "-p" . $minProphet);
		if (!defined($tppVersion) || $tppVersion ne "2.9.9")
		{	push(@interactOpts, "-x20"); }
	}
	else
	{
		push(@interactOpts, "-nP");
	}

	push(@interactOpts, "-Nall.pep.xml");

	$script .= "xinteract " . join(" ", @interactOpts) . " *.fract.xml || exit \$?\n";

	if ($runProphet)
	{
		$script .= "mv all.pep-prot.xml all.prot.xml || exit \$?\n";
	}

	$script .= "rm -f *.fract.xml\n";

	$script .= "echo PROCESSED > " . $statusFile . "\n";

	my %jobProps = (queue => $tandemQueue,
			walltime => "168:00:00");

	return $schedulerI->submitJobScript($analysisDir, $jobname, \%jobProps,
				$script, $logFile);
}

#-----------------------------------------------------------------#
# sendCompleteMail(<email>,<analysis dir>,<run_id>,<logfile>)
#	Sends completion mail for given processing path.

sub sendCompleteMail
{
	my $emailAddress = shift();
	my $analysisDir = shift();
	my $logFile = shift();

	if (!defined($emailAddress) || $emailAddress eq "")
	{	return; }

	writeLog($logFile, "LOG: Sending complete email to $emailAddress\n");

	if (open(MAIL, "| mailx -v -s \"X!Tandem analysis complete\" $emailAddress >/dev/null 2>/dev/null"))
	{
		print MAIL "X!Tandem analysis complete\n";
		print MAIL "DIRECTORY: $analysisDir\n";

		close(MAIL);
	}
	else
	{
		writeLog($logFile, "ERROR: Failed to open email.\n");
	}
}

#-----------------------------------------------------------------#
# relativize(<path>,<base path>)
#	Returns "path" relative to "base path".

sub relativize
{
	my $path = shift();
	my $basePath = shift();

	my @pathParts = split(/\//, $path);
	my @baseParts = split(/\//, $basePath);

	my $part1 = shift(@pathParts);
	my $part2 = shift(@baseParts);

	while (defined($part1) && defined($part2) && $part1 eq $part2)
	{
		$part1 = shift(@pathParts);
		$part2 = shift(@baseParts);
	}

	while (defined($part2))
	{
		push(@pathParts, '..');
		$part2 = shift(@baseParts);
	}
	return join('/', @pathParts);
}

1;
