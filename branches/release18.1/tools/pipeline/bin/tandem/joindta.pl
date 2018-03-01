#!/usr/bin/perl -w

use Getopt::Long;

$prophetMin = 0.0;
$labelType = 0; # 1 - dta name only, 2 - dta name and prophet score
$rmdir = 0;

$ret = GetOptions(
	"h|?!"                => sub{ subUsage() ; exit 0 },
	"m|min=f"             => \$prophetMin,
	"l|label=i"           => \$labelType,
);

sub subUsage {
	print "usage: $0 [--m=<prophet-minimum>] [--l=<label-type>]\n";
	print "                          <pathname> [<output-file>]\n";
	print "       - prophet-minimum - read prophet data, and exclude entries\n";
	print "                           with scores below this value\n";
	print "       - label-type - 1: dta name only, 2: dta name & prophet score\n";
	print "       - pathname - path to either directory or tar.gz with dta files\n";
	print "       - output-file - file path for output\n";
}

if ( $ret == 0 )
{
	print "ERROR: Unknown arguments specified\n" ;
	subUsage();
	exit -1;
}

$dir = shift;
if (!defined($dir))
{
	subUsage();
	exit -1;
}
$outfile = shift;

$prophetFile = $dir . '/../prophet.htm.prob';

if (-f $dir)
{
	die "Invalid filename $dir.\n" if ($dir !~ /\.tar\.gz$/);

	$basename = $dir;
	$basename =~ s/\.tar\.gz$//;

	mkdir($basename);
	system("cp", $dir, $basename);
	chdir($basename);
	system("gunzip", $dir);
	system("tar", "xf", $basename . ".tar");
	chdir("..");

	$rmdir = 1;
	$dir = $basename;
 	if (!defined($outfile))
	{
		$outfile = $basename . ".dta";
	}

	$prophetFile = "prophet.htm.prob";
	if (!-f $prophetFile)
	{
		$basename =~ s/\.[^.]+$//;
		$prophetFile = "prophet_" . $basename . ".htm.prob";
	}
}

opendir(DIR, $dir) || die "Unable to open directory $dir\n";
@files = sort(grep(/\.dta$/, readdir(DIR)));
closedir(DIR);

if ($prophetMin != 0.0 || $labelType == 2)
{
	if (open(PROPH, $prophetFile))
	{
		while(<PROPH>)
		{
			if (/^([^\.]+\.\d{4,6}\.\d{4,6}\.\d)\.\d\s+([0-9\.e-]+)/)
			{
				next if ($prophetMin != 0.0 && $2 < $prophetMin);

				$prophetMap{$1 . '.dta'} = $2;
			}
		}

		if (!defined(%prophetMap))
		{
			die "ERROR: No matching prophet entries found.\n";
		}
	}
	else
	{
		die "ERROR: $prophetFile not found.\n";
	}
}

$added = 0;
if (!defined($outfile))
{
	$outfile = "all.dta";
}
open(OUT, ">$outfile") || die "Unable to open output file $outfile\n";

foreach $file (@files)
{
	next if ($file eq $outfile);

	next if ($prophetMin != 0.0 && !$prophetMap{$file});

	# Get comet info if present
	$peptide = "";
	$protein = "";

	$fileCmt = $file;
	$fileCmt =~ s/\.dta/.cmt/;
	if (open(CMT, $fileCmt))
	{
		while (<CMT>)
		{
			chomp;
			if (/^[- ]+$/)
			{
				$first = <CMT>;
				chomp($first);
				@matchValues = split(/\s+/, $first);
				$peptide = $matchValues[8];
				$protein = $matchValues[10];
				last;
			}
		}
		close(CMT);
	}

#	print "Adding $file";
#	print " ";
#	if (defined(%prophetMap))
#	{
#		print $prophetMap{$file};
#		print " ";
#	}
#	print $peptide;
#	print " ";
#	print $protein;
#	print "\n";

	open(IN, $dir . "/" . $file) ||
		die "Unable to open input file $file\n";

	$first = 1;
	while (<IN>)
	{
		if ($first)
		{
			chomp;
			print OUT;
			if ($labelType > 0)
			{
				print OUT " " . $file;
			}
			if ($labelType > 1)
			{
				if (defined($prophetMap{$file}))
				{
					print OUT " (" . $prophetMap{$file} . ")";
				}
				else
				{
					print "WARNING: $file missing prophet data.\n";
				}
			}
			print OUT "\n";
			$first = 0;
		}
		else
		{
			print OUT;
		}
	}

	close(IN);

	print OUT "\n";

	$added++;
}

close(OUT);

system("rm", "-r", $dir) if ($rmdir);

print "Added $added files\n";

