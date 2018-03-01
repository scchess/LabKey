package Pipe::SchedulerI;
use strict;
use Carp 'confess','carp';

################################################################################
# TODO:
#   1. implement POD to remove separate documentation and easier documentation
# NOTE:
#   1. This code is refactored by Chee Hong Wong 
#      from Pipe::Torque by Brendan MacLean and Pipe::Sge by Sum Thai Wong.
#   2. Essentially, it is Pipe::Torque with its implemented changed to 
#      enforce implementation by derived class.
#   3. It defines the interface that Scheduler has to implement
#      so that the pipeline can make sure of other scheduler 
#      without code change to the analysis pipeline.
################################################################################


################################################################################

# Title   : new
# Usage   : my $schedulerI = new Pipe::SchedulerI();
# Function: Returns the SchedulerI object
# Returns : SchedulerI object that has die 
#           if the specified interface is not implemented
# Status  : Not meant to be instantiated directly.

sub new {
	my($class,@args) = @_;
	my $self = {};
	bless $self, ref($class) || $class;
	return $self;
}

################################################################################
# INTERFACE
################################################################################

# Implementation Specific Functions
# These functions are the ones that a specific implementation must
# define.
# 1) getJobTempdir
# 2) getJobNodeFile
# 3) getJobPath
# 4) isJobRunning
# 5) resetJobStatus
# 7) submitJobScript
# 9) submitJob
# 10) writeJobScript
# 11) publishOutput

#------------------------------------------------------------------------------#

# Title   : getJobTempdir
# Usage   : $jobTempDir = $obj->getJobTempdir();
# Function: Returns temp directory local to running cluster node.
# Returns : <string>
# Status  : Virtual

sub getJobTempdir {
   my ($self) = @_;
   $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : getJobNodeFile
# Usage   : $jobNodeFile = $obj->getJobNodeFile();
# Function: Returns a path to a file containing the list of nodes
#           to use for this job.
# Returns : <string>
# Args    : None
# Status  : Virtual

sub getJobNodeFile{
   my ($self) = @_;
   $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : getJobPath
# Usage   : $jobPath = $obj->getJobPath($path);
# Function: Returns path usable in running cluster node script.
# Returns : <string>
# Args    : <path>
# Status  : Virtual

sub getJobPath {
   my ($self) = @_;
   $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : isJobRunning
# Usage   : my $runState = $obj->isJobRunning ($jobId, $logFile)
#           my $runState2 = $obj->isJobRunning (
#                               $jobId1, $jobId2, ..., 
#                               $logFile)
# Function: Tells if a job(s) running by calling qstat.
# Returns : 0 = not running, 1 = running, -1 = unknown
# Args    : <jobid>[,<jobid>]*,<log file>
# Status  : Virtual

sub isJobRunning {
   my ($self,@args) = @_;
   $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : resetJobStatus
# Usage   : $obj->resetJobStatus();
# Function: Resets the cached set of running jobs.
# Returns : None
# Args    : None
# Status  : Virtual

sub resetJobStatus {
   my ($self,@args) = @_;
   $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : submitJobScript
# Usage   : my $jobId = $obj->submitJobScript(
#                           $analysisDir, $jobname, 
#                           \%jobProps, 
#                           $script, 
#                           $logFile);
#           my $jobId2 = $obj->submitJobScript(
#                           $analysisDir, $jobname, 
#                           \%jobProps, 
#                           $script, 
#                           $logFile);
# Function: Writes a cluster script, and submits it to the cluster queue.
# Returns : <job id>
# Args    : <directory>,<name>,<props>,<script text>,
#           <log file>[,<dependent job>]*
# Status  : Virtual

sub submitJobScript{
    my ( $self ) = @_;
    $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : submitJob
# Usage   : my $jobId = $obj->submitJob($name, $scriptFile, $logFile)
#           my $jobId2 = $obj->submitJob($name, $scriptFile, 
#                           $logFile, @dependentjobs)
# Function: Submits a job to the cluster queue, and returns the jobid.
# Returns : <job id>
# Args    : <name>,<script file>,<log file>[,<dependent job>]*
# Status  : Virtual

sub submitJob{
    my ( $self ) = @_;
    $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : writeJobScript
# Usage   : my $scriptFilePathname = $obj->writeJobScript($dir, $name, 
#                                        $queue, $nodes, 
#                                        "/bin/bash",$script, $logFile);
# Function: Writes a sge script for submission to the queue.
# Returns : <script file pathname>
# Args    : <directory>,<name>,<queue>,<nodes>,<shell path>,
#           <script text>,<log file>
# Status  : Virtual

sub writeJobScript{
    my ( $self ) = @_;
    $self->die_not_implemented();
}

#------------------------------------------------------------------------------#

# Title   : publishOutput
# Usage   : $obj->publishOutput($analysisDir, 
#               0,                            # write success log
#               "all", "prophet");
#           $obj->publishOutput($analysisDir, 
#               1,                            # write error log instead
#               "all", "prophet");
# Function: Sets less restrictive permissions on job output files.
# Returns : None
# Args    : <directory>,<error>,<basename>[,<name>]*
# Status  : Virtual

sub publishOutput{
    my ( $self ) = @_;
    $self->die_not_implemented();
}

################################################################################
# HELPER FUNCTION
################################################################################

#------------------------------------------------------------------------------#

# Purpose : Terminate execution.
#           Intended for use in the method definitions of 
#           abstract interface modules where methods are defined
#           but are intended to be overridden by subclasses.
# Usage   : $object->die_not_implemented();
# Example : sub method_virtual { 
#             $self = shift; 
#             $self->die_not_implemented();
#           }
# Returns : n/a
# Args    : n/a
# Status  : Helper method for virtual method implementation

sub die_not_implemented {
    my $self = shift;
    my $package = ref $self;
    my $iface = caller(0);
    my @call = caller(1);
    my $meth = $call[3];

    my $message = 
        "Abstract method \"$meth\"\n" .
        "\tis not implemented by package \"$package\".\n" .
        "This is not your fault...\n" .
        "\tPlease contact the author of $package\n" .
        "\tto complete the interface binding!\n";
    confess $message ;

    # let's get serious, after all interface should be obeyed
    die "Terminated";
}

################################################################################

1;

__END__

