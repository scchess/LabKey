package Pipe::Scheduler::SchedulerBase;
use vars qw(@ISA);
use strict;

use Carp 'confess','carp';
use Pipe::SchedulerI;

use Pipe::Utils;

@ISA = qw(Pipe::SchedulerI);

################################################################################
# TODO:
#   1. implement POD to remove separate documentation and easier documentation
# NOTE:
#   1. This code is refactored from Pipe::Torque by Brendan MacLean and 
#      Pipe::Sge by Sum Thai Wong.
#      to provide an implementation of Pipe::SchedulerI by Chee Hong Wong 
#   2. Essentially, it is contained the common code of Pipe::Torque and 
#      Pipe::Sge.  The actual implementation of Pipe::Scheduler::Torque and
#      Pipe::Scheduler::SGE then derived and override specific methods to
#      provide its own specific variants
#   3. New scheduler can be implemented freshly from Pipe::SchedulerI or 
#      derived from this class Pipe::Scheduler::SchedulerBase to benefit 
#      from its implemented features.
################################################################################


################################################################################

# Title   : new
# Usage   : my $scheduler = new Pipe::Scheduler::SchedulerBase();
# Function: Returns the SchedulerBase object which implement SchedulerI
# Returns : SchedulerBase object that has common logics implementation 
#           except for scheduler specific portion
# Status  : Not meant to be instantiated directly.

sub new {
	my($class,@args) = @_;
	my $self = $class->SUPER::new(@args);

	my ($jobtmpdir, $jobnodefile, $jobpath, $jobqueue, 
		$jobscriptext, $joboutputext, 
		$clusterbinpath, $submissionbin, $querybin, $binpath,
		$clusterfailureemail, $debuglevel, $subdirwork) 
		= $self->_rearrange([qw(JOBTMPDIR JOBNODEFILE JOBPATH JOBQUEUE 
			JOBSCRIPTEXT JOBOUTPUTEXT 
			CLUSTERBINPATH SUBMISSIONBIN QUERYBIN BINPATH
			CLUSTERFAILUREEMAIL DEBUGLEVEL SUBDIRWORK)], @args);
		
	$jobtmpdir = 'TMPDIR' if (!defined $jobtmpdir);
	$jobnodefile = 'PBS_NODEFILE' if (!defined $jobnodefile);
	$jobpath = 'PBS_O_WORKDIR' if (!defined $jobpath);
	$jobqueue = '' if (!defined $jobqueue);
	$jobscriptext = '.pbs' if (!defined $jobscriptext);
	$joboutputext = '.out' if (!defined $joboutputext);
	$submissionbin = 'qsub' if (!defined $submissionbin);
	$querybin = 'qstat' if (!defined $querybin);
	$binpath = '' if (!defined $binpath);
	$clusterfailureemail = '' if (!defined $clusterfailureemail);
	$debuglevel = 0 if (!defined $debuglevel);
	if (defined($subdirwork) && $subdirwork)
	{	$jobtmpdir = "."; }
	$self->jobtmpdir($jobtmpdir);
	$self->jobnodefile($jobnodefile);
	$self->jobpath($jobpath);
	$self->jobqueue($jobqueue);
	$self->jobscriptext($jobscriptext);
	$self->joboutputext($joboutputext);
	$self->clusterbinpath($clusterbinpath);
	$self->submissionbin($submissionbin);
	$self->querybin($querybin);
	$self->binpath($binpath);
	$self->clusterfailureemail($clusterfailureemail);
	$self->debuglevel($debuglevel);
	
	$self->server_error(0);
	my %running_jobs = ();
	$self->running_jobs(\%running_jobs);

	return $self;
}

################################################################################
# INTERFACE
################################################################################

#-----------------------------------------------------------------#
# getJobTempdir()
#	Returns temp directory local to running cluster node.

sub getJobTempdir
{
	my $self = shift;
	my $jobtmpdir = $self->jobtmpdir();
	$jobtmpdir = '${' . $jobtmpdir . '}' if $jobtmpdir ne '.';
	return $jobtmpdir . '/';
}

#-----------------------------------------------------------------#
# getJobNodeFile()
#	Returns a path to a file containing the list of nodes
#	to use for this job.

sub getJobNodeFile
{
	my $self = shift;
	return '${'.$self->jobnodefile().'}';
}

#-----------------------------------------------------------------#
# getJobPath(<path>)
#	Returns path usable in running cluster node script.

sub getJobPath
{
	my ($self, $path) = @_;
	if (substr($path, 0, 1) ne '/')
	{
		# not absolute path, so prefix with scheduler job path
		$path = '${'.$self->jobpath().'}/' . $path;
	}
	return $path;
}

#-----------------------------------------------------------------#
# isJobRunning(<jobid>[,<jobid>]*[,<log file>])
#	Tells if a job(s) running by calling qstat.
#	0 = not running, 1 = running, -1 = unknown

# derived class MUST implement getRunningJobs()
# to get the list of running jobs' id
# this list can be updated one element at a time via $self->updateJobStatus()
sub isJobRunning
{
	my $self = shift;
	my $logFile = pop(@_);

	if (!$self->server_error() && !%{$self->running_jobs()})
	{
		$self->getRunningJobs();
	}

	if ($self->server_error())
	{
		writeLog($logFile, "ERROR: Failure contacting job server.\n")
			if defined($logFile);
		return -1;
	}

	my $running_job = "";
	my $jobid;
	foreach $jobid (@_)
	{
		my $statusLine = $self->getJobStatus($jobid);
		if (defined($statusLine))
		{
			$running_job = $jobid;
			writeLog($logFile, $statusLine, 2) if defined($logFile);
		}
	}

	if ($running_job eq "")
	{
		writeLog($logFile, "ERROR: Job " . $_[$#_] . " missing.\n")
			if defined($logFile);
		return 0;
	}

	return 1;
}

# for dervied class to update job status
sub updateJobStatus
{ 
	my ($self,$id,$status) = @_; 
	my $runningJobsRef = $self->{'running_jobs'};
	$runningJobsRef->{$id} = $status;
}

# for dervied class to retrieve job status
sub getJobStatus
{ 
	my ($self,$id) = @_;
	my $runningJobsRef = $self->{'running_jobs'};
	if (exists $runningJobsRef->{$id}) {
		return $runningJobsRef->{$id};
	} else {
		return undef;
	}
}

# for derived class to implement specific ways 
# to get the list of running jobs' id
sub getRunningJobs
{
	my $self = shift;
	$self->die_not_implemented() if (!$self->die_dervied_not_implemented());
}

# to complain that the derived class has not implemented
# the virtual method needed by SchedulerBase
sub die_dervied_not_implemented
{
	my $self = shift;
	my $package = ref $self;
	my @currentcall = caller(0);
	my $currentPackage = $currentcall[0];
	my @call = caller(1);
	my $meth = $call[3];
	
	return 0 if ($package ne $currentPackage);
	
	my $message = 
		"Abstract method \"$meth\"\n" .
		"\tis not implemented by package \"$package\".\n" .
		"$package\n" .
		"\tis meant to be drived for each specific scheduler...\n" .
		"\tPlease check for existing scheduler implementation or roll your own.\n";
	confess $message ;
	
	# let's get serious, after all interface should be obeyed
	die "Terminated";
}

#-----------------------------------------------------------------#
# resetJobStatus()
#	Resets the cached set of running jobs.

#TODO: wch
#clean up the use of running_jobs
#may also need to explore running_jobs to the dervied class, but not public
#is there a protected concept in PerlOO?
sub resetJobStatus
{
	my $self = shift;
	my %empty=();
	$self->running_jobs(\%empty);
}

#-------------------------------------------------------------------#
# submitJobScript(<directory>,<name>,<props>,<script text>,<log file>,<jobs>)
#	Writes an sge script, and submits it to the sge queue.

sub submitJobScript
{
	my $self = shift;
	my $dir = shift();
	my $name = shift();
	my $props = shift();
	my $script = shift();
	my $logFile = shift();
	my @jobs = @_;
	
	my $scriptFile = $self->writeJobScript($dir,
		$name,
		$props,
		$script,
		$logFile);

	return "" if ($scriptFile eq "");

	return $self->submitJob($name, $scriptFile, $logFile, @jobs);
}

#-------------------------------------------------------------------#
# submitJob(<name>,<script file>,<log file>,<jobs>)
#	Submits a job to the sge queue, and returns the jobid.

# derived class MUST implement 
#     createJobDependencies() and getSubmissionJobId()
# submitJob() will then be able to do its work
sub submitJob
{
	my $self = shift;
	my $name = shift();
	my $scriptFile = shift();
	my $logFile = shift();
	my @jobs = @_;
	my $jobid = '';

	my $options = $self->createJobDependencies(@jobs);
	my $cmd = join " ",
		($self->submissionbinfullpath(),
		 $options,
		 $scriptFile);

	writeLog($logFile, "LOG: job command: $cmd \n", 2);

	$cmd .= " 2> " . $scriptFile . ".err |";

	if (!open(QSUB, $cmd))
	{
		writeLog($logFile, "ERROR: Failed to execute command.\n");
	}
	else
	{
		my $jobid_out = $self->getSubmissionJobId(<QSUB>);
		if (!defined($jobid_out) || $jobid_out eq "")
		{
			my $errOut = "";
			if (open(ERR, $scriptFile . ".err"))
			{
				while (<ERR>)
				{ $errOut .= $_; }
				close(ERR);
			}

			writeLog($logFile, "ERROR: Failure submitting command.\n" . $errOut);
		}
		else
		{
			chomp $jobid_out;
			$jobid = $jobid_out;
			writeLog($logFile, "LOG: Submitted $name job $jobid\n", 2);
		}
	}

	unlink $scriptFile . ".err";
	unlink $scriptFile unless isDebugLevel(3);
	return $jobid;
}

# for derived class to implement specific ways 
# to specific the list of job that the new job will depend on
sub createJobDependencies
{
	my $self = shift;
	$self->die_not_implemented() if (!$self->die_dervied_not_implemented());
}

# for derived class to implement specific ways 
# to get the job id of the submitted job
sub getSubmissionJobId
{
	my $self = shift;
	$self->die_not_implemented() if (!$self->die_dervied_not_implemented());
}

#-------------------------------------------------------------------#
# writeJobScript(<directory>,<name>,<queue>,<nodes>,<shell path>,
#			<script text>,<log file>)
#	Writes a sge script for submission to the queue.

# derived class MUST implement getScriptHeader() and getScriptFooter()
# so that the full job script can be constructed by writeJobScript()
# Optionally, derived class can override getJobScriptFile() and
# getJobScriptOutputFile() to a return a desired location for these files
sub writeJobScript
{
	my $self = shift;
	my $dir = shift();
	my $name = shift();
	my $props = shift();
	my $script = shift();
	my $logFile = shift();

	my $nodes = $props->{"nodes"};
	if (!defined($nodes))
	{	$nodes = 1; }
	if ($self->nodesmax > 0 && $nodes > $self->nodesmax)
	{	$nodes = $self->nodesmax; }
	my $shellPath = $props->{"shell"};
	if (!defined($shellPath))
	{	$shellPath = "/bin/bash"; }
	my $queue = $props->{"queue"};
	# check for queue override on command line
	if ($self->jobqueue ne '')
	{	$queue = $self->jobqueue; }
	my $walltime = $props->{"walltime"};

	my $scriptFile = $self->getJobScriptFile($dir,$name);
	my $outFile = $self->getJobScriptOutputFile($dir,$name);

	my $finalScript = '';
	$finalScript .= $self->getScriptHeader(
		-DIR=>$dir,
		-SHELLPATH=>$shellPath,
		-QUEUE=>$queue,
		-NODES=>$nodes,
		-WALLTIME=>$walltime,
		-OUTPUT=>$outFile);
	$finalScript .= $script;
	$finalScript .= $self->getScriptFooter();

	if (!open(QSUB, ">$scriptFile"))
	{
		writeLog($logFile, "ERROR: Failed to open script file $scriptFile.\n");
		return '';
	}

	print QSUB $finalScript;
	close(QSUB);

	return $scriptFile;
}

# default implementation to get the job script filepath
# scheduler can override this method to provide own version
sub getJobScriptFile
{
	my $self = shift;
	my $dir = shift;
	my $name = shift;
	
	my $filename = $self->_mergePath($dir,$name);
	$filename .= $self->jobscriptext();
	return $filename;
}

# default implementation to get the job script output filepath
# scheduler can override this method to provide own version
sub getJobScriptOutputFile
{
	my $self = shift;
	my $dir = shift;
	my $name = shift;
	
	my $filename = $self->_mergePath($dir,$name);
	$filename .= $self->joboutputext();
	return $filename;
}

# for dervied class to generate the script header
# specific to the scheduler so that the job can start appropriately
sub getScriptHeader
{
	my $self = shift;
	$self->die_not_implemented() if (!$self->die_dervied_not_implemented());
}

# for dervied class to generate the script footer
# specific to the scheduler so that the job script end can be marked
sub getScriptFooter
{
	my $self = shift;
	$self->die_not_implemented() if (!$self->die_dervied_not_implemented());
}

#-------------------------------------------------------------------#
# publishOutput(<directory>,<error>,<basename>[,<name list>])
#	Sets less restrictive permissions on job output files.

sub publishOutput
{
	my $self = shift;
	my $dir = shift();
	my $error = shift();
	my $basename = shift();
	my @names = @_;

	# Make sure all files have been written to disk.
	my $name;
	if (!$error)
	{
		foreach $name (@names)
		{
			my $outFile = $dir . $basename . "."  . $name . ".out";
			if (! -f $outFile)
			{	return 0; }
		}
	}

	my $logFile = $dir . $basename . ".log";
	# Just append always to be consistent with CPAS.
	# if ($error)
	# {
	# 	$logFile .= ".err";
	# 	unlink($logFile);
	# }

	if (open(LOG, ">>" . $logFile))
	{
		foreach $name (@names)
		{
			my $outFile = $dir . $basename . "."  . $name . ".out";
			
			if (open(OUT, $outFile))
			{
				my @stats = stat(OUT);
				my @mtimeParts = localtime($stats[9]);

				print LOG "*******************************************************************************\n";
				printf LOG "* %s - %02d-%02d-%4d %02d:%02d:%02d\n",
					$name,$mtimeParts[4]+1,$mtimeParts[3],$mtimeParts[5]+1900,
					$mtimeParts[2],$mtimeParts[1],$mtimeParts[0];
				print LOG "*******************************************************************************\n\n";
				while(<OUT>)
				{
					print LOG;
				}
				close(OUT);
				print LOG "\n";
			}
			unlink($outFile);
		}
		close(LOG);
		chmod(0664, $logFile);
	}
	return 1;
}

################################################################################
# ACCESSORY
################################################################################

sub jobtmpdir
{ 
	my ($self,$value) = @_; 
	$self->{'jobtmpdir'} = $value if( defined $value);
	return $self->{'jobtmpdir'}; 
}

sub jobnodefile
{ 
	my ($self,$value) = @_; 
	$self->{'jobnodefile'} = $value if( defined $value);
	return $self->{'jobnodefile'}; 
}

sub jobpath
{ 
	my ($self,$value) = @_; 
	$self->{'jobpath'} = $value if( defined $value);
	return $self->{'jobpath'}; 
}

sub jobqueue
{ 
	my ($self,$value) = @_; 
	$self->{'jobqueue'} = $value if( defined $value);
	return $self->{'jobqueue'}; 
}

sub jobscriptext
{ 
	my ($self,$value) = @_; 
	$self->{'jobscriptext'} = $value if( defined $value);
	return $self->{'jobscriptext'}; 
}

sub joboutputext { 
	my ($self,$value) = @_; 
	$self->{'joboutputext'} = $value if( defined $value);
	return $self->{'joboutputext'}; 
}

sub clusterbinpath
{ 
	my ($self,$value) = @_; 
	$self->{'clusterbinpath'} = $value if( defined $value);
	return $self->{'clusterbinpath'}; 
}

sub submissionbin
{ 
	my ($self,$value) = @_;
	if (defined $value)
	{
		$self->{'submissionbin'} = $value;
		$self->submissionbinfullpath(
			$self->_mergePath(
				$self->clusterbinpath(), 
				$self->submissionbin()
			));
	}
	return $self->{'submissionbin'}; 
}

sub submissionbinfullpath
{ 
	my ($self,$value) = @_; 
	$self->{'submissionbinfullpath'} = $value if( defined $value);
	return $self->{'submissionbinfullpath'}; 
}

sub querybin
{ 
	my ($self,$value) = @_; 
	if (defined $value)
	{
		$self->{'querybin'} = $value;
		$self->querybinfullpath(
			$self->_mergePath(
				$self->clusterbinpath(), 
				$self->querybin()
			));
	}
	return $self->{'querybin'}; 
}

sub querybinfullpath
{ 
	my ($self,$value) = @_; 
	$self->{'querybinfullpath'} = $value if( defined $value);
	return $self->{'querybinfullpath'}; 
}

sub binpath
{ 
	my ($self,$value) = @_; 
	$self->{'binpath'} = $value if( defined $value);
	return $self->{'binpath'}; 
}

sub running_jobs
{ 
	my ($self,$value) = @_; 
	$self->{'running_jobs'} = $value if( defined $value);
	return $self->{'running_jobs'}; 
}

sub clusterfailureemail
{ 
	my ($self,$value) = @_; 
	$self->{'clusterfailureemail'} = $value if( defined $value);
	return $self->{'clusterfailureemail'}; 
}

sub debuglevel
{ 
	my ($self,$value) = @_; 
	$self->{'debuglevel'} = $value if( defined $value);
	return $self->{'debuglevel'}; 
}

sub server_error
{ 
	my ($self,$value) = @_; 
	$self->{'server_error'} = $value if( defined $value);
	return $self->{'server_error'}; 
}

################################################################################
# HELPER FUNCTION
################################################################################

#-------------------------------------------------------------------#
# 
#TODO: Unix and Windows path!!!
sub _mergePath
{ 
	my ($self,$path,$bin) = @_;
	my $result = '';
	if (defined $path && defined $bin)
	{
		$result = $path;
		if ($result !~ /\/$/)
		{
			$result .= '/';
		}
		if ($bin !~ /^\//)
		{
			$result .= $bin;
		}
		else
		{
			$result .= substr($bin,1);
		}
	}
	elsif (defined $path)
	{
		$result = $path;
	}
	elsif (defined $bin)
	{
		$result = $bin;
	}
	return $result;
}

# taken directly from Bio::Root::RootI
sub _rearrange
{
	my $dummy = shift;
	my $order = shift;

	return @_ unless (substr($_[0]||'',0,1) eq '-');
	push @_,undef unless $#_ %2;
	my %param;
	while( @_ ) {
	(my $key = shift) =~ tr/a-z\055/A-Z/d; #deletes all dashes!
	$param{$key} = shift;
	}
	map { $_ = uc($_) } @$order;
	return @param{@$order};
}

################################################################################

1;

__END__
