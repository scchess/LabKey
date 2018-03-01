package Pipe::Scheduler::SchedulerFactory;
use strict;

################################################################################
# TODO:
#   1. implement POD to remove separate documentation and easier documentation
# NOTE:
#   1. This code is implemented by Chee Hong Wong.
#   2. New scheduler is to sit in Pipe::Scheduler folder and 
#      implement Pipe::SchedulerI
#   3. SchedulerFactory can get an instance of specified scheduler
################################################################################

################################################################################

# Title   : getScheduler
# Usage   : my $schedulerTorque = 
#               Pipe::Scheduler::SchedulerFactory->getScheduler('Torque');
#           my $schedulerSGE = 
#               Pipe::Scheduler::SchedulerFactory->getScheduler('SGE');
# Function: Returns the specified scheduler
# Returns : scheduler object implemented Pipe::SchedulerI
# Status  : Public

sub getScheduler {
	my $self = shift;
	my $schedulerName = shift;

	die "Please specify the scheduler that you wish to use!\n" if (!defined $schedulerName);

	my $class = ref $self || $self;
	$class =~ s/(::){0,1}\w+$/$1$schedulerName/;

	my $pmLocation = $class;
	$pmLocation =~ s/::/\//g;
	$pmLocation .= '.pm';

	require $pmLocation;
	return $class->new(@_);
}

################################################################################

1;

__END__
