#! /usr/bin/perl -w
$|++;

use strict;

use Getopt::Long;
use File::Basename;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common;

use Cwd;
use lib Cwd::abs_path(dirname($0) . '/..');

use Pipe::TandemUtils;

my $replyThisFar = '';

my $clusterRun = 1;
my @logLines = ();
my $statusToReturn = '';
my $submissionTask = 0;

my $nStatus = main();
exit ($nStatus);

# keep message in a log array for finaly output
sub logMessage 
{
	my ($message) = @_;
	if ($clusterRun) {
		push @logLines, $message;
	} else {
		print $message, "\n";
	}
}

sub resetLogMessage
{
	@logLines = ();
}

# set the main status string to return
sub setReturnStatus
{
	my ($status, $toAppend) = @_;
	if ($clusterRun) {
		if (defined $toAppend && $toAppend != 0)
		{
			$statusToReturn .= $status;
		}
		else
		{
			$statusToReturn = $status;
		}
	} else {
		print $status, "\n";
	}
}

# report the run status
# start with main status line
# follow by lines of log messages
sub reportRun
{
	if ($clusterRun) {
		if (0 == $submissionTask) {
			print 'Status=';
		} else {
			print 'PROCESSING->taskid=';
		}
		if ($statusToReturn ne '') {
			print $statusToReturn, "\n";
		} else {
			my $numOfLogs = scalar(@logLines);
			if ($numOfLogs > 0) {
				$numOfLogs--;
				print $logLines[$numOfLogs], "\n";
				for(my $i=0; $i<$numOfLogs; $i++) {
					print $logLines[$i], "\n";
				}
			} else {
				print "ERROR->unknown\n";
			}
		}
	} else {
		# do nothing as in the non-cluster run
		# all message have been send to STDOUT immediately
	}
}

sub printUsage
{
	die "Usage: " . fileparse($0) . " [options]\n" .
		"	--h		: help\n" .
		"	--i=<filename>	: input file name (.mgf)\n" .
		"	--o=<filename>	: output file name (.dat)\n" .
		"	--p=<filename>	: parameter file name (mascot.xml)\n" .
		"	--t=<taskid>	: task id of search job \n" .
		"	--un=<username>	: mascot account \n" .
		"	--pwd=<password>	: password for mascot account \n" .
		"	--msvr=<url>	: Mascot server's URL \n\n" .
		"Modes of operation \n" .
		"================== \n" .
		"1) Submit file 		-->	--p=mascot.xml --i=inputfile.mgf \n" .
		"2) Monitor status	-->	--p=mascot.xml --t=taskid \n" .
		"3) Retrieve file	-->	--p=mascot.xml --t=taskid --o=outputfile.dat \n\n";
}

sub main
{
	my $basename = '';
	my $username = '';
	my $password = '';
	my $proxyURL = '';
	my $ua = LWP::UserAgent->new;
	my $securityEnabled = -1;
	my $sessionId = ''; 
	my $taskId = 0;
	my $actionstring = '';

	my $inputFile = '';
	my $outputFile = '';
	my $paramFile = '';
	my $atomic = 0;
	my $tologout = 0;
	my $ret = GetOptions(
		"a|atomic!"		=> \$atomic,
		"c|cluster!"		=> \$clusterRun,
		"h|?!"			=> sub{ printUsage(); exit 0;},
		"i|input=s"		=> \$inputFile,
		"o|output=s"		=> \$outputFile,
		"p|param=s"		=> \$paramFile,
		"t|taskid=i"		=> \$taskId,
		"un|username=s"		=> \$username,		# for mini-pipeline
		"pwd|password=s"	=> \$password,		# for mini-pipeline
		"msvr|mascotsvr=s"	=> \$basename,		# for mini-pipeline
	);
	
	if (!$ret) { printUsage(); }

	$submissionTask = 1 if ($inputFile ne '');

	# let's check for the presence of necessary parameters
	if ($basename eq '' && $paramFile eq '') { printUsage(); }

	my %props = ();
	if ($paramFile ne '') {
		%props = loadTandemInputXML($paramFile);
	}
	$basename = $props{"pipeline, mascot server"} if ($basename eq '' && exists $props{"pipeline, mascot server"});
	$proxyURL = $props{"pipeline, mascot http proxy"} if ($proxyURL eq '' && exists $props{"pipeline, mascot http proxy"});
	# check for and set proxy if available
	if ($proxyURL ne '') {
		$ua->proxy('http', $proxyURL);
	} elsif (defined($ENV{'HTTP_PROXY'})) {
		$ua->env_proxy;
	}

	my %mascotConfig = loadTandemInputXML(dirname($0) . '/mascot.xml');
	$username = $mascotConfig{"pipeline, mascot username"} if ($username eq '' && exists $mascotConfig{"pipeline, mascot username"});
	$password = $mascotConfig{"pipeline, mascot password"} if ($password eq '' && exists $mascotConfig{"pipeline, mascot password"});
	
	if ($basename eq '') { printUsage(); }
	
	my $workablebasename = findWorkableSettings ($ua, $basename);
	if ('' eq $workablebasename) { reportRun(); return (6); }
	$basename = $workablebasename;

	# check if security is enabled
	($securityEnabled, $sessionId) = isSecurityEnabled($ua, $basename);
	if (-1 == $securityEnabled) { reportRun(); return (5); }
	
	resetLogMessage();
	
	# let's acquire a session id if we do not have one or security is enabled
	if ($sessionId eq '' && 1 == $securityEnabled) {
		# security is enabled, so login with username and password
		logMessage("Logging in to mascot server...");

		$sessionId = login($ua, $basename, $username, $password);
		if ('' ne $sessionId) {
			# we have successfully login, fall thru' for processing
			$tologout = 1;
		} else {
			logMessage("ERROR->Can't login to mascot server.");
			reportRun(); return (2);
		}
	}

	if ($atomic) {
		# for taking the whole process as an atomic operation

		my $exitCode = 0;
		if ($paramFile eq '' || $inputFile eq '' || $outputFile eq '') {
			$exitCode = 1;
		}

		if (0 == $exitCode)
		{
			sleep (5);
			# submit job to mascot server
			my $searchStatus = '';
			while (1)
			{
				my %props = loadTandemInputXML($paramFile);
				injectCompositeFilter ($inputFile, \%props);
				($actionstring, $taskId) = getTaskID($ua, $basename, $sessionId);
				logMessage("Sending input file " . $inputFile . " to mascot server...");
				if (submitFile($ua, $basename, $sessionId, $taskId, $actionstring, 
						   \%props, $inputFile)) {
					logMessage("Input file successfully submitted.");
					logMessage("TaskID=" . $taskId);
					setReturnStatus($taskId);

					# TODO: implement a timer time out?
					while (1)
					{
						sleep(30);
						$searchStatus = getStatus($ua, $basename, $sessionId, $taskId);
						logMessage("Status=" . $searchStatus);
						setReturnStatus($searchStatus);
						last if ($searchStatus =~ /complete/i);
						last if ($searchStatus =~ /error=/i);
					}
					if ($searchStatus !~ /complete/i) {
						if ($searchStatus =~ /error=51/i) {
							sleep(3*60);
							next;
						} else {
							$exitCode = 3;
							last;
						}
					}

					logMessage("Retrieving result from mascot server...");
					# TODO: implement a timer time out?
					while (1)
					{
						sleep(10);
						if (getResultFile($ua, $basename, $sessionId, $taskId,
								  $outputFile)) {
							open TEST, "<$outputFile";
							if (<TEST> =~ /^MIME-Version:/) {
								logMessage("Result successfully saved in " . $outputFile . ".");
								last;
							} else {
								logMessage("Result is not ready for download yet.");
								unlink $outputFile;
							}
							close TEST;
						} else {
							logMessage("ERROR->Can't retrieve result file from mascot server.");
							$exitCode=4;
							last;
						}
					}

				} else {
					logMessage("ERROR->Can't submit input file to mascot server.");
					$exitCode=3;
				}

				# we get out of retry
				last;
			}

			if ($tologout) {
				logMessage("Logging out from mascot server...");
				if (logout($ua, $basename, $sessionId)) {
					logMessage("Successfully logged out.");
				} else {
					logMessage("ERROR->Can't logout from mascot server.");
				}
			}
		}

		reportRun (); return ($exitCode);

	} else {

		if ($paramFile ne '' && $inputFile ne '') {
			# submit job to mascot server
			my %props = loadTandemInputXML($paramFile);
			injectCompositeFilter ($inputFile, \%props);
			($actionstring, $taskId) = getTaskID($ua, $basename, $sessionId);
			logMessage("Sending input file " . $inputFile . " to mascot server...");
			if (submitFile($ua, $basename, $sessionId, $taskId, $actionstring, 
					   \%props, $inputFile)) {
				logMessage("Input file successfully submitted.");
				logMessage("TaskID=" . $taskId);
				setReturnStatus($taskId);
			} else {
				logMessage("ERROR->Can't submit input file to mascot server.");
			}	
		} elsif ($taskId != 0) {
			if ($outputFile ne '') {
				# get result file from mascot server
				logMessage("Retrieving result from mascot server...");
				# need to insert delay to work properly?
				#sleep(1);
				if (getResultFile($ua, $basename, $sessionId, $taskId,
						  $outputFile)) {
					open TEST, "<$outputFile";
					if (<TEST> =~ /^MIME-Version:/) {
						logMessage("Result successfully saved in " . $outputFile . ".");
					} else {
						logMessage("Result is not saved.");
						unlink $outputFile;
					}
					close TEST;
				} else {
					logMessage("ERROR->Can't retrieve result file from mascot server.");
				}
			} else {
				# get running status of task from mascot server
				my $searchStatus = getStatus($ua, $basename, $sessionId, $taskId);
				logMessage("Status=" . $searchStatus);
				setReturnStatus($searchStatus);
			}
		}

		if ($tologout) {
			logMessage("Logging out from mascot server...");
			if (logout($ua, $basename, $sessionId)) {
				logMessage("Successfully logged out.");
			} else {
				logMessage("ERROR->Can't logout from mascot server.");
			}
		}
	}

	reportRun();
	return 0;
}

###############################################################################
# isSecurityEnabled(<user agent>,<base name>)
sub findWorkableSettings
{
	my ($ua, $basename)  = @_;
	#http://mascot.server.org/mascot/cgi-bin/login.pl
	#http://mascot.server.org/cgi/login.pl
	#http://mascot.server.org/
	#mascot.server.org
	
	if ($basename !~ /^http:\/\//) {
		$basename = 'http://' . $basename;
	}
	if ($basename !~ /\/$/) {
		$basename .= '/';
	}
	
	my $startPathPos = index($basename, '/', length('http://'));
	my $hostname = substr($basename, 0, $startPathPos+1);

	my $securityEnabled;
	my $sessionId;
	if ($hostname ne $basename) {
		($securityEnabled, $sessionId) = isSecurityEnabled($ua, $basename);
		return $basename if (-1 != $securityEnabled);
	}

	$basename = $hostname . 'mascot/cgi/';
	($securityEnabled, $sessionId) = isSecurityEnabled($ua, $basename);
	return $basename if (-1 != $securityEnabled);

	$basename = $hostname . 'cgi-bin/';
	($securityEnabled, $sessionId) = isSecurityEnabled($ua, $basename);
	return $basename if (-1 != $securityEnabled);

	return '';
}

###############################################################################
# isSecurityEnabled(<user agent>,<base name>)
sub isSecurityEnabled
{
	my ($ua, $basename)  = @_;
	my ($securityEnabled, $sessionId) = (-1, '');

	my $url = $basename . "login.pl?action=issecuritydisabled&display=nothing&onerrdisplay=nothing";
	#my $request = HTTP::Request->new('GET', $url); 
	#my $request = GET($url); 

	#my $response = makeRequest($request);
	#print $url . "\n";
	my $response = $ua->get($url);
	if ($response->is_success) {
		my $output = getResponse($response);
		#print $response->content;
		if (ref($output)) {
			if (defined $output->{'error'}) {
				if ($output->{'error'} == -3) {
					$securityEnabled = 1;
				} elsif ($output->{'error'} == 0) {
					$securityEnabled = 0;
					$sessionId = $output->{'sessionID'};
				} else {
					logMessage("Error! Unrecognised response.");
					logMessage('HTTP STATUS: '.$response->status_line);
					logMessage('HTTP Content: '.$response->content);
				}
			}
		} elsif ('' eq $output) {
			$securityEnabled = 0;
			$sessionId = '';
		}
	}
	else
	{
		logMessage("Error! Fail to query for Mascot security settings.");
		logMessage('HTTP STATUS: '.$response->status_line);
		logMessage('HTTP Content: '.$response->content);
	}
	
	return ($securityEnabled, $sessionId);
}

###############################################################################
# login(<user agent>,<base name>,<username>,<password>)
sub login
{
	my ($ua, $basename, $username, $password) = @_;
	
	my $sessionId = '';
	my $url = $basename . "login.pl?action=login&username=" . $username . 
				  "&password=" . $password . 
				  "&display=nothing&onerrdisplay=nothing";
	#my $request = HTTP::Request->new('GET', $url); 
	#my $request = GET($url); 

	#my $response = makeRequest($request);
	my $response = $ua->get($url);
	if (ref(my $output = getResponse($response))) {
		if (defined $output->{'error'}) {
			if ($output->{'error'} == 0) {
				if (defined $output->{'sessionID'}) {
					$sessionId = $output->{'sessionID'};
				} else {
					logMessage('HTTP Content: '.$response->content);
				}
			} else {
				logMessage('HTTP Content: '.$response->content);
			}
		} else {
			logMessage('HTTP Content: '.$response->content);
		}
	} else {
		logMessage("Error! Incorrect response from server!");
	}

	return $sessionId;
}

###############################################################################
# logout(<user agent>,<base name>,<session id>)
sub logout
{
	my ($ua, $basename, $sessionId) = @_;
	
	return 1 if ('' eq $sessionId);
	
	my $flag = 0;
	my $url = $basename . "login.pl?action=logout&sessionID=" . $sessionId . 
				  "&display=nothing&onerrdisplay=nothing"; 
	
	#my $response = makeRequest($url);
	my $response = $ua->get($url);
	if (ref(my $output = getResponse($response))) {
		if (defined $output->{'error'} && $output->{'error'} == 0) {
			$flag = 1;
		}
	} else {
		logMessage("Error! Incorrect response from server!");
	}

	return $flag;
}

###############################################################################
# getResponse(<response>)
# return a string or a hash reference
sub getResponse
{
	my $content = $_[0]->is_success ? $_[0]->content : '';
	my %content = ();

	if ($content =~ /=/) {
		# key may not be empty but values may be empty
		while ($content =~ /(.+)=(.*)\n/g) {
			$content{$1} = $2;
		}
		return \%content;
	} else {
		chomp $content;
		return $content;
	}
}

###############################################################################
# getTaskID(<user agent>,<base name>,<session id>)
sub getTaskID
{
	my ($ua, $basename, $sessionId) = @_;
	
	my $actionstring = '';
	my $taskId = 0;
	my $url = $basename . 'client.pl?create_task_id';
	$url .= '&sessionID=' . $sessionId if ('' ne $sessionId);
	#my $request = HTTP::Request->new('GET', $url); 
	#my $request = GET($url); 
	
	#my $response = makeRequest($request);
	my $response = $ua->get($url);
	if (ref(my $output = getResponse($response))) {
		if (defined $output->{'actionstring'}) {
			$actionstring = $output->{'actionstring'}; 
		}
		if (defined $output->{'taskID'}) {
			$taskId = $output->{'taskID'}; 
		}
		if ($actionstring eq '' && 0 == $taskId) {
			logMessage('HTTP Content : '.$response->content);
		}
	}

	return ($actionstring, $taskId);
}

###############################################################################
# submitFile(<user agent>,<base name>,<session id>,<task id>,<action string>,
# 		 <properties>,<input file>)
sub submitFile
{
	my ($ua, $basename, $sessionId, $taskId, 
		$actionstring, $props, $analysisFile) = @_;
	
	my $url = $basename . $actionstring . '?1+--taskID+' . $taskId;
	$url .= '+--sessionID+' . $sessionId if ('' ne $sessionId);
	my @header = ('User-Agent' => 'Mascot Daemon 2.1.0', 
			  'Content-Type' => 'multipart/form-data',
			  'Connection' => 'Keep-Alive',
			  'Pragma' => 'no-cache');
	my @content = getOptions($props);
	my $request = POST($url, @header, 'Content' => [@content, 'FILE' => [$analysisFile]]);

	#*************************************************************
	# hack to append .dta to individual query title in mascot file
	#*************************************************************
	#my $content = $request->content();
	#my $test = ($content =~ /^TITLE=[\w\.]+/gm);
	#my $count = ($content  =~ s/^TITLE=[\w\.]+/$&\.dta/gm);
	#$request->header('Content-Length' => $request->header('Content-Length') + $count * 4);
	#$content =~ /^Content-Length: (\d+)/m;	
	#$count = $1 + $count * 4;
	#$content =~ s/^(Content-Length:) \d+/$1 $count/m;
	#$request->content($content);
	
	$replyThisFar = '';
	my $response = $ua->request($request, \&getCompleteStatus);
	#my $response = $ua->post($url, @header, 'Content' => [@content, 'FILE' => [$analysisFile]]);

	if (!$response->is_success) {
		logMessage('HTTP STATUS: '.$response->status_line);
		logMessage('HTTP Content: '.$response->content);
	}
	return $response->is_success;
}

###############################################################################
# getCompleteStatus
sub getCompleteStatus
{
	my $chunk = shift();
	$replyThisFar .= $chunk;
	if ($replyThisFar =~ /Finished uploading search details.../m) {
		# completed uploading search file
		die();
	}		
}

###############################################################################
# getOptions(<properties>)
sub getOptions
{
	my ($props) = @_;
	my @options = ();
	my @fieldNames = (
		["charge", "mascot, peptide_charge", "search, charge"],
		["cle", "mascot, enzyme", "search, cle"],
		["com", "mascot, comment", "search, com"],
		["db", "pipeline, database", "search, db"],
		["errortolerant", "mascot, error_tolerant", "default, errortolerant"],
		["format", "spectrum, path type", "search, format"],
		["formver", "mascot, form version", "default, formver"],
		["icat", "mascot, icat", "search, icat"],
		["instrument", "mascot, instrument", "search, instrument"],
		["intermediate", "mascot, intermediate", "default, intermediate"],
		["it_mods", "mascot, variable modifications", "search, it_mods"],
		["mods", "mascot, fixed modifications", "search, mods"],
		["overview", "mascot, overview", "search, overview"],
		["pfa", "scoring, maximum missed cleavage sites", "search, pfa"],
		["precursor", "mascot, precursor", "search, precursor"],
		["report", "mascot, report top results", "search, report"],
		["reptype", "mascot, report type", "default, reptype"],
		["search", "mascot, search type", "default, search"],
		["seg", "mascot, protein mass", "search, seg"],
		["taxonomy", "protein, taxon", "search, taxonomy"],
		["tolu", "spectrum, parent monoisotopic mass error units", "search, tolu"],
		["useremail", "pipeline, email address", "search, usermail"],
		["username", "pipeline, user name", "search, username"],
		["iatol", "mascot, iatol", "default, iatol"],
		["iastol", "mascot, iastol", "default, iastol"],
		["ia2tol", "mascot, ia2tol", "default, ia2tol"],
		["ibtol", "mascot, ibtol", "default, ibtol"],
		["ibstol", "mascot, ibstol", "default, ibstol"],
		["ib2tol", "mascot, ib2tol", "default, ib2tol"],
		["iytol", "mascot, iytol", "default, iytol"],
		["iystol", "mascot, iystol", "default, iystol"],
		["iy2tol", "mascot, iy2tol", "default, iy2tol"],
		["peak", "mascot, peak", "default, peak"],
		["ltol", "mascot, ltol", "default, ltol"],
		["showallmods", "mascot, showallmods", "default, showallmods"]
	);
	my ($option, $field) = ();

	foreach my $fieldRef (@fieldNames) {
		my $key = uc($fieldRef->[0]);
		my $val = '';
		for (my $i=1; $i<scalar(@{$fieldRef}); $i++) {
			if (defined($props->{$fieldRef->[$i]})) {
				$val = $props->{$fieldRef->[$i]};
				last;
			}
		}
		if ($key eq 'MODS' || $key eq 'IT_MODS') {
			my @elements = split /,/, $val;
			foreach my $element (@elements)
			{
				$element =~ s/^\s+//g;
				$element =~ s/\s+$//g;
				push @options, $key, $element;
			}
		}
		else {
			push @options, $key, $val;
		}
	}

	#{"tol",
	#   max{"spectrum, parent monoisotopic mass error plus",
	#     "spectrum, parent monoisotopic mass error minus"}, or
	#  "search, tol"}
	my $key = "TOL";
	my $val = undef;
	my $val1 = defined($props->{"spectrum, parent monoisotopic mass error plus"}) ? $props->{"spectrum, parent monoisotopic mass error plus"} : "";
	my $val2 = defined($props->{"spectrum, parent monoisotopic mass error minus"}) ? $props->{"spectrum, parent monoisotopic mass error minus"} : "";
	if ($val1 ne '' || $val2 ne '')
	{
		if ($val1 ne '' && $val2 ne '') {
			$val = ($val1 > $val2) ? $val1 : $val2;
		}
		elsif ($val1 ne '') {
			$val = $val1;
		}
		else {
			$val = $val2;
		}
	}
	else {
		$val = defined($props->{"search, tol"}) ? $props->{"search, tol"} : "";
	}
	push @options, $key, $val;

	$key = "MASS";
	$val = defined($props->{"spectrum, fragment mass type"}) ? $props->{"spectrum, fragment mass type"} : "";
	if ($val eq '') {
		$val = defined($props->{"search, mass"}) ? $props->{"search, mass"} : "";
	}
	push @options, $key, $val;

	my $isMonoisoptopicMass = (lc($val) eq "monoisotopic") ? 1 : 0;
	$key = "ITOL";
	my $keyField = (1 == $isMonoisoptopicMass) ? "spectrum, fragment monoisotopic mass error" : "spectrum, fragment mass error";
	$val = defined($props->{$keyField}) ? $props->{$keyField} : "";
	if ($val eq '') {
		$val = defined($props->{"search, itol"}) ? $props->{"search, itol"} : "";
	}
	push @options, $key, $val;
	$key = "ITOLU";
	$keyField = (1 == $isMonoisoptopicMass) ? "spectrum, fragment monoisotopic mass error units" : "spectrum, fragment mass error units";
	$val = defined($props->{$keyField}) ? $props->{$keyField} : "";
	if ($val eq '') {
		$val = defined($props->{"search, itolu"}) ? $props->{"search, itolu"} : "";
	}
	push @options, $key, $val;

	return @options;
}

###############################################################################
# getOptions
#sub getOptions
#{
#	my @options = ();
#	my @optionpair = ();
#
#	open FILE, '</home/bioadmin/input.txt';
#	while (<FILE>) {
#		next if ($_ =~ /^#/);
#		chomp;
#		@optionpair = split /,/;
#		if ($optionpair[0] ne 'FILE') { 
#			push @options, @optionpair;
#		} else {
#			push @options, $optionpair[0], [$optionpair[1]];	
#		}
#		push @options, '' if ($#options % 2 != 1);
#	}
#	close FILE;
#
#	return @options;
#}

###############################################################################
# getStatus(<user agent>,<base name>,<session id>,<task id>)
sub getStatus
{
	my ($ua, $basename, $sessionId, $taskId) = @_;
	
	my $url = $basename . 'client.pl?status&task_id=' . $taskId;
	$url .= '&sessionID=' . $sessionId if ('' ne $sessionId);
	my $response = $ua->get($url);
	if (ref(my $output = getResponse($response))) {
		if (defined $output->{'error'} && $output->{'error'} != 0)
		{
			return $response->content;
		}
		else
		{
			return $output->{'running'};
		}
	} else {
		return $output;
	}
}

###############################################################################
#getResultFile(<user agent>,<base name>,<session id>,<task id>,<output file>)
sub getResultFile
{
	my ($ua, $basename, $sessionId, $taskId, $resultFile) = @_;
	
	#my $url = $basename . "client.pl?result_file_name&task_id=" .
	#	  $taskId . "&sessionID=" . $sessionId;
	#my $response = $ua->get($url);
	#if (ref(my $output = getResponse($response))) {
	#	print $output->{'filename'} . "\n";	
	#}	
	
	my $url = $basename . 'client.pl?result_file_mime&task_id=' . $taskId;
	$url .= '&sessionID=' . $sessionId if ('' ne $sessionId);
	my $response = $ua->get($url, ':content_file' => $resultFile);

	return $response->is_success;
}


###############################################################################
#injectCompositeFilter(<mgf file>,<parameters>)
#
# TODO: This should really be part of msxml2other so that the code can be more effective
#       from computational point of view and also reducing the need to implement in both
#       mini-and cluster-pipeline.
#
#format:
#BEGIN IONS
#X=x
#Y=y
#Z=z
#m/z1 intensity1
#m/z2 intensity2
# :
#m/zn intensityn
#END IONS
#
sub injectCompositeFilter
{
	my ($inputFile, $optionsRef) = @_;
	
	return 0 if (!exists $optionsRef->{'search, comp'});
	my $compFilter = $optionsRef->{'search, comp'};
	return 0 if ('' eq $compFilter);
	
	my $nReturn = 0;
	# let's inject the COMPosite filter into Mascot data file
	logMessage('Adding COMPosite filter into Mascot data file...');

	if (!open (SOURCEFILE, $inputFile))
	{
		$nReturn = 1;
	}
	my $outputFile = $inputFile . '.tmp';
	if (0 == $nReturn)
	{
		$nReturn = 1  if (!open (DESTINATIONFILE, '>'.$outputFile));
	}

	if (0 == $nReturn)
	{
		my ($fBEGIN, $fCOMPFilter) = (0, 0);
		while (<SOURCEFILE>)
		{
			my $line = $_;
			$line =~ s/\r\n$//;
			$line =~ s/\r$//;
			$line =~ s/\n$//;
			
			if ($line =~ /^BEGIN\ IONS$/i)
			{
				$fBEGIN = 1;
				$fCOMPFilter = 0;
			}
			elsif ($line =~ /^END\ IONS$/i)
			{
			    $fBEGIN = 0;
			}
			elsif (1 == $fBEGIN && 0==$fCOMPFilter)
			{
				if (/\=/)
				{
					if ($line =~ /^COMP=/i)
					{
						$line = 'COMP=' . $compFilter;
						$fCOMPFilter = 1;
					}
				}
				else
				{
					# likely to be m/z intensity values
					print DESTINATIONFILE 'COMP=', $compFilter, "\n";
					$fCOMPFilter = 1;
				}
			}
			print DESTINATIONFILE $line, "\n";
		}
		close SOURCEFILE;
		close DESTINATIONFILE;
		
		my $originalFile = $inputFile . '.original';
		if (1 == rename($inputFile, $originalFile))
		{
			# a.mgf --> a.mgf.original
			if (1 == rename($outputFile, $inputFile))
			{
				# a.mgf.tmp --> a.mgf
				if (1 == unlink $originalFile)
				{
					# a.mgf.original successfully removed
				}
				else
				{
					$nReturn = 6;
				}
			}
			else
			{
				$nReturn = 5;
			}
		}
		else
		{
			$nReturn = 4;
		}
	}
	
	if (0 == $nReturn)
	{
		logMessage('COMPosite filter added.');
	}
	else
	{
		logMessage('Failed to inject composite filter into '.$inputFile.', error code='.$nReturn);
	}
	
	return $nReturn;
}


