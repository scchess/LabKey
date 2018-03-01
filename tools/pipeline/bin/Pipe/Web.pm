package Pipe::Web;

use strict;
use URI::Escape;

use Pipe::Params;
use Pipe::Utils;

BEGIN
{
	use Exporter;

	@Pipe::Web::ISA       = qw(Exporter);
	@Pipe::Web::EXPORT    = qw(startMS2Upload
					getMS2UploadStatus
					getMS2UploadRunStatus
					getMS2UploadRunLink
					getMS2UploadDescription);
	@Pipe::Web::EXPORT_OK = qw();
}

#-----------------------------------------------------------------#
# startMS2Upload(<server>,<basename>,<data dir>,<analysis dir>,
#		<upload file>,<experiment>,<status file>,<log file>)
#	Starts upload of analysis data to web server.

sub startMS2Upload
{
	my $server = shift();
	my $basename = shift();
	my $xmlDir = shift();
	my $analysisDir = shift();
	my $uploadFilename = shift();
	my $experiment = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $status = "PROCESSED";

	# Upload the processed data to the EDI server.

	my $uploadContainer = getSiteContainer($analysisDir);
	my $uploadPath = getSitePath($analysisDir, 'WS') . "/" . $uploadFilename;
	my $uploadDataPath = getSitePath($xmlDir,'WS');
	# wst: use unix path instead of samba path
	#my $uploadPath = $analysisDir . $uploadFilename;
	#my $uploadDataPath = $xmlDir;
	
	my $description = getMS2UploadDescription($analysisDir, $basename);
	my $protocol = getMS2AnalysisProtocol($analysisDir);
	my $uploadUrl = $webProtocol . "://" . $server . $webWarRoot . "/MS2" .
			$uploadContainer;
	$uploadUrl .= '/' if ($uploadContainer !~ /\/$/);
	$uploadUrl .= "addRun.post?auto=true" .
			"&description=" . uri_escape($description) .
			"&protocol=" . uri_escape($protocol) .
			"&dataDir=" . uri_escape($uploadDataPath) .
			"&fileName=" . uri_escape($uploadPath);

	if ($experiment)
	{	$uploadUrl .= "&experiment=1"; }

	my $response = makeRequest($uploadUrl, $logFile);
	if ($response->is_success)
	{
		my $content = $response->content();
		my $contentOrig = $content;
		$content =~ s/^\s*(\S.*)\s*$/$1/;
		if ($content =~ /[A-Z]*->run=([^,\r\n]*)/)
		{
			$status = "LOADING";
			setStatus($statusFile, $status, "run=$1");

			writeLog($logFile, "LOG: Upload run $1 started.\n", 1);
		}
		elsif ($content =~ /[A-Z ]*->path=([^,\r\n]*)/)
		{
			$status = "LOADING";
			setStatus($statusFile, $status, "path=$1");

			writeLog($logFile, "LOG: Upload '$description' started.\n", 1);
		}
		else
		{
			writeLog($logFile, "ERROR: Unknown status for load request:\n" .
				$contentOrig);
		}
	}

	return $status;
}

#-----------------------------------------------------------------#
# getMS2UploadRunLink(<server>,<analysis dir>,<run id>)
#	Returns a link to MS2 data on the web site.

sub getMS2UploadRunLink
{
	my $server = shift();
	my $analysisDir = shift();
	my $runid = shift();

	my $webContainer = getSiteContainer($analysisDir);
	my $linkUrl = $webProtocol . "://" . $server . $webWarRoot . "/MS2" .
		$webContainer;
	$linkUrl .= '/' if ($webContainer !~ /\/$/);
	if (defined($runid))
	{
		$linkUrl .= "showRun.view?run=" . $runid;
	}
	else
	{
		$linkUrl .= "showList.view?MS2Runs.Description~startswith=" .
			getMS2UploadDescription($analysisDir);
	}

	return $linkUrl;
}

#-----------------------------------------------------------------#
# getMS2UploadRunStatus(<server>,<run id>,<status file>,<log file>)
#	Checks progress on an upload to web server.

sub getMS2UploadRunStatus
{
	my $server = shift();
	my $runId = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $status = "LOADING";

	my $statusUrl = $webProtocol . "://" . $server . $webWarRoot .
		"/MS2/addFileRunStatus.view?run=" . $runId;

	my $response = makeRequest($statusUrl, $logFile);
	if ($response->is_success)
	{
		my $content = $response->content();
		$content =~ s/^\s*(\S.*)\s*/$1/;
		if ($content =~ /LOADING->.*status=([^,]*)/)
		{
			writeLog($logFile, "LOG: Load status=$1\n", 1);
		}
		elsif ($content =~ /FAILED/)
		{
			writeLog($logFile, "ERROR: Load failed.\n");
		}
		elsif ($content =~ /ERROR->.*message=Run deleted/)
		{
			writeLog($logFile, "ERROR: Run $runId deleted before completion.\n");

			$status = "ERROR";
			setStatus($statusFile, $status, "type=Run deleted");
		}
		elsif ($content !~ /SUCCESS/)
		{
			writeLog($logFile, "ERROR: Load status unknown:\n" .
				$content);
		}
		else
		{
			writeLog($logFile, "LOG: Load status=complete\n", 1);

			$status = "COMPLETE";
			setStatus($statusFile, $status);
		}
	}

	return $status;
}

#-----------------------------------------------------------------#
# getMS2UploadStatus(<server>,<path>,<status file>,<log file>)
#	Checks progress on an upload to web server.

sub getMS2UploadStatus
{
	my $server = shift();
	my $path = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $status = "LOADING";

	my $statusUrl = $webProtocol . "://" . $server . $webWarRoot .
		"/MS2/addFileRunStatus.view?path=" . $path;

	my $response = makeRequest($statusUrl, $logFile);
	if ($response->is_success)
	{
		my $content = $response->content();
		$content =~ s/^\s*(\S.*)\s*/$1/;
		if ($content =~ /^ERROR/)
		{
			writeLog($logFile, "ERROR: Failure uploading data to web.\n See $path.");

			$status = "ERROR";
			if ($content =~ /^ERROR->(.*)/)
			{	setStatus($statusFile, $status, $1); }
			else
			{	setStatus($statusFile, $status); }
		}
		elsif ($content !~ /^COMPLETE/)
		{
			writeLog($logFile, "LOG: Load status for $path:\n" .
				$content);
		}
		else
		{
			writeLog($logFile, "LOG: Load status=complete\n", 1);

			$status = "COMPLETE";
			setStatus($statusFile, $status);
		}
	}

	return $status;
}

#-----------------------------------------------------------------#
# getMS2UploadDescription(<analysisDir>,<basename>)
#	Gets upload description for web server.

sub getMS2UploadDescription
{
	my $analysisDir = shift();
	my $basename = shift();

	my @dparts = split(/\//, $analysisDir);
	my $description = $dparts[$#dparts - 1];
	my $protocol = "";
	# TODO: Hard coded directory names.
	if ($description eq "cmt" || $description eq "xtan" || $description eq "xtandem")
	{
		$description = $dparts[$#dparts - 2];
		$protocol = $dparts[$#dparts];
	}
	if (defined($basename) && $basename ne "")
	{
		$description .= "/" . $basename;
	}
	if (defined($protocol) && $protocol ne "")
	{
		$description .= " (" . $protocol . ")";
	}

	return $description;
}

#------------------------------------------------------------------#
# getMS2AnalysisProtocol(<analysisDir>)
#	Gets the analysis protocol name from the analysis
#	directory path.

sub getMS2AnalysisProtocol
{
	my $analysisDir = shift();

	my @dparts = split(/\//, $analysisDir);
	my $description = $dparts[$#dparts - 1];
	my $protocol = "";

	#if ($description eq "cmt" || $description eq "xtan" || $description eq "xtandem")
	if ($description eq "cmt" || $description eq "xtan" || $description eq "xtandem" || $description eq "mascot")
	{
		$protocol = $dparts[$#dparts];
	}
}

1;

