package Pipe::Utils;

use strict;

use File::Basename;
use Carp;
use LWP::UserAgent;
use HTTP::Request;
use URI::Escape;

use Pipe::Params;

BEGIN
{
	use Exporter;

	@Pipe::Utils::ISA       = qw(Exporter);
	@Pipe::Utils::EXPORT    = qw(getStatusFile
					getStatus
					setStatus
					setStatusEx
					getLogFile
					writeLog
					getTimeStamp
					isDebugLevel
					loadDefFile
					isAnalysisComplete
					completeAnalysis
					getBranchFile
					getSiteContainer
					getSitePath
					getAbsolutePath
					getRelativePath
					getVerDir
					makeRequest
					getAnalysisList);
	@Pipe::Utils::EXPORT_OK = qw();
}

my $statusFilename = "all.status";
my $logProcFilename = "pipe-processing.log";
my $logFilename = "pipe.log";

#-----------------------------------------------------------------#
# getStatusFile(<directory>[,<basename>])
#	Given a directory, returns the path to its status file.

sub getStatusFile
{
	my $path = shift();
	my $basename = shift();
	$path .= "/" unless $path =~ /\/$/;
	if (defined($basename) && $basename ne "")
	{	$path .= $basename . ".status"; }
	else
	{	$path .= $statusFilename; }
	return $path;
}

#-----------------------------------------------------------------#
# getStatus(<status file>[,<default status>])
#	Pulls the status string off the first line of a status
#	file.

sub getStatus
{
	my $statusFile = shift();
	my $statusDefault = shift();
	if (!defined($statusDefault) || $statusDefault eq "")
	{	$statusDefault = "UNKNOWN"; }
	my $status = $statusDefault;

	if (open(STATUS, $statusFile))
	{
		$status = <STATUS>;
		if (!defined($status))
		{
			$status = "ERROR->type=file system";
		}
		else
		{
			chomp $status;
			close(STATUS);

			# Handle retry after error.
			if ($status =~ /^ERROR/ && ! -f $statusFile . ".err")
			{
				system("mv", $statusFile, $statusFile . ".err");
				$status = $statusDefault;
			}
		}
	}
	
	# WAITING is the CPAS equivalent of UNKNOWN.
	if ($status eq "WAITING")
	{	$status = "UNKNOWN"; }

	return $status;
}

#-----------------------------------------------------------------#
# isErrorStuckStatus(<status file>)
#	Returns true, if current status is an error awaiting
#	human intervention.

sub isErrorStuckStatus
{
	my $statusFile = shift();
	return getStatus($statusFile) eq "ERROR" &&
		-f $statusFile;
}

#-----------------------------------------------------------------#
# setStatus(<status file>,<status>[,<info>])
# setStatusEx(<status file>,<provider>,<email>,<status>[,<info>])
#	Writes a new status string to the status file.

sub setStatus
{
	my $statusFile = shift();
	my $provider;
	my $emailAddress;
	my $status = shift();
	my $info = shift();

	setStatusEx($statusFile, $provider, $emailAddress, $status, $info);
}

sub setStatusEx
{
	my $statusFile = shift();
	my $provider = shift();
	my $emailAddress = shift();
	my $status = shift();
	my $info = shift();
	my $webStatus = shift();
	if (!defined($webStatus))
	{	$webStatus = 1; }

	if (!defined($info))
	{	($status, $info) = split(/->/, $status); }

	my $success = 0;

	if (open(STATUS, ">$statusFile"))
	{
		print STATUS $status;
		print STATUS "->" . $info if defined($info);
		print STATUS "\n";
		close STATUS;
		chmod(0664, $statusFile);

		if ($webServer ne "")
		{	
			if (!$webStatus)
			{
				$webStatus = 1 if !removeWebStatus($webServer,
								$statusFile);
			}

			if ($webStatus)
			{
				setWebStatus($webServer,
						$statusFile,
						$provider,
						$emailAddress,
						$status,
						$info);

				if ($status eq "ERROR")
				{
					# TODO: If $statusFile . ".err" exists, send mail.
				}
			}
		}

		$success = 1;
	}
	else
	{
		writeLog(getLogFile(dirname($statusFile)),
			"ERROR: Failed to open $statusFile for write.\n");
	}

	return $success;
}

#-----------------------------------------------------------------#
# setWebStatus(<server>,<status file>,<provider>,<email>,<status>[,<info>])
#	Posts status to the web server.

sub setWebStatus
{
	my $server = shift();
	my $statusFile = shift();
	my $provider = shift();
	my $emailAddress = shift();
	my $status = shift();
	my $info = shift();

	my $statusContainer = getSiteContainer($statusFile);
	my $filepath = getSitePath($statusFile,'WS');
	my $setUrl = $webProtocol . "://" . $server . $webWarRoot . "/Pipeline-Status" .
			$statusContainer;
	$setUrl .= '/' if ($statusContainer !~ /\/$/);
	$setUrl .= "setStatusFile.post?";

	$setUrl .= "status=" . uri_escape($status);
	$setUrl .= "&provider=" . uri_escape($provider) if defined($provider);
	$setUrl .= "&email=" . uri_escape($emailAddress) if defined($emailAddress);
	$setUrl .= "&info=" . uri_escape($info) if defined($info);
	$setUrl .= "&filePath=" . uri_escape($filepath);

	my $response = makeRequest($setUrl);
	my $content = "";
	if ($response->is_success)
	{
		$content = $response->content();
		$content =~ s/^\s*(\S.*)\s*/$1/;
	}

	if ($content !~ /SUCCESS/)
	{
		writeLog(getLogFile(dirname($statusFile)),
			"ERROR: Failed posting status to web for $statusFile\n" .
			$content . "\n");
	}
}

#-----------------------------------------------------------------#
# removeWebStatus(<server>,<status file>)
#	Posts status to the web server.

sub removeWebStatus
{
	my $server = shift();
	my $statusFile = shift();

	my $statusContainer = getSiteContainer($statusFile);
	my $filepath = getSitePath($statusFile,'WS');
	my $removeUrl = $webProtocol . "://" . $server . $webWarRoot . "/Pipeline-Status" .
			$statusContainer;
	$removeUrl .= '/' if ($statusContainer !~ /\/$/);
	$removeUrl .= "removeStatusFile.post?";

	$removeUrl .= "filePath=" . uri_escape($filepath);

	my $response = makeRequest($removeUrl);
	my $content = "";
	if ($response->is_success)
	{
		$content = $response->content();
		$content =~ s/^\s*(\S.*)\s*/$1/;
	}

	return ($content =~ /SUCCESS/);
}

#-----------------------------------------------------------------#
# getLogFile(<directory>[,<basename>])
#	Given a directory, returns the path to its log file.

sub getLogFile
{
	my $path = shift();
	my $basename = shift();

	$path .= "/" unless $path =~ /\/$/;
	if (defined($basename))
	{	$path .= $basename . ".log"; }
	else
	{	$path .= $logProcFilename; }
	return $path;
}

#-----------------------------------------------------------------#
# writeLog(<log file>,<message>,<debug threshold>)
#	Appends a message to a file.

sub writeLog
{
	my $logFile = shift();
	my $message = shift();
	my $threshold = shift();
	if (!defined($threshold))
	{	$threshold = 1; }

	print $message if $DEBUG >= $threshold;

	if (defined($logFile))
	{
		my $exists = (-f $logFile);
		if (open(LOG, ">>$logFile"))
		{
			print LOG $message;
			close(LOG);
			chmod(0664, $logFile) if ! $exists;
		}
		else
		{
			$logFile = "" if !defined($logFile);

			carp "ERROR: Failed to open log file $logFile.";
		}
	}
}

#-----------------------------------------------------------------#
# getTimeStamp()
#	Returns a time stamp string for the current time.

sub getTimeStamp
{
	my @parts = localtime(time);
	return sprintf("%4d-%02d-%02d %02d:%02d:%02d",
			$parts[5]+1900,
			$parts[4]+1,
			$parts[3],
			$parts[2],
			$parts[1],
			$parts[0]);
}

#-----------------------------------------------------------------#
# isDebugLevel(<level>)
#	Returns true if $DEBUG >= level.

sub isDebugLevel
{
	my $level = shift();

	return $DEBUG >= $level;
}

#-----------------------------------------------------------------#
# loadDefFile(<def file>)
#	Loads a name value pair file into a map.

sub loadDefFile
{
	my $defFile = shift();
	my %props = ();
	if (open(DEF, $defFile))
	{
		while (<DEF>)
		{
			s/#.*$//;	# remove comments
			s/^\s*//;	# remove leading whitespace
			s/\s*$//;	# remove trailing whitespace
			if (/^(.*\S)\s*=\s*(\S.*)$/)
			{
				$props{$1} = $2;
			}
		}

		close(DEF);
	}

	return %props;
}

#-----------------------------------------------------------------#
# isAnalysisComplete(<directory>,<file list>)
#	Returns true, if analysis for a directory is complete.
#	Checks to see if the directory has a complete log file.

sub isAnalysisComplete
{
	my $directory = shift();
	my ($log) = grep(/^$logFilename$/, @_);
	return (defined($log));
}

#-----------------------------------------------------------------#
# completeAnalysis(<directory>)
#	Performs operations to clean-up a directory, and mark
#	it as complete.

sub completeAnalysis
{
	my $directory = shift();
	$directory .= '/' unless $directory =~ /\/$/;

	# Rename log file to final name.
	my $logFinal = $directory . $logFilename;
	rename(getLogFile($directory), $logFinal);

	# Remove status files.
	if (opendir(DIR, $directory))
	{
		my @statusFiles = grep(/\.status$/i, readdir(DIR));
		closedir(DIR);

		my $statusFile;
		foreach $statusFile (@statusFiles)
		{
			unlink($directory . $statusFile);
		}
	}
}

#-----------------------------------------------------------------#
# getBranchFile(<filename>,<basename>)
#	Given a filename <name>.<ext> and <basename>, returns
#	<name>_<basename>.<ext>, if <basename> is not empty,
#	or the original filename, if <basename> is empy.

sub getBranchFile
{
	my $filename = shift();
	my $basename = shift();

	if (!defined($basename) || $basename eq "")
	{	return $filename; }

	my @status_parts = split( /\./, $filename ) ;
	$status_parts[0] .= "_" . $basename;
	return join( ".", @status_parts ) ;
}

#-----------------------------------------------------------------#
# getSitePath(<path>)
#	Converts a local path to a path for HTTP server consumption.

sub getSitePath
{
	my $path = shift();
	my $serverType = shift() || '';  # 'XS'-convert server, 'WS'-web server

	if ($serverType eq 'WS')
	{
		return $path if (! $webServerSamba);
	}
	elsif ($serverType eq 'XS')
	{
		return $path if (! $convertServerSamba);
	}
	else
	{
		# fall thru' for default behaviour as per original code
	}

	# Make sure path starts with unix root
	if ($path !~ /^$unixRoot/)
	{	carp "ERROR: getSitePath called with bad path $path.\n"; }

	return $smbaRoot . substr($path, length($unixRoot));
}

#-----------------------------------------------------------------#
# getAbsolutePath(<root path>,<path>)
#	Returns absolute path, given a root path, and a possibly
#	relative path.

sub getAbsolutePath
{
	my $root = shift();
	$root .= '/' unless $root =~ /\/$/;
	my $path = shift();
	$path .= '/' unless $path =~ /\/$/;

	if (substr($path, 0, 1) ne "/")
	{
		$path = $root . $path;

		# Compress out .. directories.
		while ($path =~ /\/[^\/]+\/\.\.\//)
		{
			$path =~ s/\/[^\/]+\/\.\.\//\//;
		}
	}

	return $path;
}


#-----------------------------------------------------------------#
# getRelativePath(<root path>,<path>)
#	Returns relative path, given a root path, and a path
#	to make relative to it.

sub getRelativePath
{
	my $root = shift();
	my $path = shift();
	
	my @rootParts = split(/\//, $root);
	my @pathParts = split(/\//, $path);

	my $part1 = shift(@rootParts);
	my $part2 = shift(@pathParts);

	while (defined($part1) && defined($part2) && $part1 eq $part2)
	{
		$part1 = shift(@rootParts);
		$part2 = shift(@pathParts);
	}

	unshift(@pathParts, $part2) if defined($part2);

	while (defined($part1))
	{
		unshift(@pathParts, '..');
		$part1 = shift(@rootParts);
	}

	if ($#pathParts < 0)
	{	push(@pathParts, '.'); }

	return join('/', @pathParts);
}

#-----------------------------------------------------------------#
# getSiteContainer(<directory>)
#	Gets upload container for web server.

sub getSiteContainer
{
	my $directory = shift();

	if (defined($webContainerCurrent) && $webContainerCurrent ne "")
	{	return $webContainerCurrent; }

	my $webContainer = $webContainerRoot;
	if ($webContainerLevel != -1)
	{
		# Backward compatibility: container level was 1-based,
		#     but a zero-based index is really needed here.
		my $levelBaseZero = $webContainerLevel - 1;

		my $tpath = substr($directory, length($dirRoot));
		my @tparts = split(/\//, $tpath);
		$webContainer .= "/" .
			join("/", splice(@tparts, $levelBaseZero, $webContainerDepth));
	}
	return $webContainer;
}


#-----------------------------------------------------------------#
# makeRequest(<url>,<log file>)
#	Gets upload description for web server.

sub makeRequest
{
	my $url = shift();
	my $logFile = shift();

	my $ua = LWP::UserAgent->new;
	my $request = HTTP::Request->new(GET => $url);

	my $req_log = $request->as_string;
	chop($req_log);
	writeLog($logFile, "LOG: Sending HTTP request:\n" .
		$req_log, 2);

	my $response = $ua->request($request);
	if (!$response->is_success)
	{
		writeLog($logFile, "ERROR: Failure response:\n" .
			$response->as_string . "\n");
	}
	return $response;
}

#-----------------------------------------------------------------#
# getAnalysisList(<filter include>,<filter exclude>,<path - ext list>)
#	Gets a list of base names for analysis.

sub getAnalysisList
{
	my $filterInclude = shift();
	my $filterExclude = shift();
	my @paths = @_;

	my @names = ();
	my %seen = ();

	for (my $i = 0; $i <= $#paths; $i += 2)
	{
		my $path = $paths[$i];

		next if (!opendir(DIR, $path));

		my $ext = $paths[$i+1];
		my $ext_reg = $ext;
		$ext_reg =~ s/\./\\./g;

		my @files = grep(/$ext_reg$/i, readdir(DIR));
		closedir(DIR);
		if (defined($filterInclude) && $filterInclude ne "")
		{	@files = grep(/$filterInclude/, @files); }
		if (defined($filterExclude) && $filterExclude ne "")
		{	@files = grep(!/$filterExclude/, @files); }
		
		my ($file, $basename);
		foreach $file (@files)
		{
			next if ($file !~ /($ext_reg)$/i);

			($basename) = fileparse($file, $1);

			push(@names, $basename) unless $seen{$basename}++;
		}
	}

	return sort(@names);
}

#-----------------------------------------------------------------#
# getVerDir(<directory>,<version>[,<subdir>])
#	Gets path to versioned directory given parts.

sub getVerDir
{
	my $dir = shift();
	my $ver = shift();
	my $subdir = shift();

	$dir .= "." . $ver if defined($ver);
	$dir .= "/" . $subdir if defined($subdir);

	return $dir;
}

