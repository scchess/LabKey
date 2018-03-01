package Pipe::Comet;

use strict;
use File::Basename;

use Pipe::Params;
use Pipe::Convert;
use Pipe::Email;
use Pipe::Utils;
use Pipe::Web;
use Pipe::TandemUtils;

BEGIN
{
	use Exporter;

	@Pipe::Comet::ISA       = qw(Exporter);
	@Pipe::Comet::EXPORT    = qw();
	@Pipe::Comet::EXPORT_OK = qw();
}

our $analysisFilename = "comet.def";
our $analysisDirname = "cmt";
our $providerName = "Comet (Cluster)";

my $bin_dir = dirname($0) . '/';
my $cometNodesDefault = 8;
my $cometQueue = "comet";

my $pepXMLCompare = 0;

#-----------------------------------------------------------------#
# analyze(<rood directory>,<directory path>)
#	Process a single directory containing .dat files and
#	a comet.def file.

sub analyze
{
	my $analysisRoot = shift();
	my $analysisDir = shift();

	my $status = "ERROR";

	my $logFile = getLogFile($analysisDir);
	my $statusFile = getStatusFile($analysisDir);
	my $defFile = $analysisDir . $analysisFilename;
	my %defProps = loadDefFile($defFile);

	if (!-f $statusFile)
	{
		writeXTandemXML($analysisRoot, $defFile);
	}

	my @defKeys = keys(%defProps);
	if ($#defKeys < 0)
	{
		writeLog($logFile, "ERROR: Invalid def file $defFile.\n");
		setStatus($statusFile, $status, "type=def");
		return $status;
	}
	
	my $databaseFile = $defProps{"Database"};
	my $emailAddress = $defProps{"EmailAddress"};
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
		return $status;
	}
	# Try to open and read the first line of the database.
	elsif (!open(DB, $databaseFile) || !<DB>)
	{
		setStatusEx($statusFile, $providerName, $emailAddress,
			$status, "type=database permissions");
		return $status;
	}
	close(DB);

	my $rawDir = $defProps{"DataPath"};
	my $xmlDir = $defProps{"XMLPath"};
	my $filterInclude = $defProps{"FilterInclude"};
	my $filterExclude = $defProps{"FilterExclude"};

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
		return $status;
	}

	my $analysisType = $defProps{"DataType"};
	if (!defined($analysisType))
	{	$analysisType = "Samples"; }
	my $outputFormat = $defProps{"OutputFormat"};
	if (!defined($outputFormat))
	{	$outputFormat = "xml"; }
	my $htmlOutput = 0;
	if ($outputFormat eq "html")
	{	$htmlOutput = 1; }

	$status = "PROCESSED_FILES";
	my $basename;
	foreach $basename (@analysisList)
	{
		my $status_file = analyzeFile($basename,
						$analysisType,
						$outputFormat,
						$analysisDir,
						$rawDir,
						$xmlDir,
						\%defProps);

		if ($status_file ne "COMPLETE")
		{	$status = "PROCESSING_FILES"; }
	}

	my $runid;
	if ($status eq "PROCESSED_FILES")
	{
		if (isSamples($analysisType))
		{
			my $statusInfo;
			$status = "COMPLETE";
			setStatusEx($statusFile, $providerName, $emailAddress,
				$status, $statusInfo, 0);
		}
		else
		{
			my $statusCurrent = getStatus($statusFile);
			$status = getStatus($statusFile);
			if ($status eq "UNKNOWN" || $status eq "PROCESSING_FILES")
			{
				$status = "PROCESSED_FILES";
				setStatusEx($statusFile,
						$providerName,
						$emailAddress,
						$status);
			}
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

		$status = startProphet($analysisDir,
					$htmlOutput,
					$statusFile,
					$logFile);

		if ($status ne "PROCESSING")
		{
			writeLog("ERROR: Failed to start Prophet analysis.\n");
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
		$schedulerI->publishOutput($analysisDir, 0, "all", "prophet");

		if ($webServer ne "")
		{
			writeLog($logFile, "LOG: Uploading data to web server.\n");

			my $outputFinal = "all.pep.xml";
			if ($htmlOutput)
			{	$outputFinal = "prophet.htm"; }
			$status = startMS2Upload($webServer,
					"",
					$xmlDir,
					$analysisDir,
					$outputFinal,
					0,
					$statusFile,
					$logFile);
		}
		else
		{
			$status = "COMPLETE";
			setStatus($statusFile, $status);
		}
	}
	elsif ($status =~ /LOADING->run=([0-9]*)/)
	{
		$runid = $1;

		writeLog($logFile, "LOG: Checking upload status for run $runid.\n"); 

		$status = getMS2UploadRunStatus($webServer,
						$runid,
						$statusFile,
						$logFile);
	}
	elsif ($status ne "COMPLETE")
	{
		writeLog($logFile, "ERROR: Status=\"$status\"\n".
					"	in $statusFile.\n");
	}

	if ($status eq "COMPLETE")
	{
		# Send email to user in comet.def file.

		sendCompleteMail($emailAddress, $analysisDir, $runid, $logFile);

		# Remove status file, and rename log.

		writeLog($logFile, "LOG: Comet processing completed successfully.\n");
		completeAnalysis($analysisDir);
	}

	return $status;
}

sub analyzeFile
{
	my $basename = shift();
	my $analysisType = shift();
	my $outputFormat = shift();
	my $analysisDir = shift();
	my $rawDir = shift();
	my $xmlDir = shift();
	my $defProps = shift();

	my $emailAddress = $defProps->{"EmailAddress"};
	if (defined($emailAddress) && $emailAddress !~ /\@/)
	{	$emailAddress .= '@fhcrc.org'; }
	my $htmlOutput = 0;
	if ($outputFormat eq "html")
	{	$htmlOutput = 1; }

	my $fileType = "thermo";
	my $rawFile = $rawDir . $basename . ".RAW";
	if (! -f $rawFile)
	{
		$fileType = "masslynx";
		if (! -d $rawFile)
		{	$rawFile =~ s/\.RAW$/.raw/; }
	}

	my $xmlFile = $xmlDir . $basename . ".mzXML";
	my $statusFile = getStatusFile($analysisDir, $basename);
	my $logFileBranched = getLogFile($analysisDir, $basename);
	my $logFile = getLogFile($analysisDir);

	if (! -f $logFileBranched)
	{
		writeLog($logFileBranched,
			"Comet search for " . $basename . ".mzXML\n" .
			"=======================================\n", 20);
	}

	my $outputFinal = $basename . ".pep.xml";
	my $outputIntermediate = $outputFinal;
	if ($htmlOutput)
	{
		$outputFinal = getBranchFile("prophet.htm", $basename);
		$outputIntermediate = $basename . ".cmt.html";
	}

	my $status = getStatus($statusFile);

	if ($status eq "UNKNOWN")
	{
		if (isFractions($analysisType) &&
				-f $analysisDir . $outputIntermediate)
		{
			$status = "PROCESSED";
		}
		elsif (isSamples($analysisType) &&
				-f $analysisDir . $outputFinal)
		{
			$status = "PROCESSED";
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
						$outputFormat,
						$analysisDir,
						$rawDir,
						$xmlDir,
						$defProps);
		}
	}
	elsif ($status eq "CONVERTED")
	{
		writeLog($logFile, "LOG: Running Comet for $basename\n");

		$status = startComet($basename,
					$analysisDir,
					$xmlDir,
					$defProps,
					$statusFile,
					$logFile);

		if ($status ne "PROCESSING")
		{
			writeLog($logFile, "ERROR: Failed to start Comet analysis.\n");
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
			$schedulerI->publishOutput($analysisDir, 1, $basename,
				"createdta", "comet", "summary");

			$status = "ERROR";
			setStatus($statusFile, $status, "type=job failure");
		}
	}
	elsif ($status eq "PROCESSED")
	{
		$schedulerI->publishOutput($analysisDir, 0, $basename,
				"createdta", "comet", "summary");

		if (isSamples($analysisType) && $webServer ne "")
		{
			writeLog($logFile, "LOG: Uploading $basename data to web server.\n");

			$status = startMS2Upload($webServer,
					$basename,
					$xmlDir,
					$analysisDir,
					$outputFinal,
					0,
					$statusFile,
					$logFile);
		}
		else
		{
			$status = "COMPLETE";
			setStatus($statusFile, $status);
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
		writeLog($logFile, "ERROR: Status=\"$status\"\n".
					"	in $statusFile.\n");
	}

	return $status;
}

#-----------------------------------------------------------------#
# startComet(<basename>,<analysis dir>,<xml dir>,<def props>,
#		<status file>,<log file>)
#	Starts comet running on a specific file.

sub startComet
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $defProps = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my @jobs;

	my $status = "CONVERTED";

	my $cometfile = $analysisDir . $basename . ".cmt.tar.gz";
	my $interactfile = $analysisDir . getBranchFile("interact.htm", $basename);

	my $runProphet = 0;
	if (isSamples($defProps->{"DataType"}))
	{	$runProphet = 1; }

	# Create PBS jobs based on files present.
	# Fail if the first job submitted fails, but succeed
	# if any job is successfully submitted to avoid looping
	# and filling the queue with partial jobs on the same
	# file.

	if (!$runProphet || ! -f $interactfile)
	{
		if (! -f $cometfile)
		{
			my $filterDTA = $defProps->{"DtaFilterArgs"};

			push(@jobs, createDTAJob($basename,
						$analysisDir,
						$xmlDir,
						$filterDTA,
						$logFile));

			if ($jobs[0] eq "")
			{	return $status; }
		}

		my $scoreExact = 0;
		my $scoring = $defProps->{"Scoring"};
		if (defined($scoring) && $scoring eq "exact")
		{	$scoreExact = 1; }
		my $cometNodes = $defProps->{"Nodes"};
		if (!defined($cometNodes))
		{	$cometNodes = $cometNodesDefault; }
		if ($testCluster && $cometNodes > 4)
		{	$cometNodes = 4; }

		push(@jobs, createCometJob($basename,
					$analysisDir,
					$scoreExact,
					$cometNodes,
					$logFile,
					@jobs));

		if ($jobs[0] eq "")
		{	return $status; }
	}

	if ($#jobs < 0 || $jobs[$#jobs] ne "")
	{
		my $outputFormat = $defProps->{"OutputFormat"};
		if (!defined($outputFormat))
		{	$outputFormat = "xml"; }

		push(@jobs, createPostCometJob($basename,
					$analysisDir,
					$xmlDir,
					$outputFormat,
					$runProphet,
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
# startProphet(<analysis dir>,<html output>,<status file>,<log file>)
#	Starts Peptide Prophet running on a directory of Comet
#	results.

sub startProphet
{
	my $analysisDir = shift();
	my $htmlOutput = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $status = "PROCESSED_FILES";

	my $jobid = createProphetJob($analysisDir, $htmlOutput, $statusFile, $logFile);
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
	my $filterDTA = shift();
	my $logFile = shift();

	my $jobname = $basename . ".createdta";
	my $xmlFile = $basename . ".mzXML";
	my $cometFile = $basename . ".cmt.tar";
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	$script .= "PATH=" . $bin_dir ."tpp/bin:\${PATH}\n";
	$script .= "mkdir " . $tmpdir . " || exit \$?\n";

	if(! -f $xmlDir . $xmlFile)
	{
		writeLog($logFile, "ERROR: No file $xmlFile.\n");
		return "";
	}

	my $files = join " ", ("comet.def",
				$schedulerI->getJobPath($xmlDir) . $xmlFile);

	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";
	$script .= "mkdir " . $basename . " || exit \$?\n";
	$script .= "cd " . $basename . " || exit \$?\n";
	$script .= "cp ../comet.def . || exit \$?\n";

	# Build DTA creation command

 	my $cmd = join " ", ( "mzxml2dta" ,
				"-T4094.0",
				"-B600.0",
				"-O." ,
				"../" . $xmlFile);

	$script .= $cmd . " || exit \$?\n";

	# Filter DTAs if filter args supplied.
	if (defined($filterDTA) && $filterDTA ne "")
	{
		$script .= "dtafilter -A -V " . $filterDTA . " || exit \$?\n";
	}

	# Create .cmt.tar file from created dtas
	$script .= "find . -name \"*.dta\" -o -name comet.def | " .
			"sed \"s/\\.\\///\" > worklist.tmp || exit \$?\n" ;

	$script .= "tar c --files-from=worklist.tmp -f ../" . $basename . ".cmt.tar || exit \$?\n" ;

	$script .= "cd ..\n";
	$script .= "rm -rf $basename  || exit \$?\n";
	$script .= "gzip " . $cometFile . " || exit \$?\n";
	$script .= "popd || exit \$?\n";
	$script .= "syncp.pl " . $tmpdir . $cometFile . ".gz . || exit \$?\n";
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n";

	my %jobProps = (queue => $cometQueue);

	return $schedulerI->submitJobScript($analysisDir, $jobname, \%jobProps,
				$script, $logFile);
}

#-------------------------------------------------------------------#
# createCometJob(<basename>,<analysis dir>,<nodes>,<log file>,<jobs>)
#	Submits a Comet processing job to the cluster.

sub createCometJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $scoreExact = shift();
	my $nodes = shift();
	my $logFile = shift();
	my @jobs = @_;

	my $jobname = $basename . ".comet";
	my $cometFile = $basename . ".cmt.tar.gz";
	my $nodeFile = $schedulerI->getJobNodeFile();
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	$script .= "mkdir " . $tmpdir . " || exit \$?\n";

	my $files = join " ", ("comet.def",
				$cometFile);

	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";

	$script .= "echo Running comet on \`cat " . $nodeFile . "\`\n";
	$script .= "echo \"*\ sp=4\" > nodes\n";
	$script .= "cat " . $nodeFile . " >> nodes\n";
	$script .= "pvm <<EREH\n";
	$script .= "halt\n";
	$script .= "EREH\n";
	$script .= "pvm nodes <<EREH\n";
	$script .= "id\n";
	$script .= "conf\n";
	$script .= "\n";
	$script .= "EREH\n";

	if ($scoreExact)
	{	$script .= $bin_dir . "tpp/bin/comet_exact -R -V " . $cometFile . " || exit \$?\n"; }
	else
	{	$script .= $bin_dir . "tpp/bin/comet -R -V " . $cometFile . " || exit \$?\n"; }

	$script .= "\n";
	$script .= "pvm <<EREH\n";
	$script .= "halt\n";
	$script .= "EREH\n";
	$script .= "\n";

	$script .= "popd || exit \$?\n";
	$script .= "syncp.pl " . $tmpdir . $cometFile . " . || exit \$?\n";
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n";

	my %jobProps = (queue => $cometQueue,
			nodes => $nodes);

	return $schedulerI->submitJobScript($analysisDir,
				$jobname,
				\%jobProps,
				$script,
				$logFile,
				@jobs);
}

#-------------------------------------------------------------------#
# createPostCometJob(<basename>,<analysis dir>,<xml dir>,<output format>,
#			<run prophet>,<status file>,<log file>,<jobs>)
#	Submits a post-Comet processing job to the cluster.

sub createPostCometJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $outputFormat = shift();
	my $runProphet = shift();
	my $statusFile = shift();
	my $logFile = shift();
	my @jobs = @_;

	# Strip path from status file, since it must be in the output
	# directory, and the job script will 'cd' there.
	($statusFile) = fileparse($statusFile, "");

	my $jobname = $basename . ".summary";
	my $xmlFile = $basename . ".mzXML";
	my $cometFile = $basename . ".cmt.tar.gz";
	my $summaryFile = $basename . ".cmt.html";
	my $comet2XmlFile = $basename . ".xml";
	my $pepXmlFile = $basename . ".pep.xml";
	my $pepXmlOrigFile = $basename . ".orig.xml";
	my $pepXmlCompareFile = $basename . ".cmp.xml";
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	$script .= "PATH=" . $bin_dir ."tpp/bin:\${PATH}\n";
	$script .= "export COMETLINKSFILE=/var/data/COMET/cometlinks.def\n";
	$script .= "mkdir " . $tmpdir . " || exit \$?\n";

	my $htmlOutput = 0;
	if ($outputFormat eq "html")
	{	$htmlOutput = 1; }

	my $analysisFile = $analysisDir;
	if ($htmlOutput)
	{	$analysisFile .= $summaryFile; }
	else
	{	$analysisFile .= $pepXmlFile; }

	if (! -f $analysisFile)
	{
		# Comet html to generate .cmt.html
		#
		my $files = $cometFile;
		if (!$htmlOutput)
		{
			$files .= " " . $schedulerI->getJobPath($xmlDir) . $xmlFile;
		}
		$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
		$script .= "pushd " . $tmpdir . " || exit \$?\n";

		my @fileList = ();
		if ($htmlOutput)
		{
			$script .= "comethtml $cometFile || exit \$?\n";

			push(@fileList, $tmpdir . $summaryFile);
		}
		else
		{
			$script .= "Comet2XML $cometFile || exit \$?\n";
			$script .= "mv $comet2XmlFile $pepXmlOrigFile || exit \$?\n";
			if (isDebugLevel(3))
			{
				push(@fileList, $tmpdir . $pepXmlOrigFile);

				if ($pepXMLCompare)
				{
					$script .= "normalPepXml.pl $pepXmlOrigFile || exit \$?\n";
					push(@fileList, $tmpdir . $pepXmlCompareFile);
				}
			}
			if ($runProphet)
			{
				$script .= "xinteract -p0 -Op -N" . $pepXmlFile . " " . $pepXmlOrigFile . " || exit \$?\n";

				push(@fileList, $tmpdir . "*.pep-prot.*");
			}
			else
			{
				$script .= "cp " . $pepXmlOrigFile . " " . $pepXmlFile . " || exit \$?\n";
			}
			push(@fileList, $tmpdir . $pepXmlFile);
		}

		$script .= "popd || exit \$?\n";
		$script .= "syncp.pl " . join(" ", @fileList) . " . || exit \$?\n";
		$script .= "rm -rf " . $tmpdir . " || exit \$?\n";
	}

	if ($htmlOutput && $runProphet)
	{
		if (! -f $analysisDir . getBranchFile("interact.htm", $basename))
		{
			# Cometinteract processing
			#
			$script .= "cometinteract -I $summaryFile";
			$script .= " || { echo \"Interact failed \$?\"; exit \$? ; }\n" ;
		}

		# Peptide prophet processing
		#
		$script .= "runprophet.pl $summaryFile || exit \$?\n";
		#$script .= "java -jar " . $bin_dir . "qualscore/qualscore.jar -l -a " .
		#		getBranchFile("prophet.htm", $basename) . "/n";
	}

	$script .= "echo PROCESSED > " . $statusFile . "\n";

	my %jobProps = (queue => $cometQueue);

	return $schedulerI->submitJobScript($analysisDir,
				$jobname,
				\%jobProps,
				$script,
				$logFile,
				@jobs);
}


#-------------------------------------------------------------------#
# createProphetJob(<analysis dir>,<html output>,<status file>,<log file>)

sub createProphetJob
{
	my $analysisDir = shift();
	my $htmlOutput = shift();
	my $statusFile = shift();
	my $logFile = shift();

	# Strip path from status file, since it must be in the output
	# directory, and the job script will 'cd' there.
	($statusFile) = fileparse($statusFile, "");

	my $jobname = "all.prophet";
	my $script = "";

	if ($htmlOutput)
	{
		if (! -f $analysisDir . "interact.htm")
		{
			$script .= "cometinteract -A || exit \$?\n";
		}
		$script .= "runprophet.pl || exit \$?\n";
		#$script .= "java -jar " . $bin_dir . "/qualscore/qualscore.jar -l -a prophet.htm\n";
	}
	else
	{
		$script .= "PATH=" . $bin_dir ."tpp/bin:\${PATH}\n";
		$script .= "xinteract -p0 -Op -Nall.pep.xml *.pep.xml || exit \$?\n";
	}
	$script .= "echo PROCESSED > " . $statusFile . "\n";

	my %jobProps = (queue => $cometQueue,
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
	my $runid = shift();
	my $logFile = shift();

	if (!defined($emailAddress) || $emailAddress eq "")
	{	return; }

	writeLog($logFile, "LOG: Sending complete email to $emailAddress\n");

	if (open(MAIL, "| mailx -v -s \"Comet analysis complete\" $emailAddress >/dev/null 2>/dev/null"))
	{
		print MAIL "Comet analysis complete\n";
		print MAIL "DIRECTORY: $analysisDir\n";
		if ($webServer ne "")
		{
			print MAIL "\n";
			print MAIL getMS2UploadRunLink($webServer, $analysisDir, $runid);
		}

		close(MAIL);
	}
	else
	{
		writeLog($logFile, "ERROR: Failed to open email.\n");
	}
}

#-----------------------------------------------------------------#
# writeXTandemXML(<analysis root>,<def file>)
#	Converts a comet.def to a tandem.txt.

sub writeXTandemXML
{
	my $analysisRoot = shift();
	my $defFile = shift();
	my %defProps = loadDefFile($defFile);
	my %tanProps = ();
	my @errors = ();

	my $databasePath = $defProps{"Database"};
	# FHCRC specific removal of absolute path
	$databasePath =~ s/\/data\/databases\///;
	$tanProps{"pipeline, database"} = $databasePath;
	$tanProps{"pipeline, email address"} = $defProps{"EmailAddress"};
	$tanProps{"pipeline, data type"} = $defProps{"DataType"};
	$tanProps{"pipeline, dta filter args"} = $defProps{"DtaFilterArgs"};
	$tanProps{"pipeline, scoring"} = $defProps{"Scoring"};
	$tanProps{"pipeline, data path"} = $defProps{"DataPath"};
	$tanProps{"pipeline, xml path"} = $defProps{"XMLPath"};
	$tanProps{"pipeline, filter include"} = $defProps{"FilterInclude"};
	$tanProps{"pipeline, filter exclude"} = $defProps{"FilterExclude"};

	my $missedCleavages = $defProps{"AllowedMissedCleavages"};
	if ($missedCleavages != 2)
	{
		$tanProps{"scoring, maximum missed cleavage sites"} =
			$missedCleavages;
	}

	$tanProps{"scoring, algorithm"} = "comet";
	$tanProps{"spectrum, use conditioning"} = "no";

	if ($defProps{"AddNtermPeptide"} != 0)
	{
		$tanProps{"protein, cleavage N-terminal mass change"} =
			1.007825035 + $defProps{"AddNtermPeptide"};
	}
	if ($defProps{"AddCtermPeptide"} != 0)
	{
		$tanProps{"protein, cleavage C-terminal mass change"} =
			17.002739665 + $defProps{"AddCtermPeptide"};
	}
	if ($defProps{"AddNtermProtein"} != 0)
	{
		$tanProps{"protein, N-terminal residue modification mass"} =
			$defProps{"AddNtermProtein"};
	}
	if ($defProps{"AddCtermProtein"} != 0)
	{
		$tanProps{"protein, C-terminal residue modification mass"} =
			$defProps{"AddCtermProtein"};
	}

	my $massUnits = $defProps{"UnitsMassTol"};
	if (defined($massUnits) && $massUnits =~ /^ppm$/i)
	{
		$tanProps{"spectrum, parent monoisotopic mass error units"} =
			"ppm";
	}

	my $massTol = $defProps{"MassTol"};
	if ($massTol != 2.0)
	{
		$tanProps{"spectrum, parent monoisotopic mass error plus"} =
			$massTol;
		$tanProps{"spectrum, parent monoisotopic mass error minus"} =
			$massTol;
	}

	if ($defProps{"MassTypeParent"} == 0)
	{
		push(@errors, "ERROR: Average parent mass not supported.");
	}

	if ($defProps{"MassTypeFragment"} == 0)
	{
		$tanProps{"spectrum, fragment mass type"} = "average";
	}

	my $scoringIons = $defProps{"IonSeries"};
	if (defined($scoringIons) && $scoringIons ne "010000010")
	{
		if ($scoringIons !~ /([01])([01])([01])000([01])([01])([01])/)
		{
			push(@errors, "ERROR: Unsupported IonSeries format.");
		}
		else
		{
			$tanProps{"scoring, a ions"} = "yes" if ($1 eq "1");
			$tanProps{"scoring, b ions"} = "no" if ($2 eq "0");
			$tanProps{"scoring, c ions"} = "yes" if ($3 eq "1");
			$tanProps{"scoring, x ions"} = "yes" if ($4 eq "1");
			$tanProps{"scoring, y ions"} = "no" if ($5 eq "0");
			$tanProps{"scoring, z ions"} = "yes" if ($6 eq "1");
		}	
	}

	my $tandemMod = "";
	my $variableTermModType = $defProps{"VariableTermModType"};
	my $variableNTerm = $defProps{"VariableModNTerm"};
	if (defined($variableNTerm) && $variableNTerm != 0)
	{
		if (defined($variableTermModType) && $variableTermModType == 1)
		{
			push(@errors, "ERROR: VariableModNTerm not supported for protein mods.");
		}
		else
		{
			$tandemMod .= $variableNTerm . "@[";
		}
	}
	my $variableCTerm = $defProps{"VariableModCTerm"};
	if (defined($variableCTerm) && $variableCTerm != 0)
	{
		if (defined($variableTermModType) && $variableTermModType == 1)
		{
			push(@errors, "ERROR: VariableModCTerm not supported for protein mods.");
		}
		else
		{
			$tandemMod .= $variableCTerm . "@]";
		}
	}

	my $staticTermModType = $defProps{"StaticTermModType"};
	my $staticNTerm = $defProps{"StaticAddNTerm"};
	if (defined($staticNTerm) && $staticNTerm != 0)
	{
		if (defined($staticTermModType) && $staticTermModType == 1)
		{
			$tanProps{"protein, N-terminal residue modification mass"} = $staticNTerm;
		}
		else
		{
			$tanProps{"protein, cleavage N-terminal mass change"} = $staticNTerm;
		}
	}

	my $staticCTerm = $defProps{"StaticAddCTerm"};
	if (defined($staticCTerm) && $staticCTerm != 0)
	{
		if (defined($staticTermModType) && $staticTermModType == 1)
		{
			$tanProps{"protein, C-terminal residue modification mass"} = $staticCTerm;
		}
		else
		{
			$tanProps{"protein, cleavage C-terminal mass change"} = $staticCTerm;
		}
	}

	my $partialSequence = $defProps{"PartialSequence"};
	if (defined($partialSequence) && $partialSequence ne "")
	{
		push(@errors, "ERROR: PartialSequence not supported.");
	}

	my $proteinMassFilter = $defProps{"ProteinMassFilter"};
	if (defined($proteinMassFilter) && $proteinMassFilter !~ /0\s+0/)
	{
		push(@errors, "ERROR: ProteinMassFilter not supported.");
	}

	my $sequenceHeaderFilter = $defProps{"SequenceHeaderFilter"};
	if (defined($sequenceHeaderFilter) && $sequenceHeaderFilter ne "")
	{
		push(@errors, "ERROR: SequenceHeaderFilter not supported.");
	}

	my $enzymeNum = $defProps{"EnzymeNum"};
	if (defined($enzymeNum))
	{
		if (open(DEF, $defFile))
		{
			my $inEnzymes = 0;
			my $foundEnzyme = 0;

			while (<DEF>)
			{
				next if (!$inEnzymes && !/\[COMET_ENZYME_DEF\]/);
				$inEnzymes = 1;

				next if (!/^$enzymeNum\./);

				my @enzymeParts = split(/\s+/, $_);

				$foundEnzyme = 1;
				
				if ($#enzymeParts != 4)
				{
					push(@errors, "ERROR: Failed reading enzyme definition '" . $_ . "'");
				}
				else
				{
					my $enzymeExpr = getTandemEnzymeExpr(@enzymeParts);
					if ($enzymeExpr ne "[KR]|{P}")
					{
						$tanProps{"protein, cleavage site"} = $enzymeExpr;
					}
				}


				last;
			}

			if (!$inEnzymes)
			{
				push(@errors, "ERROR: No enzyme information found.");
			}
			elsif (!$foundEnzyme)
			{
				push(@errors, "ERROR: Enzyme $enzymeNum not found.");
			}
		}	
		else
		{
			push(@errors, "ERROR: Failure reading enzymes.");
		}
	}

	for (my $i = 1; $i < 4; $i++)
	{
		my $varMod = $defProps{"VariableMod" . $i};
		if (defined($varMod) && $varMod =~ /(\d+\.\d+)\s+([A-Z])\s+([01])/)
		{
			if ($1 ne "0.0")
			{
				if ($3 eq "1")
				{
					push(@errors, "ERROR: Binary modifications not supported.");
				}
				else
				{
					$tandemMod .= "," if ($tandemMod ne "");
					$tandemMod .= $1 . "@" . $2;
				}
			}
		}
	}

	if ($tandemMod ne "")
	{
		$tanProps{"residue, potential modification mass"} = $tandemMod;
	}
	
	$tandemMod = "";
	my @AAs = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
			"L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
			"V", "X", "Y", "Z");
	for (my $i = 0; $i <= $#AAs; $i++)
	{
		my $fixedMod = $defProps{"Add_" . $AAs[$i]};
		next if (!defined($fixedMod) || $fixedMod == 0.0);

		$tandemMod .= "," if ($tandemMod ne "");
		$tandemMod .= $fixedMod . "@" . $AAs[$i];
	}

	if ($tandemMod ne "")
	{
		$tanProps{"residue, modification mass"} = $tandemMod;
	}

	my @pathParts = split(/\//, $defFile);
	my $tandemDir = $analysisRoot . "xtan/";
	
	if (! -d $tandemDir)
	{
		mkdir($tandemDir);
		# mode param for mkdir doesn't work.
		chmod(02775, $tandemDir);
	}

	$tandemDir .= "xc_" . $pathParts[$#pathParts - 1] . "/";
	if (! -d $tandemDir)
	{
		mkdir($tandemDir);
		# mode param for mkdir doesn't work.
		chmod(02775, $tandemDir);
	}

	if (-f $tandemDir . "tandem.xml")
	{
		# if there is already a tandem.xml, don't write a tandem.txt.
		return;
	}

	my $tandemXML = $tandemDir . "tandem.txt";
	if ($#errors >= 0)
	{
		$tandemXML .= ".err";	
	}

	writeTandemInputXML($tandemXML, %tanProps);

	if ($#errors >= 0 && open(TXML, ">>$tandemXML"))
	{
		print TXML "<!--\n";
		for (my $i = 0; $i <= $#errors; $i++)
		{
			print TXML $errors[$i];
			print TXML "\n";
		}
		print TXML "-->\n";

		close(TXML);
	}
}

#-----------------------------------------------------------------#
# getTandemEnzymeExpr(<comet def list>)
#	Converts comet enzyme definition properties into a
#	X!Tandem enzyme expression.

sub getTandemEnzymeExprSub
{
	my $cleave = shift();
	my $AA = shift();

	if ($AA eq "-")
	{
		return "[X]";
	}
	elsif ($cleave)
	{
		return "[" . $AA . "]";
	}
	else
	{
		return "{" . $AA . "}";
	}

}

sub getTandemEnzymeExpr
{
	my $enzymeNum = shift();
	my $enzymeName = shift();
	my $enzymeOrient = shift();
	my $enzymeAA = shift();
	my $enzymeAANot = shift();

	my $expr = "";

	if ($enzymeOrient)
	{
		$expr .= getTandemEnzymeExprSub(1, $enzymeAA);
		$expr .= "|";
		$expr .= getTandemEnzymeExprSub(0, $enzymeAANot);
	}
	else
	{
		$expr .= getTandemEnzymeExprSub(0, $enzymeAANot);
		$expr .= "|";
		$expr .= getTandemEnzymeExprSub(1, $enzymeAA);
	}

	return $expr;
}

1;
