#! perl

BEGIN {
	push  (@INC, "c:/perl/lib/");
}

use Net::FTP;

#$ftp = Net::FTP->new("ftp.cpan.org", Debug => 0);
#$ftp->login("anonymous",'from@here');
#$ftp->cwd("/pub/CPAN");
#$ftp->get("README");
#$ftp->quit;
#open(MYFILE, "README");
#while(<MYFILE>) {
#	print $_;
#} 

$ftp = Net::FTP->new("ftp.bdfi.net", Debug => 1)
 or die "Cannot connect to some.host.name: $@";

$ftp->login("bdfi",'clashBDFI')
 or die "Cannot login ", $ftp->message;

$ftp->cwd("/www")
 or die "Cannot change working directory ", $ftp->message;

$ftp->get("special.php")
 or die "get failed ", $ftp->message;

$ftp->quit;

open(MYFILE, "special.php");
while(<MYFILE>) {
	print $_;
} 

