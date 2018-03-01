package Pipe::Scheduler::SGE;
use vars qw(@ISA);
use strict;

use File::Basename;
use Pipe::Scheduler::SchedulerBase;

@ISA = qw(Pipe::Scheduler::SchedulerBase);

################################################################################
# TODO:
#   1. implement POD to remove separate documentation and easier documentation
# NOTE:
#   1. This code is refactored from Pipe::Sge by Sum Thai Wong and 
#      adapted to Pipe::Scheduler::SchedulerBase by Chee Hong Wong 
#   2. Essentially, it is contained code specific to SGE
################################################################################


################################################################################

# Title   : new
# Usage   : my $scheduler = new Pipe::Scheduler::SGE();
# Function: Returns the object for SGE scheduler which implement SchedulerI
# Returns : SGE object that CPAS cluster-pipeline can use
# Status  : n.a.

sub new {
	my($class,@args) = @_;
	my ($jobtmpdir, $jobnodefile, $jobpath, $jobscripext, $joboutputext, 
		$clusterbinpath, $submissionbin, $querybin, $binpath, $nodesmax,
		$clusterfailureemail, $debuglevel) 
    	= $class->_rearrange([qw(JOBTMPDIR JOBNODEFILE JOBPATH JOBSCRIPTEXT JOBOUTPUTEXT 
    		CLUSTERBINPATH SUBMISSIONBIN QUERYBIN BINPATH NODESMAX
    		CLUSTERFAILUREEMAIL DEBUGLEVEL)], @args);
	push @args, ('-JOBTMPDIR', 'TMPDIR') if (!defined $jobtmpdir);
	# TODO: NOTE that environment var $PE_HOSTFILE has not been tested
	push @args, ('-JOBNODEFILE', 'PE_HOSTFILE') if (!defined $jobnodefile);
	push @args, ('-JOBPATH', 'SGE_O_WORKDIR') if (!defined $jobpath);
	push @args, ('-JOBSCRIPTEXT', '.sge') if (!defined $jobscripext);
	push @args, ('-JOBOUTPUTEXT', '.out') if (!defined $joboutputext);
	push @args, ('-SUBMISSIONBIN', 'qsub') if (!defined $submissionbin);
	push @args, ('-QUERYBIN', 'qstat') if (!defined $querybin);
	push @args, ('-BINPATH', dirname($0)) if (!defined $binpath);
	push @args, ('-DEBUGLEVEL', 0) if (!defined $debuglevel);

	my $self = $class->SUPER::new(@args);

	$nodesmax = 0 if (!defined $nodesmax);
	$self->nodesmax($nodesmax);

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
#	TODO: NOT TESTED YET
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
#     running jobs's id based on SGE output
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
			$self->server_error(1) if ($firstLine !~ /^job-ID/);
		}

		while (<QSTAT>)
		{
			$self->updateJobStatus($1, $_) if (/^\s*(\d+)/);
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
#	Writes an sge script, and submits it to the sge queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitJobScript

#-------------------------------------------------------------------#
# submitJobScriptEx(<directory>,<name>,<queue>,<nodes>,<script text>,<log file>,<jobs>)
#	Writes an sge script, and submits it to the sge queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitJobScriptEx

#-------------------------------------------------------------------#
# submitPerlJobScriptEx(<directory>,<name>,<queue>,<nodes>,<script text>,<log file>,<jobs>)
#	Writes an sge script, and submits it to the sge queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitPerlJobScriptEx

#-------------------------------------------------------------------#
# submitJob(<name>,<script file>,<log file>,<jobs>)
#	Submits a job to the sge queue, and returns the jobid.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub submitJob

# Pipe::SchedulerI::SchedulerBase called to get specification on 
#     dependent jobs for SGE specification
sub createJobDependencies
{
	my $self = shift;
	my @jobs = @_;
	my $dependencies = '';
	
	if ($#jobs >= 0)
	{
		$dependencies = "-hold_jid " . join(",", @jobs);
	}
	
	return $dependencies;
}

# Pipe::SchedulerI::SchedulerBase called to get the job id 
#     based on SGE output
sub getSubmissionJobId
{
	my $self = shift;
	my $status = shift;
	
	#parse the job id
	my $jobid_out;
	if (defined $status)
	{
		if ($status =~ / (\d+) /) {
			$jobid_out = $1;
		}
	}
	return $jobid_out;
}

#-------------------------------------------------------------------#
# writeJobScript(<directory>,<name>,<queue>,<nodes>,<shell path>,
#			<script text>,<log file>)
#	Writes a sge script for submission to the queue.
#	provided by Pipe::SchedulerI::SchedulerBase
#sub writeJobScript

# Pipe::SchedulerI::SchedulerBase called to get script header for SGE specfication
sub getScriptHeader
{
	my($self,@args) = @_;
	my ($dir, $shellpath, $queue, $nodes, $outFile) 
		= $self->_rearrange([qw(DIR SHELLPATH QUEUE NODES OUTPUT)], @args);

	$nodes = $self->nodesmax() if ($self->nodesmax()>0 && $nodes>$self->nodesmax());

	# wst: 
	#  1. resource constraints corresponding to the number of nodes to be used is yet to be added 
	#  1. the testcluster block is also not included (BUT we do not need it)
	my $sniplet = '';
	$sniplet .= "#! /bin/sh\n\n";
	$sniplet .= "#\$ -q " . $queue . "\n"	# name of queue to use
		if (defined $queue);
	$sniplet .= "#\$ -m a\n";			# mail to be sent when job is aborted
	$sniplet .= "#\$ -M " . $self->clusterfailureemail() . "\n" 
		if ($self->clusterfailureemail() ne '') && (3==$self->debuglevel());
	$sniplet .= "#\$ -S " . $shellpath . "\n"; # specify shell
	$sniplet .= "#\$ -j y\n";			# standard error to be merged into standard output
	$sniplet .= "#\$ -o ". $outFile. "\n";	# filepath of standard output stream
	#uncomment the next 2 lines for debugging purposes
	#$sniplet .= "#\$ -cwd\n";			# output is to be created in current working directory
	#$sniplet .= "#\$ -V\n";			# export all environment variables to context of job

	$sniplet .= "set -x\n" if (1==$self->debuglevel());
	$sniplet .= "umask 0002\n";
	$sniplet .= "PATH=" . $self->binpath() .":\${PATH}\n" if ($self->binpath() ne '');
	$sniplet .= "\n";
	$sniplet .= "cd " . $self->getJobPath($dir) . " || exit \$?\n";
	
	return $sniplet;
}

# default implementation to get the job script filepath
# scheduler can override this method to provide own version
sub getJobScriptFile
{
	my $self = shift;
	my $dir = shift;
	my $name = shift;
	
	my $filename = $self->_mergePath($dir,'SGE.'.$name);
	$filename .= $self->jobscriptext();
	return $filename;
}

# Pipe::SchedulerI::SchedulerBase called to get script footer for SGE specfication
sub getScriptFooter
{
	my $self = shift;
	# SGE has not script end demarkation
	return '';
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

################################################################################

1;

__END__
