#!/usr/local/bin/perl -w

# Only send email if STDIN contains data for the
# email body.  For use with cron jobs which may be
# silent if now work is required.  Also, for this
# purpose, the script has a quiet mode, since output
# may get sent as mail to the cron job owner.

$quiet = 0;
$subject = "";

while ($#ARGV > 0)
{
	$arg = shift;
	if ($arg eq "-q")
	{
		$quiet = 1;
	}
	elsif ($arg eq "-s")
	{
		$subject = shift;
	}
	else
	{
		print "usage: $0 [-q] [-s <subject>] <to-address>\n";
		print "       -q - quiet mode\n";
		print "       -s - mail subject\n";
		die "\n";
	}
}

$to = shift;

$line = <STDIN>;

if (defined($line) && $line ne "")
{
	open(MAIL, "| mailx -s \"" . $subject . "\" " . $to);

	print MAIL $line;
	while (<STDIN>)
	{
		print MAIL;
	}
}
elsif (!$quiet)
{
	print "Empty input.  No mail sent.\n";
}

