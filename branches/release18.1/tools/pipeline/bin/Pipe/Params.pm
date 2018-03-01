package Pipe::Params;

use strict;
use Getopt::Long;
use File::Basename;

use Pipe::TandemUtils;

BEGIN
{
	use Exporter;

	@Pipe::Params::ISA       = qw(Exporter);
	@Pipe::Params::EXPORT    = qw(loadParams

					$DEBUG
					$dirRoot
					$queueName
					$convertProtocol
					$convertServer
					$webProtocol
					$webServer
					$convertServerSamba
					$webServerSamba
					$smbaRoot
					$unixRoot
					$fastaRoot
					$subdirWork
					$pruneLevel
					$pruneName
					$webContainerLevel
					$webContainerDepth
					$webContainerRoot
					$webContainerCurrent
					$webWarRoot
					$minProphetDefault
					$loopTime
					$testCluster
					$clusterFailureEmail
					$infinite
					$scheduler
					$schedulerI);
	@Pipe::Params::EXPORT_OK = qw();
}


#
# Default values
#

our $DEBUG = 0;

our $dirRoot = "";
our $queueName = "";
our $convertProtocol = "http";
our $convertServer = "";
our $webProtocol = "http";
our $webServer = "";
our $smbaRoot = "T:";
our $unixRoot = "/home";
# added the next two flags for scenarios that
# the web server sits on a unix platform 
# or the convert server sits on a unix platform,
# i.e. not using samba
our $webServerSamba = 1;
our $convertServerSamba = 1;
our $fastaRoot = "/data/databases";
our $subdirWork = 0;

our $pruneLevel = -1;
our $pruneName = "";
our $webContainerLevel = -1;
our $webContainerDepth = 1;
our $webContainerRoot = "";
our $webContainerCurrent = "";
our $webWarRoot = "/labkey";

our $minProphetDefault = "0.05";

our $loopTime = 60;
our $infinite = 0;
our $testCluster = 0;
our $clusterFailureEmail = '';

our $scheduler = 'Torque';
our $schedulerI = undef;

#-----------------------------------------------------------------#
# printUsage
#	Prints a usage banner, and quits.

sub printUsage
{
	my $cmd_name;
	($cmd_name) = fileparse($0);

	die "Usage: $cmd_name [options] <search dir>\n" .
		"	- search dir - directory to scan\n" .
		"	--r=<pipeline root folder> - Path to folder with pipeline root setting\n" .
		"		on destination web site\n" .
		"\n  debug: \n" .
		"	--v - verbose (add multiple to increase output)\n" .
		"	--i - infinite loop\n" .
		"	--t=<loop time> - sleep time between pipeline checks (0 = no loop)\n" .
		"\n  overrides (usually specified in params.xml):\n" .
		"	--scheduler=<scheduler> - cluster scheduler to use\n" .
		"		(supports: Torque and SGE)\n" .
		"	--q=<queue name> - queue name for cluster jobs\n" .
		"	--sd - subdirectory of analysis directory used for working files\n" .
		"	--x=<xml server> - conversion server for RAW to mzXML\n" .
		"	--xp=<xml protocol> - http or https protocol for conversion server\n" .
		"	--xx - conversion server is running Unix\n" .
		"	--w=<web server> - Web server for data upload\n" .
		"	--wp=<web protocol> - http or https for web server.\n" .
		"	--wc=<web context path> - e.g. /labkey, /CPAS or /cpas.\n" .
		"	--wx - web server is running Unix\n" .
		"	--sprefix=<source prefix> - path prefix to files on the scheduler\n" .
		"	--dprefix=<destination prefix> - path prefix to files on destination\n" .
		"		servers running Windows\n" .
		"	--f=<fasta root> - root for relative path FASTA files\n" .
		"\n  legacy parameters:\n" .
		"	--c=<container level> - Level in path to find container subfolder\n" .
		"	--d=<container depth> - folder names to add to container (default 1)\n" .
		"	--l=<prune level> - directory tree level at which to prune\n" .
		"	--p=<prune name> - prune if name does not exist at specified level\n" .
		"";
}

#-----------------------------------------------------------------#
# loadParams(<local-params file>)
#	Loads parameter global values from program arguments.

sub loadParams
{
	my $paramFile = shift();

	loadParamsXML($paramFile,
		"admin email"                => \$clusterFailureEmail,
		"scheduler"                  => \$scheduler,
		"scheduler queue"            => \$queueName,
		"work local!"                => \$subdirWork,
		"conversion protocol"        => \$convertProtocol,
		"conversion server"          => \$convertServer,
		"conversion server windows!" => \$convertServerSamba,
		"labkey protocol"            => \$webProtocol,
		"labkey server"              => \$webServer,
		"labkey context path"        => \$webWarRoot,
		"labkey server windows!"     => \$webServerSamba,
		"unix path prefix"           => \$unixRoot,
		"windows path prefix"        => \$smbaRoot,
		"fasta root path"            => \$fastaRoot,
	);

	my $convertServerUnix = 0;
	my $webServerUnix = 0;
	my $ret = GetOptions(
		"h|?!"                   => sub{ printUsage() ; exit 0 },
	#	"V!"                     => sub{ printVersionInfo() ; exit 0 },
		"v+"                     => \$DEBUG,
		"q|queue=s"              => \$queueName,
		"x|xml-converter=s"      => \$convertServer,
		"xp|xml-protocol=s"      => \$convertProtocol,
		"xx|xml-converter-samba!"=> \$convertServerUnix,
		"w|web-server=s"         => \$webServer,
		"wp|web-protocol=s"      => \$webProtocol,
		"wc|web-cpath=s"         => \$webWarRoot,
		"wx|web-server-samba!"   => \$webServerUnix,
		"dprefix=s"              => \$smbaRoot,
		"sprefix=s"              => \$unixRoot,
		"f|fasta-root=s"         => \$fastaRoot,
		"r|container-root=s"     => \$webContainerRoot,
		"c|container-level=i"    => \$webContainerLevel,
		"d|container-depth=i"    => \$webContainerDepth,
		"l|prune-level=i"        => \$pruneLevel,
		"p|prune-name=s"         => \$pruneName,
		"t|loop-time=i"          => \$loopTime,
		"i|infinite!"            => \$infinite,
		"sc|scheduler=s"         => \$scheduler,
		"sd|subdir!"             => \$subdirWork,
		"tc|test-cluster!"       => \$testCluster,
	);
	$convertServerSamba = 0 if $convertServerUnix;
	$webServerSamba = 0 if $webServerUnix;

	$dirRoot = shift(@ARGV);

	if ($ret == 0 || !defined($dirRoot))
	{
		printUsage();
	}

	$dirRoot .= '/' unless $dirRoot =~ /\/$/;
	$unixRoot = $dirRoot if ($unixRoot eq "" && ($webServerSamba || $convertServerSamba));
	$fastaRoot .= '/' unless $fastaRoot =~ /\/$/;

	if ($webServer ne "")
	{
		if ($webServerSamba && ($smbaRoot eq "" || $unixRoot eq ""))
		{
			print "ERROR: Web server require --s and --u parameters unless --nows.\n";
			printUsage();
		}
	}

	if ($convertServer ne "")
	{
		if ($convertServerSamba && ($smbaRoot eq "" || $unixRoot eq ""))
		{
			print "ERROR: Convert server require --s and --u parameters unless -noxs.\n";
			printUsage();
		}
	}
}

sub loadParamsXML
{
	my $paramFile = shift();
	my %paramsMap = @_;
	my %paramsLocal = loadTandemInputXML($paramFile);
	
	my $key;
	foreach $key (sort(keys(%paramsMap)))
	{
		my $keyLocal = $key;
		$keyLocal =~ s/!$//;
		$keyLocal = "pipeline config, " . $keyLocal;

		my $val = $paramsLocal{$keyLocal};

		next if (!defined($val));

		if ($key !~ /!$/)
		{	${$paramsMap{$key}} = $val; }
		elsif ($val =~ /yes/i)
		{	${$paramsMap{$key}} = 1; }
		elsif ($val =~ /no/i)
		{	${paramsMap{$key}} = 0; }
		else
		{
			print "ERROR: The parameter '" . $keyLocal . "' must be either yes or no.\n";
		}
	}
}

1;
