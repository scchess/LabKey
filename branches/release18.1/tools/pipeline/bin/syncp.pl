#!/usr/bin/perl -w

# syncp.pl
#	Synchronized copy program for use when copying data from
#	central storage to a cluster node, or vice versa.

use strict;
use File::Basename;
use Cwd;
use Fcntl qw(:DEFAULT :flock);

use lib Cwd::abs_path(dirname($0));

use Pipe::Utils;

my $lockCount = 5;

my $lockDir = Cwd::abs_path(dirname($0));
$lockDir .= "/" if ($lockDir !~ /\/$/);
$lockDir .= "syncp-locks/";

#
# First get and increment the counter value.
#

print getTimeStamp() . " : Getting lock counter\n";

sysopen(COUNT, $lockDir . "counter", O_RDWR | O_CREAT)
	|| die "Failed to open counter file: $!";

# try to get the lock for up to 5 minutes.
my $sec;
for ($sec = 0; $sec < 300; $sec += 5)
{
	last if flock(COUNT, LOCK_EX);

	sleep(5);
}

if ($sec >= 300)
{	die "Failed to write-lock counter file: $!"; }

my $counter = <COUNT> || -1;  # first time would be undef
$counter = ($counter + 1) % $lockCount;

seek(COUNT, 0, 0)
	|| die "Failed to rewind counter file : $!";
print COUNT $counter, "\n"
	|| die "Failed to write counter file: $!";

# next line technically superfluous in this program, but
# a good idea in the general case
truncate(COUNT, tell(COUNT))
	|| die "can't truncate counterfile: $!";
close(COUNT);


#
# Then wait for the lock indicated by the counter.
#

print getTimeStamp() . " : Acquiring lock $counter\n";

my $lockFile = $lockDir . "lock" . $counter;

sysopen(L_FILE, $lockFile, O_RDWR | O_CREAT)   
	|| die "Failed to open $lockFile: $!";

# try to get the lock for up to 5 minutes.
for ($sec = 0; $sec < 300; $sec += 5)
{
	last if flock(L_FILE, LOCK_EX);

	sleep(5);
}

if ($sec >= 300)
{	die "Failed to lock $lockFile: $!"; }

#
# Do the copy inside the lock.
#


my $source;
my $dest = pop();

while ($source = shift())
{
	print getTimeStamp() . " : cp $source $dest\n";

	my $ret = system("cp", $source, $dest);
	if ($ret != 0)
	{
		die "Failed copying $source to $dest";
	}
}

close(L_FILE);

print getTimeStamp() . " : complete\n";

