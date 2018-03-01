package Pipe::Mascot;

use strict;
use File::Basename;

use Pipe::Params;
use Pipe::Convert;
use Pipe::Email;
use Pipe::TandemUtils;
use Pipe::Utils;
use Pipe::Web;

our $analysisFilename = "mascot.xml";
our $analysisDirname = "mascot";
our $providerName = "Mascot (Cluster)";

my $bin_dir = dirname($0) . '/';
my $mascotQueue = "mascot";

################################################################################
# TODO:
#   1. Refactor loadTandemInputXML() into loadInputXML()?
#   2. Capture error codes returned by mascot.pl
# NOTE:
#   1. This module is adapted from Pipe::Tandem by Brandon Maclean and
#      implements Mascot MS2 analysis in the cluster pipeline
#   2. Requires a separate server installation of Mascot to provide web service
#   3. Calls mascot.pl to submit search request to Mascot server
#
# AUTHORS: Sum Thai Wong
#	   Chee Hong Wong
################################################################################


#-----------------------------------------------------------------------------#
# analyze(<root directory>,<directory path>)
#   Process a single directory containing a mascot.xml file.
#
# STEPS:
#   1. Read in configuration from mascot.xml
#   2. Analyze files individually from xmlDir
#   3. Determine type of analysis - samples or fractions
#   4. Analysis for samples ends here while fractions undergo additional prophet
#      analysis
#   5. Upload final results to web server after analysis completes
#   6. Notify user through email and clean up intermediate files

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
		writeLog($logFile, "ERROR: Invalid mascot.xml file $defFile.\n");
		if (!-f $statusFile)
		{
			setStatus($statusFile, $status, "type=parameters");
		}
		return $status;
	}
	
	$webContainerCurrent = $defProps{"pipeline, load folder"};
	
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
					if (-f $analysisDir . "all.prot.xml")
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

		my $minProphet = $defProps{"pipeline prophet, min probability"};
		if (!defined($minProphet))
		{	$minProphet = $minProphetDefault; }
		my $accurateMassParam = $defProps{"pipeline prophet, accurate mass"};
		my $hasAccurateMass = (defined($accurateMassParam) && $accurateMassParam =~ /yes/i);
		my $xpressCmd = getQuantitationCmd(\%defProps, $xmlDir);
		
		$status = startProphet($analysisDir,
					$xmlDir,
					$minProphet,
					$hasAccurateMass,
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
		# Send email to user in mascot.xml file.

		sendCompleteMail($emailAddress, $analysisDir, $logFile);

		# Remove status file, and rename log.

		writeLog($logFile, "LOG: Mascot processing completed successfully.\n");
		completeAnalysis($analysisDir);
	}

	$webContainerCurrent = "";
	return $status;
}

#-----------------------------------------------------------------------------#
# analyzeFile(<basename>,<analysis type>,<analysis directory>,<raw directory>,
#	      <xml directory>,<default properties>)
#   Process a single MS data file.
#
# STEPS:
#   1. Read in default properties
#   2. Check current status of data file
#   3. Convert data file to .mzxml format if needed
#   4. Convert .mzxml file to .mgf and submit to Mascot web server
#   5. Poll Mascot web server and retrieve results when processing complete
#   6. Perform prophet analysis
#   7. Upload final results to web server after analysis completes

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

	my $fileType = "thermo";
	my $rawFile = $rawDir . $basename . ".RAW";
	if (! -f $rawFile)
	{
		$rawFile =~ s/\.RAW$/.raw/;
		if (-d $rawFile)
		{	$fileType = "masslynx"; }
	}

	my $xmlFile = $xmlDir . $basename . ".mzXML";
	my $mascotFile = $analysisDir . $basename . ".dat";
	my $statusFile = getStatusFile($analysisDir, $basename);
	my $logFileBranched = getLogFile($analysisDir, $basename);
	my $logFile = getLogFile($analysisDir);
	my $logPermissive = 0;

	if (! -f $logFileBranched)
	{
		writeLog($logFileBranched,
			"Mascot search for " . $basename . ".mzXML\n" .
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
	elsif ($status eq "CONVERTED" || $status =~ /^MASCOT SERVER BUSY/)
	{
		writeLog($logFile, "LOG: Running Mascot for $basename\n");

		$status = startMascot($basename,
					$analysisDir,
					$xmlDir,
					$statusFile,
					$logFile);

		# need to check for $status eq "ERROR"?
		if ($status ne "PROCESSING" && $status ne "ERROR")
		{
			writeLog($logFile, "ERROR: Failed to start Mascot analysis.\n");
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
			$schedulerI->publishOutput($analysisDir, $logPermissive, $basename, 
				"createmgf", "mascot", "convertdat");

			$status = "ERROR";
			setStatus($statusFile, $status, "type=job failure");
		}
	}
	elsif ($status =~ /^PROCESSING->taskid=(.*)/)
	{
		$schedulerI->publishOutput($analysisDir, 0, $basename,
			"createmgf", "mascot", "convertdat");

		my $taskid = $1;
		chomp $taskid;
		if (defined($taskid) && $taskid =~ /^\d+/)
		{
			writeLog($logFile, "LOG: Checking mascot status for $basename with taskid $taskid.\n");
			if (open SUB, $bin_dir . "mascot/mascot.pl --t=$taskid --p=$analysisDir$analysisFilename |")
			{
				local $/;	# enable localized slurp mode
				my $statusLine = <SUB>;
				close SUB;
				if ($statusLine =~ /^Status=complete/m)
				{
					if (open SUB, $bin_dir . "mascot/mascot.pl --t=$taskid --o=$mascotFile --p=$analysisDir$analysisFilename |") 
					{
						$statusLine = <SUB>;
						if ($statusLine =~ /^Status=Result successfully saved/m)
						{
							writeLog($logFile, "LOG: Completed mascot processing for $basename.\n");
							
							$status = "MASCOT PROCESSED";
							setStatus($statusFile, $status);
						}
						else
						{
							writeLog($logFile, "ERROR: Mascot result retrieval for $basename returns, $statusLine\n");
			
							$status = "ERROR";
							my $statusType = $statusLine;
							($statusType) = $statusType =~ /(.*)[\r\n]/;
							if ($statusLine =~ /^Status=error=/m)
							{
								$statusType =~ s/^Status=error=//;
								setStatus($statusFile, $status, 'type=mascot error code '.$statusType);
							}
							elsif ($statusLine =~ /^Status=ERROR->/m)
							{
								$statusType =~ s/^Status=ERROR->//;
								setStatus($statusFile, $status, 'type=mascot server error ('.$statusType.')');
							}
							else
							{
								setStatus($statusFile, $status, 'type='.$statusType);
							}
						}
					}
					else
					{
						# error in executing mascot.pl
						writeLog($logFile, "ERROR: Failure to initiate mascot result retrieval for $basename.\n"); 
						redirectLog ($statusFile, $logFile, 20);
						
						$status = "ERROR";
						setStatus($statusFile, $status, "type=mascot result retrieval failure");
					}
				}
				elsif ($statusLine =~ /^Status=error=51/m)
				{
					writeLog($logFile, "LOG: Mascot server is too busy to process $basename, retry later\n");
	
					$status = "MASCOT SERVER BUSY";
					setStatus($statusFile, $status);
				}
				elsif ($statusLine =~ /^Status=error=/m)
				{
					writeLog($logFile, "ERROR: Mascot server has encountered error processing $basename, $statusLine\n");
	
					$status = "ERROR";
					my $statusType = $statusLine;
					($statusType) = $statusType =~ /(.*)[\r\n]/;
					$statusType =~ s/^Status=error=//;
					setStatus($statusFile, $status, 'type=mascot error code '.$statusType);
				}
				elsif ($statusLine =~ /^Status=ERROR->/m)
				{
					writeLog($logFile, "ERROR: Mascot server interaction has encountered error processing $basename, $statusLine\n");
	
					$status = "ERROR";
					my $statusType = $statusLine;
					($statusType) = $statusType =~ /(.*)[\r\n]/;
					$statusType =~ s/^Status=ERROR->//;
					setStatus($statusFile, $status, 'type=mascot server error ('.$statusType.')');
				}
				else
				{
					writeLog($logFile, "LOG: Mascot search for $basename with taskid $taskid, $statusLine\n");
				}
			}
			else
			{
				# error in executing mascot.pl
				writeLog($logFile, "ERROR: Failure to initiate mascot status query for $basename.\n"); 
				
				$status = "ERROR";
				setStatus($statusFile, $status, "type=mascot status query failure");
			}
		} else {
			if (!defined($taskid) || '' eq $taskid)
			{
				# error in executing mascot.pl
				writeLog($logFile, "ERROR: Failure to get mascot query task id from \"$status\"\n"); 
				redirectLog ($statusFile, $logFile, 20);

				$status = "ERROR";
				setStatus($statusFile, $status, "type=mascot status query failure (without taskid)");
			}
			elsif (defined($taskid) && $taskid =~ /^ERROR->/)
			{
				# error in executing mascot.pl
				writeLog($logFile, "ERROR: Failure to get mascot query task id from \"$status\"\n"); 
				redirectLog ($statusFile, $logFile, 20);
				
				$status = "ERROR";
				$taskid =~ s/^ERROR->//;
				setStatus($statusFile, $status, "type=mascot server error ($taskid)");
			}
			else
			{
				# error in executing mascot.pl
				writeLog($logFile, "ERROR: Failure to query mascot status for $basename.\n"); 
				redirectLog ($statusFile, $logFile, 20);
				
				$status = "ERROR";
				setStatus($statusFile, $status, "type=mascot status query failure");
			}
		}
	}
	elsif ($status eq "MASCOT PROCESSED")
	{
		writeLog($logFile, "LOG: Running post mascot processing for $basename.\n");
		
		my $runProphet = 0;
		my $minProphet = $defProps->{"pipeline prophet, min probability"};
		if (!defined($minProphet))
		{	$minProphet = $minProphetDefault; }
		my $accurateMassParam = $defProps->{"pipeline prophet, accurate mass"};
		my $hasAccurateMass = (defined($accurateMassParam) && $accurateMassParam =~ /yes/i);
		my $xpressCmd;
		if (isSamples($analysisType))
		{
			$runProphet = 1;
			$xpressCmd = getQuantitationCmd($defProps, $xmlDir);
		}
		my $hasFractions = isFractions($analysisType);
		my $database = $defProps->{"pipeline, database"}; #"search, db";

		if ((my $jobid = createPostMascotJob($basename,
		 				     $analysisDir,
						     $xmlDir,
						     $database,
						     $runProphet,
						     $minProphet,
						     $hasAccurateMass,
						     $hasFractions,
						     $xpressCmd, 
						     $statusFile,
						     $logFile)) ne "")
		{
			$status = "PROCESSING";
			setStatus($statusFile, $status, "jobid=" . $jobid);
		}
	}
	elsif ($status eq "PROCESSED")
	{		
		my @stats = stat($statusFile);
		$logPermissive = 1 if time() - $stats[9] > 2*60;
		if ($schedulerI->publishOutput($analysisDir, $logPermissive,
			$basename, "createmgf", "mascot", "convertdat"))
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

#-----------------------------------------------------------------------------#
# startMascot(<basename>,<analysis dir>,<xml dir>,<status file>,<log file>)
#   Starts mascot running on a specific file.
#
#   Submits 2 jobs to scheduler:
#	(a) conversion of .mzxml to .mgf
#	(b) submission of .mgf to Mascot web server

sub startMascot
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my @jobs;

	my $status = "CONVERTED";
	
	my $mgfFile = $analysisDir . $basename . ".mgf";
	my $mascotFile = $analysisDir . $basename . ".dat";

	if (! -f $mascotFile)
	{
		if (! -f $mgfFile)
		{
			push(@jobs, createMgfJob($basename,
						 $analysisDir,
						 $xmlDir,
						 $logFile));

			if ($jobs[0] eq "")
			{	return $status; }
		}

		if (! -z $mgfFile)
		{
			push(@jobs, createMascotJob($basename,
					    	    $analysisDir,
					            $xmlDir,
					            $statusFile,
					            $logFile,
					            @jobs));
		}
		else
		{
			writeLog($logFile, "ERROR: No mascot data found for $basename.\n");
			$status = "ERROR";
			setStatus($statusFile, $status, "type=no mascot data");
			return $status;
		}

		if ($jobs[0] eq "")
		{	return $status; }
	}

	# NOTE: createPostMascotJob is invoked after status becomes
	#	"MASCOT PROCESSED" in analyzeFile()
	#if ($#jobs < 0 || $jobs[$#jobs] ne "")
	#{
	#	push(@jobs, createPostMascotJob($basename,
	#				$analysisDir,
	#				$xmlDir,
	#				$scoreExact,
	#				$runProphet,
	#				$minProphet,
	#				$hasAccurateMass,
	#				$hasFractions,
	#				$xpressCmd,
	#				$statusFile,
	#				$logFile,
	#				@jobs));

	#	if ($jobs[0] eq "")
	#	{	return $status; }
	#}

	if ($#jobs >= 0 && $jobs[$#jobs] eq "")
	{	pop(@jobs); }

	$status = "PROCESSING";
	setStatus($statusFile, $status, "jobid=" . join(",", @jobs));	
	#setStatus($statusFile, $status, "jobid=" . $jobs[$#jobs]);

	writeLog($logFile, "LOG: Sleeping 2 seconds for job scheduler.\n", 2);
	sleep 2;

	return $status;
}

#-----------------------------------------------------------------#
# startProphet(<analysis dir>,<run prophet>,<status file>,<log file>)
#	Starts Peptide Prophet running on a directory of Mascot
#	results.
#
#   Submits 1 job to scheduler:
#	(a) starts prophet analysis

sub startProphet
{
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $minProphet = shift();
	my $hasAccurateMass = shift();
	my $xpressCmd = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $status = "PROCESSED_FILES";

	my $jobid = createProphetJob($analysisDir,
					$xmlDir,
					$minProphet,
					$hasAccurateMass,
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
# createMgfJob(<basename>,<analysis dir>,<xml dir>,<log file>)
#	Creates a cluster job for mgf creation.

sub createMgfJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $logFile = shift();

	my $jobname = $basename . ".createmgf";
	my $xmlFile = $basename . ".mzXML";
	my $mgfFile = $basename . ".mgf";
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	if(! -f $xmlDir . $xmlFile)
	{
		writeLog($logFile, "ERROR: No file $xmlFile.\n");
		return "";
	}

	$script .= "PATH=" . $bin_dir . "tpp/bin:" . $bin_dir . "mascot:\${PATH}\n";
	$script .= "test -d " . $tmpdir . " || mkdir " . $tmpdir . " || exit \$?\n";

	my $files = $schedulerI->getJobPath($xmlDir) . $xmlFile; 
	
	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";

	# Build MGF creation command

 	my $cmd = join " ", ("MzXML2Search" ,
				"-mgf",
				"-T4094.0",
				"-B600.0");

	$cmd .= " " . $xmlFile;

	$script .= $cmd . " || exit \$?\n";
	$script .= "popd || exit \$?\n";
	
	$files = $tmpdir . $mgfFile;
	$script .= "syncp.pl " . $files . " . || exit \$?\n";
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n";

	my %jobProps = (queue => $mascotQueue);

	return $schedulerI->submitJobScript($analysisDir, $jobname, \%jobProps,
				$script, $logFile);
}

#------------------------------------------------------------------------------#
# createMascotJob(<basename>,<analysis dir>,<xml dir>,<status file>,
#		  <log file>,<jobs>)
#   Create a cluster job for running Mascot creation.
#

sub createMascotJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $statusFile = shift();
	my $logFile = shift();
	my @jobs = @_;
	
	my $jobname = $basename . ".mascot";
	my $mgfFile = $basename . ".mgf";
	my $outFile = $jobname . ".out";
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	$script .= "PATH=" . $bin_dir . "tpp/bin:" . $bin_dir . "mascot:\${PATH}\n";
	$script .= "test -d " . $tmpdir . " || mkdir " . $tmpdir . " || exit \$?\n";

	my $files = join " ", ($analysisFilename, $mgfFile); 
	#my $files = $schedulerI->getJobPath($xmlDir) . $mgfFile; 
	
	$script .= "syncp.pl " . $files . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";

	#we need to prepare the appropriate input.xml
	$script .= "mascotPrepare.pl";
	$script .= " --i=" . $mgfFile; 
	#$script .= " --i=" . getRelativePath($analysisDir, $inputFile);
	$script .= " --f=" . $fastaRoot;
	$script .= " " . $analysisFilename . " || exit \$?\n";

	# submit input mgf file to mascot server
	my $cmd = join " ", ("mascot.pl",
			     "--p=input.xml",
			     "--i=" . $mgfFile,
			     "--cluster");
	#$script .= $cmd . " || exit \$?\n";
	#$script .= "echo PROCESSING-\\>taskid=`" . $cmd . 
	#	   " | grep 'TaskID=\\d*' | cut -d= -f2` > " . $statusFile .
	#	   " || exit \$?\n";
	$script .= $cmd . " > " . $statusFile .
		   " || exit \$?\n";
	
	$script .= "popd || exit \$?\n";
	$script .= "rm -rf " . $basename . " || exit \$?\n";

	my %jobProps = (queue => $mascotQueue);

	return $schedulerI->submitJobScript($analysisDir, $jobname, \%jobProps,
				$script, $logFile, @jobs);
}

#-------------------------------------------------------------------#
# createPostMascotJob(<basename>,<output dir>,<xml dir>,
#			<database>,<run prophet>,<min prophet>,<has fract>,
#			<xpress cmd>,<status file>,<log file>)
#	Submits a post-Mascot job to the cluster.

sub createPostMascotJob
{
	my $basename = shift();
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $database = shift();
	my $runProphet = shift();
	my $minProphet = shift();
	my $hasAccurateMass = shift();
	my $hasFractions = shift();
	my $xpressCmd = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $jobname = $basename . ".convertdat";
	my $xmlFile = $basename . ".mzXML";
	my $datFile = $basename . ".dat";
	my $pepXmlFile = $basename . ".pep.xml";
	my $pepXmlFractFile = $basename . ".fract.xml";
	my $pepXmlOrigFile = $basename . ".xml";
	my $protXmlFile = $basename . ".prot.xml";
	my $protXmlIntFile = $basename . ".pep-prot.xml";
	my $dtaGzFile = $basename . ".pep.tgz";
	my $dtaGzOrigFile = $basename . ".tgz";
	
	my $tmpdir = $schedulerI->getJobTempdir() . $basename . ".work/";
	my $script = "";

	if(! -f $xmlDir . $xmlFile)
	{
		writeLog($logFile, "ERROR: No file $xmlFile.\n");
		return "";
	}

	$script .= "PATH=" . $bin_dir . "tpp/bin:" . $bin_dir . "mascot:\${PATH}\n";
	$script .= "test -d " . $tmpdir . " || mkdir " . $tmpdir . " || exit \$?\n";

	my @files = ($analysisFilename, $datFile, $xmlDir . $xmlFile);

	$script .= "syncp.pl " . join(" ", @files) . " " . $tmpdir . " || exit \$?\n";
	$script .= "pushd " . $tmpdir . " || exit \$?\n";

	# convert .dat to .xml
	my $cmd = join " ", ("Mascot2XML",
			     $datFile,
			     "-D" . $fastaRoot . $database,
			     "-xml");
	
	$script .= $cmd . " || exit \$?\n";
	$script .= "mv " . $dtaGzOrigFile . " " . $dtaGzFile . " || exit \$?\n";
	
	my @fileList = ($tmpdir . $dtaGzFile);
	
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
		$prophetOpt .= "A" if $hasAccurateMass;
		push(@interactOpts, $prophetOpt);
		push(@interactOpts, "-nR");
		push(@interactOpts, "-p" . $minProphet);
		push(@interactOpts, "-x20");
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
		}
	}

	$script .= "popd || exit \$?\n";
	$script .= "syncp.pl " . join(" ", @fileList) . " . || exit \$?\n";
	$script .= "rm -rf " . $tmpdir . " || exit \$?\n";

	$script .= "echo PROCESSED > " . $statusFile . "\n";
	
	my %jobProps = (queue => $mascotQueue);

	return $schedulerI->submitJobScript($analysisDir,
				$jobname,
				\%jobProps,
				$script,
				$logFile);
}


#-------------------------------------------------------------------#
# createProphetJob(<analysis dir>,<xml dir>,<min prophet>,
#			<xpress cmd>,<status file>,<log file>)

sub createProphetJob
{
	my $analysisDir = shift();
	my $xmlDir = shift();
	my $minProphet = shift();
	my $hasAccurateMass = shift();
	my $xpressCmd = shift();
	my $statusFile = shift();
	my $logFile = shift();

	# Strip path from status file, since it must be in the output
	# directory, and the job script will 'cd' there.
	($statusFile) = fileparse($statusFile, "");

	my $jobname = "all.prophet";
	my $script = "";

	$script .= "PATH=" . $bin_dir ."tpp/bin:\${PATH}\n";
	$script .= "rm all.pep.xml\n";

	my @interactOpts = ();

	if (defined($xpressCmd) && $xpressCmd ne '')
	{
		push(@interactOpts, $xpressCmd);
	}

	my $prophetOpt = "-Opt";
	$prophetOpt .= "A" if $hasAccurateMass;
	push(@interactOpts, $prophetOpt);
	push(@interactOpts, "-nR");
	push(@interactOpts, "-p" . $minProphet);
	push(@interactOpts, "-x20");

	push(@interactOpts, "-Nall.pep.xml");

	$script .= "xinteract " . join(" ", @interactOpts) . " *.fract.xml || exit \$?\n";

	$script .= "mv all.pep-prot.xml all.prot.xml || exit \$?\n";

	$script .= "rm -f *.fract.xml\n";

	$script .= "echo PROCESSED > " . $statusFile . "\n";

	my %jobProps = (queue => $mascotQueue,
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

	if (open(MAIL, "| mailx -v -s \"Mascot analysis complete\" $emailAddress >/dev/null 2>/dev/null"))
	{
		print MAIL "Mascot analysis complete\n";
		print MAIL "DIRECTORY: $analysisDir\n";

		close(MAIL);
	}
	else
	{
		writeLog($logFile, "ERROR: Failed to open email.\n");
	}
}

sub redirectLog
{
	my $partialLog = shift();
	my $masterLog = shift();
	my $debugLevel = shift();
	if (!defined($debugLevel))
	{	$debugLevel = 1; }

	if (open REDIRECTLOG, $partialLog) {
		while (<REDIRECTLOG>) {
			writeLog($masterLog, $_, $debugLevel);
		}
		close REDIRECTLOG;
	}
}

1;
