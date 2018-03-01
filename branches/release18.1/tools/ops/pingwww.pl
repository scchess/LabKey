$status = "OK";
$date = `date`;
chop($date);

# ping server
$res = `wget --server-response --spider http://edi.fhcrc.org/EDI/home.jsp 2>&1 | grep "1 HTTP"`;
if (!($res =~ m/200 OK/)) 
	{ $status = "ERROR"; printf "FAILED /EDI/home.jsp\n"; }

$res = `wget --server-response --spider http://edi.fhcrc.org/EDI/Junit/alive.view 2>&1 | grep "1 HTTP"`;
if (!($res =~ m/200 OK/)) 
	{ $status = "ERROR"; printf "FAILED /EDI/Junit/alive.view\n"; }

# test for status changed
$prevstatus = "OK";
if (-e "status.txt") 
    {chop($prevstatus = `cat status.txt`);}
if ($status eq $prevstatus) 
	{printf "$date status unchanged: $status\n"; exit;}
`echo.exe $status > status.txt`;

# send mail
if ($status == "OK") {$file = "okmail.txt";}
if ($status != "OK") {$file = "errormail.txt";}
$to = `grep To: $file`;
chop($to);
$to = substr($to,4);
$to =~ tr/[;,]/ /;

printf "$date status changed: $status\nsending mail: $to\n";
`ssmtp $to < $file`;
