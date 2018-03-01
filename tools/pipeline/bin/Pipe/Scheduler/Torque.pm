package Pipe::Scheduler::Torque;
use vars qw(@ISA);
use strict;

use File::Basename;
use Pipe::Scheduler::SchedulerBase;

@ISA = qw(Pipe::Scheduler::SchedulerBase);

################################################################################
# TODO:
#   1. implement POD to remove separate documentation and easier documentation
# NOTE:
#   1. This code is refactored from Pipe::Torque by Brendan MacLean and 
#      adapted to Pipe::Scheduler::SchedulerBase by Chee Hong Wong 
#   2. Essentially, it is contained code specific to Torque
################################################################################


################################################################################

# Title   : new
# Usage   : my $scheduler = new Pipe::Scheduler::Torque();
# Function: Returns the object for Torque scheduler which implement SchedulerI
# Returns : Torque object that CPAS cluster-pipeline can use
# Status  : n.a.

sub new {
	my($class,@args) = @_;
	my ($jobtmpdir, $jobnodefile, $jobpath, $jobscripext, $joboutputext, 
		$clusterbinpath, $submissionbin, $querybin, $binpath, $nodesmax, $nodeclass,
		$testcluster, $clusterfailureemail, $debuglevel) 
    	= $class->_rearrange([qw(JOBTMPDIR JOBNODEFILE JOBPATH JOBSCRIPTEXT JOBOUTPUTEXT 
    		CLUSTERBINPATH SUBMISSIONBIN QUERYBIN BINPATH NODESMAX NODECLASS
    		TESTCLUSTER CLUSTERFAILUREEMAIL DEBUGLEVEL)], @args);
	push @args, ('-JOBTMPDIR', 'TMPDIR') if (!defined $jobtmpdir);
	push @args, ('-JOBNODEFILE', 'PBS_NODEFILE') if (!defined $jobnodefile);
	push @args, ('-JOBPATH', 'PBS_O_WORKDIR') if (!defined $jobpath);
	push @args, ('-JOBSCRIPTEXT', '.pbs') if (!defined $jobscripext);
	push @args, ('-JOBOUTPUTEXT', '.out') if (!defined $joboutputext);
	push @args, ('-SUBMISSIONBIN', 'qsub') if (!defined $submissionbin);
	push @args, ('-QUERYBIN', 'qstat') if (!defined $querybin);
	push @args, ('-BINPATH', dirname($0).':/usr/local/bin:/opt/pvm3/3.4.4/bin/LINUX') if (!defined $binpath);
	push @args, ('-DEBUGLEVEL', 0) if (!defined $debuglevel);

	my $self = $class->SUPER::new(@args);

	$nodesmax = 0 if (!defined $nodesmax);
	$nodeclass = 'comet' if (!defined $nodeclass);
	$testcluster = 0 if (!defined $testcluster);
	$self->nodesmax($nodesmax);
	$self->nodeclass($nodeclass);
	$self->testcluster($testcluster);

	return $self;
}


################################################################################
# INTERFACE
################################################################################

#-----------------------------------------------------------------#
# getJobTempdir()
#	Returns temp directory local to running cluster node.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub getJobTempdir

#-----------------------------------------------------------------#
# getJobNodeFile()
#	Returns a path to a file containing the list of nodes
#	to use for this job.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub getJobNodeFile

#-----------------------------------------------------------------#
# getJobPath(<path>)
#	Returns path usable in running cluster node script.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub getJobPath

#-----------------------------------------------------------------#
# isJobRunning(<jobid>[,<jobid>]*[,<log file>])
#	Tells if a job(s) running by calling qstat.
#	0 = not running, 1 = running, -1 = unknown
#	provided by Pipe::SchedulerI::SchedulerBase
#sub isJobRunning

# Pipe::SchedulerI::SchedulerBase called to get the list of 
#     running jobs's id based on Torque output
sub getRunningJobs
{
	my $self = shift;
	
	if (!open(QSTAT, $self->querybinfullpath().' 2>&1 |'))
	{
		$self->server_error(1);
	}
	else
	{
		my $firstLine = <QSTAT>;
		if (defined($firstLine) && $firstLine ne "")
		{
			$self->server_error(1) if ($firstLine !~ /^Job id/);
		}

		while (<QSTAT>)
		{
			$self->updateJobStatus($1, $_) if (/^(\d+\.\w+)/);
		}
	}
	close(QSTAT);
}

#-----------------------------------------------------------------#
# resetJobStatus()
#	Resets the cached set of running jobs.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub resetJobStatus

#-------------------------------------------------------------------#
# submitJobScript(<directory>,<name>,<nodes>,<script text>,<log file>,<jobs>)
#	Writes a torque script, and submits it to the torque queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitJobScript

#-------------------------------------------------------------------#
# submitJobScriptEx(<directory>,<name>,<queue>,<nodes>,<script text>,<log file>,<jobs>)
#	Writes a torque script, and submits it to the torque queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitJobScriptEx

#-------------------------------------------------------------------#
# submitPerlJobScriptEx(<directory>,<name>,<queue>,<nodes>,<script text>,<log file>,<jobs>)
#	Writes an sge script, and submits it to the sge queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitPerlJobScriptEx

#-------------------------------------------------------------------#
# submitJob(<name>,<script file>,<log file>,<jobs>)
#	Submits a job to the torque queue, and returns the jobid.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitJob

# Pipe::SchedulerI::SchedulerBase called to get specification on 
#     dependent jobs for Torque specification
sub createJobDependencies
{
	my $self = shift;
	my @jobs = @_;
	my $dependencies = '';

	if ($#jobs >= 0)
	{
		$dependencies .= " -W depend=";
		foreach my $jobid (@jobs)
		{
			$dependencies .= "afterok:" . $jobid . ",";
		}
		chop($dependencies);
	}

	return $dependencies;
}

# Pipe::SchedulerI::SchedulerBase called to get the job id 
#     based on Torque output
sub getSubmissionJobId
{
	my $self = shift;
	my $status = shift;
	#well, we are lucky, the line contains just the job id 
	return $status;
}

#-------------------------------------------------------------------#
# writeJobScript(<directory>,<name>,<queue>,<nodes>,<shell path>,
#			<script text>,<log file>)
#	Writes a torque script for submission to the queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub writeJobScript

# Pipe::SchedulerI::SchedulerBase called to get script header for Torque specfication
sub getScriptHeader
{
	my($self,@args) = @_;
	my ($dir, $shellpath, $queue, $nodes, $walltime, $outFile) 
		= $self->_rearrange([qw(DIR SHELLPATH QUEUE NODES WALLTIME OUTPUT)], @args);

	$nodes = $self->nodesmax() if ($self->nodesmax()>0 && $nodes>$self->nodesmax());

	my $sniplet = '';
	$sniplet .= "# BEGIN SCRIPT\n";
	$sniplet .= "#PBS -q " . $queue . "\n";
	$sniplet .= "#PBS -l nodes=" . $nodes;
	$sniplet .= ":" . $self->nodeclass() if ($self->nodeclass() ne '');
	$sniplet .= "\n";
	if (defined($walltime))
	{	$sniplet .= "#PBS -l walltime=" . $walltime . "\n"; }
	#uncomment the next line to prevent run away job if we are not sure of the script
	#$sniplet .= "#PBS -l walltime=06:00:00\n";
	if ($self->testcluster())
	{	$sniplet .= "#PBS -W x=FLAGS:ADVRES:cptest.45\n"; }
	else
	{	$sniplet .= "#PBS -W x=NODESET:ONEOF:FEATURE\n"; }
	$sniplet .= "#PBS -m a\n";
	$sniplet .= "#PBS -M " . $self->clusterfailureemail() . "\n"
		if ($self->clusterfailureemail() ne '') && (3==$self->debuglevel());
	$sniplet .= "#PBS -S " . $shellpath . "\n";
	$sniplet .= "#PBS -j oe\n";
	$sniplet .= "#PBS -o " . $outFile . "\n";

	$sniplet .= "set -x\n" if (1==$self->debuglevel());
	$sniplet .= "umask 0002\n";
	$sniplet .= "PATH=" . $self->binpath() .":\${PATH}\n" if ($self->binpath() ne '');
	$sniplet .= "\n";
	$sniplet .= "cd " . $self->getJobPath($dir) . " || exit \$?\n";
	
	return $sniplet;
}

# Pipe::SchedulerI::SchedulerBase called to get script footer for Torque specfication
sub getScriptFooter
{
	my $self = shift;
	return "# END SCRIPT\n";
}

#-------------------------------------------------------------------#
# publishOutput(<directory>,<error>,<basename>[,<name list>])
#	Sets less restrictive permissions on job output files.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub publishOutput

################################################################################
# ACCESSORY
################################################################################

sub nodesmax { 
	my ($self,$value) = @_; 
	$self->{'nodesmax'} = $value if( defined $value);
	return $self->{'nodesmax'}; 
}

sub nodeclass { 
	my ($self,$value) = @_; 
	$self->{'nodeclass'} = $value if( defined $value);
	return $self->{'nodeclass'}; 
}

sub testcluster { 
	my ($self,$value) = @_; 
	$self->{'testcluster'} = $value if( defined $value);
	return $self->{'testcluster'}; 
}

################################################################################

1;

__END__
