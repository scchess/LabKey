package Pipe::Convert;

use strict;
use URI::Escape;

use Pipe::Params;
use Pipe::Utils;

BEGIN
{
	use Exporter;

	@Pipe::Convert::ISA       = qw(Exporter);
	@Pipe::Convert::EXPORT    = qw(startConversion
					getConversionStatus);
	@Pipe::Convert::EXPORT_OK = qw();
}

#-----------------------------------------------------------------#
# startConversion(<server>,<raw path>,<xml path>,<type>,
#			<status file>,<log file>,<extra params>)
#	Starts conversion of .raw to .mzXML.

sub startConversion
{
	my $server = shift();
	my $rawPath = shift();
	my $xmlPath = shift();
	my $type = shift();
	my $statusFile = shift();
	my $logFile = shift();
	my %params = @_;

	my $status = "REQUESTING";

	# Tell conversion server to handle it.

	my $convertUrl = $convertProtocol . "://" . $server .
			"/ConversionQueue/ConvertSpectrum/submit.post" .
			"?type=" . $type .
			"&infile=" . uri_escape(getSitePath($rawPath,'XS')) .
			"&outfile=" . uri_escape(getSitePath($xmlPath,'XS'));

	my $key;
	foreach $key (keys(%params))
	{
		$convertUrl .= "&" . $key . "=" . uri_escape($params{$key});
	}

	my $response = makeRequest($convertUrl, $logFile);
	if ($response->is_success)
	{
		my $content = $response->content();
		$content =~ s/^\s*(\S.*)\s*/$1/;
		if ($content eq "Pending")
		{
			$status = "CONVERTING";
			setStatus($statusFile, $status);
			writeLog($logFile, "LOG: Converting from raw $rawPath.\n", 2);
		}
		elsif ($content eq "Succeeded")
		{
			$status = getConversionStatus($server,
						$rawPath,
						$statusFile,
						$logFile);
		}
		else
		{
			$status = "ERROR";
			setStatus($statusFile, $status, "type=convert");
			writeLog($logFile, "ERROR: Bad submit for convert request:\n" .
				$content . "\n");
		}
	}

	return $status;
}

#-----------------------------------------------------------------#
# getConversionStatus(<server>,<raw path>,<log file>)
#	Returns status of an in-progress conversion.

sub getConversionStatus
{
	my $server = shift();
	my $rawPath = shift();
	my $statusFile = shift();
	my $logFile = shift();

	my $status = "CONVERTING";

	writeLog($logFile, "LOG: Checking conversion status for $rawPath\n", 2);

	my $site_rawPath = uri_escape(getSitePath($rawPath,'XS'));
	my $statusUrl = $convertProtocol . "://" . $server .
			"/ConversionQueue/ConvertSpectrum/status.view" .
			"?infile=" . $site_rawPath;

	my $response = makeRequest($statusUrl, $logFile);
	if ($response->is_success)
	{
		my $content = $response->content();
		$content =~ s/^\s*(\S.*)\s*/$1/;
		if ($content eq "Succeeded")
		{
			my $ackUrl = $convertProtocol . "://" . $server .
					"/ConversionQueue/ConvertSpectrum/acknowledge.post" .
					"?infile=" . $site_rawPath;
			$response = makeRequest($ackUrl, $logFile);
			if ($response->is_success)
			{
				$content = $response->content();
				$content =~ s/^\s*(\S.*)\s*/$1/;
				if ($content eq "Acknowledged" || $content eq "Unknown")
				{
					# Ready to start analysis.
					# NOTE: Unknown is treated like Acknowledged, since
					#       the most likely cause is the server being
					#       restarted before the acknowledgement could
					#       happen.

					$status = "CONVERTED";
					setStatus($statusFile, $status);
				}
				else
				{
					writeLog($logFile, "ERROR: Acknowledge failed:\n" .
						$content . "\n");
				}
			}
		}
		elsif ($content eq "Unknown" || $content eq "Failed")
		{
			writeLog($logFile, "ERROR: Convert request failed to complete.\n");
			$status = "ERROR";
			setStatus($statusFile, $status, "type=convert");
		}
		elsif ($content ne "Pending")
		{
			writeLog($logFile, "ERROR: Bad status for convert request:\n" .
				$content . "\n");
		}
	}

	return $status;
}

1;
