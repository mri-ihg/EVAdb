########################################################################
# Tim M Strom June 2008
# Institute of Human Genetics
# Helmholtz Zentrum Muenchen
########################################################################

package Solexa;

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;
use XML::Simple;
use DBI;
use Crypt::Eksblowfish::Bcrypt;

my $gapplication   = "ExomeEdit";
my $maindbForLogin = "database=solexa;host=localhost";
my $maindb         = "solexa";
my $exomedb        = "exomehg19";
my $logindb        = "exomevcfe";
my $exomevcfe      = "exomevcfe";
my $text           = "/srv/tools/solexa.txt";
my $text2          = "/srv/tools/textreadonly2.txt"; #yubikey id and api
my $cgidir         = "/cgi-bin/mysql/solexa";
my $noyubikey      = 1;
my $maxFailedLogin = 6;
my $igvport        = ""; #not used
my $user           = ""; 
my $iduser         = ""; 
my $role           = ""; #not used

sub new {
	my $class = shift;
	my $self = {};
	bless $self,$class;
	return $self;
}

########################################################################
# login_succeeded
########################################################################
sub login_succeeded {
my $user         = shift;
my $dbh          = shift;
my $failed_last  = "";

#$dbh->{Profile} = 4;
#$dbh->{LongTruncOk} = 1;
my $query = "SELECT failed_last FROM $logindb.user WHERE name=?";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";
$failed_last = $out->fetchrow_array;

# set login counter in exomehg19.login
if ($failed_last <= $maxFailedLogin) {
	$query = "update $logindb.user
		SET succeeded_all=succeeded_all+1, failed_last=0
		WHERE name=?";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($user) || die print "$DBI::errstr";
}
else {
	printHeader();
	print "Account disabled<br>";
	exit(1);
}

}
########################################################################
# login_failed
########################################################################
sub login_failed {
my $user         = shift;
my $dbh          = shift;
my $failed_last  = "";

my $query = "update $logindb.user
	SET failed_all=failed_all+1, failed_last=failed_last+1
	WHERE name=?";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";

}
########################################################################
# create sessionid
########################################################################

sub createSessionId {
my $self      = shift;
my $ref       = shift;
my $user      = $ref->{name};
my $password  = $ref->{password};
my $otp       = $ref->{yubikey};
my $yubikeyOK = 0;
my %yubikey   = ();
my $item      = "";
my $value     = "";
my %logins    = ();
my $yubikey   = "";
my $password_stored = "";
my $yubikey_stored  = "";
my $igvport_stored  = "";
my $edit_role       = 0;
my $cgi             = new CGI;

#for login database
open(IN, "$text");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$logins{$item}=$value;
}
close IN;

# for yubikey server
open(IN, "$text2");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$yubikey{$item}=$value;
}
close IN;
my $id        = $yubikey{id};
my $api       = $yubikey{api};
my $nonce     = "";

#select password and yubikey from user table
my $dbh = DBI->connect("DBI:mysql:$maindbForLogin", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
#$dbh->{Profile} = 4;
#$dbh->{LongTruncOk} = 1;
my $query = "SELECT password,yubikey,igvport,role,edit FROM $logindb.user WHERE name=?";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";
($password_stored,$yubikey_stored,$igvport_stored,$role,$edit_role) = $out->fetchrow_array;

# user darf nicht leer sein, passiert wenn man loginDo.pl direkt aufruft
# password_stored is empty when no entry in database
if (($user eq '') or ($password eq '') or ($password_stored eq '') or ($edit_role == 0)) {
	$self->printHeader();
	print qq(<meta http-equiv="refresh" content="0; URL=login.pl">);
	$self->showMenu;
}	
else {
# encrypt password
$password = Crypt::Eksblowfish::Bcrypt::bcrypt($password,$password_stored) ;

# if yubikey_stored is 0: do not check yubikey server
if ($noyubikey == 1) {
	$yubikeyOK = "OK";
}
else
{
if ( ($yubikey_stored eq 0) and ($yubikey_stored ne "") ) {
	$yubikeyOK = "OK";
}
else {
	$yubikeyOK = Auth::Yubikey_WebClient::yubikey_webclient($otp,$id,$api,$nonce);
	#$self->printHeader();
	#print "yubikeyOK $yubikeyOK<br>";
	unless ($yubikey_stored eq substr($otp,0,12)) {
		$yubikeyOK = "ERR"
	}
}
}

my $session   = "";
my $newcookie = "";
if ( ($password_stored eq $password) and ($yubikeyOK eq "OK") ) {
	# authorization OK check for maxFailedLogin
	&login_succeeded($user,$dbh);
	$igvport=$igvport_stored;

	# create sessionkey
	CGI::Session->name("$gapplication");
	$session  = CGI::Session->new() or die CGI::Session->errstr;
	$session->expire('+180m');     # expire after 180 minutes
	$session->param('application',$gapplication);
	$session->param('user',$user);
	$session->param('igvport',$igvport);
	
	# create cookie
	$newcookie = $cgi->cookie( 
		   -name   => $session->name,
                   -value  => $session->id,
		   -path   => "$cgidir",
		   -secure => 1
		   );

	print $cgi->header(-cookie=>$newcookie);
	$self->printHeader("","sessionid_created");
	$self->showMenu;
	print "<font size = 6>Login successful</font><br>" ;
	#print "<font size = 6>IGVport $igvport</font><br>" ;
	unless ($noyubikey == 1) {
		print "<font size = 6>YubiKey $yubikeyOK<br>";
	}
}
else {
	# login failed
	$self->printHeader();
	$self->showMenu;
	if (($password_stored ne '') and ($user ne '')) {
		&login_failed($user,$dbh);
	}
	print "<font size = 6>Login failed</font><br><br>" ;
}
}

return($dbh);
}
########################################################################
# delete sessionid
########################################################################

sub deleteSessionId {
my $self     = shift;
my $cgi      = new CGI;
my $sess_id  = $cgi->cookie($gapplication);

my $session  = CGI::Session->new($sess_id) or die CGI::Session->errstr;;
$session->delete;  

}

########################################################################
# load sessionid
########################################################################

sub loadSessionId {
my $self        = shift;
my $sess_id     = shift;
my $application = "";
my $item        = "";
my $value       = "";
my %logins      = ();
my $cgi         = new CGI;

if (!defined($sess_id)) {
	$sess_id = "";
}
if ($sess_id eq "") {
	$sess_id = $cgi->cookie("$gapplication");
}

my $session     = CGI::Session->load($sess_id) or die CGI::Session->errstr;
	if ( $session->is_expired ) {
 		showMenu("login");
		#print "Your session is expired. Please login.";
		print qq(<meta http-equiv="refresh" content="0; URL=login.pl">);
		exit(1);
	}
	if ( $session->is_empty ) {
 		showMenu("login");
        	#print "Your sessionid is empty. Please login.";
		print qq(<meta http-equiv="refresh" content="0; URL=login.pl">);
		exit(1);
	}
	$application = $session->param('application');
	$user        = $session->param('user');
	$igvport     = $session->param('igvport');
	if ($application ne $gapplication) {
 		showMenu("login");
		print "<font size = 6>Wrong application.</font> <br>";
		exit(1);
	}
	open(IN, "$text");
	while (<IN>) {
		chomp;
		($item,$value)=split(/\:/);
		$logins{$item}=$value;
	}
	close IN;

	my $dbh = DBI->connect("DBI:mysql:$maindbForLogin", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
	my $query = "SELECT iduser FROM $logindb.user WHERE name=?";
	my $out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($user) || die print "$DBI::errstr";
	$iduser = $out->fetchrow_array;

return($dbh);
}

########################################################################
# actualDate
########################################################################
sub actualDate {
my ($seconds,$minutes,$hours,$day,$month,$year);
($seconds,$minutes,$hours,$day,$month,$year)=localtime();
$year+=1900;
$month+=1;
if (length($month) == 1) {$month="0".$month;}
if (length($day) == 1) {$day="0".$day;}
my $date="$year-$month-$day";
return($date);
}

########################################################################
# showAllProject
########################################################################

sub showAllProject {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initProject   ();
$self->getShowProject($dbh,$id,$ref,'Y');

}

########################################################################
# showAllLane
########################################################################

sub showAllLane {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initLane   ();
$self->getShowLane($dbh,$id,$ref,'Y');

}

########################################################################
# showAllLibrary
########################################################################

sub showAllLibrary {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initLibrary   ();
$self->getShowLibrary($dbh,$id,$ref,'Y');

}

########################################################################
# showAllPool
########################################################################

sub showAllPool {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initPool   ();
$self->getShowPool($dbh,$id,$ref,'Y');

}
########################################################################
# showAllRun
########################################################################

sub showAllRun {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initRunEdit($dbh);
$self->getShowRun($dbh,$id,$ref,'Y');

}
########################################################################
# showAllKit
########################################################################

sub showAllKit {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initKit();
$self->getShowKit($dbh,$id,$ref,'Y');

}
########################################################################
# showAllStock
########################################################################

sub showAllStock {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initStock();
$self->getShowStock($dbh,$id,$ref,'Y');

}
########################################################################
# showAllTag
########################################################################

sub showAllTag {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initTag();
$self->getShowTag($dbh,$id,$ref,'Y');

}
########################################################################
# showAllRun2stock
########################################################################

sub showAllRun2stock {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initRun2stock();
$self->getShowRun2stock($dbh,$id,$ref,'Y');

}
########################################################################
# showAllLibrary2pool
########################################################################

sub showAllLibrary2pool {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initLibrary2pool();
$self->getShowLibrary2pool($dbh,$id,$ref,'Y');

}
########################################################################
# showAllSample2library
########################################################################

sub showAllSample2library {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initSample2library();
$self->getShowSample2library($dbh,$id,$ref,'Y');

}
########################################################################
# showAllShopping
########################################################################

sub showAllShopping {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initShopping();
$self->getShowShopping($dbh,$id,$ref,'Y');

}
########################################################################
# init for new run2stock
########################################################################
sub initRun2stock {
my $self         = shift;
my $rid          = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Run2Stock ID",
	  	type        => "readonly2",
		name        => "idrun2stock",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run",
	  	type        => "selectdb",
		name        => "rid",
	  	value       => "$rid",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Stock",
	  	type        => "selectdb",
		name        => "sid",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "entered",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}

########################################################################
# init for new initLibrary2pool
########################################################################
sub initLibrary2pool {
my $self         = shift;
my $lid          = shift;
my $idpool       = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Library2pool ID",
	  	type        => "readonly2",
		name        => "idlibrary2pool",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pool",
	  	type        => "readonly2",
		name        => "idpool",
	  	value       => "$idpool",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library",
	  	type        => "selectdb",
		name        => "lid",
	  	value       => "$lid",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "loversion",
	  	type        => "hidden",
		name        => "loversion",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}

########################################################################
# init for new sample2library
########################################################################
sub initSample2library {
my $self         = shift;
my $lid          = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Sample2library ID",
	  	type        => "readonly2",
		name        => "idsample2library",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library",
	  	type        => "readonly2",
		name        => "lid",
	  	value       => "$lid",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample",
	  	type        => "selectdb",
		name        => "idsample",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}

########################################################################
# init for Lane
########################################################################
sub initLane {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Lane ID",
	  	type        => "readonly2",
		name        => "aid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run",
	  	type        => "readonly",
		name        => "rid",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pool",
	  	type        => "readonly",
		name        => "idpool",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane",
	  	type        => "readonly",
		name        => "alane",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity",
	  	type        => "text",
		name        => "amolar",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "aread1failed",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "aread2failed",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Paid",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "apaid",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "aversion",
	  	type        => "hidden",
		name        => "aversion",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}


########################################################################
# init for new and edit library
########################################################################
sub initLibrary {
my $self         = shift;
#my $idproject    = shift;

my $ref          = "";

my $sth          = "";
my $pname        = "";
my $pdescription = "";
my $sql          = "";
my $href         = "";
my $date         = &actualDate;


my @AoH = (
	  {
	  	label       => "Library ID",
	  	type        => "readonly2",
		name        => "lid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library Name",
	  	type        => "text",
		name        => "lname",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Description",
	  	type        => "text",
		name        => "ldescription",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "lcomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Exome kit",
	  	type        => "selectdb",
		name        => "lkit",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Status",
	  	labels      => "to do, lib in process, library prepared, pooled, Taqman finished, sequenced, external",
	  	type        => "radio",
		name        => "lstatus",
	  	value       => "to do",
	  	values      => "to do, lib in process, library prepared, pooled, Taqman finished, sequenced, external",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type library",
	  	type        => "selectdb",
		name        => "libpair",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type assay",
	  	type        => "selectdb",
		name        => "idassay",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Index",
	  	type        => "text",
		name        => "lindex",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Index 1",
	  	type        => "selectdb",
		name        => "idtag",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Index 2",
	  	type        => "selectdb",
		name        => "idtag2",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Quality",
	  	labels      => "good, low",
	  	type        => "radio",
		name        => "lquality",
	  	value       => "good",
	  	values      => "good, low",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "uid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "ldate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "lmenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Should be pooled",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "lforpool",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library failed",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "lfailed",
	  	value       => "0",
	  	values      => "0, 1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Starting Material (ng)",
	  	type        => "text",
		name        => "lmaterial",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PCR (cycles)",
	  	type        => "text",
		name        => "lpcr",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BA post PCR Concentration (ng/ul)",
	  	type        => "text",
		name        => "lbiopostpcrngul",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BA1000 Concentration (ng/ul)",
	  	type        => "text",
		name        => "lbio1conc",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BA1000 Mol (nMol)",
	  	type        => "text",
		name        => "lbio1mol",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BA1000 Volume (ul)",
	  	type        => "text",
		name        => "lbio1vol",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BA1000 Size (bp)",
	  	type        => "text",
		name        => "lbio1size",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library Size (bp)",
	  	type        => "readonly",
		name        => "linsertsize",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library Size SD (bp)",
	  	type        => "readonly",
		name        => "linsertsizesd",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BAhs Concentration (ng/ul)",
	  	type        => "text",
		name        => "lbiohsconc",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BAhs Mol (nMol)",
	  	type        => "text",
		name        => "lbiohsmol",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BAhs Volume (ul)",
	  	type        => "text",
		name        => "lbiohsvol",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BAhs size (bp)",
	  	type        => "text",
		name        => "lbiohssize",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PicoGreen (pg/ul)",
	  	type        => "text",
		name        => "lpicogreenpgul",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PicoGreen (nMol)",
	  	type        => "text",
		name        => "lpicogreen",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "qPCR (nMol)",
	  	type        => "text",
		name        => "lqpcr",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Duplicates (%)",
	  	type        => "text",
		name        => "lduplicates",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "lversion",
	  	type        => "hidden",
		name        => "lversion",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}

########################################################################
# init for new librarySheet called by searchSampleDo.pl
########################################################################
sub initLibrarySheet {
my $self         = shift;
#my $idproject    = shift;

my $ref          = "";

my $sth          = "";
my $pname        = "";
my $pdescription = "";
my $sql          = "";
my $href         = "";
my $date         = &actualDate;


my @AoH = (
	  {
	  	label       => "Description",
	  	type        => "text",
		name        => "ldescription",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "lcomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Exome kit",
	  	type        => "selectdb",
		name        => "lkit",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type library",
	  	type        => "selectdb",
		name        => "libpair",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type assay",
	  	type        => "selectdb",
		name        => "idassay",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "ldate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Label library<br>'preparation in process'",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "libinprocess",
	  	value       => "",
	  	values      => ", 1",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for new run
########################################################################
sub initPoolingDo {
my $self         = shift;
my $ref          = "";

my @AoH = (
	  {
	  	label       => "Label library as<br>'pooled'",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "pooled",
	  	value       => "",
	  	values      => ", 1",
	  	bgcolor     => "formbg",
	  },
);
$ref = \@AoH;
return($ref);
}
########################################################################
# init for new run
########################################################################
sub initRun {
my $self         = shift;
my $dbh          = shift;

my $ref          = "";

my $sth          = "";
my $pname        = "";
my $lname        = "";
my $sql          = "";
my $href         = "";
my $date         = &actualDate;


my @AoH = (
	  {
	  	label       => "Run ID",
	  	type        => "readonly2",
		name        => "rid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Flowcell Barcode",
	  	type        => "text",
		name        => "rname",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Description",
	  	type        => "selectdb",
		name        => "rdescription",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Index run",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "rindex",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "rcomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Failed comment",
	  	type        => "text",
		name        => "rfailed",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane1 Pool barcode",
	  	type        => "barcode",
		name        => "idpool1",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol1",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane2 Pool barcode",
	  	type        => "barcode",
		name        => "idpool2",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol2",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane3 Pool barcode",
	  	type        => "barcode",
		name        => "idpool3",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol3",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane4 Pool barcode",
	  	type        => "barcode",
		name        => "idpool4",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol4",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane5 Pool barcode",
	  	type        => "barcode",
		name        => "idpool5",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol5",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane6 Pool barcode",
	  	type        => "barcode",
		name        => "idpool6",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol6",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane7 Pool barcode",
	  	type        => "barcode",
		name        => "idpool7",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol7",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane8 Pool barcode",
	  	type        => "barcode",
		name        => "idpool8",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol8",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Flow-cell (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "rdate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "rdaterun",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Directory",
	  	type        => "text",
		name        => "rdirectory",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "rmenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "rversion",
	  	type        => "hidden",
		name        => "rversion",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
);
my $query = "
SELECT obarcode,odescription,idpool
FROM pool
";
my $sth = $dbh->prepare($query) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
my @row = ();
my $tmp = "";
while (@row = $sth->fetchrow_array) {
	if ($row[0] ne "") { # if barcode is empty
		if ($tmp ne "") {
			$tmp .= ",";
		}
		$tmp .= "\"$row[0]\":[\"$row[1]\",\"$row[2]\"]";
	}
}

print qq#
<script>

        // Global hash of barcode/names
        var myHash = new Array();
         // myHash={ 1234:["POOL1","asdf"], 4567:["POOL2","qwer"] };
        myHash={ $tmp };

        function CheckBarcode(barcodeText)
        {
                var barcode          = barcodeText.value;
                var barcodeTextId    = barcodeText.name;
                var validationId     = barcodeTextId+"validation";
		var idpool           = barcodeTextId.replace("barcode","idpool");

                if ( myHash[barcode] != undefined )
                {
                        // Display name
                        document.getElementsByName( validationId )[0].value=myHash[barcode][0];
                        document.getElementsByName( idpool )[0].value=myHash[barcode][1];
                }
                else
                {
                        // Clear element and display error
                        barcodeText.value="";
                        document.getElementsByName( validationId )[0].value="INVALID";
                        document.getElementsByName( idpool )[0].value="INVALID";
                }
        }
</script>
#;

$ref = \@AoH;
return($ref);
}
########################################################################
# init for run edit
########################################################################
sub initRunEdit {
my $self         = shift;
#my $idproject   = shift;
my $dbh          = shift;

my $ref          = "";


my @AoH = (
	  {
	  	label       => "Run ID",
	  	type        => "readonly2",
		name        => "rid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Flowcell Barcode",
	  	type        => "text",
		name        => "rname",
	  	value       => "",
		size        => "30",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Description",
	  	type        => "selectdb",
		name        => "rdescription",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Index run",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "rindex",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "rcomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Failed comment",
	  	type        => "text",
		name        => "rfailed",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane1 Pool barcode",
	  	type        => "barcode",
		name        => "idpool1",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol1",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed1",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed1",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane2 Pool barcode",
	  	type        => "barcode",
		name        => "idpool2",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol2",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed2",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed2",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane3 Pool barcode",
	  	type        => "barcode",
		name        => "idpool3",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol3",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed3",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed3",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane4 Pool barcode",
	  	type        => "barcode",
		name        => "idpool4",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol4",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed4",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed4",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane5 Pool barcode",
	  	type        => "barcode",
		name        => "idpool5",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol5",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed5",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed5",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane6 Pool barcode",
	  	type        => "barcode",
		name        => "idpool6",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol6",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed6",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed6",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane7 Pool barcode",
	  	type        => "barcode",
		name        => "idpool7",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol7",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed7",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed7",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane8 Pool barcode",
	  	type        => "barcode",
		name        => "idpool8",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Molarity (pM)",
	  	type        => "text",
		name        => "mol8",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 1 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read1failed8",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read 2 failed",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "read2failed8",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "uid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Flow-cell (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "rdate",
	  	value       => "",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "rdaterun",
	  	value       => "",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Directory",
	  	type        => "text",
		name        => "rdirectory",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "rmenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "rversion",
	  	type        => "hidden",
		name        => "rversion",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
);

my $query = "
SELECT obarcode,odescription,idpool
FROM pool
";
my $sth = $dbh->prepare($query) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
my @row = ();
my $tmp = "";
while (@row = $sth->fetchrow_array) {
	if ($row[0] ne "") { # if barcode is empty
		if ($tmp ne "") {
			$tmp .= ",";
		}
		$tmp .= "\"$row[0]\":[\"$row[1]\",\"$row[2]\"]";
	}
}

print qq#
<script>

        // Global hash of barcode/names
        var myHash = new Array();
         // myHash={ 1234:["POOL1","asdf"], 4567:["POOL2","qwer"] };
        myHash={ $tmp };

        function CheckBarcode(barcodeText)
        {
                var barcode          = barcodeText.value;
                var barcodeTextId    = barcodeText.name;
                var validationId     = barcodeTextId+"validation";
		var idpool           = barcodeTextId.replace("barcode","idpool");

                if ( myHash[barcode] != undefined )
                {
                        // Display name
                        document.getElementsByName( validationId )[0].value=myHash[barcode][0];
                        document.getElementsByName( idpool )[0].value=myHash[barcode][1];
                }
                else
                {
                        // Clear element and display error
                        barcodeText.value="";
                        document.getElementsByName( validationId )[0].value="INVALID";
                        document.getElementsByName( idpool )[0].value="INVALID";
                }
        }
</script>
#;

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search shopping
########################################################################
sub initSearchShopping {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Company",
	  	type        => "selectdb",
		name        => "idcompany",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Article group",
	  	labels      => "All, Consumables, Computer, Computer_service, Sequencing_Machines, Sequencing_service, Other_machines, Other_machines_service, Other",
	  	type        => "radio",
		name        => "articlegroup",
	  	value       => "",
	  	values      => ", Consumables, Computer, Computer_service, Sequencing_Machines, Sequencing_service, Other_machines, Other_machines_service, Other",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Article",
	  	type        => "text",
		name        => "bdescription",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PSP element",
	  	type        => "text",
		name        => "pspelement",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
                label       => "Invoice number",
		type        => "text",
		name        => "invoice",
		value       => "",
		size        => "45",
		maxlegth    => "45",
		bgcolor     => "formbg",
	  }
);

$ref = \@AoH;
return($ref);
}

########################################################################
# init for search projects
########################################################################
sub initSearchProjects {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Projectflag",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "pmenuflag",
	  	value       => "T",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library",
	  	type        => "text",
		name        => "lname",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Libraryflag",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "lmenuflag",
	  	value       => "T",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pool Name",
	  	type        => "text",
		name        => "odescription",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pool Barcode",
	  	type        => "text",
		name        => "obarcode",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Poolflag",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "omenuflag",
	  	value       => "T",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run",
	  	type        => "text",
		name        => "rname",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run",
	  	type        => "selectdb",
		name        => "rid",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Runflag",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "rmenuflag",
	  	value       => "",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Output",
	  	labels      => "Runs only, Libraries only, Libraries and Runs",
	  	type        => "radio",
		name        => "withlanes",
	  	value       => "T",
	  	values      => "only_runs, F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Project, Date",
	  	type        => "radio",
		name        => "order",
	  	value       => "Date",
	  	values      => "Project, Date",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Statistics
########################################################################
sub initStatistics {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Machine",
	  	type        => "selectdb",
		name        => "machine",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read number",
	  	type        => "selectdb",
		name        => "readNumber",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lane number",
	  	type        => "selectdb",
		name        => "alane",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Projectflag",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "pmenuflag",
	  	value       => "T",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library",
	  	type        => "selectdb",
		name        => "lid",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Libraryflag",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "lmenuflag",
	  	value       => "",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run",
	  	type        => "selectdb",
		name        => "rid",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Runflag",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "rmenuflag",
	  	value       => "",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Failed",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "failed",
	  	value       => "",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "% Error Rate <=",
	  	type        => "text",
		name        => "errorPF",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Project, Date",
	  	type        => "radio",
		name        => "order",
	  	value       => "Date",
	  	values      => "Project, Date",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search yield 
########################################################################
sub initYield {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Failed",
	  	labels      => "False, True, All",
	  	type        => "radio",
		name        => "failed",
	  	value       => "F",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "% Error Rate <=",
	  	type        => "text",
		name        => "errorPF",
	  	value       => "100",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Project, Date",
	  	type        => "radio",
		name        => "order",
	  	value       => "Date",
	  	values      => "Project, Date",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Stocks
########################################################################
sub initSearchStocks {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Kit",
	  	type        => "selectdb",
		name        => "cid",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Used",
	  	labels      => "Not_used, Used, All",
	  	type        => "radio",
		name        => "idrun2stock",
	  	value       => "not_used",
	  	values      => "not_used, used, ",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for new Kit
########################################################################
sub initKit {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Kid ID",
	  	type        => "readonly2",
		name        => "cid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Kit number",
	  	type        => "text",
		name        => "cname",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Description",
	  	type        => "text",
		name        => "cdescription",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "cmenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}


########################################################################
# init for new Stock
########################################################################
sub initStock {
my $self         = shift;

my $ref          = "";
my $date=&actualDate;

my @AoH = (
	  {
	  	label       => "Stock ID",
	  	type        => "readonly2",
		name        => "sid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Kit",
	  	type        => "selectdb",
		name        => "cid",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Expiration 1 (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "expiration",
	  	value       => "",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lot No 1",
	  	type        => "text",
		name        => "lot",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Expiration 2 (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "expiration2",
	  	value       => "",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lot No 2",
	  	type        => "text",
		name        => "lot2",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "uidreceived",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Received (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "sgetdate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Replacement",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "replacement",
	  	value       => "F",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "scomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "smenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for new Tag
########################################################################
sub initTag {
my $self         = shift;

my $ref          = "";
my $date=&actualDate;

my @AoH = (
	  {
	  	label       => "Index ID",
	  	type        => "readonly2",
		name        => "idtag",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Group",
	  	type        => "text",
		name        => "tgroup",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Name",
	  	type        => "text",
		name        => "tname",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Dual Index (1 or 2)",
	  	type        => "text",
		name        => "tdualindex",
	  	value       => "",
		size        => "40",
		maxlength   => "40",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Index",
	  	type        => "text",
		name        => "ttag",
	  	value       => "",
		size        => "40",
		maxlength   => "40",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "tentered",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "tdate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "tmenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}

########################################################################
# init for new Pool
########################################################################
sub initPool {
my $self         = shift;

my $ref          = "";
my $date=&actualDate;

my @AoH = (
	  {
	  	label       => "Pool ID",
	  	type        => "readonly2",
		name        => "idpool",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pool name",
	  	type        => "text",
		name        => "oname",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pool description",
	  	type        => "text",
		name        => "odescription",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Lanes to sequence",
	  	type        => "text",
		name        => "olanestosequence",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pool comment",
	  	type        => "text",
		name        => "ocomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Barcode",
	  	type        => "text",
		name        => "obarcode",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Plate",
	  	type        => "text",
		name        => "oplate",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Row",
	  	type        => "select1",
		name        => "orow",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Column",
	  	type        => "select1",
		name        => "ocolumn",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Flowcell",
	  	labels      => "HiSeq4000, NovaSeqSP, NovaSeq_S1, NovaSeq_S2, NovaSeq_S4, MiSeq",
	  	type        => "radio",
		name        => "oflowcell",
	  	value       => "NovaSeqS2",
	  	values      => "HiSeq4000, NovaSeqSP, NovaSeqS1, NovaSeqS2, NovaSeqS4, MiSeq",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read length",
	  	labels      => "PE_50_bp, PE_100_bp, PE_150_bp, Custom",
	  	type        => "radio",
		name        => "oreadlength",
	  	value       => "PE100bp",
	  	values      => "PE50bp, PE100bp, PE150bp, Custom",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Workflow",
	  	labels      => "Standard, XP",
	  	type        => "radio",
		name        => "oworkflow",
	  	value       => "Standard",
	  	values      => "Standard, XP",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Loading concentration (pMol)",
	  	type        => "text",
		name        => "oloadingconcentration",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PhiX (%)",
	  	type        => "text",
		name        => "ophix",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },


	  {
	  	label       => "First Pooling: Total volume (ul)",
	  	type        => "text",
		name        => "ovolume",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "First Pooling: Aimed concentration (nMol)",
	  	type        => "text",
		name        => "oaimedconcentration",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "First Pooling: Used volume (ul)",
	  	type        => "text",
		name        => "ousedvolume",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "First Pooling: qPCR (nMol)",
	  	type        => "text",
		name        => "opcr",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "qPCR recalculated (nMol)",
	  	type        => "text",
		name        => "opcrrecalculated",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PicoGreen (nMol)",
	  	type        => "text",
		name        => "picogreennmol",
	  	value       => "",
		size        => "15",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "oentered",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "odate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "omenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "oversion",
	  	type        => "hidden",
		name        => "oversion",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for new Shopping
########################################################################
sub initShopping {
my $self         = shift;

my $ref          = "";
my $date=&actualDate;

my @AoH = (
	  {
	  	label       => "Order ID",
	  	type        => "readonly2",
		name        => "idshopping",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Company",
	  	type        => "selectdb",
		name        => "bcompany",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Article group",
	  	labels      => "Consumables, Computer, Computer_service, Sequencing_Machines, Sequencing_service, Other_machines, Other_machines_service, Other",
	  	type        => "radio",
		name        => "articlegroup",
	  	value       => "Consumables",
	  	values      => "Consumables, Computer, Computer_service, Sequencing_Machines, Sequencing_service, Other_machines, Other_machines_service, Other",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Article number",
	  	type        => "text",
		name        => "bnumber",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Article description",
	  	type        => "text",
		name        => "bdescription",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PSP-Element",
	  	type        => "text",
		name        => "pspelement",
	  	value       => "A-630430-001",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "List price",
	  	type        => "text",
		name        => "blistprice",
	  	value       => "",
		size        => "15",
		maxlength   => "15",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Price",
	  	type        => "text",
		name        => "bprice",
	  	value       => "",
		size        => "15",
		maxlength   => "15",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Einkaufswagen",
	  	type        => "text",
		name        => "beinkaufswagen",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order number",
	  	type        => "text",
		name        => "bordernumber",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
		label       => "Invoice number",
		type        => "text",
		name        => "invoice",
		value       => "",
		size        => "45",
		maxlength   => "45",
		bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "buser",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "bdate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# initPooling for pooling called by pooling.pl
########################################################################
sub initPooling {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Number of samples",
	  	type        => "text",
		name        => "npool",
	  	value       => "12",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Final volume (ul)",
	  	type        => "text",
		name        => "volume",
	  	value       => "50",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Final concentration (nMol)",
	  	type        => "text",
		name        => "concentration",
	  	value       => "10",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "For pool",
	  	labels      => "No, Yes, All",
	  	type        => "radio",
		name        => "lforpool",
	  	value       => "T",
	  	values      => "F, T, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# initSequencing for sequencing called by sequencing.pl
########################################################################
sub initSequencing {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Flowcell",
	  	labels      => "All, HiSeq4000, NovaSeqSP, NovaSeq_S1, NovaSeq_S2, NovaSeq_S4, MiSeq",
	  	type        => "radio",
		name        => "oflowcell",
	  	value       => " ",
	  	values      => " , HiSeq4000, NovaSeqSP, NovaSeqS1, NovaSeqS2, NovaSeqS4, MiSeq",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Read length",
	  	labels      => "All, PE_50_bp, PE_100_bp, PE_150_bp, Custom",
	  	type        => "radio",
		name        => "oreadlength",
	  	value       => " ",
	  	values      => " , PE50bp, PE100bp, PE150bp, Custom",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Workflow",
	  	labels      => "All, Standard, XP",
	  	type        => "radio",
		name        => "oworkflow",
	  	value       => " ",
	  	values      => " , Standard, XP",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# getShowProject
########################################################################

sub getShowProjectOld {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT *
	FROM project 
	WHERE pid = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Project</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		#print "$href->{name}<br>";
		if ($mode eq 'Y') {
			if ($href->{name} eq 'pid') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="project.pl?id=$resultref->{pid}&amp;mode=edit">$resultref->{pid} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}

########################################################################
# getShowLane
########################################################################

sub getShowLane {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT *
	FROM lane a, run r, pool o
	WHERE a.rid=r.rid
	AND a.idpool=o.idpool
	AND aid = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Project</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($href->{name} eq 'rid') {
				$href->{value}=$resultref->{rname};	
		}
		elsif ($href->{name} eq 'idpool') {
				$href->{value}=$resultref->{oname};	
		}
		if ($mode eq 'Y') {
			if ($href->{name} eq 'aid') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="lane.pl?id=$resultref->{aid}">$resultref->{aid} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowLibrary
########################################################################

sub getShowLibrary {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT l.*
	FROM library l
	WHERE lid = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Library</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'lid') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="library.pl?id=$resultref->{lid}&amp;mode=edit">$resultref->{lid} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowPool
########################################################################

sub getShowPool {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT o.*
	FROM pool o
	WHERE idpool = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;


# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Pool</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idpool') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="pool.pl?id=$resultref->{idpool}&amp;mode=edit">$resultref->{idpool} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# showRun2stock
########################################################################

sub showRun2stock {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my @labels       = ();

print qq(<a href="run2stock.pl?mode=new&rid=$id">Add stock</a><br>);

$sql = "
	SELECT  * 
	FROM run2stock rs
	LEFT JOIN $logindb.user  u ON u.iduser=rs.entered
	LEFT JOIN stock          s ON s.sid=rs.sid
	LEFT JOIN kit            c ON c.cid=s.cid
	WHERE   rs.rid = $id
	";
	
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
@labels	= (
	'id',
	'Received',
	'Stock Id',
	'Kit Number',
	'Kit',
	'Lot 1',
	'Lot 2'
	);

print q(<table border="1" cellspacing="0" cellpadding="1"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
while ($resultref = $sth->fetchrow_hashref) {
	print "<tr>";
	print "<tr><td><a href=\"run2stock.pl?mode=edit&id=$resultref->{idrun2stock}\">$resultref->{idrun2stock}</a></td>"; 
	print "<td>$resultref->{sgetdate}</td>"; 
	print "<td align=\"center\">$resultref->{sid}</td>"; 
	print "<td>$resultref->{cname}</td>"; 
	print "<td>$resultref->{cdescription}</td>"; 
	print "<td>$resultref->{lot}</td>"; 
	print "<td>$resultref->{lot2}</td>"; 
	print "</tr>";
}
print "</table><br>";

}

########################################################################
# showRunPF
########################################################################
sub showRunPF {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my @labels       = ();

my $rname = "";

$sql = "
        SELECT rid, rname
        FROM run r
        where r.rid = ? ";

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute($id) || die print "$DBI::errstr";
@labels = (
        'rid',
        'rname'
        );

print q(<br><br><br><table border="1" cellspacing="0" cellpadding="1"> );
print "<tr>";
foreach (@labels) {
        print "<th align=\"center\">$_</th>";
}
print "</tr>";
while ($resultref = $sth->fetchrow_hashref) {
        print "<tr>";
        print "<td>$resultref->{rid}</td><td>$resultref->{rname}</td>";
        print "</tr>";
	$rname=$resultref->{rname};
}
print "</table><br>";

if ( -d glob "/data/runs/Runs/*$rname/Demultiplexed/Project_all/" )
{
	print "<br>Flowcell has been demultiplexed<br>";
	print "<table><tr><td>%PF Sample</td><td>Sample</td></tr>";
	my $out=`/data/isilon/users/scripts/illumina-pipeline/makePF.sh /data/runs/Runs/*$rname | awk '{print "<tr><td>"\$1"</td><td>"\$2"</td><tr>"}'`;
	print "$out";
	print "</table>";
}else{
	print "<br>Flowcell $rname has not been demultiplexed<br>"; 
}

}

########################################################################
# showPool2library called by pool.pl
########################################################################

sub showPool2library {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my @labels       = ();
my @row          = ();
my $i            = 0;

#print qq(<a href="library2pool.pl?mode=new&idpool=$id">Add Library to Pool</a><br>);

$sql = "
	SELECT DISTINCT  l.lid,idlibrary2pool,pdescription,s.name,lname,ldescription,lcomment,ltlibtype,lplibpair,
	l.lstatus,
	tag1.tgroup,
	tag1.tname,
	if((LENGTH(tag1.ttag)>0),LENGTH(tag1.ttag),LENGTH(b1.ttag)),
	tag2.tname,
	LENGTH(tag2.ttag)
	FROM library2pool lo
	INNER JOIN pool            o    ON o.idpool    = lo.idpool
	INNER JOIN library         l    ON lo.lid      = l.lid
	LEFT JOIN sample2library   sl   ON l.lid       = sl.lid
	LEFT JOIN $exomedb.sample  s    ON sl.idsample = s.idsample
	LEFT JOIN $exomedb.project p    ON s.idproject = p.idproject
	LEFT JOIN libtype          lt   ON l.libtype   = lt.ltid
	LEFT JOIN libpair          lp   ON l.libpair   = lp.lpid
	LEFT JOIN tag              tag1 ON l.idtag     = tag1.idtag
	LEFT JOIN tag              tag2 ON l.idtag2    = tag2.idtag
	LEFT JOIN barcodes10x      b1   ON l.idtag     = b1.idtag 
	WHERE   o.idpool = $id
	";
#print "$sql<br>";	
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
@labels	= (
	'Library',
	'Library2Pool',
	'Project',
	'Sample',
	'Lib Name',
	'Lib Description',
	'LibComment',
	'Type material',
	'Type library',
	'Status',
	'Index group',
	'Index1',
	'Length',
	'Index2',
	'Length',
	);


&tableheader("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

my $samples="";

while (@row = $sth->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td><a href=\"library.pl?mode=edit&id=$row[$i]\">$row[$i]</a></td>"; 
		}
		else {
			print "<td>$row[$i]</td>"; 
		}
		
		$i++;
	}
	print "</tr>";
	
	$samples .= "%20" if $samples ne "";
	$samples .= $row[3];
}

=begin comment
while ($resultref = $sth->fetchrow_hashref) {
	print "<tr>";
	print "<td><a href=\"library.pl?mode=edit&id=$resultref->{lid}\">$resultref->{lid}</a></td>"; 
	#print "<td><a href=\"library2pool.pl?mode=edit&id=$resultref->{idlibrary2pool}\">$resultref->{idlibrary2pool}</a></td>"; 
	print "<td>$resultref->{idlibrary2pool}</td>"; 
	print "<td>$resultref->{pdescription}</td>"; 
	print "<td>$resultref->{lname}</td>"; 
	print "<td>$resultref->{ldescription}</td>"; 
	print "<td>$resultref->{lcomment}</td>"; 
	print "<td>$resultref->{ltlibtype}</td>"; 
	print "<td>$resultref->{lplibpair}</td>"; 
	print "<td>$resultref->{tname}</td>"; 
	print "</tr>";
}
=end comment
=cut

print "</tbody></table></div>";

print "<div><hr><a href=\"../snv-vcf/searchStat.pl?sample=$samples&autosearch=1\"</a>Pool Quality</a> - Opens a mask on SNV-VCF with Stats table for all the samples in the pool<hr></div>";

&tablescript;

}
########################################################################
# showLibrary2pool called by library.pl, um die pools2library vor der
# library-Maske anzuzeigen
########################################################################

sub showLibrary2pool {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my @labels       = ();

#print qq(<a href="library2pool.pl?mode=new&lid=$id">Add to Pool</a><br>);

$sql = "
	SELECT  o.idpool, oname, odescription, ocomment, group_concat(distinct r.rname) runs 
	FROM library2pool lo
	INNER JOIN pool     o   ON o.idpool=lo.idpool
	INNER JOIN library  l   ON lo.lid=l.lid
	LEFT JOIN lane      ln  ON ln.idpool=o.idpool
	LEFT JOIN run       r   ON r.rid=ln.rid
	WHERE   l.lid = $id
	GROUP BY idpool
	";
	
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
@labels	= (
	'Pool',
	'Name',
	'Description',
	'Comment',
	'Runs'
	);

print q(<table border="1" cellspacing="0" cellpadding="1"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
while ($resultref = $sth->fetchrow_hashref) {
	print "<tr>";
	print "<tr><td><a href=\"pool.pl?mode=edit&id=$resultref->{idpool}\">$resultref->{idpool}</a></td>"; 
	#print "<td><a href=\"library2pool.pl?mode=edit&id=$resultref->{idlibrary2pool}\">$resultref->{idlibrary2pool}</a></td>"; 
	print "<td>$resultref->{oname}</td>"; 
	print "<td >$resultref->{odescription}</td>"; 
	print "<td>$resultref->{ocomment}</td>";
	print "<td>$resultref->{runs}</td>";
	print "</tr>";
}
print "</table><br>";

}
########################################################################
# showSample2library
########################################################################

sub showSample2library {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my @labels       = ();

#print qq(<a href="sample2library.pl?mode=new&lid=$id">Add sample</a><br>);

$sql = "
	SELECT  sa.idsample,sa.name,sa.pedigree,sa.sex,co.name AS cooperation 
	FROM sample2library sl
	LEFT JOIN $exomedb.sample  sa      ON sa.idsample=sl.idsample
	LEFT JOIN library l                 ON l.lid=sl.lid
	LEFT JOIN $exomedb.cooperation  co ON sa.idcooperation = co.idcooperation
	WHERE   sl.lid = $id
	";
#print "$sql<br>";
	
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
@labels	= (
	'id',
	'Sample',
	'Pedigree',
	'Sex',
	'Cooperation'
	);

print q(<table border="1" cellspacing="0" cellpadding="1"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
while ($resultref = $sth->fetchrow_hashref) {
	print "<tr>";
	print "<td><a href=\"../snvedit/sample.pl?id=$resultref->{idsample}&mode=edit\">$resultref->{idsample}</a></td>"; 
	print "<td>$resultref->{name}</td>"; 
	print "<td align=\"center\">$resultref->{pedigree}</td>"; 
	print "<td>$resultref->{sex}</td>"; 
	print "<td>$resultref->{cooperation}</td>"; 
	print "</tr>";
}
print "</table><br>";

}
########################################################################
# getShowRun
########################################################################

sub getShowRun {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT *
	FROM run r
	LEFT JOIN lane a ON r.rid=a.rid
	WHERE r.rid = $id";
	
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";


while ($resultref = $sth->fetchrow_hashref) {
# fill @AoH with results
for $href ( @{$ref} ) {
	if ((exists $resultref->{$href->{name}}) or ($href->{name} =~ /^\w+\d+$/)) { #idpool und mol 1..n durchlassen, die nicht in resultref existieren
		if ($href->{name} =~ /^idpool\d+$/) {  # nur idpool 1..n
			$_=$href->{name};
			/(\d+)$/;
			if ($1 eq $resultref->{alane}) { 
				$href->{value} = $resultref->{idpool};
			}
		}
		elsif ($href->{name} =~ /^mol\d+$/) {  # nur mol 1..n
			$_=$href->{name};
			/(\d+)$/;
			if ($1 eq $resultref->{alane}) { 
				$href->{value} = $resultref->{amolar};
			}
		}
		elsif ($href->{name} =~ /^read1failed\d+$/) {  # nur read1failed 1..n
			$_=$href->{name};
			/(\d+)$/;
			if ($1 eq $resultref->{alane}) { 
				$href->{value} = $resultref->{aread1failed};
			}
		#print "$1 $href->{name} $href->{value}<br>";
		}
		elsif ($href->{name} =~ /^read2failed\d+$/) {  # nur read2failed 1..n
			$_=$href->{name};
			/(\d+)$/;
			if ($1 eq $resultref->{alane}) { 
				$href->{value} = $resultref->{aread2failed};
			}
		#print "$1 $href->{name} $href->{value}<br>";
		}
		else { # der Rest, idpool1..n nicht leer \FCberschreiben 
			$href->{value} = $resultref->{$href->{name}};
		}
		#print "$href->{name} $href->{value}<br>";
	}
}
} #end while resultref


# print @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Run</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
		for $href ( @{$ref} ) {
			if ($href->{name} eq 'rid') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="run.pl?id=$href->{value}&amp;mode=edit">$href->{value} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $href->{value} &nbsp;</td></tr>";		
			}
		}
}



if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowKit
########################################################################

sub getShowKit {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT *
	FROM kit
	WHERE cid = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Kit</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'cid') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="kit.pl?id=$resultref->{cid}&amp;mode=edit">$resultref->{cid} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowStock
########################################################################

sub getShowStock {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT  * 
	FROM stock s
	LEFT JOIN $logindb.user   u ON u.iduser=s.uidreceived
	LEFT JOIN kit             c ON c.cid=s.cid
	WHERE sid = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Stock</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'sid') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="stock.pl?id=$resultref->{sid}&amp;mode=edit">$resultref->{sid} </a></td></tr>);
			}
			elsif ($href->{name} eq 'cid') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{cdescription} &nbsp;</td></tr>";		
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowTag
########################################################################

sub getShowTag {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT  * 
	FROM tag t
	LEFT JOIN $logindb.user u ON t.tentered=u.iduser
	WHERE   t.idtag = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Stock</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idtag') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="tag.pl?id=$resultref->{idtag}&amp;mode=edit">$resultref->{idtag} </a></td></tr>);
			}
			elsif ($href->{name} eq 'tentered') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{name} &nbsp;</td></tr>";		
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowRun2stock
########################################################################

sub getShowRun2stock {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT  rs.idrun2stock,rs.rid,rs.sid,rs.entered,
	c.cdescription,u.name
	FROM run2stock rs
	LEFT JOIN $logindb.user  u ON u.iduser=rs.entered
	LEFT JOIN stock          s ON s.sid=rs.sid
	LEFT JOIN kit            c ON c.cid=s.cid
	WHERE   idrun2stock = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Run2Stock</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		#print "$href->{name} $href->{value}<br>";
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idrun2stock') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="run2stock.pl?id=$resultref->{idrun2stock}&amp;mode=edit">$resultref->{idrun2stock} </a></td></tr>);
			}
			elsif ($href->{name} eq 'sid') {
				print "<tr><td>$href->{label}</td>
				<td>$href->{value} $resultref->{cdescription} &nbsp;</td></tr>";		
			}
			elsif ($href->{name} eq 'entered') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{name} &nbsp;</td></tr>";		
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowLibrary2pool
########################################################################

sub getShowLibrary2pool {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT  lo.*,lname,oname
	FROM library2pool lo
	INNER JOIN library  l    ON lo.lid=l.lid
	INNER JOIN pool     o    ON lo.idpool=o.idpool
	WHERE   idlibrary2pool = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Library2Pool</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		#print "$href->{name} $href->{value}<br>";
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idlibrary2pool') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="library2pool.pl?id=$resultref->{idlibrary2pool}&amp;mode=edit">$resultref->{idlibrary2pool} </a></td></tr>);
			}
			elsif ($href->{name} eq 'lid') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{lname} &nbsp;</td></tr>";		
			}
			elsif ($href->{name} eq 'idpool') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{oname} &nbsp;</td></tr>";		
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# getShowSample2library
########################################################################

sub getShowSample2library {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT  sl.idsample2library,sl.idsample,sl.lid,sa.name,sa.pedigree,sa.sex,co.name AS cooperation,l.lname
	FROM sample2library sl
	LEFT JOIN $exomedb.sample  sa      ON sa.idsample=sl.idsample
	LEFT JOIN library l                 ON l.lid=sl.lid
	LEFT JOIN $exomedb.cooperation  co ON sa.idcooperation = co.idcooperation
	WHERE   sl.idsample2library = $id
	";
	
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Sample2Library</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		#print "$href->{name} $href->{value}<br>";
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idsample2library') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="sample2library.pl?id=$resultref->{idsample2library}&amp;mode=edit">$resultref->{idsample2library} </a></td></tr>);
			}
			elsif ($href->{name} eq 'lid') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{lname} &nbsp;</td></tr>";		
			}
			elsif ($href->{name} eq 'idsample') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{name} &nbsp;</td></tr>";		
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}

########################################################################
# getShowShopping
########################################################################

sub getShowShopping {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

$sql = "
	SELECT *
	FROM shopping 
	WHERE idshopping = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">User</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idshopping') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="shopping.pl?id=$resultref->{idshopping}&amp;mode=edit">$resultref->{idshopping} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}

########################################################################
# insertIntoProject
########################################################################

sub insertIntoProjectold {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{pid} = 0 ;
$ref->{pname} = uc($ref->{pname});

my $sql = "";
my $sth = "";

#check_before_update($ref,$dbh);
if ($ref->{pname} eq "") {
	showMenu("");
	print "Please fill in a project name.Nothing done.<br>";
	printFooter();
	exit(1);
}
if ($ref->{uid} eq "") {
	undef($ref->{uid});
}
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{pid}=$sth->{mysql_insertid};
$sth->finish;

}

########################################################################
# insertIntoLibrary
########################################################################

sub insertIntoLibrary {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql = "";
my $sth = "";
my $idpool = 0;

$ref->{lid} = 0 ;
# jede library wird als default auf to do gesetzt
$ref->{lstatus} = 'to do' ;
$ref->{lname} = uc($ref->{lname});
$ref->{uid} = $iduser;
if ($ref->{uid} eq "") {
	undef($ref->{uid});
}
if ($ref->{idtag} eq "") {
	undef($ref->{idtag});
}

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

#check_before_update($ref,$dbh);
#for $href ( @{$ref} ) {
if ($ref->{lname} eq "") {
	showMenu("");
	print "Please fill in a library name.Nothing done.<br>";
	printFooter();
	exit(1);
}

$sql = sprintf "INSERT INTO %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{lid}=$sth->{mysql_insertid};

# insert into pool
$sql="
INSERT INTO pool
(oname,odescription,ocomment,oentered,odate,oversion)
VALUES
('$ref->{lname}',
'$ref->{ldescription}',
'$ref->{lcomment}',
'$ref->{uid}',
'$ref->{ldate}',
'$ref->{lversion}')
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
$idpool=$sth->{mysql_insertid};

# insert into library2pool
$sql="
INSERT INTO library2pool
(lid,idpool)
VALUES
($ref->{lid},
$idpool)
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";

$sth->finish;
return($idpool);
}
########################################################################
# insertIntoLibrary2pool
########################################################################

sub insertIntoLibrary2pool {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my $lane      = 0;

# it is not allowed to change the pool content
# when the pool has already been assigned to a run
$sql="
SELECT idpool 
FROM lane
WHERE idpool=$ref->{idpool}";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
$lane = $sth->fetchrow_array;
if ($lane>0) {
	showMenu("");
	print "Pool is already sequenced. Not allowed to change. Lane $lane<br>";
	printFooter();
	exit;
}

if (($ref->{lid} eq "") or ($ref->{idpool} eq "")) {
	showMenu("");
	print "Please fill in a library and pool name. Nothing done.<br>";
	printFooter();
	exit(1);
}

$ref->{idlibrary2pool} = 0 ;
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

if (($ref->{lid} eq "") or ($ref->{idpool} eq "")) {
	showMenu("");
	print "Please fill in a library and pool name. Nothing done.<br>";
	printFooter();
	exit(1);
}

$sql = sprintf "INSERT INTO %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idlibrary2pool}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# insertIntoPool
########################################################################

sub insertIntoPool {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql = "";
my $sth = "";

$ref->{oentered} = $iduser;
if ($ref->{oname} eq "") {
	showMenu("");
	print "Please fill in a pool name. Nothing done.<br>";
	printFooter();
	exit(1);
}

if ($ref->{obarcode} eq "") {
	undef($ref->{obarcode});
}
if ($ref->{oplate} eq "") {
	undef($ref->{oplate});
}
if ($ref->{orow} eq "") {
	undef($ref->{orow});
}
if ($ref->{ocolumn} eq "") {
	undef($ref->{ocolumn});
}

$ref->{idpool} = 0 ;
$ref->{oname} = uc($ref->{oname});
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "INSERT INTO %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idpool}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# insertIntoRun
########################################################################

sub insertIntoRun {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql           = "";
my $sth           = "";
my @fields        = (); # into run
my @values        = (); # into run
my @lane_idpool      = (); # into lane (library id)
my @lane_mol      = (); # into lane (library id)
my @lane          = (); # into lane (library id)
my $key           = "";
my $i             = 0;
my $aid           = 0;

delete($ref->{barcode1});
delete($ref->{barcode2});
delete($ref->{barcode3});
delete($ref->{barcode4});
delete($ref->{barcode5});
delete($ref->{barcode6});
delete($ref->{barcode7});
delete($ref->{barcode8});
delete($ref->{barcode1validation});
delete($ref->{barcode2validation});
delete($ref->{barcode3validation});
delete($ref->{barcode4validation});
delete($ref->{barcode5validation});
delete($ref->{barcode6validation});
delete($ref->{barcode7validation});
delete($ref->{barcode8validation});

$ref->{rid}       = 0;
$ref->{rname} = uc($ref->{rname});
$ref->{uid} = $iduser;
if ($ref->{uid} eq "") {
	undef($ref->{uid});
}
if ($ref->{rname} eq "") {
	showMenu("");
	print "Please enter the flowcell barcode.Nothing done.<br>";
	printFooter();
	exit(1);
}
if ($ref->{idpool1} < 1) {
	showMenu("");
	print "Please select at least a library for lane 1.Nothing done.<br>";
	printFooter();
	exit(1);
}

foreach $key (keys %$ref) {
	if ($key =~ /^idpool\d+$/) { #das sind die 8 lanes, eigenes Array f\FCr insert into lane
		$i++;
		#print "$key $ref->{$key}<br>";
		push(@lane_idpool,$ref->{$key});
		push(@lane,$i);
	}
	elsif ($key =~ /^mol\d+$/) {  #das sind die molaritaeten der 8 lanes, eigenes Array f\FCr insert into lane
		if ($ref->{$key} eq "") {
			($ref->{$key}='NULL');
		}
		else {
			$ref->{$key}= "'" . $ref->{$key} . "'";
		}
		push(@lane_mol,$ref->{$key});
		#print "lane @lane @lane_mol<br>";
	}
	else {
		#print "$key<br>";
		push(@fields,$key);
		push(@values,$ref->{$key});
	}
	
}

$dbh->{AutoCommit}=0 ;
eval {
$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{rid}=$sth->{mysql_insertid};

$i=0; # insert into lane
foreach (@lane_idpool) {
	$sql = "";
	if ($lane_idpool[$i] ne "") {
		$sql = "INSERT INTO lane
		(aid,alane,rid,idpool,amolar)
		VALUES ($aid,$lane[$i],$ref->{rid},$lane_idpool[$i],$lane_mol[$i])
		";	
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	#print "$i $sql<br>";
	$i++;
	#$ref->{rid}=$sth->{mysql_insertid};

}
};
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("COMMIT");
}
$sth->finish;

}
########################################################################
# insertIntoKit
########################################################################

sub insertIntoKit {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{cid} = 0 ;
#$ref->{sampleId} = uc($ref->{sampleId});

my $sql = "";
my $sth = "";
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

#check_before_update($ref,$dbh);
#for $href ( @{$ref} ) {
#check_before_update($ref,$dbh);
if ($ref->{cname} eq "") {
	print "Name $ref->{cname} empty <br>";
	exit(1);
}

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{cid}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# insertIntoStock
########################################################################

sub insertIntoStock {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";

$ref->{sid} = 0 ;
$ref->{uidreceived} = $iduser;
if ($ref->{uidreceived} eq "") {
	undef($ref->{uidreceived});
}

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

#check_before_update($ref,$dbh);
#for $href ( @{$ref} ) {
#check_before_update($ref,$dbh);
if ($ref->{cid} eq "") {
	print "Name $ref->{cid} empty <br>";
	exit(1);
}

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
#print"$sql<br>";
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{sid}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# insertIntoTag
########################################################################

sub insertIntoTag {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";

$ref->{idtag}    = 0 ;
$ref->{tentered} = $iduser ;

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

if (($ref->{tgroup} eq "") or ($ref->{tname} eq "") or ($ref->{ttag} eq "") or ($ref->{tdualindex} eq "")) {
	print "Please fill in Group, Name and Tag. <br>";
	exit(1);
}

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
#print"$sql<br>";
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idtag}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# insertIntoRun2stock
########################################################################

sub insertIntoRun2stock {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";

$ref->{idrun2stock}  = 0 ;
$ref->{entered}      = $iduser ;
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};


$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idrun2stock}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# insertIntoSample2library
########################################################################

sub insertIntoSample2library {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";

$ref->{idsample2library} = 0 ;
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};


$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idsample2library}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# insertIntoShopping
########################################################################

sub insertIntoShopping {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{idshopping} = 0 ;
$ref->{buser}      = $iduser;

my $sql = "";
my $sth = "";
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

#check_before_update($ref,$dbh);
if ($ref->{bnumber} eq "") {
	print "Article Number $ref->{bnumber} empty <br>";
	exit(1);
}

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idshopping}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editLane
########################################################################

sub editLane {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";



$dbh->{AutoCommit}=0;
eval {
$ref->{aversion}=&checkVersion($dbh,$table,"aid","aversion",$ref->{aid},$ref->{aversion});
#print "refpversion $ref->{pversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
	#print "$field<br>";
}

$sql = sprintf "UPDATE %s SET %s WHERE aid=$ref->{aid}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
};
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("commit");
}

$sth->finish;

}
########################################################################
# checkVersion prueft ob sich die Versionnummer erhoeht hat
# wenn ok, wird die Versionsnummer um 1 erhoeht
########################################################################

sub checkVersion {
my $dbh        = shift;
my $table      = shift;
my $idfield    = shift; # id field
my $field      = shift; # version field
my $id         = shift;
my $version    = shift;
my $sql        = "";
my $sth        = "";
my $actversion = 0;

$sql = "SELECT $field
	FROM $table
	WHERE $idfield=$id
	";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$actversion = $sth->fetchrow_array;
#print "version    $version<br>";
#print "actversion $actversion<br>";
if ($version != $actversion) {
	showMenu("");
	print "Data have been updated by another user. Nothing done.<br>";
	printFooter();
	exit(0);
}
else {
	$actversion++;
}
$actversion;
}
########################################################################
# editLibrary
########################################################################

sub editLibrary {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";

$ref->{lname} = uc($ref->{lname});
$ref->{'uid'} = $iduser;
if ($ref->{'uid'} eq "") {
	undef($ref->{uid});
}
if ($ref->{idtag} eq "") {
	undef($ref->{idtag});
}
if ($ref->{idtag2} eq "") {
	undef($ref->{idtag2});
}

#check_before_update($ref,$dbh);
if ($ref->{lname} eq "") {
	showMenu("");
	print "Please fill in a library name.Nothing done.<br>";
	printFooter();
	exit(1);
}

$dbh->{AutoCommit}=0;
#start eval
eval {
$ref->{lversion}=&checkVersion($dbh,$table,"lid","lversion",$ref->{lid},$ref->{lversion});
#print "lversion $ref->{lversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}
$sql = sprintf "UPDATE %s SET %s WHERE lid=$ref->{lid}",
         $table, join(",", @fields2);
	 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
}; #end eval
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("commit");
}
$sth->finish;

}
########################################################################
# editPool
########################################################################

sub editPool {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";

$ref->{oname}    = uc($ref->{oname});
$ref->{oentered} = $iduser;

#check_before_update($ref,$dbh);
if ($ref->{oname} eq "") {
	showMenu("");
	print "Please fill in a pool name.Nothing done.<br>";
	printFooter();
	exit(1);
}

if ($ref->{obarcode} eq "") {
	undef($ref->{obarcode});
}
if ($ref->{oplate} eq "") {
	undef($ref->{oplate});
}
if ($ref->{orow} eq "") {
	undef($ref->{orow});
}
if ($ref->{ocolumn} eq "") {
	undef($ref->{ocolumn});
}

$dbh->{AutoCommit}=0;
#start eval
eval {
$ref->{oversion}=&checkVersion($dbh,$table,"idpool","oversion",$ref->{idpool},$ref->{oversion});
#print "lversion $ref->{lversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}
$sql = sprintf "UPDATE %s SET %s WHERE idpool=$ref->{idpool}",
         $table, join(",", @fields2);
	 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
}; #end eval
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("commit");
}
$sth->finish;

}
########################################################################
# editLibrary2pool
########################################################################

sub editLibrary2pool {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";
my $lane     = "";

# it is not allowed to change to pool content
# when the pool has already been assigned to a run
$sql="
SELECT idpool 
FROM lane
WHERE idpool=$ref->{idpool}";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
$lane = $sth->fetchrow_array;
if ($lane>0) {
	showMenu("");
	print "Pool is already sequenced. Not allowed to change. Lane $lane<br>";
	printFooter();
	exit;
}


if (($ref->{lid} eq "") or ($ref->{idpool} eq "")) {
	showMenu("");
	print "Please fill in a library and pool name. Nothing done.<br>";
	printFooter();
	exit(1);
}

$dbh->{AutoCommit}=0;
#start eval
eval {
$ref->{loversion}=&checkVersion($dbh,$table,"idlibrary2pool","loversion",$ref->{idlibrary2pool},$ref->{loversion});
#print "lversion $ref->{lversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}
$sql = sprintf "UPDATE %s SET %s WHERE idlibrary2pool=$ref->{idlibrary2pool}",
         $table, join(",", @fields2);
	 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
}; #end eval
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("commit");
}
$sth->finish;

}
########################################################################
# editRun
########################################################################

sub editRun {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql              = "";
my $sth              = "";
my @fields           = (); # into run
my @values           = (); # into run
my @fields2          = ();
my $field            = "";
my $value            = "";
my $key              = "";
my $i                = 0;
my @lane_idpool      = ();
my @lane_mol         = ();
my @lane_read1failed = ();
my @lane_read2failed = ();
my @lane             = ();
my %aidold           = ();
my @row              = ();
my $insertflag       = "";

delete($ref->{barcode1});
delete($ref->{barcode2});
delete($ref->{barcode3});
delete($ref->{barcode4});
delete($ref->{barcode5});
delete($ref->{barcode6});
delete($ref->{barcode7});
delete($ref->{barcode8});
delete($ref->{barcode1validation});
delete($ref->{barcode2validation});
delete($ref->{barcode3validation});
delete($ref->{barcode4validation});
delete($ref->{barcode5validation});
delete($ref->{barcode6validation});
delete($ref->{barcode7validation});
delete($ref->{barcode8validation});

$ref->{rname} = uc($ref->{rname});
$ref->{uid}   = $iduser;
if ($ref->{uid} eq "") {
	undef($ref->{uid});
}
#check_before_update($ref,$dbh);
if ($ref->{rname} eq "") {
	showMenu("");
	print "Please enter the flowcell barcode.Nothing done.<br>";
	printFooter();
	exit(1);
}
if ($ref->{idpool1} < 1) {
	showMenu("");
	print "Please select at least a library for lane 1.Nothing done.<br>";
	printFooter();
	exit(1);
}

#separate run and lane table entries
$dbh->{AutoCommit}=0;
#start eval
eval {
$ref->{rversion}=&checkVersion($dbh,$table,"rid","rversion",$ref->{rid},$ref->{rversion});
$i = 0;
foreach $key (keys %$ref) {
	if ($key =~ /^idpool\d+$/) {
		$i++;
		if ($ref->{$key} < 1) {
			$ref->{$key} =-1
		}
		push(@lane_idpool,$ref->{$key});
		push(@lane,$i);
	}
	elsif ($key =~ /^mol\d+$/) {
		if ($ref->{$key} eq "") {
			($ref->{$key}='NULL');
		}
		else {
			$ref->{$key}= "'" . $ref->{$key} . "'";
		}
		push(@lane_mol,$ref->{$key});
		#print "lane @lane @lane_mol<br>";
	}
	elsif ($key =~ /^read1failed\d+$/) {
		if ($ref->{$key} eq "") {
			($ref->{$key}='NULL');
		}
		else {
			$ref->{$key}= "'" . $ref->{$key} . "'";
		}
		push(@lane_read1failed,$ref->{$key});
		#print "lane @lane @lane_read1failed<br>";
	}
	elsif ($key =~ /^read2failed\d+$/) {
		if ($ref->{$key} eq "") {
			($ref->{$key}='NULL');
		}
		else {
			$ref->{$key}= "'" . $ref->{$key} . "'";
		}
		push(@lane_read2failed,$ref->{$key});
		#print "lane @lane @lane_read2failed<br>";
	}
	else {
		push(@fields,$key);
		push(@values,$ref->{$key});
	}
	
}
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

#update run table
$sql = sprintf "UPDATE %s SET %s WHERE rid=$ref->{rid}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";

# suche die schon existierenden Lanes
$sql = "SELECT alane,aid
	FROM lane
	WHERE rid = $ref->{rid}
	";
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute || die print "$DBI::errstr";

while (@row = $sth->fetchrow_array) {
	$aidold{$row[0]}=$row[1];
}
	
# edit,delete or insert into lane
$i=0; 
foreach (@lane_idpool) {
	$insertflag ="";
	$sql= "";
	if (exists $aidold{$i+1}) {
		$insertflag = "n";
	}
	#print "aidold $aidold{$i+1} $insertflag <br>";
	if ($insertflag ne "n") {
		unless ($lane_idpool[$i] == -1) { #hier werden die leeren html-Felder aussortiert
		$sql = "INSERT INTO lane
			(aid,alane,rid,idpool,amolar,aread1failed,aread2failed)
			VALUES (0,$lane[$i],$ref->{rid},$lane_idpool[$i],$lane_mol[$i],
			    $lane_read1failed[$i],$lane_read2failed[$i])
			";
		}
	}
	else {
		if ($lane_idpool[$i] == -1) { 
		$sql = "DELETE 
			FROM lane
			WHERE aid = $aidold{$i+1}
			";
		}
		else {
		$sql = "UPDATE lane
			SET alane=$lane[$i],rid=$ref->{rid},idpool=$lane_idpool[$i],amolar=$lane_mol[$i],
			    aread1failed=$lane_read1failed[$i],aread2failed=$lane_read2failed[$i]
			WHERE aid = $aidold{$i+1}
			";
		}
	}
	#print "$i $sql<br>";
	if ($sql ne "") {
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}

	$i++;
}
};
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("commit");
}
$sth->finish;

}
########################################################################
# editKit
########################################################################

sub editKit {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
my @fields2   = ();
my $field     = "";
my $value     = "";

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

#check_before_update($ref,$dbh);
if ($ref->{cname} eq "") {
	print "Name $ref->{cname} empty <br>";
	exit(1);
}

$sql = sprintf "UPDATE %s SET %s WHERE cid=$ref->{cid}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$sth->finish;

}
########################################################################
# editStock
########################################################################

sub editStock {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";
$ref->{uidreceived} = $iduser;
if ($ref->{uidreceived} eq "") {
	undef($ref->{uidreceived});
}

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

#check_before_update($ref,$dbh);
if ($ref->{cid} eq "") {
	print "Kit $ref->{cid} empty <br>";
	exit(1);
}

$sql = sprintf "UPDATE %s SET %s WHERE sid=$ref->{sid}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$sth->finish;

}
########################################################################
# editTag
########################################################################

sub editTag {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";

$ref->{tentered} = $iduser;
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

if (($ref->{tgroup} eq "") or ($ref->{tname} eq "") or ($ref->{ttag} eq "")) {
	print "Please fill in Group, Name and Tag. <br>";
	exit(1);
}

$sql = sprintf "UPDATE %s SET %s WHERE idtag=$ref->{idtag}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$sth->finish;

}
########################################################################
# editRun2stock
########################################################################

sub editRun2stock {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";

$ref->{entered} = $iduser;
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}


$sql = sprintf "UPDATE %s SET %s WHERE idrun2stock=$ref->{idrun2stock}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$sth->finish;

}
########################################################################
# editSample2library old wird nicht mehr benutzt?
########################################################################

sub editSample2library {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}


$sql = sprintf "UPDATE %s SET %s WHERE idsample2library=$ref->{idsample2library}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$sth->finish;

}
########################################################################
# editShopping
########################################################################

sub editShopping {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

my $sql       = "";
my $sth       = "";
$ref->{buser} = $iduser;
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
my @fields2   = ();
my $field     = "";
my $value     = "";

foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

#check_before_update($ref,$dbh);
if ($ref->{bnumber} eq "") {
	print "Article Number $ref->{uname} empty <br>";
	exit(1);
}

$sql = sprintf "UPDATE %s SET %s WHERE idshopping=$ref->{idshopping}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$sth->finish;

}
########################################################################
# recalculatePool
########################################################################
sub recalculatePool {
my $self              = shift;
my $ref               = shift;
my $dbh               = shift;
my $out               = "";
my $idpool            = $ref->{idpool};
my $npool             = 0;
my $poolconentration  = $ref->{'oaimedconcentration'};
my $poolvolume        = $ref->{'ovolume'};
my $usedvolume        = $ref->{'ousedvolume'};
$poolvolume = $poolvolume-$usedvolume;
my @row               = ();
my @labels            = ();
my $i                 = 0;
my $n                 = 1;
my $max_mapped        = 0;
my $initial_volume    = 0;
my $new_concentration = 0;
my $new_volume        = 0;
my $additional_volume = 0;

# max_mapped
my $query = "
SELECT  max(es.mapped) 
FROM pool o
INNER JOIN library2pool       lo ON o.idpool    = lo.idpool
INNER JOIN library             l ON lo.lid      = l.lid
INNER JOIN sample2library     sl ON l.lid       = sl.lid
INNER JOIN $exomedb.sample     s ON sl.idsample = s.idsample
INNER JOIN $exomedb.exomestat es ON s.idsample  = es.idsample
WHERE o.idpool = $idpool
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$max_mapped = $out->fetchrow_array;


my $query = "
SELECT 
s.name,
l.lname,
l.lqpcr,
es.avgcov,
es.mapped
FROM pool o
INNER JOIN library2pool       lo ON o.idpool    = lo.idpool
INNER JOIN library             l ON lo.lid      = l.lid
INNER JOIN sample2library     sl ON l.lid       = sl.lid
INNER JOIN $exomedb.sample     s ON sl.idsample = s.idsample
INNER JOIN $exomedb.exomestat es ON s.idsample  = es.idsample
WHERE o.idpool = $idpool
ORDER BY es.mapped
";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$npool = $out->rows;

@labels	= (
'n',
'Sample<br>Name',
'Library<br>Name',
'qPCR<br>(nMol)',
'Initial Volume -<br>Used Volume',
'Average<br>Coverage',
'Mapped<br>Reads',
'New Concentration<br>(Mapped Reads/Initial Volume)',
'New Volume<br>(highest mapped reeds/<br>Concentration)',
'Additional<br>Volume'
);

print "POOL ID $idpool<br>";
print "POOL Name $idpool<br><br>";

&tableheader("1400px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	#$initial_volume    = 1;
	if (($row[2] == 0) or ($row[2] eq "")){
			print "No qPCR values available for sample $row[0]<br><br>";
			exit(1);
	}
	else {
		$initial_volume    = ($poolconentration*$poolvolume)/($npool*$row[2]); #$row[2]=lqpcr
	}
	$new_concentration = $row[4]/$initial_volume; # mapped reads / initial volume
	$new_volume        = $max_mapped/$new_concentration;
	$additional_volume = $new_volume-$initial_volume;
	$initial_volume    = sprintf("%.1f",$initial_volume);
	$new_concentration = sprintf("%.0f",$new_concentration);
	$new_volume        = sprintf("%.1f",$new_volume);
	$additional_volume = sprintf("%.1f",$additional_volume);
	if ($i == 0) {
		print "<td align=\"center\">$n</td>";
	}
	foreach (@row) {
		print "<td align=\"center\">$row[$i]</td>";
		if ($i == 2) {
			print "<td align=\"center\">$initial_volume</td>";
		}
		if ($i == 4) {
			print "<td align=\"center\">$new_concentration</td>";
			print "<td align=\"center\">$new_volume</td>";
			print "<td align=\"center\">$additional_volume</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}

print "</tbody></table></div>";
&tablescript;

}

########################################################################
# searchResults resultssearch
########################################################################
sub searchResults {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $where     = "";
my $start     = "";
my $end       = "";
my $estart    = "";
my $eend      = "";
my $color     = "";
my $group     = "";
my $runs      = "";
my $laneswith = "";
my @values2   = ();
my $field     = "";
my $order     = "p.pname,r.rdate,a.alane";
my $i         = 0;
my $projectLibrary = "";
my $readlink  = " LEFT JOIN rread e ON a.aid = e.aid ";

if ($ref->{withlanes} eq 'only_runs') {
	$runs = "
	DISTINCT r.rinstrument,
	CONCAT('<a href=\"run.pl?id=',r.rid,'&amp;mode=edit\">',r.rname,'</a>'),
	t.name,
	(select group_concat(st.lot,' ',st.lot2 separator ' ') FROM run rr	
	INNER JOIN run2stock rs ON rr.rid = rs.rid
	INNER JOIN stock st ON rs.sid=st.sid
	WHERE rr.rid=r.rid),
	r.rcomment,
	r.rfailed,
	r.rmenuflag,
	r.rdate,
	REPLACE(LENGTH(REPLACE(GROUP_CONCAT(a.aread1failed SEPARATOR ''),'F','')),'0',''),
	REPLACE(LENGTH(REPLACE(GROUP_CONCAT(a.aread2failed SEPARATOR ''),'F','')),'0','')
	";
	$group = " GROUP BY r.rid ";
}
else { # libraries or all lanes
	if ($ref->{withlanes} eq 'T') {
		$laneswith   = "
				,CONCAT('<a href=\"run.pl?id=',r.rid,'&amp;mode=edit\">',r.rname,'</a>'),
				t.name,
				r.rdate,
				r.rmenuflag,
				CONCAT('<a href=\"lane.pl?id=',a.aid,'\">',a.alane,'</a>'),
				amolar,
				REPLACE(REPLACE(INSERT(aread1failed,2,0,'     '),'F',''),'T','failed'),
				REPLACE(REPLACE(INSERT(aread2failed,2,0,'     '),'F',''),'T','failed'),
				REPLACE(REPLACE(INSERT(apaid,2,0,'    '),'F',''),'T','paid')
				";
	}
	$projectLibrary   = "
	CONCAT('<a href=\"../snvedit/project.pl?id=',p.idproject,'&amp;mode=edit\">',p.pname,'</a>'),
	p.pdescription,
	p.pmenuflag,
	CONCAT('<a href=\"library.pl?id=',l.lid,'&amp;idproject=',p.idproject,'&amp;mode=edit\">',l.lname,'</a>'),
	l.ldescription,
	l.lkit,
	l.lstatus,
	l.lfailed,
	l.lforpool,
	l.lquality,
	l.lmenuflag,
	CONCAT('<a href=\"pool.pl?id=',o.idpool,'&amp;mode=edit\">',o.oname,'</a>'),
	o.odescription
	$laneswith
	"
	
}
if ($ref->{withlanes} eq 'only_runs') {
@labels	= (
	'n',
	'Machine',
	'Flowcell',
	'Run Des.',
	'Lots',
	'Comment',
	'Failed comment',
	'Flag',
	'Date',
	'Failed 1',
	'Failed 2',
	);
	$readlink = " ";
}
elsif ($ref->{withlanes} eq 'T'){ # libraries and Runs
	@labels	= (
	'n',
	'Project Name',
	'Project Des.',
	'Flag',
	'Library Name',
	'Library Des.',
	'Kit',
	'Status',
	'Failed',
	'Pool',
	'Quality',
	'Flag',
	'Pool Name',
	'Pool Des.',
	'Flowcell',
	'Run Des.',
	'Date',
	'Flag',
	'Lane',
	'pMol',
	'Read1',
	'Read2',
	'Paid',
	);
}
elsif ($ref->{withlanes} eq 'F'){ # libraries only
	@labels	= (
	'n',
	'Project Name',
	'Project Des.',
	'Flag',
	'Library Name',
	'Library Des.',
	'Kit',
	'Status',
	'Failed',
	'Pool',
	'Quality',
	'Flag',
	'Pool Name',
	'Pool Des.'
	);
}


if ($ref->{order} eq 'Date') {
	$order="r.rdate ,r.rname, a.alane";
}
delete($ref->{order});
if ($ref->{withlanes} eq 'F'){ # libraries only
	$order = " l.lname ";
}
delete($ref->{withlanes});

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "idproject") {
			$field= "p." . $field;
		}
		if ($field eq "lname") {
			$field= "l." . $field;
		}
		if ($field eq "obarcode") {
			$field= "o." . $field;
		}
		if ($field eq "rid") {
			$field= "r." . $field;
		}
		if ($field eq "rname") {
			$field= "r." . $field;
		}
		if ($field eq "datebegin") {
			$where .= " r.rdate >= '$values[$i]' ";
		}
		elsif ($field eq "dateend") {
			$where .= " r.rdate <= '$values[$i]' ";
		}
		else {
			$where .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}


if ($where ne "") {
	$where = "WHERE  $where";
}

$query = "SELECT DISTINCT
	$projectLibrary
	$runs
	FROM library l 
	INNER JOIN sample2library sl ON l.lid=sl.lid
	INNER JOIN $exomedb.sample s  ON sl.idsample=s.idsample
	RIGHT JOIN $exomedb.project p ON s.idproject=p.idproject 
	LEFT JOIN library2pool lo ON l.lid=lo.lid
	LEFT JOIN pool o ON lo.idpool=o.idpool
	LEFT JOIN lane a ON o.idpool=a.idpool
	LEFT JOIN run r ON r.rid=a.rid
	LEFT JOIN runtype t ON t.runtypeid=r.rdescription
	$readlink
	$where
	$group
	ORDER BY $order 
	";
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

$i=0;


&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

my $n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	if ($i == 0) {
		print "<td align=\"center\"> $n</td>";
	}
	foreach (@row) {
		print "<td align=\"center\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}

print "</tbody></table></div>";
#&tablescript;


$out->finish;
}
########################################################################
# listKit not used
########################################################################
sub listKit {
my $self         = shift;
my $dbh          = shift;

my $query  = "";
my $out    = "";
my @row    = ();
my $i      = 0;
my @labels = ();

$query = "SELECT  cid,cname,cdescription,cmenuflag FROM kit ORDER BY cname";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'Action',
	'Kit number',
	'Description',
	'Flag'
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td align=\"center\"><a href=\"kit.pl?id=$row[$i]&mode=edit\">edit</a></td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>";
}
print "</table>";
print "</form>";

}
########################################################################
# listNewPools
########################################################################
sub listNewPools {
my $self         = shift;
my $dbh          = shift;

my $query  = "";
my $out    = "";
my @row    = ();
my $i      = 0;
my @labels = ();

$query = "
SELECT DISTINCT 
CONCAT('<a href=\"pool.pl?id=',o.idpool,'&mode=edit\">',o.idpool,'</a>'),
p.pname,
p.pdescription,
o.oname,
o.odescription,
o.ocomment,
o.omenuflag
FROM pool o
LEFT JOIN library2pool lo ON lo.idpool=o.idpool
LEFT JOIN library l ON l.lid=lo.lid
LEFT JOIN sample2library sl ON l.lid=sl.lid
LEFT JOIN $exomedb.sample s ON sl.idsample=s.idsample
LEFT JOIN $exomedb.project p ON s.idproject=p.idproject
WHERE o.omenuflag = 'T'
ORDER BY pname DESC,oname";
#WHERE ISNULL(a.aid)

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";


@labels	= (
	'Pool Id',
	'Project Name',
	'Project Des',
	'Pool Name',
	'Pool Description',
	'Pool Comment',
	'Flag'
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td>$row[$i]</td>";
		$i++;
	}
	print "</tr>";
}
print "</table>";
print "</form>";

}
########################################################################
# listTags
########################################################################
sub listTags {
my $self         = shift;
my $dbh          = shift;

my $query  = "";
my $out    = "";
my @row    = ();
my $i      = 0;
my @labels = ();

$query = "
	SELECT   
	CONCAT('<a href=\"tag.pl?id=',idtag,'&mode=edit\">',idtag,'</a>'),
	tgroup,
	tname,
	tdualindex,
	ttag
	FROM tag 
	ORDER BY
	tgroup,tname
";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";


@labels	= (
	'Index Id',
	'Group',
	'Name',
	'Dualindex',
	'Index'
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td>$row[$i]</td>";
		$i++;
	}
	print "</tr>";
}
print "</table>";
print "</form>";

}
########################################################################
# listStock
########################################################################
sub listStockOld {
my $self         = shift;
my $dbh          = shift;

my $query  = "";
my $out    = "";
my @row    = ();
my $i      = 0;
my $n      = 1;
my @labels = ();

$query = "SELECT  sid,cname,cdescription,u.uname,sgetdate,v.uname,pname,suseddate,scomment 
	  FROM stock s
	  LEFT JOIN user u       ON u.uid=s.uidreceived
	  LEFT JOIN kit c        ON c.cid=s.cid
	  LEFT JOIN project p    ON p.pid=s.pid
	  ORDER BY cname,sgetdate,suseddate";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'Action',
	'Kit Number',
	'Description',
	'Received from',
	'Received',
	'Used from',
	'For Project',
	'Used',
	'Comment'
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td align=\"right\">$n</td>";
			print "<td align=\"center\"><a href=\"stock.pl?id=$row[$i]&mode=edit\">edit</a></td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	$n++;
	print "</tr>";
}
print "</table>";
print "</form>";

}
########################################################################
# searchStock resultsStock
########################################################################
sub searchStock {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $query  = "";
my $where  = "";
my $out    = "";
my @row    = ();
my $i      = 0;
my $n      = 1;
my @labels = ();
my @values2   = ();
my $field     = "";

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "cid") {
			$field= "s." . $field;
		}
		if ($field eq "idrun2stock") {
			if ($values[$i] eq "not_used") {
				$where .= " ISNULL(idrun2stock) AND smenuflag='T'";
			}
			elsif ($values[$i] eq "used") {
				$where .= " (idrun2stock) IS NOT NULL  OR smenuflag='F'";
			}
		}
		else {
			$where .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}

if ($where ne "") {
	$where = "WHERE  $where";
}

$query = "SELECT  s.sid,cname,cdescription,u.name,sgetdate,
	  expiration,lot,expiration2,lot2,
	  r.rname,r.rdate,
	  replacement,scomment 
	  FROM stock s
	  LEFT JOIN $logindb.user u ON u.iduser = s.uidreceived
	  LEFT JOIN kit           c ON c.cid    = s.cid
	  LEFT JOIN run2stock    rs ON rs.sid   = s.sid
	  LEFT JOIN run           r ON r.rid    = rs.rid
	  $where
	  ORDER BY cname,sgetdate";
	  
#print "$query <br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";


@labels	= (
	'n',
	'Action',
	'Kit Number',
	'Description',
	'Received from',
	'Received',
	'Expiration1',
	'Lot1',
	'Expiration2',
	'Lot2',
	'Run',
	'Flowcell Date',
	'Replac.',
	'Comment'
	);


&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td align=\"right\">$n</td>";
			print "<td align=\"center\"><a href=\"stock.pl?id=$row[$i]&mode=edit\">$row[$i]</a></td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	$n++;
	print "</tr>";
}
print "</tbody></table></div>";
#&tablescript;
print "</form>";

}
########################################################################
# searchErrorRate resultsstatistics 
########################################################################
sub searchErrorRate {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $query    = "";
my $where    = "";
my $whereR   = "";
my $out      = "";
my @row      = ();
my $i        = 0;
my $n        = 1;
my $failed   = "";
my $field    = "";
my @labels   = ();
my @values2  = ();
my $maxerror = 100;
my $order    = "p.pname,r.rdate,a.alane,e.readNumber";
my $order_pairs  = "p.pname,r.rdate,a.alane";

if ($ref->{order} eq 'Date') {
	$order="r.rdate,r.rid,a.alane,e.readNumber";
	$order_pairs="r.rdate,r.rid,a.alane";
}
delete($ref->{order});

if ($ref->{failed} eq 'F') {  # schlecht: reads nicht normalisiert
	$order="r.rdate ,a.alane,e.readNumber";
	$order_pairs="r.rdate ,a.alane";
	$failed = "((aread1failed = 'F' AND readnumber = 1)
	OR   (aread2failed = 'F' AND readnumber = 2))";
}
if ($ref->{failed} eq 'T') {
	$order="r.rdate ,a.alane,e.readNumber";
	$order_pairs="r.rdate ,a.alane";
	$failed = "((aread1failed = 'T' AND readnumber = 1)
	OR   (aread2failed = 'T' AND readnumber = 2))";
}
delete($ref->{failed});

if (exists($ref->{errorPF}) and ($ref->{errorPF} ne "")) {
	$maxerror=$ref->{errorPF};
}
delete($ref->{errorPF});


##################  Runs ########################################
print "<br><span class=\"big\">All runs and lanes (including failed and unfinished)</span><br><br>";

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($field eq "readNumber") {
			$i++;
			next;
		}
		if ($where ne "") {
			$where  .= " AND ";
		}
		if ($field eq "idproject") {
			$field= "p." . $field;
		}
		if ($field eq "lid") {
			$field= "l." . $field;
		}
		if ($field eq "rid") {
			$field= "r." . $field;
		}
		if ($field eq "datebegin") {
			$where  .= " r.rdate >= '$values[$i]' ";
		}
		elsif ($field eq "dateend") {
			$where  .= " r.rdate <= '$values[$i]' ";
		}
		else {
			$where  .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
#print "$where @values<br>";
# nruns and nlanes
$query = "SELECT COUNT(DISTINCT(r.rid)), COUNT(DISTINCT(a.aid))
		FROM lane a, library l, run r, pool o, library2pool lo, 
		sample2library sl, $exomedb.sample s, $exomedb.project p
		WHERE l.lid=lo.lid
		AND   lo.idpool=o.idpool
		AND   o.idpool=a.idpool
		AND   a.rid=r.rid
		AND   l.lid=sl.lid
		AND   sl.idsample=s.idsample
		AND   s.idproject=p.idproject
		AND   $where
		";
#print "@values2<br>$where<br>$query<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";
my ($nruns,$nlanes) = $out->fetchrow_array;

# read1failed
$query = "SELECT COUNT(DISTINCT (a.aid))
		FROM lane a, library l, run r, pool o, library2pool lo,
		sample2library sl, $exomedb.sample s, $exomedb.project p
		WHERE l.lid=lo.lid
		AND   lo.idpool=o.idpool
		AND   o.idpool=a.idpool
		AND   a.rid=r.rid
		AND   l.lid=sl.lid
		AND   sl.idsample=s.idsample
		AND   s.idproject=p.idproject
		AND   a.aread1failed = 'T'
		AND   $where
		";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";
my ($read1failed) = $out->fetchrow_array;

# read2failed
$query = "SELECT COUNT(DISTINCT (a.aid))
		FROM lane a, library l, run r, pool o, library2pool lo,
		sample2library sl, $exomedb.sample s, $exomedb.project p
		WHERE l.lid=lo.lid
		AND   lo.idpool=o.idpool
		AND   o.idpool=a.idpool
		AND   a.rid=r.rid
		AND   l.lid=sl.lid
		AND   sl.idsample=s.idsample
		AND   s.idproject=p.idproject
		AND   a.aread2failed = 'T'
		AND   $where
		";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";
my ($read2failed) = $out->fetchrow_array;

print "Runs  $nruns<br>";
print "Lanes $nlanes<br>";
print "Read1 failed $read1failed<br>";
print "Read2 failed $read2failed<br>";

#################################################################
#nochmal where, um readnumber einzuschliessen
$where     = "";
@values2   = ();
@fields    = ();
@values    = ();
$i         = 0;
@fields    = sort keys %$ref;
@values    = @{$ref}{@fields};

foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where  .= " AND ";
			$whereR .= " AND ";
		}
		if ($field eq "idproject") {
			$field= "p." . $field;
		}
		if ($field eq "lid") {
			$field= "l." . $field;
		}
		if ($field eq "rid") {
			$field= "r." . $field;
		}
		if ($field eq "datebegin") {
			$where .= " r.rdate >= '$values[$i]' ";
			$whereR .= " r.rdate >= '$values[$i]' ";
		}
		elsif ($field eq "dateend") {
			$where  .= " r.rdate <= '$values[$i]' ";
			$whereR .= " r.rdate <= '$values[$i]' ";
		}
		else {
			$where  .= $field . " like ? ";
			$whereR .= $field . " like '$values[$i]' ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
if ($failed ne "") {
	if ($where ne "") {
		$where  .= " AND ";
		$whereR .= " AND ";
	}
	$where  .= " $failed ";
	$whereR .= " $failed ";
}


##################  Summary.htm Mean ########################################
print "<br><span class=\"big\">Summary</span><br><br>";

#truncate(sum(clusterCountPF*originalReadLength/1e7),3),

$query = "SELECT  
		Concat(count(DISTINCT e.rreadid),' Reads, % Error Rate <= ',$maxerror),
		truncate(sum(clusterCountPF*originalReadLength/1e9/
		(
		SELECT count(ll.lid)
		FROM lane aa, library ll, pool oo, library2pool lolo
		WHERE a.aid=aa.aid
	  	AND   ll.lid=lolo.lid
	  	AND   lolo.idpool=oo.idpool
	  	AND   oo.idpool=aa.idpool
		)
		),0),
		truncate(sum(clusterCountPF/1000000/
		(
		SELECT count(ll.lid)
		FROM lane aa, library ll, pool oo, library2pool lolo
		WHERE a.aid=aa.aid
	  	AND   ll.lid=lolo.lid
	  	AND   lolo.idpool=oo.idpool
	  	AND   oo.idpool=aa.idpool
		)
		),0),
		truncate(avg(clusterCountRaw/1000000),0),
		truncate(avg(clusterCountPF/1000000),0),
		truncate(avg(oneSig),0),
		truncate(avg(errorPF),2)
	  FROM $exomedb.sample s
	  INNER JOIN  sample2library sl  ON sl.idsample = s.idsample
	  INNER JOIN  $exomedb.project p ON s.idproject = p.idproject
	  INNER JOIN  library l          ON l.lid       = sl.lid
	  INNER JOIN  library2pool lo    ON l.lid       = lo.lid
	  INNER JOIN  pool o             ON lo.idpool   = o.idpool
	  INNER JOIN  lane a             ON o.idpool    = a.idpool
	  INNER JOIN  run r              ON a.rid       = r.rid
	  INNER JOIN  rread e            ON e.aid       = a.aid
	  WHERE errorPF<=$maxerror
	  AND   errorPF>=0
	  AND   $where
	  ";
	  # errorPF > 0 weil failed runs default 0-Werte haben
	  # geaendert 07.07.2012, weil runs ohne PhiX auch 0 error rate haben
	  #print "$query <br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n Reads',
	'Yield (Gb)',
	'Sum Clusters (PF M)',
	'Mean Clusters (raw M)',
	'Mean Clusters (PF M)',
	'Mean 1st Cycle Int (PF)',
	'Mean % Error Rate (PF)',
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			#print "<td align=\"right\">$n</td>";
			print "<td> $row[$i]</td>";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	$n++;
	print "</tr>";
}
print "</table>";
print "<br>";


##################  Summary.htm Error rate ########################################
#		GROUP_CONCAT(DISTINCT pdescription),
#		GROUP_CONCAT((l.lname) ORDER BY l.lname)

$query = "SELECT   r.rinstrument,
                rname,rdate,
		alane,readNumber,originalReadLength,amolar,	
		truncate(clusterCountPF*originalReadLength/1000000000,0),
		truncate(clusterCountRaw/1000000,0),
		truncate(clusterCountPF/1000000,0),
		oneSig,
		truncate(clusterCountPF/clusterCountRaw*100,2),
		percentUniquelyAlignedPF,averageAlignScorePF,errorPF,errorPFstdev
	  FROM rread e,lane a, library l, run r, pool o, library2pool lo,
	  sample2library sl, $exomedb.sample s, $exomedb.project p
	  WHERE e.aid=a.aid
	  AND   l.lid=lo.lid
	  AND   lo.idpool=o.idpool
	  AND   o.idpool=a.idpool
	  AND   a.rid=r.rid
	  AND   l.lid=sl.lid
	  AND   sl.idsample=s.idsample
	  AND   s.idproject=p.idproject
	  AND   errorPF<=$maxerror
	  AND   $where
	  GROUP BY a.aid,e.rreadid
	  ORDER BY $order
	  ";
	  
	  
#print "$query <br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Machine',
	'Run',
	'Date',
	'Lane',
	'Read',
	'Length',
	'pMol',
	'Yield (Gbases)',
	'Clusters (raw Mill)',
	'Clusters (PF Mill)',
	'1st Cycle Int (PF)',
	'% PF Clusters',
	'% Align (PF)',
	'Align Score (PF)',
	'% Error Rate (PF)',
	'stdev'
	);


&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td align=\"right\">$n</td>";
			print "<td> $row[$i]</td>";
		}
		elsif (($i >=1) and ($i <=4)) {
			print "<td align=\"left\"> $row[$i]</td>";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	$n++;
	print "</tr>";
}
print "</tbody></table></div>";
#&tablescript;

my $item   = "";
my $value  = "";
my %logins = ();
open(IN, "$text");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$logins{$item}=$value;
}
close IN;

$query = "SELECT   r.rinstrument,
                rname as flowcell,
		rdate,
		alane,readNumber,originalReadLength,amolar,	
		truncate(clusterCountPF*originalReadLength/1000000000,0),
		truncate(clusterCountRaw/1000000,0),
		truncate(clusterCountPF/1000000,0),
		oneSig as intensity,
		truncate(clusterCountPF/clusterCountRaw*100,2),
		percentUniquelyAlignedPF,averageAlignScorePF,
		errorPF as errorRate,errorPFstdev
	  FROM rread e,lane a, library l, run r, pool o, library2pool lo,
	  sample2library sl, $exomedb.sample s, $exomedb.project p
	  WHERE e.aid=a.aid
	  AND   l.lid=lo.lid
	  AND   lo.idpool=o.idpool
	  AND   o.idpool=a.idpool
	  AND   a.rid=r.rid
	  AND   l.lid=sl.lid
	  AND   sl.idsample=s.idsample
	  AND   s.idproject=p.idproject
	  AND   errorPF<=$maxerror
	  AND   $whereR
	  GROUP BY a.aid,e.rreadid
	  ORDER BY $order
	  ";
	  
#$R->run(qq`q<- q+geom_point(aes(x=paste(rdate,flowcell),y=errorRate,color=readNumber),show.legend=F) + ylim(0,3)`);

use Statistics::R;
my $R = Statistics::R->new();

$R->run(qq`library(lattice)`);
$R->run(qq`library(RMySQL)`);
$R->run(qq`library(ggplot2)`);

$R->run(qq`con <- dbConnect(MySQL(), user="$logins{dblogin}", password="$logins{dbpasswd}", dbname="$maindb")`);

$R->run(qq`mydata<-dbGetQuery(con, "$query")`);

$R->run(qq`png("/srv/www/htdocs/tmp/qcerror.png", width=1800, height=500)`);
$R->run(qq`q<-ggplot(na.omit(mydata))`);
$R->run(qq`q<- q+geom_point(aes(x=paste(rdate,flowcell),y=errorRate,color=readNumber),show.legend=F)`);
$R->run(qq`q<- q+theme(axis.text.x = element_text(angle = 90, hjust = 1))`);
#$R->run(qq`q<- q+geom_text(aes(x=paste(rdate,flowcell),y=errorRate,label=paste(flowcell,alane)),hjust=0,vjust=0)`);
$R->run(qq`q<- q+labs(x='Date',y='Error rate')`);
$R->run(qq`q`);

print "<br><br>";

print"<img src='/tmp/qcerror.png'>";

$R->run(qq`png("/srv/www/htdocs/tmp/qcintensity.png", width=1800, height=500)`);
$R->run(qq`q<-ggplot(na.omit(mydata))`);
$R->run(qq`q<- q+geom_point(aes(x=paste(rdate,flowcell),y=intensity,color=readNumber),show.legend=F)`);
$R->run(qq`q<- q+theme(axis.text.x = element_text(angle = 90, hjust = 1))`);
#$R->run(qq`q<- q+geom_text(aes(x=paste(rdate,flowcell),y=intensity,label=paste(flowcell,alane)),hjust=0,vjust=0)`);
$R->run(qq`q<- q+labs(x='Date',y='Intensity')`);
$R->run(qq`q`);

print "<br><br>";

print"<img src='/tmp/qcintensity.png'>";

$R->stop();

}
########################################################################
# searchYield resultsyield
########################################################################
sub searchYield {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $where     = "";
my $field     = "";
my $failed    = "";
my $query     = "";
my $out       = "";
my $maxerror  = 100;
my @labels    = "";
my @row       = "";
my @values2   = ();
my @fields    = ();
my @values    = ();
my $i         = 0;
my $n         = 1;
my $order     = "p.pdescription,r.rdate";
my $sumGB     = 0;
my %sumGB     = ();
my $lanes     = 0;
my $reads     = 0;
my %lanes     = ();
my $alllanes  = "";
my %libs      = ();
my %libsall   = ();
my $project   = "";
my $tmp       = "";
my %institution = ();
my %department  = ();



if ($ref->{order} eq 'Date') {
	$order="r.rdate,r.rid";
}
delete($ref->{order});
if ($ref->{failed} eq 'F') {  # schlecht: reads nicht normalisiert
	$failed = "((aread1failed = 'F' AND readnumber = 1)
	OR   (aread2failed = 'F' AND readnumber = 2))";
}
if ($ref->{failed} eq 'T') {
	$failed = "((aread1failed = 'T' AND readnumber = 1)
	OR   (aread2failed = 'T' AND readnumber = 2))";
}
delete($ref->{failed});
if (exists($ref->{errorPF}) and ($ref->{errorPF} ne "")) {
	$maxerror=$ref->{errorPF};
}
delete($ref->{errorPF});

@fields    = sort keys %$ref;
@values    = @{$ref}{@fields};

foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "idproject") {
			$field= "p." . $field;
		}
		if ($field eq "datebegin") {
			$where .= " r.rdate >= '$values[$i]' ";
		}
		elsif ($field eq "dateend") {
			$where .= " r.rdate <= '$values[$i]' ";
		}
		else {
			$where .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
if ($failed ne "") {
	if ($where ne "") {
		$where .= " AND ";
	}
	$where .= " $failed ";
}

#count(e.rreadid),

print "<br><span class=\"big\">Yield</span><br><br>";
#substring(l.lname,1,position('_' in replace(l.lname,' ','_'))-1),
################################################################
$query = "SELECT  
pdescription,
s.name,
group_concat(DISTINCT lname, ' ', ldescription),
group_concat(DISTINCT lt.ltlibtype),	
group_concat(DISTINCT lp.lplibpair),	
group_concat(DISTINCT r.rname),
group_concat(DISTINCT r.flowcellmode),
count(DISTINCT a.aid),
group_concat(DISTINCT e.originalReadLength),
count(e.rreadid),
(SELECT count(ll.lid)
FROM library ll, pool oo, library2pool lolo
WHERE oo.idpool=o.idpool
AND oo.idpool=lolo.idpool
AND lolo.lid=ll.lid) as pooled,
truncate(sum(clusterCountPF*originalReadLength/1000000000)/
(SELECT count(ll.lid)
FROM library ll, pool oo, library2pool lolo
WHERE oo.idpool=o.idpool
AND oo.idpool=lolo.idpool
AND lolo.lid=ll.lid),3) as Yield_GB_PF,
r.rdate
FROM $exomedb.sample s
INNER JOIN $exomedb.project p  ON s.idproject=p.idproject 
LEFT JOIN $exomedb.disease2sample ds  ON s.idsample=ds.idsample 
INNER JOIN sample2library sl   ON sl.idsample=s.idsample 
INNER JOIN library l           ON l.lid=sl.lid 
INNER JOIN library2pool lo     ON l.lid=lo.lid 
INNER JOIN pool o              ON lo.idpool=o.idpool 
INNER JOIN lane a              ON o.idpool=a.idpool 
INNER JOIN run r               ON a.rid=r.rid 
INNER JOIN rread e             ON e.aid=a.aid
LEFT  JOIN libtype lt          ON l.libtype=lt.ltid
LEFT  JOIN libpair lp          ON l.libpair=lp.lpid
WHERE   errorPF<=$maxerror
AND   $where
GROUP BY
p.idproject,l.lid,o.idpool
ORDER BY
$order
";
# errorPF > 0 weil failed runs default 0-Werte haben
# print "$query <br>";
# print "@values2 <br>";
#substring(l.lname,1,position('_' in replace(l.lname,' ','_'))-1)

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Project',
	'Sample',
	'Libraries',
	'LibType',
	'ReadType',
	'Flow cell',
	'Flow cell mode',
	'Lanes',
	'Length',
	'Reads',
	'Pooled',
	'Yield (Gb)',
	'Date'
	);


&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";


while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td>$n</td>";
		}
		print "<td> $row[$i]</td>";
		if ($i==11) { # Summe Yield 
			$sumGB+=$row[$i];
			$sumGB{substr($row[12],0,4)}+=$row[$i];
		}
		$i++;
	}
	print "</tr>";
	$n++;
}
print "</tbody></table></div>";
#&tablescript;


print "<br>";
################################################################
# calculate lanes and reads, libtype 7 is amplicon
$query = "SELECT
(count(DISTINCT a.aid)/
(SELECT count(ll.lid)
FROM library ll 
INNER JOIN library2pool lolo   ON lolo.lid=ll.lid 
INNER JOIN  pool oo            ON oo.idpool=lolo.idpool
WHERE oo.idpool=o.idpool  AND ll.libtype != 7
)) as lane,
(count(DISTINCT e.rreadid)/
(SELECT count(ll.lid)
FROM library ll 
INNER JOIN library2pool lolo   ON lolo.lid=ll.lid 
INNER JOIN  pool oo            ON oo.idpool=lolo.idpool
WHERE oo.idpool=o.idpool AND ll.libtype != 7
)) as rread,
group_concat(DISTINCT r.flowcellmode),
group_concat(DISTINCT e.originalReadLength),
p.pdescription,
p.institution,
p.department
FROM $exomedb.sample s
INNER JOIN $exomedb.project p ON s.idproject=p.idproject 
LEFT JOIN $exomedb.disease2sample ds  ON s.idsample=ds.idsample 
INNER JOIN sample2library sl   ON sl.idsample=s.idsample 
INNER JOIN library l           ON l.lid=sl.lid 
INNER JOIN library2pool lo     ON l.lid=lo.lid 
INNER JOIN pool o              ON lo.idpool=o.idpool 
INNER JOIN lane a              ON o.idpool=a.idpool 
INNER JOIN run r               ON a.rid=r.rid 
INNER JOIN rread e             ON e.aid=a.aid
WHERE errorPF<=$maxerror
AND   $where
GROUP BY p.idproject,l.lid,o.idpool,r.flowcellmode,e.originalReadLength
";
# errorPF > 0 weil failed runs default 0-Werte haben
#print "$query <br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";
# $row[4] = Projectdescription
# $row[2] = flowcellmode
# $row[3] = read length
# $row[0] = lanes
while (@row = $out->fetchrow_array) {
	$lanes += $row[0];
	$reads += $row[1];
	$lanes{$row[4]}{$row[2]}{$row[3]} += $row[0];
	$institution{$row[4]} = $row[5];
	$department{$row[4]} = $row[6];
}
#print "$where<br>";
# libraries because they can be in several pools
$query = "
SELECT
pdescription,
COUNT(DISTINCT l.lid),
group_concat(DISTINCT r.flowcellmode),
group_concat(DISTINCT e.originalReadLength),
lt.ltlibtype
FROM $exomedb.sample s
INNER JOIN $exomedb.project p  ON s.idproject=p.idproject 
LEFT JOIN $exomedb.disease2sample ds  ON s.idsample=ds.idsample 
INNER JOIN sample2library sl   ON sl.idsample=s.idsample 
INNER JOIN library l           ON l.lid=sl.lid 
INNER JOIN library2pool lo     ON l.lid=lo.lid 
INNER JOIN pool o              ON lo.idpool=o.idpool 
INNER JOIN lane a              ON o.idpool=a.idpool 
INNER JOIN run r               ON a.rid=r.rid 
INNER JOIN rread e             ON e.aid=a.aid
LEFT  JOIN libtype lt          ON l.libtype=lt.ltid
LEFT  JOIN libpair lp          ON l.libpair=lp.lpid
WHERE $where
GROUP BY p.idproject,l.libtype,r.flowcellmode,e.originalReadLength
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";
#row0 = project description
#row4 = libtype
#row2 = flowcellmode (if NovaSeq)
#row3 = ReadLength
#row1 = number of libs
while (@row = $out->fetchrow_array) {
	$libs{$row[0]}{$row[4]}{$row[2]}{$row[3]} += $row[1];
	$libsall{$row[4]}       += $row[1];
}


@labels	= (
	'Project',
	'Institution',
	'Department',
	'Lanes',
	'Flow cell',
	'Length',
	'Exomic',
	'Genomic',
	'RNA',
	'ChIP-Seq',
	'ChIP-Seq RNA',
	'MIP',
	'mtDNA',
	'DropSeq',
	'scRNA',
	'ATAC-Seq',
	'scATAC-Seq'
	);

#print q(<table border="1" cellspacing="0" cellpadding="0"> );
#print "<tr>";
my $readlength= 0;
my $flowcellmode = "";
&tableheaderDefault_new("table02","1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";
foreach $project (sort keys %lanes) {
	foreach $flowcellmode (sort keys %{$lanes{$project}}) {
	foreach $readlength (sort keys %{$lanes{$project}{$flowcellmode}}) {	
		$tmp = sprintf("%.2f",$lanes{$project}{$flowcellmode}{$readlength});
		$alllanes += $tmp;
		print "<tr>";
		print "<td>$project</td>";
		print "<td>$institution{$project}</td>";
		print "<td>$department{$project}</td>";
		print "<td align=\"right\">$tmp</td>";
		print "<td>$flowcellmode </td>";
		print "<td>$readlength </td>";
		print "<td align=\"right\">$libs{$project}{'exomic'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'genomic'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'RNA'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'ChIP-Seq'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'ChIP-Seq RNA'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'MIP'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'mtDNA'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'DropSeq'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'scRNA'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'ATAC-Seq'}{$flowcellmode}{$readlength}</td>";
		print "<td align=\"right\">$libs{$project}{'scATAC-Seq'}{$flowcellmode}{$readlength}</td>";
		print "</tr>";
	}
	}
}
print "<tr>";
print "<td>Sum</td>";
print "<td></td>";
print "<td></td>";
print "<td align=\"right\">$alllanes</td>";
print "<td align=\"right\"></td>";
print "<td align=\"right\"></td>";
print "<td align=\"right\">$libsall{'exomic'}</td>";
print "<td align=\"right\">$libsall{'genomic'}</td>";
print "<td align=\"right\">$libsall{'RNA'}</td>";
print "<td align=\"right\">$libsall{'ChIP-Seq'}</td>";
print "<td align=\"right\">$libsall{'ChIP-Seq RNA'}</td>";
print "<td align=\"right\">$libsall{'MIP'}</td>";
print "<td align=\"right\">$libsall{'mtDNA'}</td>";
print "<td align=\"right\">$libsall{'DropSeq'}</td>";
print "<td align=\"right\">$libsall{'scRNA'}</td>";
print "<td align=\"right\">$libsall{'ATAC-Seq'}</td>";
print "<td align=\"right\">$libsall{'scATAC-Seq'}</td>";
print "</tr>";
#print "</table>";
print "</tbody></table></div>";
&tablescriptnew("table02");
print "<br>";


$lanes = sprintf("%.2f",$lanes);
$reads = sprintf("%.2f",$reads);
$sumGB = sprintf("%.3f",$sumGB/1000);

@labels	= (
	'Lanes',
	'Reads',
	'Yield (Tb)'
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
print "<tr>";
print "<td align=\"center\"> $lanes</td>";
print "<td align=\"center\"> $reads</td>";
print "<td align=\"center\"> $sumGB</td>";
print "</tr>";
print "</table>";
print "<br>";
########################################################################
# GB per year
@labels	= (
	'Year',
	'Yield (Tb)'
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
foreach $tmp (sort keys %sumGB) {
	print "<tr>";
	$sumGB = sprintf("%.3f",$sumGB{$tmp}/1000);
	print "<td>$tmp</td><td align=\"center\"> $sumGB</td>";
	print "</tr>";
}
print "</table>";
print "<br>";

########################################################################
# calculate lanes and reads, libtype 7 is amplicon
%lanes = ();
%libs = ();
%libsall = ();
$query = "SELECT
(count(DISTINCT a.aid)/
(SELECT count(ll.lid)
FROM library ll 
INNER JOIN library2pool lolo   ON lolo.lid=ll.lid 
INNER JOIN  pool oo            ON oo.idpool=lolo.idpool
WHERE oo.idpool=o.idpool  AND ll.libtype != 7
)) as lane,
(count(DISTINCT e.rreadid)/
(SELECT count(ll.lid)
FROM library ll 
INNER JOIN library2pool lolo   ON lolo.lid=ll.lid 
INNER JOIN  pool oo            ON oo.idpool=lolo.idpool
WHERE oo.idpool=o.idpool AND ll.libtype != 7
)) as rread,
substring(r.rdate,1,4)
FROM $exomedb.sample s
INNER JOIN $exomedb.project p  ON s.idproject=p.idproject 
LEFT JOIN $exomedb.disease2sample ds  ON s.idsample=ds.idsample 
INNER JOIN sample2library sl   ON sl.idsample=s.idsample 
INNER JOIN library l           ON l.lid=sl.lid 
INNER JOIN library2pool lo     ON l.lid=lo.lid 
INNER JOIN pool o              ON lo.idpool=o.idpool 
INNER JOIN lane a              ON o.idpool=a.idpool 
INNER JOIN run r               ON a.rid=r.rid 
INNER JOIN rread e             ON e.aid=a.aid
WHERE errorPF<=$maxerror
AND   $where
GROUP BY substring(r.rdate,1,4),l.lid,o.idpool
";
# errorPF > 0 weil failed runs default 0-Werte haben
#print "$query <br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

while (@row = $out->fetchrow_array) {
	$lanes += $row[0];
	$reads += $row[1];
	$lanes{$row[2]} += $row[0];
}
#print "$where<br>";
# libraries because they can be in several pools
$query = "
SELECT
substring(r.rdate,1,4),
COUNT(DISTINCT l.lid),
lt.ltlibtype
FROM $exomedb.sample s
INNER JOIN $exomedb.project p  ON s.idproject=p.idproject 
LEFT JOIN $exomedb.disease2sample ds  ON s.idsample=ds.idsample 
INNER JOIN sample2library sl   ON sl.idsample=s.idsample 
INNER JOIN library l           ON l.lid=sl.lid 
INNER JOIN library2pool lo     ON l.lid=lo.lid 
INNER JOIN pool o              ON lo.idpool=o.idpool 
INNER JOIN lane a              ON o.idpool=a.idpool 
INNER JOIN run r               ON a.rid=r.rid 
INNER JOIN rread e             ON e.aid=a.aid
LEFT  JOIN libtype lt          ON l.libtype=lt.ltid
LEFT  JOIN libpair lp          ON l.libpair=lp.lpid
WHERE $where
GROUP BY substring(r.rdate,1,4),l.libtype
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";
while (@row = $out->fetchrow_array) {
	$libs{$row[0]}{$row[2]} += $row[1];
	$libsall{$row[2]}       += $row[1];
}


@labels	= (
	'Year',
	'Lanes',
	'Exomic',
	'Genomic',
	'RNA',
	'ChIP-Seq',
	'ChIP-Seq RNA',
	'MIP',
	'mtDNA',
	'DropSeq',
	'scRNA',
	'ATAC-Seq',
	'scATAC-Seq'
	);

print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
foreach $project (sort keys %lanes) {
	$tmp = sprintf("%.2f",$lanes{$project});
	$alllanes += $tmp;
	print "<tr>";
	print "<td>$project </td>";
	print "<td align=\"right\">$tmp</td>";
	print "<td align=\"right\">$libs{$project}{'exomic'}</td>";
	print "<td align=\"right\">$libs{$project}{'genomic'}</td>";
	print "<td align=\"right\">$libs{$project}{'RNA'}</td>";
	print "<td align=\"right\">$libs{$project}{'ChIP-Seq'}</td>";
	print "<td align=\"right\">$libs{$project}{'ChIP-Seq RNA'}</td>";
	print "<td align=\"right\">$libs{$project}{'MIP'}</td>";
	print "<td align=\"right\">$libs{$project}{'mtDNA'}</td>";
	print "<td align=\"right\">$libs{$project}{'DropSeq'}</td>";
	print "<td align=\"right\">$libs{$project}{'scRNA'}</td>";
	print "<td align=\"right\">$libs{$project}{'ATAC-Seq'}</td>";
	print "<td align=\"right\">$libs{$project}{'scATAC-Seq'}</td>";
	print "</tr>";
}
print "</table>";
print "<br>";
print "<br>";
print "<br>";


}

########################################################################
# listShopping listorder searchShopping resultsshopping resultsorder
########################################################################
sub listShopping {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $query  = "";
my $out    = "";
my @row    = ();
my $i      = 0;
my @labels = ();
my $sum    = 0;
my $align  = "";
my @prepare   = ();
my $where  = "";


$where = "WHERE 1=1 ";
if ($ref->{'datebegin'} ne "") {
	$where .= " AND bdate >= ? ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where .= " AND bdate <= ? ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'idcompany'} ne "") {
	$where .= " AND bcompany = ? ";
	push(@prepare, $ref->{'idcompany'});
}
if ($ref->{'articlegroup'} ne "") {
	$where .= " AND articlegroup = ? ";
	push(@prepare, $ref->{'articlegroup'});
}
if ($ref->{'bdescription'} ne "") {
	$where .= " AND bdescription = ? ";
	push(@prepare, $ref->{'bdescription'});
}
if ($ref->{'pspelement'} ne "") {
	$where .= " AND pspelement = ? ";
	push(@prepare, $ref->{'pspelement'});
}
if ($ref->{'invoice'} ne "" ) {
	$where .= " AND invoice = ? ";
	push(@prepare, $ref->{'invoice'});
}

$query = "SELECT  idshopping,co.coname,bnumber,bdescription,articlegroup,pspelement,blistprice,
	bprice,beinkaufswagen,bordernumber,invoice,u.name,bdate
	FROM shopping
	LEFT JOIN $logindb.user u ON buser=u.iduser
	LEFT JOIN company co ON bcompany=co.idcompany
	$where
	ORDER BY  bdate desc";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Id',
	'Company',
	'Article number',
	'Article',
	'Article group',
	'PSP-Element',
	'List price',
	'Price',
	'Einkaufswagen',
	'Order number',
	'Invoice number',
	'Entered by',
	'Date'
	);

&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

my $n=1;

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		$align="";
		if (($i >= 4) and ($i <= 7)) {
			$align="align='right'";
		}
		if ($i == 0) {
			print "<td align=\"center\">$n</td>";
			$n++;
			print "<td align=\"center\"><a href=\"shopping.pl?id=$row[$i]&mode=edit\">edit</a></td>";
		}
		else {
			print "<td $align> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>";
}
print "</tbody></table></div>\n";
#&tablescript;

$query = qq#
SELECT substring(bdate,1,4),sum(bprice)
FROM shopping
$where
GROUP BY
substring(bdate,1,4)
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'Year',
	'Sum'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<br><th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td align=\"right\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
}
print "</table>\n";


#per year,PSP-Element
$query = qq#
SELECT substring(bdate,1,4),pspelement,sum(bprice)
FROM shopping
LEFT JOIN company co ON bcompany=co.idcompany
$where
GROUP BY
substring(bdate,1,4),pspelement
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'Year',
	'PSP-Element',
	'Sum'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<br><th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td align=\"right\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
}
print "</table>\n";


#per year,Company
$query = qq#
SELECT substring(bdate,1,4),co.coname,sum(bprice)
FROM shopping
LEFT JOIN company co ON bcompany=co.idcompany
$where
GROUP BY
substring(bdate,1,4),bcompany
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'Year',
	'Company',
	'Sum'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<br><th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td align=\"right\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
}
print "</table>\n";


#per year,PSP-Element,Company
$query = qq#
SELECT substring(bdate,1,4),pspelement,co.coname,sum(bprice)
FROM shopping
LEFT JOIN company co ON bcompany=co.idcompany
$where
GROUP BY
substring(bdate,1,4),pspelement,bcompany
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'Year',
	'PSP-Element',
	'Company',
	'Sum'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<br><th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td align=\"right\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
}
print "</table>\n";

#perPSP-Element,article group
$query = qq#
SELECT pspelement,articlegroup,sum(bprice)
FROM shopping
$where
GROUP BY
pspelement,articlegroup
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'PSP-Element',
	'Article group',
	'Sum'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<br><th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td align=\"right\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
}
print "</table>\n";

#article group all
$query = qq#
SELECT substring(s.bdate,1,4),s.articlegroup,sum(s.bprice),
(SELECT sum(s2.bprice)
FROM shopping s2
$where
AND substring(s.bdate,1,4) = substring(s2.bdate,1,4)
AND s.articlegroup = s2.articlegroup
AND ((s2.pspelement like 'A-630430-001') or (s2.pspelement like 'A-632700-001'))
) as hmgu,
(SELECT sum(s3.bprice)
FROM shopping s3
$where
AND substring(s.bdate,1,4) = substring(s3.bdate,1,4)
AND s.articlegroup = s3.articlegroup
AND !((s3.pspelement like 'A-630430-001') or (s3.pspelement like 'A-632700-001'))
) as others,
FORMAT ((SELECT sum(s4.bprice)
FROM shopping s4
$where
AND substring(s.bdate,1,4) = substring(s4.bdate,1,4)
AND s.articlegroup = s4.articlegroup
AND !((s4.pspelement like 'A-630430-001') or (s4.pspelement like 'A-632700-001'))
) / sum(bprice), 2) as percent
FROM shopping s
$where
GROUP BY
substring(bdate,1,4),
s.articlegroup
#;
#print "$query<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,@prepare,@prepare,@prepare) || die print "$DBI::errstr";

@labels	= (
	'Year',
	'Article group',
	'Sum',
	'HMGU',
	'Others',
	'Ratio',
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<br><th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td align=\"right\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
}
print "</table>";


#article group all
$query = qq#
SELECT s.articlegroup,sum(s.bprice),
(SELECT sum(s2.bprice)
FROM shopping s2
$where
AND s.articlegroup = s2.articlegroup
AND ((s2.pspelement like 'A-630430-001') or (s2.pspelement like 'A-632700-001'))
) as hmgu,
(SELECT sum(s3.bprice)
FROM shopping s3
$where
AND s.articlegroup = s3.articlegroup
AND !((s3.pspelement like 'A-630430-001') or (s3.pspelement like 'A-632700-001'))
) as others,
FORMAT ((SELECT sum(s4.bprice)
FROM shopping s4
$where
AND s.articlegroup = s4.articlegroup
AND !((s4.pspelement like 'A-630430-001') or (s4.pspelement like 'A-632700-001'))
) / sum(bprice), 2) as percent
FROM shopping s
$where
GROUP BY
s.articlegroup
#;
#print "$query<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,@prepare,@prepare,@prepare) || die print "$DBI::errstr";

@labels	= (
	'Article group',
	'Sum',
	'HMGU',
	'Others',
	'Ratio',
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<br><th align=\"center\">$_</th>";
}
print "</tr>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		print "<td align=\"right\"> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
}
print "</table>";

$out->finish;


}
########################################################################
# checkBarcode
########################################################################

sub checkBarcode {
my $self        = shift;
my $dbh         = shift;
my $file        = shift;
my @file        = ();
my $line        = "";
my $rack        = "";
my $tube        = "";
my $dummy       = "";
my $i           = 0;
my $j           = 0;
my @barcode     = ();
my @values      = ();
my @labels      = ();
my $prow        = "";
my $pcol        = "";
my $barcode     = "";
my $query       = "";
my $out         = "";
my @row         = ();
my $class       = "";
my @barcodepass = ();
my @pospass     = ();

$i = 0;
if ($file ne "") {
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		next if /No Tube/;
		next if /No Read/;
		s/\"//g;
		$line = $_;
		if ($i == 0) {
			($dummy,$rack) = split(/\:/,$line);
		}
		else {	
			(@values) = split(/\,/,$line);
			push(@barcode,[@values]);
		}
		$i++;
	}
}

@labels	= (
	'Plate Row',
	'Plate Col',
	'Barcode',
	'Db Plate',
	'Db Row',
	'Db Col',
	'Pool',
	'Description',
	'Comment'
	);

print "Rack: $rack<br>\n";
print q(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
	print "</tr>";
for $i ( 0 .. $#barcode ) {
	($pcol,$barcode) =  @{$barcode[$i]};
	push(@pospass,$pcol);
	$prow=substr($pcol,0,1);
	$pcol=substr($pcol,1,2);
	push(@barcodepass,$barcode);
	
	$query = "SELECT  oplate,orow,ocolumn, 
		  CONCAT('<a href=\"pool.pl?id=',idpool,'&amp;mode=edit\">',oname,'</a>'),
		  odescription,ocomment
		  FROM pool 
		  WHERE obarcode='$barcode'";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute() || die print "$DBI::errstr";
	@row = $out->fetchrow_array;
	
	if (($row[1] ne $prow) or ($row[2] ne $pcol)) {
		$class="class=\"person\"";
	}
	else {
		$class="";
	}
	print "<tr>";
	print "<td $class>$prow</td>\n";
	print "<td $class>$pcol</td>\n";
	print "<td>$barcode</td>\n";
	$j=0;
	foreach (@row) {
		print "<td> $row[$j]</td>";
		$j++;
	}
	print "</tr>";
}
print "</table>";

print qq(<input type="hidden" name="rack" value="$rack">);
for $i ( 0 .. $#barcodepass ) {
	print qq(<input type="hidden" name="barcodepass" value="$barcodepass[$i]">);
}
for $i ( 0 .. $#pospass ) {
	print qq(<input type="hidden" name="pospass" value="$pospass[$i]">);
}


}
########################################################################
# updateplatepositions called by checkBarcodeDoDo.pl
########################################################################

sub updateplatepositions {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $i           = 0;
my $rack        = "";
my $row         = "";
my $col         = "";
my $barcode     = "";
my (@barcode)   = split(/\0/,$ref->{barcodepass});
my (@pos)       = split(/\0/,$ref->{pospass});
my $sql         = "";
my $sth         = "";

for $i ( 0 .. $#barcode ) {
	$barcode=$barcode[$i];
	if (length($barcode)<10) {
		$barcode = substr("0000000000",0,10-length($barcode)) . $barcode;
		print "Warning $barcode less than 10 characters. Leading zero added.<br>";
	}

	$sql = "
	UPDATE pool
	SET oplate=NULL , orow=NULL , ocolumn=NULL
	WHERE obarcode='$barcode'
	";
	print "$sql<br>";
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
}
for $i ( 0 .. $#barcode ) {
	$rack = $ref->{rack};
	$barcode=$barcode[$i];
	$row=substr($pos[$i],0,1);
	$col=substr($pos[$i],1,2);
	if (length($barcode)<10) {
		$barcode = substr("0000000000",0,10-length($barcode)) . $barcode;
		print "Warning $barcode less than 10 characters. Leading zero added.<br>";
	}

	$sql = "
	UPDATE pool
	SET oplate='$rack' , orow='$row' , ocolumn='$col'
	WHERE obarcode='$barcode'
	";
	print "$sql<br>";
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
}

}
########################################################################
# makePool
########################################################################

sub makePool {
my $self        = shift;
my $dbh         = shift;
my $file        = shift;
my @file        = ();
my $line        = "";
my $rack        = "";
my $tube        = "";
my $dummy       = "";
my $i           = 0;
my $j           = 0;
my @barcode     = ();
my @values      = ();
my @labels      = ();
my $prow        = "";
my $pcol        = "";
my $barcode     = "";
my $obarcode    = "";
my $query       = "";
my $out         = "";
my @row         = ();
my $libs        = ();
my $oname       = ();
my $tmp         = "";

$i = 0;
if ($file ne "") {
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		next if /No Tube/;
		next if /No Read/;
		s/\"//g;
		$line = $_;
		if ($i == 0) {
			($dummy,$rack) = split(/\:/,$line);
		}
		else {	
			(@values) = split(/\,/,$line);
			push(@barcode,[@values]);
		}
		$i++;
	}
}

@labels	= (
	'Lib Id',
	'Lib Name',
	'Lib Description',
	'Lib Comment'
	);

#print "Rack: $rack<br>\n";
print qq(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
	print "</tr>";
for $i ( 0 .. $#barcode ) {
	($pcol,$barcode) =  @{$barcode[$i]};
	$prow=substr($pcol,0,1);
	$pcol=substr($pcol,1,2);
	if (length($barcode)<10) {
		$barcode = substr("0000000000",0,10-length($barcode)) . $barcode;
		print "Warning $barcode less than 10 characters. Leading zero added.<br>";
	}
	if ($i == 0) { # check if tube in A01
		if (($prow ne "A") or ($pcol ne "01")) {
			print "Tube in A01 missing!<br><br>";
			exit(1);
		}
		else { # tube for new pool, check if barcode is not used
			$obarcode=$barcode; # barcode for new pool
			$query="SELECT * FROM pool WHERE obarcode='$obarcode'";
			$out = $dbh->prepare($query) || die print "$DBI::errstr";
			$out->execute() || die print "$DBI::errstr";
			if ($out->rows > 0) {
				print "Barcode for new pool already used!<br><br>";
				exit(1);
			}
		}
		next;
	}
	
	$query = "SELECT  l.lid,l.lname,l.ldescription,l.lcomment
		  FROM pool o
		  INNER JOIN library2pool lp on o.idpool=lp.idpool
		  INNER JOIN library l       on lp.lid=l.lid
		  WHERE o.obarcode='$barcode'";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute() || die print "$DBI::errstr";
	if ($out->rows == 0) {
		print "$prow$pcol $barcode not in database!<br>";
	}
	
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		$j=0;
		if ($i>1) {$libs .= ",";}   # for hidden fields
		if ($i>1) {$oname .= "_";}
		$libs  .=$row[0];
		$tmp    =$row[1];
		($tmp)  =split(/\_/,$tmp);
		$oname .=$tmp;
		foreach (@row) {
			print "<td> $row[$j]</td>";
			$j++;
		}
		print "</tr>";
	}
}
print "</table><br>\n";
print qq(<input type="text"   name="oname" value="$oname" size="100" maxlength="100">Pool Name<br>\n);
print qq(<input type="text"   name="obarcode" value="$obarcode" size="100" maxlength="100">Pool Barcode<br>\n);
print qq(<input type="hidden" name="libs"  value="$libs"><br><br>\n);


}
########################################################################
# makePoolExtern from makePoolExternDo.pl
########################################################################

sub makePoolExtern {
my $self        = shift;
my $dbh         = shift;
my $file        = shift;
my @file        = ();
my $line        = "";
my $i           = 0;
my $j           = 0;
my @barcode     = ();
my @labels      = ();
my $barcode     = "";
my $obarcode    = "";
my $query       = "";
my $out         = "";
my @row         = ();
my $libs        = ();
my $oname       = ();
my $tmp         = "";

if ($file ne "") {
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		next if /No Tube/;
		next if /No Read/;
		s/\"//g;
		$line = $_;
		push(@barcode,$line);
	}
}

@labels	= (
	'Lib Id',
	'Lib Name',
	'Lib Description',
	'Lib Comment'
	);

#print "Rack: $rack<br>\n";
print qq(<table border="1" cellspacing="0" cellpadding="0"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
	print "</tr>";
for $i ( 0 .. $#barcode ) {
	$barcode =  @barcode[$i];
	if ($i == 0) { # check if tube in A01
		if (length($barcode)<10) {
			$barcode = substr("0000000000",0,10-length($barcode)) . $barcode;
			print "Warning $barcode less than 10 characters. Leading zero added.<br>";
		}
		# tube for new pool, check if barcode is not used
		$obarcode=$barcode; # barcode for new pool
		$query="SELECT * FROM pool WHERE obarcode='$obarcode'";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute() || die print "$DBI::errstr";
		if ($out->rows > 0) {
			print "Barcode for new pool already used!<br><br>";
			exit(1);
		}
		
		next;
	}
	$barcode = $barcode . "_LIB1";
	$query = "SELECT  l.lid,l.lname,l.ldescription,l.lcomment
		  FROM library l
		  WHERE l.lname='$barcode'";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute() || die print "$DBI::errstr";
	if ($out->rows == 0) {
		print "$barcode not in database!<br>";
	}
	
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		$j=0;
		if ($i>1) {$libs .= ",";}   # for hidden fields
		if ($i>1) {$oname .= "_";}
		$libs  .=$row[0];
		$tmp    =$row[1];
		($tmp)  =split(/\_/,$tmp);
		$oname .=$tmp;
		foreach (@row) {
			print "<td> $row[$j]</td>";
			$j++;
		}
		print "</tr>";
	}
}
print "</table><br>\n";
print qq(<input type="text"   name="oname" value="$oname" size="100" maxlength="100">Pool Name<br>\n);
print qq(<input type="text"   name="obarcode" value="$obarcode" size="100" maxlength="100">Pool Barcode<br>\n);
print qq(<input type="hidden" name="libs"  value="$libs"><br><br>\n);


}
########################################################################
# makePool2 insert new pool from barcode file
########################################################################

sub makePool2 {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $i           = 0;
my $sql         = "";
my $sth         = "";
my $sth2        = "";
my @row         = ();
my $libs        = "";
my $oname       = "";
my $obarcode    = "";
my $idpool      = "";
my $date=&actualDate;

$libs     = $ref->{libs};
$oname    = $ref->{oname};
$obarcode = $ref->{obarcode};
if ($oname eq "") {
	print "Pool name empty!<br>";
	exit(1);
}
$dbh->{AutoCommit}=0 ;
eval {
# insert into pool
$sql=qq#
INSERT INTO pool
(oname,obarcode,omenuflag,odate)
VALUES
("$oname",
"$obarcode",
"T",
"$date")
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
$idpool=$sth->{mysql_insertid};

# insert into library2pool
$sql = "SELECT  l.lid,l.lname,l.ldescription,l.lcomment
	  FROM library l
	  WHERE l.lid in ($libs);
	  ";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
while (@row = $sth->fetchrow_array) {
	$sql="
	INSERT INTO library2pool
	(lid,idpool)
	VALUES
	($row[0],
	$idpool)
	";
	$sth2 = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth2->execute() || die print "$DBI::errstr";
}
};
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("COMMIT");
}
$sth->finish;
$sth2->finish;
return($idpool);
}
########################################################################
# makePoolExtern2 insert new pool from barcode file from makePoolExternDo2.pl
########################################################################

sub makePoolExtern2 {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $i           = 0;
my $sql         = "";
my $sth         = "";
my $sth2        = "";
my @row         = ();
my $libs        = "";
my $oname       = "";
my $obarcode    = "";
my $idpool      = "";
my $date=&actualDate;

$libs     = $ref->{libs};
$oname    = $ref->{oname};
$obarcode = $ref->{obarcode};
if ($oname eq "") {
	print "Pool name empty!<br>";
	exit(1);
}
$dbh->{AutoCommit}=0 ;
eval {
# insert into pool
$sql=qq#
INSERT INTO pool
(oname,obarcode,omenuflag,odate)
VALUES
("$oname",
"$obarcode",
"T",
"$date")
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
$idpool=$sth->{mysql_insertid};

# insert into library2pool
$sql = "SELECT  l.lid,l.lname,l.ldescription,l.lcomment
	  FROM library l
	  WHERE l.lid in ($libs);
	  ";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
while (@row = $sth->fetchrow_array) {
	$sql="
	INSERT INTO library2pool
	(lid,idpool)
	VALUES
	($row[0],
	$idpool)
	";
	$sth2 = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth2->execute() || die print "$DBI::errstr";
	&pooled($dbh,$row[0]); # inserted by Tim 2019-04-04
}
};
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter();
	exit(0);
}
else {
	$dbh->do("COMMIT");
}
$sth->finish;
$sth2->finish;
return($idpool);
}
########################################################################
# getLidByName
########################################################################

sub getLidByName {
	my $dbh    = shift;
	my $name  = shift;
	my $sql    = "";
	my $sth    = "";
	my $id    = "";

	$sql = qq#SELECT lid FROM library
	WHERE lname = "$name"#;
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$id = $sth->fetchrow_array;

	return($id);
}
########################################################################
# getIdpoolByName
########################################################################

sub getIdpoolByName {
	my $dbh    = shift;
	my $name  = shift;
	my $sql    = "";
	my $sth    = "";
	my $id    = "";

	$sql = qq#SELECT idpool FROM pool
	WHERE oname = "$name"#;
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$id = $sth->fetchrow_array;

	return($id);
}
########################################################################
# importTaqman
########################################################################

sub importTaqman {
my $self        = shift;
my $dbh         = shift;
my $ref         = shift;
my $file        = shift;
my $line        = "";
my $i           = 0;
my $j           = 0;
my $qpcr        = 0;
my $bp          = "";
my $barcode     = "";
my @line        = ();
my %barcode     = ();
my $sql         = "";
my $sth         = "";
my $res         = "";
my $lid         = "";
my @row         = ();
my @labels      = ();

if ($file ne "") {
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		s/\"//g;
		if (/^\s*$/) {next;}
		if (/^\d+/) {
			$line = $_;
			(@line) = split(/\t/,$line);
			if ($line[0] >= 74) {  # kleiner ist Standard
				($barcode)=split(/\_/,$line[1]); 
				$barcode{$barcode}=$line[7];
				#print "$barcode $line[7]<br>";
			}
		}
	}
}

# update table pool
foreach $barcode (keys %barcode) {
	($lid,$bp)=&getbp($dbh,$barcode);
	if ($bp > 0) {
		$qpcr=$barcode{$barcode}*288/$bp*6;
		#print "bp $bp<br>";
	}
	else {
		$qpcr=$barcode{$barcode}*6;
		print "Warning: bp missing for barcode $barcode.<br>";
	}
	if ($lid > 0) { # lib must exist
		unless ($lid=~/\,/) { # not for pools
			&updatestatus($dbh,$lid);
		}
	}
	
	$sql = "UPDATE pool SET opcr=FORMAT($qpcr,2) WHERE obarcode='$barcode'"
         	;
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$res=$sth->execute() || die print "$DBI::errstr";
	$sth->finish;
	if ($res != 1) {
		print "Warning: barcode $barcode missing.<br>";
	}
	#print "$res $sql<br>";
}
print "<br>";

# print results
@labels	= (
	'Pool',
	'Description',
	'Comment',
	'Barcode',
	'Plate',
	'Row',
	'Column',
	'PicoGreen (nMol)',
	'qPCR (nMol)'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
	
foreach $barcode (keys %barcode) {
	$sql = "SELECT 
	CONCAT('<a href=\"pool.pl?id=',o.idpool,'&amp;mode=edit\">',oname,'</a>'),
	odescription,ocomment,obarcode,
	oplate,orow,ocolumn,
	FORMAT(AVG(l.lpicogreen),2),
	opcr
	FROM library l
	INNER JOIN library2pool lo ON (l.lid = lo.lid)
	INNER JOIN pool o ON (lo.idpool = o.idpool)
	WHERE obarcode='$barcode'
	GROUP BY o.idpool
	";
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	#print "$sql<br>";
	while (@row = $sth->fetchrow_array) {
		$i=0;
		print "<tr>";
		foreach (@row) {
			print "<td>$row[$i]</td>";
			$i++;
		}	
		print "</tr>";
	}
}
print "</table>";

}

sub updatestatus {
	my $dbh         = shift;
	my $lid         = shift;
	my $sql         = "";
	my $sth         = "";
	$sql = "UPDATE library SET lstatus='Taqman finished' WHERE lid='$lid'";
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$sth->finish;
}

sub getbp {
	my $dbh         = shift;
	my $barcode     = shift;
	my $sql         = "";
	my $sth         = "";
	my $bp          = "";
	my $lid         = "";
	$sql = qq#
	SELECT GROUP_CONCAT(l.lid),
	IF (AVG(lbiohssize)>0,AVG(lbiohssize),AVG(lbio1size))
	FROM
	library l
	INNER JOIN library2pool lo ON (l.lid = lo.lid)
	INNER JOIN pool o ON (lo.idpool = o.idpool)
	WHERE o.obarcode=$barcode
	GROUP BY o.idpool
	#;
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	($lid,$bp) = $sth->fetchrow_array;
	#print "bp $bp<br>";
	return($lid,$bp);
}
########################################################################
# importLibInfo called by importLibInfoDo.pl
########################################################################

sub importLibInfo {
my $self        = shift;
my $dbh         = shift;
my $ref         = shift;
my $file        = shift;
my $line        = "";
my $i           = 0;
my $j           = 0;
my @labels      = ();
my @slice       = ();
my @values      = ();
my %assignment  = ();
my @row         = ();
my @tag         = ();
my $forpoolflag = $ref->{forpool};
my $withbarcodeflag = $ref->{withbarcode};

if ($ref->{sheet} eq "Exome Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbiopostpcrngul",
"BA post Hyb (ng/ul)"       => "lbiohsconc",
"BA post Hyb (nMol)"        => "lbiohsmol",
"BA post Hyb bp"            => "lbiohssize",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen",
"qPCR (nMol)"               => "lqpcr",
"Index1"                    => "idtag",
"Index2"                    => "idtag2"
);
}
if ($ref->{sheet} eq "Genome Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbio1conc",
"BA post PCR (nMol)"        => "lbio1mol",
"BA post PCR bp"            => "lbio1size",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen",
"qPCR (nMol)"               => "lqpcr",
"Index1"                    => "idtag",
"Index2"                    => "idtag2"
);
}

if ($ref->{sheet} eq "ChIPseq Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbio1conc",
"BA post PCR (nMol)"        => "lbio1mol",
"BA post PCR bp"            => "lbio1size",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen",
"qPCR (nMol)"               => "lqpcr",
"Index1"                    => "idtag",
"Index2"                    => "idtag2"
);
}

if ($ref->{sheet} eq "RNAseq Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbio1conc",
"BA post PCR (nMol)"        => "lbio1mol",
"BA post PCR bp"            => "lbio1size",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen",
"qPCR (nMol)"               => "lqpcr",
"Index1"                    => "idtag",
"Index2"                    => "idtag2"
);
}


print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i = 0;
if ($file ne "") {
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		if (/^\s*$/) {next;}
		if (/^\,{6,}$/) {next;}
		s/\"\"//g;
		s/\"//g;
		$line = $_;
		print "<tr>";
		# select columns that are in assignment (slice)
		if ($i == 0) {
			(@labels) = split(/\,/,$line);
			for $j (0..$#labels) {
				if ($assignment{$labels[$j]} ne "") {
					push(@slice,$j);
					print "<td>$labels[$j]</td>";
				}
				# i.e. "barcode"   =$assignment{"DNA Barcode"}
				$labels[$j]=$assignment{$labels[$j]};
			}
			@labels = @labels[@slice];
			&check_labels;
		}
		else {	
			(@values) = split(/\,/,$line);
			@values = @values[@slice];
			&intodb($i-1,$forpoolflag,$withbarcodeflag);
		}
		$i++;
		print "</tr>";
	}
}
print "</table>";

sub getTag {
	my $tag         = shift;
	my $sql         = "";
	my $sth         = "";
	my $idtag       = "";
	$sql= "
	SELECT idtag
	FROM tag
	WHERE tname = '$tag'
	";
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$idtag = $sth->fetchrow_array;
	#print "tag $idtag<br>";
	if ($idtag eq "") {
		print "Did not find tag $tag!! Exit.<br>";
		exit(1);
	}
	return($idtag);
}

sub check_labels {
	my %labels = ();
	# check if all values of assignment are keys of values
	for $i (0..$#labels) {
		$labels{$labels[$i]}=$labels[$i];
	}
	foreach (keys %assignment) {
		if (!exists($labels{$assignment{$_}})) {
			print "</table><br>";
			print "Error: Column '$_' missing.<br>";
			exit(1);
		}
	}
	foreach (values %assignment) {
		if (!exists($labels{$_})) {
			print "</table><br>";
			print "Error: Column $_ missing.<br>";
			exit(1);
		}
	}
}

sub intodb { #library and pool
	my $ntag        = shift;
	my $forpoolflag = shift;
	my $withbarcodeflag = shift;
	my $sql         = "";
	my $sth         = "";
	my $lname       = "";
	my @row         = ();
	my $i           = 0;
	my %values      = ();
	my $label       = "";
	my $lname       = "";
	my $field       = "";
	my $value       = "";
	my @fields2     = ();
	my $oname       = "";
	my $obarcode    = "";
	my $id          = "";
	
	# convert arrays label and values in hash
	for $i (0..$#labels) {
		$values{$labels[$i]}=$values[$i];
		if ($labels[$i] eq "lname") {
			$id=getLidByName($dbh,$values{$labels[$i]});
			print "<td align=\"center\"><a href=\"library.pl?id=$id&mode=edit\">$values{$labels[$i]}</a></td>";
		}
		elsif ($labels[$i] eq "oname") {
			$id=getIdpoolByName($dbh,$values{$labels[$i]});
			print "<td align=\"center\"><a href=\"pool.pl?id=$id&mode=edit\">$values{$labels[$i]}</a></td>";
		}
		else {
			print "<td align=\"center\">$values{$labels[$i]}</td>";
		}
	}
	# fixed values and set 'should be pooled to true
	if ($ref->{sheet} eq "Exome Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}=$forpoolflag;
		$values{lpcr}='17';
		$values{lbiohsvol}='30';
		$values{lmaterial}='3000';
		$values{idtag}=&getTag($values{idtag});
		if ($values{idtag2} ne "") {
			$values{idtag2}=&getTag($values{idtag2});
		}
	}
	if ($ref->{sheet} eq "Genome Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}=$forpoolflag;
		$values{lpcr}='10';
		$values{lbio1vol}='30';
		$values{lmaterial}='1000';
		$values{idtag}=&getTag($values{idtag});
		if ($values{idtag2} ne "") {
			$values{idtag2}=&getTag($values{idtag2});
		}
	}
	if ($ref->{sheet} eq "ChIPseq Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}=$forpoolflag;
		$values{lpcr}='30';
		$values{lbio1vol}='30';
		$values{lmaterial}='500';
		$values{idtag}=&getTag($values{idtag});
		if ($values{idtag2} ne "") {
			$values{idtag2}=&getTag($values{idtag2});
		}
	}
	if ($ref->{sheet} eq "RNAseq Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}=$forpoolflag;
		$values{lpcr}='15';
		$values{lbio1vol}='30';
		$values{lmaterial}='3000';
		$values{idtag}=&getTag($values{idtag});
		if ($values{idtag2} ne "") {
			$values{idtag2}=&getTag($values{idtag2});
		}
	}
	# check if barcode equals barcode_control
	if ($values{barcode} ne $values{barcode_control}) {
		print "</table><br>";
		print "Error: Barcode and barcode control not the same.<br>";
		exit(1);
	}
	delete($values{barcode});
	delete($values{barcode_control});
	# for pool
	$oname=($values{oname});
	if ($withbarcodeflag eq "T") {
		$obarcode=($values{obarcode});
		if (length($obarcode)<10) {
			$obarcode = substr("0000000000",0,10-length($obarcode)) . $obarcode;
		}
	}
	delete($values{oname});
	delete($values{obarcode});	
	# check lname
	$lname=$values{lname};
	delete($values{lname});
	if ($lname eq "") {
		print "</table><br>";
		print "Error: No library name.<br>";
		exit(1);
	}
	
	my @fields    = sort keys %values;
	my @values    = @values{@fields};
	#print join("<td></td>",@values);
	foreach $field (@fields) {
		$value=$field . " = ?";
		push(@fields2,$value);
	}

	# into library
	$sql = sprintf "UPDATE library SET %s WHERE lname='$lname'",
         	join(",", @fields2);
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute(@values) || die print "$DBI::errstr";
	$sth->finish;

	# into pool
	if ($withbarcodeflag eq "T") {
		$sql = "UPDATE pool SET obarcode='$obarcode' WHERE oname='$oname'";	
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute() || die print "$DBI::errstr";
		$sth->finish;
	}
} # end intodb


}
########################################################################
# importLibInfoOld called by importLibInfoDo.pl
########################################################################

sub importLibInfoOld {
my $self        = shift;
my $dbh         = shift;
my $ref         = shift;
my $file        = shift;
my $line        = "";
my $i           = 0;
my $j           = 0;
my @labels      = ();
my @slice       = ();
my @values      = ();
my %assignment  = ();
my @row         = ();
my @tag         = ();

if ($ref->{sheet} eq "Exome Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbiopostpcrngul",
"BA post Hyb (ng/ul)"       => "lbiohsconc",
"BA post Hyb (nMol)"        => "lbiohsmol",
"BA post Hyb bp"            => "lbiohssize",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen"
);
}
if ($ref->{sheet} eq "Genome Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbio1conc",
"BA post PCR (nMol)"        => "lbio1mol",
"BA post PCR bp"            => "lbio1size",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen"
);
}

if ($ref->{sheet} eq "ChIPseq Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbio1conc",
"BA post PCR (nMol)"        => "lbio1mol",
"BA post PCR bp"            => "lbio1size",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen"
);
}

if ($ref->{sheet} eq "RNAseq Sheet") {
%assignment=
(
"DNA Barcode"               => "barcode",
"DNA Barcode control"       => "barcode_control",
"Library"                   => "lname",
"Pool"                      => "oname",
"Pool Barcode"              => "obarcode",
"BA post PCR (ng/ul)"       => "lbio1conc",
"BA post PCR (nMol)"        => "lbio1mol",
"BA post PCR bp"            => "lbio1size",
"PicoGreen (pg/ul)"         => "lpicogreenpgul",
"PicoGreen (nMol)"          => "lpicogreen"
);
}

&getTags;

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i = 0;
if ($file ne "") {
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		if (/^\s*$/) {next;}
		if (/^\,{6,}$/) {next;}
		s/\"\"//g;
		s/\"//g;
		$line = $_;
		print "<tr>";
		# select columns that are in assignment (slice)
		if ($i == 0) {
			(@labels) = split(/\,/,$line);
			for $j (0..$#labels) {
				if ($assignment{$labels[$j]} ne "") {
					push(@slice,$j);
					print "<td>$labels[$j]</td>";
				}
				$labels[$j]=$assignment{$labels[$j]};
			}
			@labels = @labels[@slice];
			&check_labels;
		}
		else {	
			(@values) = split(/\,/,$line);
			@values = @values[@slice];
			&intodb($i-1);
		}
		$i++;
		print "</tr>";
	}
}
print "</table>";

sub getTagsOld {
	my $sql         = "";
	my $sth         = "";
	$sql= "
	SELECT idtag
	FROM tag
	WHERE tgroup = 'Illumina TrueSeq RNA and DNA'
	ORDER BY tname
	";
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	while (@row = $sth->fetchrow_array) {
		push(@tag,$row[0]);
	}
	if ($#tag != 11) {
		print "Tags not correct.<br>";
		exit(1);
	}
}

sub check_labelsOld {
	my %labels = ();
	# check if all values of assignment are keys of values
	for $i (0..$#labels) {
		$labels{$labels[$i]}=$labels[$i];
	}
	foreach (keys %assignment) {
		if (!exists($labels{$assignment{$_}})) {
			print "</table><br>";
			print "Error: Column '$_' missing.<br>";
			exit(1);
		}
	}
	foreach (values %assignment) {
		if (!exists($labels{$_})) {
			print "</table><br>";
			print "Error: Column $_ missing.<br>";
			exit(1);
		}
	}
}

sub intodbOld { #library and pool
	my $ntag        = shift;
	my $sql         = "";
	my $sth         = "";
	my $lname       = "";
	my @row         = ();
	my $i           = 0;
	my %values      = ();
	my $label       = "";
	my $lname       = "";
	my $field       = "";
	my $value       = "";
	my @fields2     = ();
	my $oname       = "";
	my $obarcode    = "";
	my $id          = "";
	
	# convert arrays label and values in hash
	for $i (0..$#labels) {
		$values{$labels[$i]}=$values[$i];
		if ($labels[$i] eq "lname") {
			$id=getLidByName($dbh,$values{$labels[$i]});
			print "<td align=\"center\"><a href=\"library.pl?id=$id&mode=edit\">$values{$labels[$i]}</a></td>";
		}
		elsif ($labels[$i] eq "oname") {
			$id=getIdpoolByName($dbh,$values{$labels[$i]});
			print "<td align=\"center\"><a href=\"pool.pl?id=$id&mode=edit\">$values{$labels[$i]}</a></td>";
		}
		else {
			print "<td align=\"center\">$values{$labels[$i]}</td>";
		}
	}
	# fixed values and set 'should be pooled to true
	if ($ref->{sheet} eq "Exome Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}='T';
		$values{lpcr}='17';
		$values{lbiohsvol}='30';
		$values{lmaterial}='3000';
		$values{idtag}=$tag[$ntag%12];
	}
	if ($ref->{sheet} eq "Genome Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}='F';
		$values{lpcr}='10';
		$values{lbio1vol}='30';
		$values{lmaterial}='1000';
		$values{idtag}=$tag[$ntag%12];
	}
	if ($ref->{sheet} eq "ChIPseq Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}='T';
		$values{lpcr}='30';
		$values{lbio1vol}='30';
		$values{lmaterial}='500';
		$values{idtag}=$tag[$ntag%12];
	}
	if ($ref->{sheet} eq "RNAseq Sheet") {
		$values{lstatus}='library prepared';
		$values{lforpool}='T';
		$values{lpcr}='15';
		$values{lbio1vol}='30';
		$values{lmaterial}='3000';
		$values{idtag}=$tag[$ntag%12];
	}
	# check barcode is barcode_control
	if ($values{barcode} ne $values{barcode_control}) {
		print "</table><br>";
		print "Error: Barcode and barcode control not the same.<br>";
		exit(1);
	}
	delete($values{barcode});
	delete($values{barcode_control});
	# for pool
	$oname=($values{oname});
	$obarcode=($values{obarcode});
	if (length($obarcode)<10) {
		$obarcode = substr("0000000000",0,10-length($obarcode)) . $obarcode;
	}
	delete($values{oname});
	delete($values{obarcode});	
	# check lname
	$lname=$values{lname};
	delete($values{lname});
	if ($lname eq "") {
		print "</table><br>";
		print "Error: No library name.<br>";
		exit(1);
	}
	
	my @fields    = sort keys %values;
	my @values    = @values{@fields};
	#print join("<td></td>",@values);
	foreach $field (@fields) {
		$value=$field . " = ?";
		push(@fields2,$value);
	}

	# into library
	$sql = sprintf "UPDATE library SET %s WHERE lname='$lname'",
         	join(",", @fields2);
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	#$sth->execute(@values) || die print "$DBI::errstr";
	$sth->finish;

	# into pool
	$sql = "UPDATE pool SET obarcode='$obarcode' WHERE oname='$oname'";	
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	#$sth->execute() || die print "$DBI::errstr";
	$sth->finish;
} # end intodb


}
########################################################################
# listKits
########################################################################
sub listKits {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $count     = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

		
$i=0;
$query = qq#
SELECT
s.sid,c.cdescription,s.sgetdate,s.expiration,s.lot,count(l.lkit)
FROM
library l,stock s, kit c
WHERE s.cid = c.cid
AND l.lkit = s.sid
GROUP BY
s.sid
ORDER BY
s.sgetdate DESC
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'Kit id',
	'Kit',
	'Recieved',
	'Expiration',
	'Lot No',
	'Used'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 5) { #edit
			print "<td align=\"right\"> $row[$i]</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";


$out->finish;
}
########################################################################
# listAssays
########################################################################
sub listAssays {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $count     = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

		
$i=0;
$query = qq#
SELECT
A.idassay,
A.name
FROM
assay A
ORDER BY
A.name ASC
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'Num',
	'Assay Name'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit
			print "<td align=\"center\">$n</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";


$out->finish;
}
########################################################################
# searchSample for createlibsheet called by searchSampleDo.pl
########################################################################
sub searchSample {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $field     = "";
my @values2   = ();

print qq(
<script type=\"text/javascript\">

function checkAll() {
	for (var i=0;i < document.myform.checkbox.length;i++) {
		document.myform.checkbox[i].checked=\"1\"
	}
}

</script>
);
print "\n<input type='button' name='checkkAll' value='Check all checkboxes' onClick='checkAll()'>\n";
print "<input type='reset' value='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Reset&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ><br><br>";

my $myorder = "s.name";
if ($ref->{myorder} eq "pedigree") {
	$myorder = "s.pedigree,s.name";
}
elsif ($ref->{myorder} eq "status") {
	$myorder = "l.lstatus,s.splate,s.srow,s.scolumn,s.name,o.oname";
}
elsif ($ref->{myorder} eq "date") {
	$myorder = "s.entered";
}
delete($ref->{myorder});

if ($ref->{withoutlib} == 1) {
	delete($ref->{libtype});
	delete($ref->{lstatus});
	delete($ref->{lforpool});
}

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$where = "WHERE s.nottoseq = 0 AND (l.lfailed = 0 or ISNULL(l.lfailed)) ";
#$where = "WHERE s.nottoseq = 0 ";

foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "withoutlib") {
			$where .= " ISNULL(l.lid) "
			
		}
		else {
			$where .= $field . " = ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}

#$where = "WHERE" . " $where";

			
$i=0;
$query = qq#
SELECT
s.idsample,s.name,l.lid,o.idpool,
concat('<a href="../snvedit/sample.pl?id=',s.idsample,'&amp;mode=edit">',s.idsample,'</a>'),
s.name,s.splate,s.srow,s.scolumn,
s.foreignid,s.pedigree,s.sex,concat(d.name,' (',d.symbol,')'),
s.analysis,s.entered,s.scomment,c.name,
concat('<a href="library.pl?id=',l.lid,'&amp;mode=edit">',l.lname,'</a>'),
t.tname,t.ttag,l.lstatus,
concat('<a href="pool.pl?id=',o.idpool,'&amp;mode=edit">',o.oname,'</a>'),
p.pdescription,
k.cdescription,
i.my
FROM
$exomedb.sample s 
INNER JOIN $exomedb.project         p ON s.idproject=p.idproject
LEFT  JOIN $exomedb.cooperation     c ON (s.idcooperation = c.idcooperation)
LEFT  JOIN $exomedb.invoice         i ON (s.idinvoice = i.idinvoice)
LEFT  JOIN $exomedb.disease2sample ds ON (s.idsample = ds.idsample)
LEFT  JOIN $exomedb.disease         d ON (ds.iddisease = d.iddisease)
LEFT  JOIN sample2library          sl ON (s.idsample = sl.idsample)
LEFT  JOIN library                  l ON (sl.lid = l.lid)
LEFT  JOIN tag                      t ON (l.idtag = t.idtag)
LEFT  JOIN library2pool            lo ON (l.lid = lo.lid)
LEFT  JOIN pool                     o ON (lo.idpool = o.idpool)
LEFT  JOIN stock                   st ON l.lkit= st.sid
LEFT  JOIN kit                      k ON st.cid=k.cid
$where
GROUP BY
s.idsample,l.lid,o.idpool
ORDER BY
$myorder
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Box',
	'id',
	'DNA',
	'Plate',
	'Row',
	'Column',
	'Foreign Id',
	'Pedigree',
	'Sex',
	'Disease',
	'Analysis',
	'Entered',
	'Comment',
	'Cooperation',
	'Library',
	'Index',
	'Tag',
	'Status',
	'Pool',
	'Project',
	'Kit',
	'Invoice'
	);

# form

# table
print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print "<td align=\"center\">
			<input type=\"checkbox\" name=\"checkbox\" value=\"$row[$i]_$row[$i+1]_$row[$i+2]_$row[$i+3]\"></td>";
		}
		elsif ($i > 3) {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";

$out->finish;
}
########################################################################
# searchTaqman called by taqmanDo.pl
########################################################################
sub searchTaqman {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;

			
$i=0;
# pooled libraries haben schon das label 'taqman finished'
# deshalb Suche nach 'o.opcr=0 or ISNULL(o.opcr)'
$query = qq#
SELECT
o.idpool,
GROUP_CONCAT('<a href="library.pl?id=',l.lid,'&amp;mode=edit">',l.lname,'</a>'),
FORMAT(AVG(lbiohssize),0),
FORMAT(AVG(lbio1size),0),
FORMAT(AVG(lpicogreen),1),
FORMAT(o.opcr,0) as pcr,
l.lstatus,
o.oplate,o.orow,o.ocolumn,
CONCAT('<a href="pool.pl?id=',o.idpool,'&amp;mode=edit">',o.oname,'</a>')
FROM
library l
INNER JOIN library2pool lo ON (l.lid = lo.lid)
INNER JOIN pool o ON (lo.idpool = o.idpool)
GROUP BY
o.idpool
HAVING l.lstatus='library prepared'
OR ((pcr=0 OR ISNULL(pcr)) AND (COUNT(l.lid)>1))
ORDER BY
o.oplate,o.orow,o.ocolumn
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'Box',
	'Library',
	'BA size',
	'BA hs size',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'Status',
	'Plate',
	'Row',
	'Column',
	'Pool'
	);

# form

# table
print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print "<td align=\"center\">
			<input type=\"checkbox\" name=\"checkbox\" value=\"$row[$i]\"></td>";
		}
		elsif ($i > 0) {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";

$out->finish;
}
########################################################################
# searchPooling called by poolingDo.pl
########################################################################
sub searchPooling {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $poolconentration = $ref->{'concentration'};
my $poolvolume       = $ref->{'volume'};
#Number of samples
my $npool            = $ref->{'npool'};
#my $npool            = 12;
my $set              = 0;
my $tag              = 0;
my $where            = "";

if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = $ref->{'ds.iddisease'} ";
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = $ref->{'s.idcooperation'} ";
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND idproject = $ref->{'idproject'} ";
}
if ($ref->{'lforpool'} eq "T") {
	$where .= " AND l.lforpool = 'T' ";
}
if ($ref->{'lforpool'} eq "F") {
	$where .= " AND l.lforpool = 'F' ";
}
			
$i=0;
# pooled libraries haben schon das label 'taqman finished'
# deshalb Suche nach 'o.opcr=0 or ISNULL(o.opcr)'
#GROUP_CONCAT('\<a href=\"library.pl?id=',l.lid,'&amp;pid=&amp;mode=edit\"\>',l.lname,'\</a\>'),
#CONCAT('<a href=\"pool.pl?id=',o.idpool,'&amp;pid=&amp;mode=edit\">',o.oname,'</a>'),
$query = qq#
SELECT
o.idpool,l.lid,
group_concat(DISTINCT l.lname),
o.oname,
obarcode,o.oplate,o.orow,o.ocolumn,
group_concat(DISTINCT t.tname),
group_concat(DISTINCT t2.tname),
l.lstatus,
FORMAT(AVG(lbiohssize),0),
FORMAT(AVG(lbio1size),0),
FORMAT(AVG(lpicogreen),1),
FORMAT(l.lqpcr,1),
FORMAT(($poolconentration*$poolvolume)/($npool*l.lpicogreen),1),
FORMAT(($poolconentration*$poolvolume)/($npool*l.lqpcr),1)
FROM
library l
INNER JOIN library2pool lo ON (l.lid = lo.lid)
INNER JOIN pool o ON (lo.idpool = o.idpool)
INNER JOIN sample2library sl ON (l.lid = sl.lid)
INNER JOIN $exomedb.sample s ON (sl.idsample = s.idsample)
LEFT JOIN $exomedb.disease2sample ds ON (s.idsample = ds.idsample)
LEFT JOIN $exomedb.disease d ON (ds.iddisease=d.iddisease)
INNER JOIN tag t  ON (l.idtag  = t.idtag)
LEFT JOIN tag t2  ON (l.idtag2 = t2.idtag)
WHERE l.lfailed = 0
AND s.nottoseq = 0
$where
GROUP BY
l.lid
HAVING ( ((sum(l.lpicogreen) > 0 ) OR (sum(l.lqpcr) > 0 ))
AND (COUNT(l.lid)=1) )
ORDER BY
l.lname
#;
#print "query = $query<br>where = $where<br>";
#l.lstatus='Taqman finished' AND 

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

# sort tag
my %sorted  = ();
my %counter = ();
while (@row = $out->fetchrow_array) {
	$counter{$row[8]}++;
	$sorted{$counter{$row[8]}}{$row[8]}=[@row];
}
@labels	= (
	'n',
	'Box',
	'Library',
	'Pool',
	'Barcode',
	'Plate',
	'Row',
	'Column',
	'Index1',
	'Index2',
	'Status',
	'BA size',
	'BA hs size',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'ul for 10 nMol (PicoGreen)',
	'ul for 10 nMol (qPCR)'
	);

# form

# table
print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

$n=1;
my $tmpajoin = "";
foreach $set (sort keys %sorted) {
foreach $tag (sort keys %{$sorted{$set}} ) {
	print "<tr>";
	$i=0;
	(@row) = @{$sorted{$set}{$tag}};
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			$tmpajoin=join("###",@row);
			#print "@row<br>";
			print "<td align=\"center\">
			<input type=\"checkbox\" name=\"checkbox\" value=\"$tmpajoin\"></td>";
		}
		elsif ($i == 2) {
			#print "<td align=\"center\"> $row[$i]</td>";
print "<td align=\"center\"><a href=\"library.pl?id=$row[1]\&amp;mode=edit\">$row[2]</a\></td>";
		}
		elsif ($i == 3) {
			#print "<td align=\"center\"> $row[$i]</td>";
print "<td align=\"center\"><a href=\"pool.pl?id=$row[0]\&amp;mode=edit\">$row[3]</a\></td>";
		}
		elsif ($i > 2) {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
}
print "</table>";

$out->finish;
}
########################################################################
# searchPooling called by poolingDo.pl
########################################################################
sub searchPoolingold {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $poolconentration = $ref->{'concentration'};
my $poolvolume       = $ref->{'volume'};
#Number of samples
my $npool            = $ref->{'npool'};
#my $npool            = 12;
my $set              = 0;
my $tag              = 0;
my $where            = "";

if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = $ref->{'ds.iddisease'} ";
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = $ref->{'s.idcooperation'} ";
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND idproject = $ref->{'idproject'} ";
}
if ($ref->{'lforpool'} eq "T") {
	$where .= " AND l.lforpool = 'T' ";
}
if ($ref->{'lforpool'} eq "F") {
	$where .= " AND l.lforpool = 'F' ";
}
			
$i=0;
# pooled libraries haben schon das label 'taqman finished'
# deshalb Suche nach 'o.opcr=0 or ISNULL(o.opcr)'
#GROUP_CONCAT('\<a href=\"library.pl?id=',l.lid,'&amp;pid=&amp;mode=edit\"\>',l.lname,'\</a\>'),
#CONCAT('<a href=\"pool.pl?id=',o.idpool,'&amp;pid=&amp;mode=edit\">',o.oname,'</a>'),
$query = qq#
SELECT
o.idpool,l.lid,
l.lname,o.oname,
obarcode,o.oplate,o.orow,o.ocolumn,
group_concat(t.tname),
l.lstatus,
FORMAT(AVG(lbiohssize),0),
FORMAT(AVG(lbio1size),0),
FORMAT(AVG(lpicogreen),1),
FORMAT(o.opcr,1),
FORMAT(($poolconentration*$poolvolume)/($npool*l.lpicogreen),1),
FORMAT(($poolconentration*$poolvolume)/($npool*o.opcr),1)
FROM
library l
INNER JOIN library2pool lo ON (l.lid = lo.lid)
INNER JOIN pool o ON (lo.idpool = o.idpool)
INNER JOIN sample2library sl ON (l.lid = sl.lid)
INNER JOIN $exomedb.sample s ON (sl.idsample = s.idsample)
LEFT JOIN $exomedb.disease2sample ds ON (s.idsample = ds.idsample)
LEFT JOIN $exomedb.disease d ON (ds.iddisease=d.iddisease)
INNER JOIN tag t  ON (l.idtag = t.idtag)
WHERE l.lfailed = 0
AND s.nottoseq = 0
$where
GROUP BY
l.lid
HAVING ( (sum(lpicogreen) > 0 )
AND (COUNT(l.lid)=1) )
ORDER BY
l.idtag,s.idproject,s.name
#;
#print "query = $query<br>";
#l.lstatus='Taqman finished' AND 

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

# sort tag
my %sorted  = ();
my %counter = ();
while (@row = $out->fetchrow_array) {
	$counter{$row[8]}++;
	$sorted{$counter{$row[8]}}{$row[8]}=[@row];
}
@labels	= (
	'n',
	'Box',
	'Library',
	'Pool',
	'Barcode',
	'Plate',
	'Row',
	'Column',
	'Index',
	'Status',
	'BA size',
	'BA hs size',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'ul for 10 nMol (PicoGreen)',
	'ul for 10 nMol (qPCR)'
	);

# form

# table
print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

$n=1;
my $tmpajoin = "";
foreach $set (sort keys %sorted) {
foreach $tag (sort keys %{$sorted{$set}} ) {
	print "<tr>";
	$i=0;
	(@row) = @{$sorted{$set}{$tag}};
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			$tmpajoin=join("###",@row);
			#print "@row<br>";
			print "<td align=\"center\">
			<input type=\"checkbox\" name=\"checkbox\" value=\"$tmpajoin\"></td>";
		}
		elsif ($i == 2) {
			#print "<td align=\"center\"> $row[$i]</td>";
print "<td align=\"center\"><a href=\"library.pl?id=$row[1]\&amp;mode=edit\">$row[2]</a\></td>";
		}
		elsif ($i == 3) {
			#print "<td align=\"center\"> $row[$i]</td>";
print "<td align=\"center\"><a href=\"pool.pl?id=$row[0]\&amp;mode=edit\">$row[3]</a\></td>";
		}
		elsif ($i > 2) {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
}
print "</table>";

$out->finish;
}
########################################################################
# poolingsheet called by poolingDoDo.pl
########################################################################

sub poolingsheet {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $checkboxref = shift;
my (@checkbox)  = @$checkboxref;
my $idpool      = "";
my @labels      = ();
my @row         = ();
my %indices     = ();
my $i           = 0;
my $n           = 1;
my $volumeqpcr  = 0;
my $volumepicoGreen  = 0;
my $date=&actualDate;

@labels	= (
	'n',
	'Library',
	'Pool',
	'Barcode',
	'Plate',
	'Row',
	'Column',
	'Index1',
	'Index2',
	'Status',
	'BA size',
	'BA hs size',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'ul for 10 nMol (PicoGreen)',
	'ul for 10 nMol (qPCR)'
	);

# form
print "$date<br><br>";

# table
print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
foreach $idpool (@checkbox) {
	(@row) = split(/###/,$idpool);
	#print "@row<br>";
	$volumepicoGreen += $row[15];
	$volumeqpcr += $row[16];
	print "<tr>";
	$i=0;
	# check for duplicate indices
	if ($row[8] ne '') {
		$indices{$row[8]}{$row[9]}++;
		if ($indices{$row[8]}{$row[9]} >=2) {
			print "Duplicate Index (@row)<br><br>";
			exit;
		}
	}
	if ($ref->{pooled} == 1) {
		&pooled($dbh,$row[1]);
	}
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		elsif ($i > 1) {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";
print "<br><span class=\"big\">Volume PicoGreen $volumepicoGreen ul</span>";
print "<br><span class=\"big\">Volume qPCR      $volumeqpcr ul</span>";

}
########################################################################
sub pooled {
my $dbh = shift;
my $lid = shift;
my $sth = "";
my $sql = qq#
UPDATE library
SET lstatus="pooled"
WHERE lid = $lid
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
#print "$lid pooled<br>";

}
########################################################################
# searchSequencing called by sequencingDo.pl
########################################################################
sub searchSequencing {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $npool            = 12;
my $set              = 0;
my $tag              = 0;
my $where            = "";

if ($ref->{'ds.iddisease'} ne "") {
	if ($where ne "") {
		$where .= "AND " . $where;
	}
	$where .= " ds.iddisease = $ref->{'ds.iddisease'} ";
}
if ($ref->{'s.idcooperation'} ne "") {
	if ($where ne "") {
		$where .= "AND ";
	}
	$where .= " s.idcooperation = $ref->{'s.idcooperation'} ";
}
if ($ref->{'oflowcell'} ne " ") {
	if ($where ne "") {
		$where .= "AND ";
	}
	$where .= " o.oflowcell = \"$ref->{'oflowcell'}\" ";
}
if ($ref->{'oreadlength'} ne " ") {
	if ($where ne "") {
		$where .= "AND ";
	}
	$where .= " o.oreadlength = \"$ref->{'oreadlength'}\" ";
}
if ($ref->{'oworkflow'} ne " ") {
	if ($where ne "") {
		$where .= "AND ";
	}
	$where .= " o.oworkflow = \"$ref->{'oworkflow'}\" ";
}
if ($ref->{'idproject'} ne "") {
	if ($where ne "") {
		$where .= "AND ";
	}
	$where .= " s.idproject = $ref->{'idproject'} ";
}
if ($ref->{'lforpool'} ne "") {
	if ($where ne "") {
		$where .= "AND ";
	}
	$where .= " lforpool = \'$ref->{'lforpool'}\' ";
}
if ($where ne "") {
	$where = "WHERE " . $where;
}
#print "where $where<br>";
	
$i=0;
#GROUP_CONCAT('\<a href=\"library.pl?id=',l.lid,'&amp;pid=&amp;mode=edit\"\>',l.lname,'\</a\>'),
#CONCAT('<a href=\"pool.pl?id=',o.idpool,'&amp;pid=&amp;mode=edit\">',o.oname,'</a>'),
$query = qq#
SELECT DISTINCT
p.pdescription,
o.idpool,o.odescription,
o.oflowcell,
o.oreadlength,
o.oworkflow,
tag1.tgroup,
if((LENGTH(tag1.ttag)>0),LENGTH(tag1.ttag),LENGTH(b10x.ttag)),
LENGTH(tag2.ttag),
o.ophix,
obarcode,o.oplate,o.orow,o.ocolumn,
group_concat(DISTINCT l.lstatus),
sum(DISTINCT o.olanestosequence),
if(count(a.aid)/count(DISTINCT l.lid)-sum(replace(a.aread1failed,'T',1))/count(DISTINCT l.lid)>0,
count(a.aid)/count(DISTINCT l.lid)-sum(replace(a.aread1failed,'T',1))/count(DISTINCT l.lid),0) as finished,
if(count(l.lid) > 1, FORMAT(o.picogreennmol,1) , FORMAT(l.lpicogreen,1) ),
FORMAT(o.opcr,1),FORMAT(o.opcrrecalculated,1),
o.oloadingconcentration
FROM
library l
INNER JOIN sample2library sl ON (l.lid = sl.lid)
INNER JOIN $exomedb.sample s ON (sl.idsample = s.idsample)
INNER JOIN library2pool lo ON (l.lid = lo.lid)
INNER JOIN pool o ON (lo.idpool = o.idpool)
LEFT JOIN lane a ON o.idpool = a.idpool
LEFT JOIN $exomedb.disease2sample ds ON (s.idsample = ds.idsample)
LEFT JOIN $exomedb.disease d ON (ds.iddisease = d.iddisease)
LEFT JOIN $exomedb.project p ON s.idproject = p.idproject
LEFT JOIN tag              tag1 ON l.idtag     = tag1.idtag
LEFT JOIN tag              tag2 ON l.idtag2    = tag2.idtag
LEFT JOIN (SELECT b1.* from barcodes10x b1 GROUP BY b1.idtag) b10x ON b10x.idtag=l.idtag 
$where
GROUP BY
o.idpool
HAVING ( (count(l.lid)>1 AND ( (sum(o.picogreennmol) > 0) OR (sum(o.opcr) > 0) ) )
OR ( (sum(replace(lforpool,'T',1)) = 0) AND sum(lpicogreen) > 0 ) )
AND  
finished
< sum(DISTINCT o.olanestosequence)
ORDER BY 
o.oplate,o.orow,o.ocolumn
#;
# sucht alle mit 'forpooling' not 'T' OR sum(replace(lforpool,'T',1)) = 0
#print "query = $query<br>";
# more than 1 lib in pool: HAVING ( (count(l.lid)>1 AND ( (sum(o.picogreennmol) > 0) OR (sum(o.opcr) > 0) ) )
# forpooling = false: OR ( (sum(replace(lforpool,'T',1)) = 0) AND sum(lpicogreen) > 0 ) )

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'Box',
	'Project',
	'Poold.',
	'Flow cell',
	'Read length',
	'Workflow',
	'Index group',
	'Index1 length',
	'Index2 length',
	'PhiX (%)',
	'Barcode',
	'Plate',
	'Row',
	'Column',
	'Status',
	'Lanes to do',
	'Lanes finished',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'qPCR recaculated (nMol)',
	'Loading concentration (pM)'
	);

# form

# table
print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";

$n=1;
my $tmpajoin = "";
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			$tmpajoin=join("###",@row);
			#print "@row<br>";
			print "<td align=\"center\">
			<input type=\"checkbox\" name=\"checkbox\" value=\"$tmpajoin\"></td>";
			print "<td align=\"center\"> $row[$i]</td>";
		}
		elsif ($i == 2) {
			#print "<td align=\"center\"> $row[$i]</td>";
			print "<td align=\"center\"><a href=\"pool.pl?id=$row[1]\&amp;mode=edit\">$row[2]</a\></td>";
		}
		elsif ($i > 2)  {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";

$out->finish;
}
########################################################################
# sequencingsheet called by sequencingDoDo.pl
########################################################################
# for HiSeq4000 and NovaSeq
sub sequencingsheet {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $checkboxref = shift;
my (@checkbox)  = @$checkboxref;
my $idpool      = "";
my @labels      = ();
my @row         = ();
my $k           = 0;
my $i           = 0;
my $n           = 0;
my $tmp         = 0;
my $mycolor     = 0;
my $colortype   = 0;
my $date=&actualDate;
my $offset      = 20;
my $lanestodo   = 0;
my $lanesfinished = 0;
my $picogreen   = 0;
my $qpcr        = 0;
my $flowcellnmol = 2;
my $qpcrrecalculated = 0;
my $requiredvolume = 0;
my $volpool     = 0;
my $voleb       = 0;
my $phix        = 0;
my $used        = "";
my $flowcell    = "";
my $workflow    = ""; # Standard or XP
my $naoh        = "";
my $trishcl     = "";
my $laneperflowcell = "";
my $loadingconcentration = "";

# for NovaSeq
my %loadingconcentrationhiseq = (
	100 => 1.0,
	150 => 1.5,
	200 => 2.0,
	250 => 2.5,
	300 => 3.0,
	350 => 3.5,
	400 => 4.0,
	450 => 4.5,
	500 => 5.0
);

# for NovaSeq
my %loadingconcentrationnovaseq = (
	100 => 0.5,
	150 => 0.75,
	200 => 1.0,
	250 => 1.25,
	300 => 1.5,
	350 => 1.75,
	400 => 2.0,
	450 => 2.25,
	500 => 2.5
);

my %loadingconcentrationmiseq = (
	100 => 0.5,
	150 => 0.75,
	200 => 1.0,
	250 => 1.25,
	300 => 1.5,
	350 => 1.75,
	400 => 2.0,
	450 => 2.25,
	500 => 2.5
);

# for NovaSeq
my %volume = (
	NovaSeqSP => {
		Standard => 100,
		XP       => 18,
	},
	NovaSeqS1 => {
		Standard => 100,
		XP       => 18,
	},
	NovaSeqS2 => {
		Standard => 150,
		XP       => 22,
	},
	NovaSeqS4 => {
		Standard => 310,
		XP       => 30,
	},
);

my %phix = (
	NovaSeqSP => {
		Standard => 0.6,
		XP       => 0.7,
	},
	NovaSeqS1 => {
		Standard => 0.6,
		XP       => 0.7,
	},
	NovaSeqS2 => {
		Standard => 0.9,
		XP       => 0.8,
	},
	NovaSeqS4 => {
		Standard => 1.9,
		XP       => 1.1,
	},
);

my %naoh = (
	NovaSeqSP => {
		Standard => 25,
		XP       => 4,
	},
	NovaSeqS1 => {
		Standard => 25,
		XP       => 4,
	},
	NovaSeqS2 => {
		Standard => 37,
		XP       => 5,
	},
	NovaSeqS4 => {
		Standard => 77,
		XP       => 7,
	},
);

my %trishcl = (
	NovaSeqSP => {
		Standard => 25,
		XP       => 5,
	},
	NovaSeqS1 => {
		Standard => 25,
		XP       => 5,
	},
	NovaSeqS2 => {
		Standard => 38,
		XP       => 6,
	},
	NovaSeqS4 => {
		Standard => 78,
		XP       => 8,
	},
);

@labels	= (
	'n',
	'Project',
	'Poold.',
	'Flow cell',
	'Read length',
	'Workflow',
	'Index group',
	'Index1 length',
	'Index2 length',
	'PhiX (%)',
	'Barcode',
	'Plate',
	'Row',
	'Column',
	'Status',
	'Lanes to do',
	'Lanes finished',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'qPCR recaculated (nMol)',
	'Loading concentration (pM)',
	'Used',
	'Required Vol (ul)',
	'Vol Pool (ul)',
	'Vol EB (ul)',
	'PhiX (ul)',
	'NaOH (ul)',
	'Tris-HCl 400 mM (ul)'
	);

print "$date<br><br>";

# table
#print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;
&tableheader("2300px");
print "<thead><tr>";

#print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";
#print "</tr>";
foreach $idpool (@checkbox) {
	(@row) = split(/###/,$idpool);
	#print "@row<br>";
	$flowcell=$row[3];
	$workflow=$row[5];
	$loadingconcentration=$row[$offset];
	$flowcellnmol="";
	$lanestodo=$row[$offset-5];
	$lanesfinished=$row[$offset-4];
	$picogreen=$row[$offset-3];
	$qpcr=$row[$offset-2];
	$qpcrrecalculated=$row[$offset-1];
	if ($flowcell eq 'HiSeq4000') {
		$laneperflowcell = 8;
	}
	elsif ($flowcell eq 'MiSeq') {
		$laneperflowcell = 1;
	}
	elsif ($flowcell eq 'NovaSeqS4') {
		$laneperflowcell = 4;
	}
	else {
		$laneperflowcell = 2;
	}
	for ($k=1;$k<=$lanestodo-$lanesfinished;$k++) { # several lanes
	if ($n%$laneperflowcell == 0) {   #new flowcell every 8 lanes
		print "<tr><td>Flowcell</td>";
		for ($tmp=1;$tmp<=$offset+7;$tmp++) {
			print "<td></td>";
		}
		print "</tr>";
	}
	print "<tr>";
	if ($k == 1) {$mycolor="class=\"formbg\"";} else {$mycolor="";}
	#if ($k == 1 and $colortype==0) {$mycolor="class=\"formbg\"";$colortype=1}
	#elsif ($k == 1 and $colortype==1) {$mycolor="class=\"cytoFish\"";$colortype=0}
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			# Lanes
			$tmp=$n%$laneperflowcell+1;
			print "<td align=\"center\">$tmp</td>";
			print "<td align=\"center\" $mycolor> $row[$i]</td>";
		}
		# 1 idpool wird ausgelassen
		elsif ($i >= 2) {
			print "<td align=\"center\" $mycolor> $row[$i]</td>";
		}
		if ($i == $offset) {
			if ($flowcell eq 'HiSeq4000') {
				$requiredvolume = 5;
				$phix=$requiredvolume/10;
				$flowcellnmol = $loadingconcentrationhiseq{$loadingconcentration};
			}
			elsif ($flowcell eq 'MiSeq') {
				$requiredvolume = 5;
				$phix=$requiredvolume/10;
				$flowcellnmol = $loadingconcentrationhiseq{$loadingconcentration};
			}
			else { #NovaSeq 
				$requiredvolume = $volume{$flowcell}{$workflow};
				$phix = $phix{$flowcell}{$workflow};
				$naoh = $naoh{$flowcell}{$workflow};
				$trishcl = $trishcl{$flowcell}{$workflow};
				$flowcellnmol = $loadingconcentrationnovaseq{$loadingconcentration};
			}
			if ($picogreen > 0) { #picogreen
				$used = "Picogreen";
				#$volpool=sprintf("%.2f",($requiredvolume-$requiredvolume/10)*$flowcellnmol/$picogreen);
				if ($flowcell eq 'HiSeq4000') {
					$volpool=sprintf("%.2f",($requiredvolume-$phix)*$flowcellnmol/$picogreen);
				}
				elsif ($flowcell eq 'MiSeq') {
					$volpool=sprintf("%.2f",($requiredvolume-$phix)*$flowcellnmol/$picogreen);
				}
				else {
					$volpool=sprintf("%.2f",($requiredvolume)*$flowcellnmol/$picogreen);
				}
			}
			if ($qpcrrecalculated > 0) { # opcrrecalculted
				$used = "qPCR recalculated";
				if ($flowcell eq 'HiSeq4000') {
					$volpool=sprintf("%.2f",($requiredvolume-$phix)*$flowcellnmol/$qpcrrecalculated);
				}
				elsif ($flowcell eq 'MiSeq') {
					$volpool=sprintf("%.2f",($requiredvolume-$phix)*$flowcellnmol/$qpcrrecalculated);
				}
				else {
					$volpool=sprintf("%.2f",($requiredvolume)*$flowcellnmol/$qpcrrecalculated);
				}
			}
			elsif ($qpcr > 0) { # opcr
				$used = "qPCR";
				if ($flowcell eq 'HiSeq4000') {
					$volpool=sprintf("%.2f",($requiredvolume-$phix)*$flowcellnmol/$qpcr);
				}
				elsif ($flowcell eq 'MiSeq') {
					$volpool=sprintf("%.2f",($requiredvolume-$phix)*$flowcellnmol/$qpcr);
				}
				else {
					$volpool=sprintf("%.2f",($requiredvolume)*$flowcellnmol/$qpcr);
				}
			}
			if ($flowcell eq 'HiSeq4000') {
				$voleb=sprintf("%.2f",$requiredvolume-$phix-$volpool);
			}
			elsif ($flowcell eq 'MiSeq') {
				$voleb=sprintf("%.2f",$requiredvolume-$phix-$volpool);
			}
			else {
				$voleb=sprintf("%.2f",$requiredvolume-$volpool);
			}
			print "<td align=\"center\">$used</td>";
			print "<td align=\"center\">$requiredvolume</td>";
			print "<td align=\"center\">$volpool</td>";
			print "<td align=\"center\">$voleb</td>";
			print "<td align=\"center\">$phix</td>";
			print "<td align=\"center\">$naoh</td>";
			print "<td align=\"center\">$trishcl</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
	}
}
#print "</table>";
print "</tbody></table></div>";
&tablescript2;

}

########################################################################
# sequencingsheet called by sequencingDoDo.pl
########################################################################
# for HiSeq2500
sub sequencingsheet_old {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $checkboxref = shift;
my (@checkbox)  = @$checkboxref;
my $idpool      = "";
my @labels      = ();
my @row         = ();
my $k           = 0;
my $i           = 0;
my $n           = 0;
my $tmp         = 0;
my $mycolor     = 0;
my $colortype   = 0;
my $date=&actualDate;
my $offset      = 14;
my $denaturation= 0;
my $dilution    = 0;
my $adddilution = 0;
my $dilution2   = 0;
my $adddilution2= 0;

@labels	= (
	'n',
	'Project',
	'Disease',
	'Pool',
	'Poold.',
	'Plate',
	'Barcode',
	'Row',
	'Column',
	'Status',
	'Lanes to do',
	'Lanes finished',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'Flowcell (pMol)',
	'1:7/1:2 denaturation in EB pM',
	'20pM dilution in HT1 \B5l',
	'Add HT1 \B5l',
	'Volume 20pM dilution \B5l',
	'Add HT1 \B5l'
	);

# form
print "$date<br><br>";

# table
print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
foreach $idpool (@checkbox) {
	(@row) = split(/###/,$idpool);
	#print "@row<br>";
	for ($k=1;$k<=$row[$offset-4]-$row[$offset-3];$k++) { # several lanes
	if ($n%8 == 0) {   #new flowcell every 8 lanes
		print "<tr><td>Flowcell</td>";
		for ($tmp=1;$tmp<=$offset+5;$tmp++) {
			print "<td></td>";
		}
		print "</td>";
	}
	print "<tr>";
	if ($k == 1) {$mycolor="class=\"formbg\"";} else {$mycolor="";}
	#if ($k == 1 and $colortype==0) {$mycolor="class=\"formbg\"";$colortype=1}
	#elsif ($k == 1 and $colortype==1) {$mycolor="class=\"cytoFish\"";$colortype=0}
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			# Lanes
			$tmp=$n%8+1;
			print "<td align=\"center\">$tmp</td>";
			print "<td align=\"center\" $mycolor> $row[$i]</td>";
		}
		# 1 idpool wird ausgelassen
		elsif (($i > 2) or ($i == 1)){
			print "<td align=\"center\" $mycolor> $row[$i]</td>";
		}
		if ($i == $offset) {
			if ($row[$offset-2] > 0) {
				if ($row[$offset-2] < 5) { # opicogreenmol
				$denaturation=sprintf("%.2f (1:2)",$row[$offset-2]*1000/2);
				}
				else  {
				$denaturation=sprintf("%.2f (1:7)",$row[$offset-2]*1000/7);
				}
			}
			if ($row[$offset-1] > 0) { # opcr
				if ($row[$offset-1] < 5) {
				$denaturation=sprintf("%.2f (1:2)",$row[$offset-1]*1000/2);
				}
				else  {
				$denaturation=sprintf("%.2f (1:7)",$row[$offset-1]*1000/7);
				}
			}
			$dilution=sprintf("%.2f",200*20/$denaturation);
			$adddilution=200-$dilution;
			$dilution2=$row[$offset]*10;
			$adddilution2=200-$dilution2;
			print "<td align=\"center\">$denaturation</td>";
			print "<td align=\"center\">$dilution</td>";
			print "<td align=\"center\">$adddilution</td>";
			print "<td align=\"center\">$dilution2</td>";
			print "<td align=\"center\">$adddilution2</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
	}
}
print "</table>";

}

########################################################################
# taqmansheet called by taqmanDoDo.pl
########################################################################

sub taqmansheet {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $checkboxref = shift;
my (@checkbox)  = @$checkboxref;
my $dilution    = 6;
my @oname       = ();
my @obarcode    = ();
my %pipette     = ();
my $date        = &actualDate;
my $mypid       = getppid;
my $mytime      = time;
my $pidtime     = "$mypid$mytime";
my $tmp_dir     = "/www/solexatmp/$pidtime";
my $tmp_dir    = "/srv/www/htdocs/tmp";
my $down_dir    = "/solexatmp/$pidtime";
my $down_dir   = "/tmp";
mkdir("$tmp_dir",0755);

print "<pre>";
&labsheet;
print "</pre>";
print "<br><br>";
print "<span class=\"big\">Taqman Import</span>";
print "<br><br>";
print "<pre>";
&importsheet;
print "</pre>";
print "<br><br>";
print "<span class=\"big\">Taqman Pipettesheet</span>";
print "<br><br>";
print "<pre>";
&pipettesheet;
print "</pre>";

sub labsheet {
my $file        = "";
my $sql         = "";
my $sth         = "";
my @row         = ();
my @labels      = ();
my $i           = 0;
my $k           = 0;
my $idpool      = "";

@labels	= (
	'n',
	'Pool',
	'Plate',
	'Row',
	'Column',
	'Barcode',
	'Barcode Control',
	'BA size',
	'PicoGreen (nMol)',
	'qPCR (nMol)',
	'qPCR corrected (nMol)'
	);

foreach (@labels) {
	$file .= "$_,";
}
$file .= "\n";



$k=1;
foreach $idpool (@checkbox) {
	
$sql = qq#
SELECT
$k,
o.oname,
o.oplate,o.orow,o.ocolumn,
o.obarcode,'',
FORMAT(IF (AVG(lbiohssize)>0,AVG(lbiohssize),AVG(lbio1size)),0),
FORMAT(AVG(lpicogreen),1),
'',CONCAT("=J",$k+1,"*288/H",$k+1,"*",$dilution)
FROM
library l
INNER JOIN library2pool lo ON (l.lid = lo.lid)
INNER JOIN pool o ON (lo.idpool = o.idpool)
WHERE l.lstatus='library prepared'
AND o.idpool=$idpool
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
	$i=0;
	foreach (@row) {
		if ($i==1) {
			# for triplicates
			if (length($row[$i])>15) {
				$row[$i]=substr($row[$i],0,15);
				$row[$i] .="...";
			}
			push(@oname,$row[$i]);
		}
		if ($i==5) {
			push(@obarcode,$row[$i]); # nur f\FCr Import sheet
		}
		$file .= "$row[$i],";
		$i++;
	}
	$file .= "\n";
	$k++;

} #end foreach lid
print $file;
open (OUT, ">$tmp_dir/taqman-labsheet-$date.csv") || die "Can't write to $tmp_dir/labsheet-$date.csv";
print OUT $file;
print "\n";
print "<a href=\"$down_dir/taqman-labsheet-$date.csv\">Taqman Labsheet</a>\n";
} #end sub labsheet

sub importsheet {
my $file    = "";
my $oname   = "";
my $i       = 0;
my $k       = 0;
my $pos     = 0;
my $start   = 0;
my $rowlength   = 12; # samples per row

$file=
"*** SDS Setup File Version	3
*** Output Plate Size	384
*** Output Plate ID	qPCR_$date
*** Number of Detectors	1
Detector	Reporter	Quencher	Description	Comments
LIBQPCR	SYBR		sybergreen primer for quantifika			
Well	Sample Name	Detector	Task	Quantity
26	Std.10pM	LIBQPCR	STND	10.0
27	Std.1pM	LIBQPCR	STND	1.0
28	Std.0.1pM	LIBQPCR	STND	0.1
29	Std.0.01pM	LIBQPCR	STND	0.01
30	Std.0.001pM	LIBQPCR	STND	0.0010
31	NTC	LIBQPCR	NTC	0.0
50	Std.10pM	LIBQPCR	STND	10.0
51	Std.1pM	LIBQPCR	STND	1.0
52	Std.0.1pM	LIBQPCR	STND	0.1
53	Std.0.01pM	LIBQPCR	STND	0.01
54	Std.0.001pM	LIBQPCR	STND	0.0010
55	NTC	LIBQPCR	NTC	0.0
";
%pipette = (
	26 => 'Std.10pM',
	27 => 'Std.1pM',
	28 => 'Std.0.1pM',
	29 => 'Std.0.01pM',
	30 => 'Std.0.001pM',
	31 => 'NTC',
	50 => 'Std.10pM',
	51 => 'Std.1pM',
	52 => 'Std.0.1pM',
	53 => 'Std.0.01pM',
	54 => 'Std.0.001pM',
	55 => 'NTC',
);
$start=74;
foreach $oname (@oname) {
	$pos=$start+$i%$rowlength;
	$file.= "$pos	$obarcode[$i]_$oname	LIBQPCR	UNKN	0.0\n";
	$file.= $pos+24 . "	$obarcode[$i]_$oname	LIBQPCR	UNKN	0.0\n";
	$file.= $pos+2*24 . "	$obarcode[$i]_$oname	LIBQPCR	UNKN	0.0\n";
	$pipette{$pos}=$oname;
	$pipette{$pos+24}=$oname;
	$pipette{$pos+2*24}=$oname;
	$i++;
	if ($i%$rowlength == 0) {
		$start = $start + 3*24;
	}
}
print $file;
open (OUT, ">$tmp_dir/taqman-import-$date.txt") || die "Can't write to $tmp_dir/labsheet-$date.txt";
print OUT $file;
print "\n";
print "<a href=\"$down_dir/taqman-import-$date.txt\">Taqman Import</a>\n";
} #end sub importsheet

sub pipettesheet {
my $file    = "";
my $oname   = "";
my $i       = 0;
my $j       = 0;
my $pos     = 1;
my $row     = 6;
my $start   = 0;

for ($i=1;$i<=16;$i++) {
	for ($j=1;$j<=24;$j++) {
		if (exists($pipette{$pos})) {
			$file .= "$pipette{$pos}";
		}
		$file .= ",";
		$pos++;
	}
	$file .= "\n";
}

print $file;
open (OUT, ">$tmp_dir/taqman-pipettesheet-$date.csv") || die "Can't write to $tmp_dir/labsheet-$date.csv";
print OUT $file;
print "\n";
print "<a href=\"$down_dir/taqman-pipettesheet-$date.csv\">Taqman Pipettesheet</a>\n";
} #end sub pipettesheet
}
########################################################################
# libsheet lname bestimmen called by libsheet.pl
########################################################################

sub libsheet {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $checkboxref = shift;
my (@checkbox)  = @$checkboxref;
my ($idsample,$samplename,$lid);
my $sql         = "";
my $sth         = "";
my @row         = ();
my @lid         = ();
my $idpool      = "";
my @idpool      = ();
my $libinprocess= $ref->{libinprocess};
delete($ref->{checkbox});
delete($ref->{libinprocess});

if ($ref->{create_exome} eq "Create Libraries for Exome") {
	delete($ref->{create_exome});
	&createlibentries;
	&exomesheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for exome
}
elsif ($ref->{create_genome} eq "Create Libraries for Genome") {
	delete($ref->{create_genome});
	&createlibentries;
	&genomesheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for genome
}
elsif ($ref->{create_rnaseq} eq "Create Libraries for RNAseq") {
	delete($ref->{create_rnaseq});
	&createlibentries;
	&chipseqsheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for genome
}
elsif ($ref->{create_chipseq} eq "Create Libraries for ChIPseq") {
	delete($ref->{create_chipseq});
	&createlibentries;
	&chipseqsheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for genome
}
elsif ($ref->{exome_sheet} eq "Exome Sheet") {
	foreach (@checkbox) { # loop around checkbox
		($idsample,$samplename,$lid,$idpool)=split(/\_/);
		push(@lid,$lid); # lid for sheet
		push(@idpool,$idpool); # lid for sheet
	}
	&exomesheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for exome
}
elsif ($ref->{genome_sheet} eq "Genome Sheet") {
	foreach (@checkbox) { # loop around checkbox
		($idsample,$samplename,$lid,$idpool)=split(/\_/);
		push(@lid,$lid); # lid for sheet
		push(@idpool,$idpool); # lid for sheet
	}
	&genomesheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for genome
}
elsif ($ref->{rnaseq_sheet} eq "RNAseq Sheet") {
	foreach (@checkbox) { # loop around checkbox
		($idsample,$samplename,$lid,$idpool)=split(/\_/);
		push(@lid,$lid); # lid for sheet
		push(@idpool,$idpool); # lid for sheet
	}
	&rnaseqsheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for genome
}
elsif ($ref->{chipseq_sheet} eq "ChIPseq Sheet") {
	foreach (@checkbox) { # loop around checkbox
		($idsample,$samplename,$lid,$idpool)=split(/\_/);
		push(@lid,$lid); # lid for sheet
		push(@idpool,$idpool); # lid for sheet
	}
	&chipseqsheet($dbh,\@lid,\@idpool,$libinprocess); #csv sheet for genome
}


########################################################################
sub createlibentries {
	#my $ntag = 0;
	#my @tag = ();
	# check if all parameters are provided
	if ($ref->{libtype}  eq "") {
		print "Please select a material. Nothing done.<br>";
		printFooter();
		exit(1);
	}
	if ($ref->{libpair}  eq "") {
		print "Please select a library type. Nothing done.<br>";
		printFooter();
		exit(1);
	}
	if ($ref->{idassay}  eq "") {
		print "Please select a assay type. Nothing done.<br>";
		printFooter();
		exit(1);
	}
	$ref->{uid} = $iduser;
	if ($ref->{uid}  eq "") {
		print "Please select 'Entered from'. Nothing done.<br>";
		printFooter();
		exit(1);
	}
	# search for tags
	#$sql= "
	#SELECT idtag
	#FROM tag
	#WHERE tgroup = 'Illumina TrueSeq RNA and DNA'
	#ORDER BY tname
	#";
	#$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	#$sth->execute() || die print "$DBI::errstr";
	#while (@row = $sth->fetchrow_array) {
	#	push(@tag,$row[0]);
	#}
	#if ($#tag != 11) {
	#	print "Tags not correct.<br>";
	#	exit(1);
	#}
	# end search for tags
	foreach (@checkbox) { # loop around checkbox
		($idsample,$samplename,$lid)=split(/\_/);
		#$ref->{idtag}=$tag[$ntag%12];
		
		$dbh->{AutoCommit}=0;
		eval {
			&checkLibraryName;
			&createlid;
			&createSample2library;
		};
		if ($@) {
			print " $@ Rollback done.<br>";
			eval { $dbh->rollback };
			exit(0);
		}
		else {
			$dbh->do("commit");
		}
		#$ntag++;
	} # end loop around checkbox
} # end createlibentries

sub checkLibraryName {
	my $oldlib = "";
	my $i = 1;
	
	while (1==1) {
		$sql= "
		SELECT lname 
		FROM library
		WHERE lname = \"$samplename\_LIB$i\"
		";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute() || die print "$DBI::errstr";
		$oldlib = $sth->fetchrow_array;
		if ($oldlib eq uc($samplename) . "\_LIB" . $i) {
			$i++;
		}
		else {
			last;
		}
	} # end while true
	$ref->{lname}=$samplename . "\_LIB" . $i;
}
sub createlid {
	print "Tag $ref->{idtag}. ";
	$idpool=&insertIntoLibrary('',$ref,$dbh,'library');
	print qq#Library <a href="library.pl?id=$ref->{lid}&amp;mode=edit">$ref->{lname}</a> created.<br>#;
	push(@lid,$ref->{lid}); # lid for sheet, wird in insertIntoLibrary definiert
	push(@idpool,$idpool); # idpool for sheet
	#print "lid $ref->{lid}<br>";
}
sub createSample2library {
	my $s2lref;
	$s2lref->{idsample}=$idsample;
	$s2lref->{lid}=$ref->{lid};
	&insertIntoSample2library('',$s2lref,$dbh,'sample2library');
}
} # end libsheet
########################################################################

sub exomesheet {
my $dbh          = shift;
my $lidref       = shift;
my $idpoolref    = shift;
my $libinprocess = shift;
my @lid          = @$lidref;
my @idpool       = @$idpoolref;
my $shearing_DNA = 3000;
my $shearing_TE  = 130;
my $lid          = "";
my $idpool       = "";
my @labels       = ();
my $k            = 0;
my $i            = 0;
my $sql          = "";
my $sth          = "";
my @row          = ();

print "<br>";
@labels	= (
	'Box',
	'Column',
	'Row',
	'DNA Id',
	'DNA Barcode',
	'DNA Barcode control',
	'Library',
	'Pool',
	'Pool Barcode',
	'Number',
	'Index1',
	'Index2',
	'Nano Drop (ng/ul)',
	"Shearing DNA ul($shearing_DNA ng)",
	"Shearing TE ul ($shearing_TE - DNA)",
	"BA post shearing (ng/ul)",
	"BA post shearing (nMol)",
	"BA post shearing bp",
	"BA post PCR (ng/ul)",
	"BA post PCR (nMol)",
	"BA post PCR bp",
	"750 ng",
	"BA post Hyb (ng/ul)",
	"BA post Hyb (nMol)",
	"BA post Hyb bp",
	"PicoGreen (pg/ul)",
	"PicoGreen (nMol)",
	"qPCR (nMol)",
	"Project",
	"Kit"
	);

foreach (@labels) {
	print "$_,";
}
print "<br>";



$k=1;
foreach $lid (@lid) {
	#print "$_<br>";
	#($idsample,$lid)=split(/\_/);
	$idpool = $idpool[$k-1];
	#print "$idpool<br>";
	
$sql = qq#
SELECT
s.splate,s.scolumn,s.srow,s.name,s.sbarcode,
'',l.lname,o.oname,'',$k,t.tname,tt.tname,
s.snanodrop,concat("=$shearing_DNA/M",$k+1),concat("=$shearing_TE-N",$k+1),
'','','','','','',concat('=750/S',$k+1),'','','','','','',p.pdescription,k.cdescription
FROM
$exomedb.sample s
INNER JOIN $exomedb.project p ON s.idproject=p.idproject
LEFT JOIN sample2library sl ON (s.idsample = sl.idsample)
LEFT JOIN library l ON (sl.lid = l.lid)
LEFT JOIN tag t ON (l.idtag = t.idtag)
LEFT JOIN tag tt ON (l.idtag2 = t.idtag)
LEFT JOIN library2pool lo ON (l.lid = lo.lid)
LEFT JOIN pool o ON (lo.idpool = o.idpool)
LEFT JOIN stock st ON l.lkit= st.sid
LEFT JOIN kit k ON st.cid=k.cid
WHERE l.lid='$lid'
AND o.idpool='$idpool'
ORDER BY
t.tname
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
	$i=0;
	foreach (@row) {
		print "$row[$i],";
		$i++;
	}
	print "<br>";
	$k++;
	
# libinprocess
if ($libinprocess == 1) {
	&libinprocess($dbh,$lid);
}

} #end foreach lid

########################################################################

sub genomesheet {
my $dbh          = shift;
my $lidref       = shift;
my $idpoolref    = shift;
my $libinprocess = shift;
my @lid          = @$lidref;
my @idpool       = @$idpoolref;
my $shearing_DNA = 1000;
my $shearing_TE  = 50;
my $lid          = "";
my $idpool       = "";
my @labels       = ();
my $k            = 0;
my $i            = 0;
my $sql          = "";
my $sth          = "";
my @row          = ();

print "<br>";
@labels	= (
	'Box',
	'Column',
	'Row',
	'DNA Id',
	'DNA Barcode',
	'DNA Barcode control',
	'Library',
	'Pool',
	'Pool Barcode',
	'Number',
	'Index1',
	'Index2',
	'Nano Drop (ng/ul)',
	"Shearing DNA ul($shearing_DNA ng)",
	"Shearing TE ul ($shearing_TE - DNA)",
	"BA post shearing (ng/ul)",
	"BA post shearing (nMol)",
	"BA post shearing bp",
	"BA post PCR (ng/ul)",
	"BA post PCR (nMol)",
	"BA post PCR bp",
	"PicoGreen post PCR (pg/ul)",
	"PicoGreen post PCR (nMol)",
	"PicoGreen (10 nMol)",
	"PicoGreen (pg/ul)",
	"PicoGreen (nMol)",
	"qPCR (nMol)"
	);

foreach (@labels) {
	print "$_,";
}
print "<br>";



$k=1;
foreach $lid (@lid) {
	#print "$_<br>";
	#($idsample,$lid)=split(/\_/);
	$idpool = $idpool[$k-1];
	
$sql = qq#
SELECT
s.splate,s.scolumn,s.srow,s.name,s.sbarcode,
'',l.lname,o.oname,'',$k,t.tname,tt.tname,
s.snanodrop,concat("=$shearing_DNA/M",$k+1),concat("=$shearing_TE-N",$k+1),
'','','','','','','',concat("=V",$k+1,"*1000/650*200/U",$k+1),
concat("=W",$k+1,"*3-30"),'',concat("=Y",$k+1,"*1000/650*200/U",$k+1)
FROM
$exomedb.sample s 
LEFT JOIN sample2library sl ON (s.idsample = sl.idsample)
LEFT JOIN library l ON (sl.lid = l.lid)
LEFT JOIN tag t ON (l.idtag = t.idtag)
LEFT JOIN tag tt ON (l.idtag2 = t.idtag)
LEFT JOIN library2pool lo ON (l.lid = lo.lid)
LEFT JOIN pool o ON (lo.idpool = o.idpool)
WHERE l.lid  = '$lid'
AND o.idpool = '$idpool'
ORDER BY
t.tname
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
	$i=0;
	foreach (@row) {
		print "$row[$i],";
		$i++;
	}
	print "<br>";
	$k++;

# libinprocess
if ($libinprocess == 1) {
	&libinprocess($dbh,$lid);
}


}
} # end genomesheet
########################################################################

sub rnaseqsheet {
my $dbh          = shift;
my $lidref       = shift;
my $idpoolref    = shift;
my $libinprocess = shift;
my @lid          = @$lidref;
my @idpool       = @$idpoolref;
my $rna_DNA      = 3000;
my $rna_TE       = 50;
my $lid          = "";
my $idpool       = "";
my @labels       = ();
my $k            = 0;
my $i            = 0;
my $sql          = "";
my $sth          = "";
my @row          = ();

print "<br>";
@labels	= (
	'Box',
	'Column',
	'Row',
	'DNA Id',
	'DNA Barcode',
	'DNA Barcode control',
	'Library',
	'Pool',
	'Pool Barcode',
	'Number',
	'Index1',
	'Index2',
	'BA RNA nano (ng/ul)',
	'RIN',
	"$rna_DNA (ng)",
	"TE ul (50 - DNA)",
	"BA post PCR (ng/ul)",
	"BA post PCR (nMol)",
	"BA post PCR bp",
	"PicoGreen post PCR (pg/ul)",
	"PicoGreen post PCR (nMol)",
	"PicoGreen (10 nMol)",
	"PicoGreen (pg/ul)",
	"PicoGreen (nMol)",
	"qPCR (nMol)"
	);

foreach (@labels) {
	print "$_,";
}
print "<br>";



$k=1;
foreach $lid (@lid) {
	#print "$_<br>";
	#($idsample,$lid)=split(/\_/);
	$idpool = $idpool[$k-1];
	
$sql = qq#
SELECT
s.splate,s.scolumn,s.srow,s.name,s.sbarcode,
'',l.lname,o.oname,'',$k,t.tname,tt.tname,
'','',concat("=$rna_DNA/M",$k+1),concat("=$rna_TE-O",$k+1),
'','','','',concat("=T",$k+1,"*1000/650*200/S",$k+1),
concat("=U",$k+1,"*3-30"),'',concat("=W",$k+1,"*1000/650*200/S",$k+1)
FROM
$exomedb.sample s 
LEFT JOIN sample2library sl ON (s.idsample = sl.idsample)
LEFT JOIN library l ON (sl.lid = l.lid)
LEFT JOIN tag t ON (l.idtag = t.idtag)
LEFT JOIN tag tt ON (l.idtag2 = t.idtag)
LEFT JOIN library2pool lo ON (l.lid = lo.lid)
LEFT JOIN pool o ON (lo.idpool = o.idpool)
WHERE l.lid  = '$lid'
AND o.idpool = '$idpool'
ORDER BY
t.tname
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
	$i=0;
	foreach (@row) {
		print "$row[$i],";
		$i++;
	}
	print "<br>";
	$k++;

# libinprocess
if ($libinprocess == 1) {
	&libinprocess($dbh,$lid);
}

}
} # end chipseqsheet

########################################################################
sub chipseqsheet {
my $dbh          = shift;
my $lidref       = shift;
my $idpoolref    = shift;
my $libinprocess = shift;
my @lid          = @$lidref;
my @idpool       = @$idpoolref;
my $chipseq_DNA = 500;
my $chipseq_TE  = 50;
my $lid          = "";
my $idpool       = "";
my @labels       = ();
my $k            = 0;
my $i            = 0;
my $sql          = "";
my $sth          = "";
my @row          = ();

print "<br>";
@labels	= (
	'Box',
	'Column',
	'Row',
	'DNA Id',
	'DNA Barcode',
	'DNA Barcode control',
	'Library',
	'Pool',
	'Pool Barcode',
	'Number',
	'Index1',
	'Index2',
	'Nano Drop (ng/ul)',
	"$chipseq_DNA (ng)",
	"TE ul (50 - DNA)",
	"BA post PCR (ng/ul)",
	"BA post PCR (nMol)",
	"BA post PCR bp",
	"PicoGreen post PCR (pg/ul)",
	"PicoGreen post PCR (nMol)",
	"PicoGreen (10 nMol)",
	"PicoGreen (pg/ul)",
	"PicoGreen (nMol)",
	"qPCR (nMol)"
	);

foreach (@labels) {
	print "$_,";
}
print "<br>";



$k=1;
foreach $lid (@lid) {
	#print "$_<br>";
	#($idsample,$lid)=split(/\_/);
	$idpool = $idpool[$k-1];
	
$sql = qq#
SELECT
s.splate,s.scolumn,s.srow,s.name,s.sbarcode,
'',l.lname,o.oname,'',$k,t.tname,tt.tname,
'',concat("=$chipseq_DNA/M",$k+1),concat("=$chipseq_TE-N",$k+1),
'','','','',concat("=S",$k+1,"*1000/650*200/R",$k+1),
concat("=T",$k+1,"*3-30"),'',concat("=V",$k+1,"*1000/650*200/R",$k+1)
FROM
$exomedb.sample s 
LEFT JOIN sample2library sl ON (s.idsample = sl.idsample)
LEFT JOIN library l ON (sl.lid = l.lid)
LEFT JOIN tag t ON (l.idtag = t.idtag)
LEFT JOIN tag tt ON (l.idtag2 = t.idtag)
LEFT JOIN library2pool lo ON (l.lid = lo.lid)
LEFT JOIN pool o ON (lo.idpool = o.idpool)
WHERE l.lid  = '$lid'
AND o.idpool = '$idpool'
ORDER BY
t.tname
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
	$i=0;
	foreach (@row) {
		print "$row[$i],";
		$i++;
	}
	print "<br>";
	$k++;

# libinprocess
if ($libinprocess == 1) {
	&libinprocess($dbh,$lid);
}

}
} # end rnasheet
########################################################################

}
########################################################################
# libinprocess
########################################################################

sub libinprocess {
my $dbh = shift;
my $lid = shift;
my $sth = "";
my $sql = qq#
UPDATE library
SET lstatus="lib in process"
WHERE lid = $lid
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
#print "lib in process<br>";

}
########################################################################
# libsheetold
########################################################################

sub libsheetold {
my $self        = shift;
my $ref         = shift;
my $dbh         = shift;
my $checkboxref = shift;
my (@checkbox)  = @$checkboxref;
my ($sampleid,$libid);
my $sql         = "";
my $sth         = "";
my @row         = ();
my @labels      = ();
my $i           = 0;
my $k           = 0;


my $shearing_DNA = 3000;
my $shearing_TE  = 50;

@labels	= (
	'Box',
	'Column',
	'Row',
	'Sample Barcode',
	'Sample Barcode control',
	'Library Barcode',
	'DNA Id',
	'Library',
	'Number',
	'Index',
	'Nano Drop (ng/ul)',
	"Shearing DNA ul($shearing_DNA ng)",
	"Shearing TE ul ($shearing_TE - DNA)"
	);

foreach (@labels) {
	print "$_,";
}
print "<br>";



$k=1;
foreach (@checkbox) {
	#print "$_<br>";
	($sampleid,$libid)=split(/\_/);
	
$sql = qq#
SELECT
s.splate,s.scolumn,s.srow,s.sbarcode,'',
s.name,l.lname,$k,t.tname,
'',concat("=$shearing_DNA/J",$k+1),concat("=$shearing_TE-K",$k+1)
FROM
$exomedb.sample s 
LEFT JOIN sample2library sl ON (s.idsample = sl.idsample)
LEFT JOIN library l ON (sl.lid = l.lid)
LEFT JOIN tag t ON (l.idtag = t.idtag)
WHERE l.lid='$libid'
ORDER BY
t.tname
#;
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
	$i=0;
	foreach (@row) {
		print "$row[$i],";
		$i++;
	}
	print "<br>";
	$k++;

}

}
########################################################################
# drawMask
########################################################################

sub drawMask {
my $self   = shift;
my $AoH    = shift;
my $mode   = shift;
my $dbh    = shift;

my $href   = "";

print qq(
<table border="1" cellspacing="0" cellpadding="3">
);

foreach $href (@{$AoH}) {
	if ($href->{type} eq 'readonly' ) {
		&readonly($href->{label},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'readonly2') {
		&text($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},'readonly');
	}
	elsif ($href->{type} eq 'barcode') {
		&barcode($dbh,$href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},'readonly');
	}
	elsif ($href->{type} eq 'hidden') {
		&hidden($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},'readonly');
	}
	elsif ($href->{type} eq 'text') {
		&text($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'jsdate') {
		&jsdate($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'textFocus') {
		&textFocus($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'radio') {	
		&radio($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'radioWell') {	
		&radioWell($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'radioBarcode') {	
		&radioBarcode($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'radioCheck') {	
		&radio($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'checkbox') {	
		&checkbox($href->{label},$href->{type},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'select1') {	
		&select1($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'selectdb') {	
		&selectdb($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'selectApplicant') {	
		&selectApplicant($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'selectWgleader') {	
		&selectWgleader($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'selectFenumber') {	
		&selectFenumber($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'textArea') {	
		&textArea($href->{label},$href->{name},$href->{value},$href->{cols},$href->{rows},$href->{maxlength},$href->{bgcolor});
	}
}
if ($mode eq "nosubmit") {
	#&submit;
}
elsif ($mode eq "barcode") {
	&submitBarcode;
}
else {
	&submit('formbg');
}

print qq(
</table>
);

}
########################################################################
# deleteSpace: delete beginning and trailing space
########################################################################

sub deleteSpace {
my $self      = shift;
my $ref       = shift;
my $fieldName = "";
my $value     = "";

while (($fieldName,$value) = each (%$ref)) {
	$value    =~ s/^\s+// ;
	$value    =~ s/\s+$// ;
	$ref->{$fieldName}=$value;
}
}

########################################################################
# OKprompt
########################################################################

sub OKprompt {
my $self        = shift;

print qq(
<script type="text/javascript">
<!--
Check = confirm("Soll der Eintrag gespeichert werden?");
if(Check == false) {
	history.back();
}
//-->
</script>
);

}

########################################################################
# text
########################################################################

sub text {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $size       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;
	my $readonly   = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	);
	if ($readonly eq 'readonly') {
		print qq(<td class="$bgcolor"><input class="readonly" name="$name" value="$value" size="$size" maxlength="$maxlength" readonly></td>);
	}
	else {
		print qq(<td class="$bgcolor"><input name="$name" value="$value" size="$size" maxlength="$maxlength"></td>);
	}
	print qq(
	</tr>
	);

}

########################################################################
# barcode
########################################################################

sub barcode {
	my $dbh        = shift;
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $size       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;
	my $readonly   = shift;
	
	my $barcode    = $name;
	$barcode =~ s/idpool/barcode/;
	my $odescription = "";
	my $sth = "";
	# odescription
	if ($value ne "") {
	my $query = "
	SELECT odescription
	FROM pool
	WHERE idpool = '$value';
	";
	$sth = $dbh->prepare($query) || die print "$DBI::errstr";
	$sth->execute || die print "$DBI::errstr";
	$odescription = $sth->fetchrow_array;
	}	
	print qq(
	<tr>
	<td class="person">$label</td>
	<td class="$bgcolor">
	);
	print qq(<input name="$barcode" value="" onchange="CheckBarcode(this)" size="$size" maxlength="$maxlength">);
	print qq(Pool Description<input class="readonly"  name="$barcode\validation" value="$odescription" size="$size" maxlength="$maxlength" readonly>);
	print qq(Pool Id <input class="readonly"  name="$name" value="$value" size="$size" maxlength="$maxlength" readonly>);
	print qq(
	</td></tr>
	);

}
########################################################################
# jsdate
########################################################################

sub jsdate {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $size       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;
	my $readonly   = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	);
	if ($readonly eq 'readonly') {
		print qq(<td class="$bgcolor"><input class="readonly" name="$name" value="$value" size="$size" maxlength="$maxlength" readonly>);
	}
	else {
		print qq(<td class="$bgcolor"><input name="$name" value="$value" size="$size" maxlength="$maxlength">);
	}
	print qq(
	<script language="JavaScript">
	new tcal ({
		// form name
		'formname': 'myform',
		// input name
		'controlname': '$name'
	});
	</script>
	</td>
	</tr>
	
	);

}
########################################################################
# hidden
########################################################################

sub hidden {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $size       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;
	my $readonly   = shift;

	print qq(<input type="hidden" name="$name" value="$value">);

}
########################################################################
# readonly
########################################################################

sub readonly {
	my $label      = shift;
	my $value      = shift;
	my $bgcolor    = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label&nbsp;</td>);
	print qq(<td class="$bgcolor">$value&nbsp;</td>);
	print qq(
	</tr>
	);
}

########################################################################
# radio
########################################################################

sub radio {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	if ($type eq "radioCheck") {
		print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	}
	else {
		print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	}
	
	$i=0;
	print qq(<td class="$bgcolor">\n);
	foreach (@labels) {
		print qq(<input type="radio" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		if ($type eq "radioCheck") {
			print qq( onchange="Check()">$labels[$i]<br>\n);
		}
		else {
			print qq( >$labels[$i]<br>\n);
		}
		$i++;
	}
	print qq(</td></tr>);
	
}

########################################################################
# radioBarcode For Barcode2. Makes buttons for position
########################################################################

sub radioBarcode {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	
	$i=0;
	print qq(<td class="$bgcolor">\n);
	foreach (@labels) {
		print qq(<input type="radio" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		print qq(>$labels[$i]&nbsp;&nbsp;&nbsp;);
		$i++;
	}
	print qq(</td></tr>);
	
}

########################################################################
# radioWell. For Barcodes, checkboxes for the 24 wells
########################################################################

sub radioWell {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	
	$i=0;
	print qq(<td class="$bgcolor">\n);
	print qq(<table border='1'>\n);
	print qq(<tr><td class="$bgcolor" valign="top">);
	foreach (@labels) {
		print qq(<input type="radio" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		print qq(>$labels[$i]<br>\n);
		$i++;
		if (($i == 8) or ($i == 16)) {
			print qq(</td><td class="$bgcolor" valign="top">);
		}
	}
	print qq(</td></tr>);
	print qq(</table>\n);
	print qq(</td></tr>);
	
}
########################################################################
# radioold
########################################################################

sub radioold {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	print qq(<tr><td class="$bgcolor">);
	foreach (@labels) {
		print qq($_ <br>);
		$i++;
	}
	print qq(</td>);
	
	$i=0;
	print qq(<td class="$bgcolor">);
	foreach (@labels) {
		print qq(<input type="$type" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		print qq(><br>);
		$i++;
	}
	print qq(</td></tr>);
	
}
########################################################################
# checkbox
########################################################################

sub checkbox {
	my $label    = shift;
	my $type     = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	print qq(<tr>
	<td class="$bgcolor">$label</td>
	<td class="$bgcolor"><input type="$type" name="$name" value="$values");
	if ( $value eq $values ) {print " checked " ;}
	print qq(>
	</td>
	</tr>
	);

}

########################################################################
# select1
########################################################################

#sub select1 {
#	my $label    = shift;
#	my $name     = shift;
#	my $value    = shift;
#	my $bgcolor  = shift;

#	print qq(
#	<tr>
#	<td class="$bgcolor">$label</td>
#	<td  class="$bgcolor">
#	);
#	select("$name","$value");
#	print qq(
#	</td>
#	</tr>
#	);
#}

########################################################################
# select1
########################################################################

sub select1 {
	my $label    = shift;
	my $name     = shift;
	my $value    = shift;
	my $bgcolor  = shift;
	my @row      = ();
	my $row      = ();
	
	if ($name eq "orow") {
		@row = ("","A","B","C","D","E","F","G","H");
	}
	elsif  ($name eq "ocolumn") {
		@row = ("","01","02","03","04","05","06","07","08","09","10","11","12");
	}

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	<td  class="$bgcolor">
	<select name="$name">	
	);
	foreach $row (@row) {
		if ($row eq $value) {
			print"<option selected value =\"$row\">$row</option>";
		}
		else { 
			print"<option value =\"$row\">$row</option>";
		}
	}
	print qq(
	</select>	
	</td>
	</tr>
	);
}
########################################################################
# selectdb
########################################################################

sub selectdb {
	my $label     = shift;
	my $name      = shift;
	my $value     = shift;
	my $bgcolor   = shift;
	my $sql       = "";
	my $sth       = "";
	my @row       = ();
	my $dbh       = &loadSessionId;
	my $htmltext  = "";
	my $menuflag  = "";
	

	if ($name eq "idproject") {
		$sql = "SELECT idproject,pmenuflag,CONCAT(pname,' - ',pdescription) 
			FROM $exomedb.project 
			ORDER BY pname DESC";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name =~ "lid") {
		$sql = "SELECT l.lid,lmenuflag,CONCAT(pname,' - ',pdescription,' Lib  ',lname,' - ',ldescription),pmenuflag,lname
			FROM library l, sample2library sl, $exomedb.sample s, $exomedb.project p
			WHERE l.lid=sl.lid
			AND sl.idsample=s.idsample
			AND s.idproject=p.idproject
			ORDER BY pname DESC,lname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name =~ "idpool") {
		if ($label eq "Pool") {
		# nur nicht-sequenzierte Pool fuer die library2pool-Auswahl
		$sql = "SELECT DISTINCT o.idpool,o.omenuflag,CONCAT(COALESCE(pname,''),' - ',COALESCE(pdescription,''),' Pool  ',oname,' - ',odescription),pmenuflag,oname,obarcode
			FROM pool o
			LEFT JOIN library2pool lo    ON lo.idpool=o.idpool
			LEFT JOIN library l          ON l.lid=lo.lid
			LEFT JOIN lane    a          ON a.idpool=o.idpool
			INNER JOIN sample2library sl ON l.lid=sl.lid
			INNER JOIN $exomedb.sample s ON sl.idsample=s.idsample
			LEFT JOIN $exomedb.project p ON s.idproject=p.idproject
			WHERE ISNULL(a.aid)
			ORDER BY pname DESC,oname";
			#print "pool $value<br>";
		}
		else {
		$sql = "SELECT DISTINCT o.idpool,o.omenuflag,CONCAT(COALESCE(pname,''),' - ',COALESCE(pdescription,''),' Pool  ',oname,' - ',odescription),pmenuflag,oname,obarcode
			FROM pool o
			LEFT JOIN library2pool lo    ON lo.idpool=o.idpool
			LEFT JOIN library l          ON l.lid=lo.lid
			INNER JOIN sample2library sl ON l.lid=sl.lid
			INNER JOIN $exomedb.sample s ON sl.idsample=s.idsample
			LEFT JOIN $exomedb.project p ON s.idproject=p.idproject
			ORDER BY pname DESC,oname";
		}
		#print "pool $value<br>";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "rid") {
		$sql = "SELECT rid,rmenuflag,CONCAT(rname,' - ',t.name,' - ',rcomment),rmenuflag,rname
			FROM run r, runtype t
			WHERE r.rdescription = t.runtypeid
			ORDER BY rdate DESC,rdaterun DESC
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "sid") {
		if  ($value>0) { # alle anzeigen
		$sql = "SELECT sid,cmenuflag,CONCAT(s.sid,' - ',cname,' - ',cdescription,' - ',s.sgetdate,' - ',s.lot) 
			FROM stock s, kit c 
			WHERE s.cid = c.cid
			ORDER BY cname";
		}
		else { # nur die noch nicht gebrauchten anzeigen
		$sql = "SELECT s.sid,cmenuflag,CONCAT(s.sid,' - ',cname,' - ',cdescription,' - ',s.sgetdate,' - ',s.lot) 
			FROM run2stock rs 
			RIGHT JOIN stock s on (rs.sid = s.sid)
			INNER JOIN kit c on (s.cid = c.cid)
			WHERE ISNULL(rs.idrun2stock)
			ORDER BY cname,sgetdate";
		}
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "idtag") {
		$sql = "SELECT idtag,tmenuflag,CONCAT(tgroup,' - ',tname,' - ',ttag) 
			FROM tag 
			WHERE tdualindex=1
			ORDER BY tgroup,tname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "idtag2") {
		$sql = "SELECT idtag,tmenuflag,CONCAT(tgroup,' - ',tname,' - ',ttag) 
			FROM tag 
			WHERE tdualindex=2
			ORDER BY tgroup,tname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "cid") {
		$sql = "SELECT cid,cmenuflag,CONCAT(cname,' - ',cdescription) 
			FROM kit 
			ORDER BY cname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif (($name eq "uidreceived") or ($name eq "entered") or ($name eq "tentered") or 
	($name eq "uid") or ($name eq "l.uid") or ($name eq "oentered") or ($name eq "buser")) {
		$sql = "SELECT uid,umenuflag,CONCAT(uname,', ',uprename) 
			FROM user 
			ORDER BY uname,uprename";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "machine")  {
		$sql = "SELECT DISTINCT machine,machine,machine 
			FROM rread 
			ORDER BY machine";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "bcompany")  {
		$sql = "SELECT DISTINCT idcompany,coflag,coname 
			FROM company 
			ORDER BY coname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "readNumber")  {
		$sql = "SELECT DISTINCT readNumber,readNumber,readNumber 
			FROM rread 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "alane")  {
		$sql = "SELECT DISTINCT alane,alane,alane 
			FROM lane 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "rdescription")  {
		$sql = "SELECT DISTINCT runtypeid,name, name
			FROM runtype 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "libtype")  {
		$sql = "SELECT DISTINCT ltid,ltlibtype, ltlibtype
			FROM libtype 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "idassay")  {
		$sql = "SELECT DISTINCT idassay,name, name
			FROM assay 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "libpair")  {
		$sql = "SELECT DISTINCT lpid,lplibpair, lplibpair
			FROM libpair 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "idcompany")  {
		$sql = "SELECT DISTINCT idcompany,coname, coname
			FROM company 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}

	if ($name eq "ds.iddisease") { # for search
		$sql = "SELECT iddisease,name,name
			FROM $exomedb.disease
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "s.idcooperation") { # for search
		$sql = "SELECT idcooperation,name,concat(name,', ',prename)
			FROM $exomedb.cooperation
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "lstatus") {
		$sql = "SELECT lstatus,lstatus,lstatus
			FROM library 
			GROUP BY
			lstatus
			ORDER BY lstatus";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "idsample")  {
		$sql = "SELECT s.idsample,s.idsample, concat(s.name,' - ',s.pedigree,' - ',s.sex,' - ',c.name)
			FROM $exomedb.sample s
			INNER JOIN $exomedb.cooperation c ON (s.idcooperation=c.idcooperation)
			ORDER BY s.name DESC
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "lkit") { # for insert
		$sql = "SELECT sid,s.smenuflag,concat(c.cdescription,', recieved: ',s.sgetdate,', lot: ',s.lot)
			FROM stock s, kit c
			WHERE s.cid = c.cid
			AND c.cdescription like '%SureSelect%'
			AND c.cmenuflag='T'
			ORDER BY s.sgetdate DESC";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	<td  class="$bgcolor">
	);
	#print "value $value<br>";
	print"<select name=\"$name\">";	
	print "<option value =\"\"> </option>";
	while (@row = $sth->fetchrow_array) {
		if ($row[0] eq $value) {
			print"<option selected value =\"$row[0]\"> $row[2]</option>";
		}
		elsif (($row[1] ne 'F') and ($row[3] ne 'F')) { # das ist fuer die Flag-Felder
			print"<option value =\"$row[0]\"> $row[2]</option>";
		}
	}
	print"</select>";	
	

	print qq(
	</td>
	</tr>
	);
	
}
########################################################################
# textArea
########################################################################

sub textArea {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $cols       = shift;
	my $rows       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	<td  class="$bgcolor"><textarea name="$name" cols="$cols" rows="$rows" maxlength="$maxlength">$value</textarea></td>
	</tr>
	);

}

########################################################################
# submit
########################################################################

sub submit {
	my $bgcolor  = shift;

	print qq(
	<tr>
	<td class="$bgcolor">&nbsp;</td>
	<td class="$bgcolor">
	<input type="submit" value="Submit">
	<input type="reset"  value="Reset">
	</td>
	</tr>
	);

}

########################################################################
# tableheader
########################################################################
sub tableheader {
my $width = shift;
if ($width ne "") {
	$width = "style=\"width:$width\"";
}

print qq(
<div id="container" $width>
<table id="table01" border="1" cellspacing="0" cellpadding="0" class="display compact"> 
);

}
########################################################################
# tableheaderDefault_old
########################################################################
sub tableheaderDefault_old {
my $width   = shift;
my $numeric = shift;
my $string  = shift;
my $html    = shift;
my $mode    = shift;  # for burden test
my $buf     = "";

if (!defined($width)) {$width = "";}
$buf = "<br><br>";
if ($width eq "650px") {
	$width = "class='width650'";
}
elsif ($width eq "1000px") {
	$width = "class='width1000'";
}
elsif ($width eq "1500px") {
	$width = "class='width1500'";
}

$buf .= qq(
<div id="container" $width>
<table id="table01" numeric="$numeric" string="$string" html="$html" cellspacing="0" class="compact display" width="100%"> 
);

if ($mode eq "") {
	print $buf;
}
else {
	return $buf;
}

}

########################################################################
# tableheaderDefault
########################################################################
sub tableheaderDefault {
my $width   = shift;
my $numeric = shift;
my $string  = shift;
my $html    = shift;
my $mode    = shift;  # for burden test
my $buf     = "";

if (!defined($width)) {$width = "";}
$buf = "<br><br>";
if ($width eq "650px") {
	$width = "class='width650'";
}
elsif ($width eq "1000px") {
	$width = "class='width1000'";
}
elsif ($width eq "1500px") {
	$width = "class='width1500'";
}

$buf .= qq(
<div id="container" $width>
<table id="default" numeric="$numeric" string="$string" html="$html" cellspacing="0" class="compact display" width="100%"> 
);

if ($mode eq "") {
	print $buf;
}
else {
	return $buf;
}

}

########################################################################
# tableheaderDefault_new
########################################################################
sub tableheaderDefault_new {
my $tableid = shift;
my $width   = shift;
my $numeric = shift;
my $string  = shift;
my $html    = shift;
my $mode    = shift;  # for burden test
my $buf     = "";
if ($tableid eq "") {
	$tableid = "table01";
}

if (!defined($width)) {$width = "";}
$buf = "<br><br>";
if ($width eq "650px") {
	$width = "class='width650'";
}
elsif ($width eq "1000px") {
	$width = "class='width1000'";
}
elsif ($width eq "1500px") {
	$width = "class='width1500'";
}

$buf .= qq(
<div id="container2" $width>
<table id="$tableid" numeric="$numeric" string="$string" html="$html" cellspacing="0" class="compact display" width="100%">
);

if ($mode eq "") {
	print $buf;
}
else {
	return $buf;
}

}

########################################################################
# tablescript
########################################################################
sub tablescript {

print q(
<script type="text/javascript" charset="utf-8">
$(document).ready(function() {
 var oTable = $('#table01').DataTable({
 	"bPaginate":      true,
  	"bLengthChange":  true,
	"bFilter":        true,
 	"bSort":          true,
	"bInfo":          true,
	"bAutoWidth":     true,
	"orderClasses":   false,
	"iDisplayLength": -1,
	"aLengthMenu": [[-1, 100, 50, 25], ["All", 100, 50, 25]],
	"sDom": 'T<"clear">lfrtip',
	"select":         'multi',
	"fixedHeader":    true
});



});
</script>
);
#		"aButtons": [ "select_all", "select_none" ]

print q(
<style type="text/css">
table.dataTable tr.odd  { background-color: #f9f9f1; }
table.dataTable tr.even { background-color: #ffffff; }
table.dataTable tr.odd  td.sorting_1 { background-color: #efefef; }
table.dataTable tr.even td.sorting_1 { background-color: #f9f9f5; }
table.dataTable td {padding: 2px; }
table.dataTable th { background-color: #efefef; }
</style>
);

}
########################################################################
# tablescriptnew
########################################################################
sub tablescriptnew {
my $tableid = shift;

print qq(
<script type="text/javascript" charset="utf-8">
\$(document).ready(function() {
 var oTable = \$('#$tableid').DataTable({
 	"paginate":      false,
  	"lengthChange":  true,
	"filter":        true,
 	"sort":          false,
	"info":          true,
	"autoWidth":     true,
	"orderClasses":  false,
	"displayLength": -1,
	"lengthMenu":   [[-1, 100, 50, 25], ["All", 100, 50, 25]],
	"dom":           'Bfrtip',
	"select":        'multi',
 	"buttons":       ['csv'],
	"fixedHeader":   true
});



});
</script>
);
#		"aButtons": [ "select_all", "select_none" ]

print q(
<style type="text/css">
table.dataTable tr.odd  { background-color: #f9f9f1; }
table.dataTable tr.even { background-color: #ffffff; }
table.dataTable tr.odd  td.sorting_1 { background-color: #efefef; }
table.dataTable tr.even td.sorting_1 { background-color: #f9f9f5; }
table.dataTable td {padding: 2px; }
table.dataTable th { background-color: #efefef; }
</style>
);

}
########################################################################
# tablescript2
########################################################################
sub tablescript2 {

print q(
<script type="text/javascript" charset="utf-8">
$(document).ready(function() {
 var oTable = $('#table01').DataTable({
 	"paginate":       false,
  	"lengthChange":   true,
	"filter":         false,
 	"sort":           false,
	"info":           false,
	"autoWidth":      false,
	"orderClasses":   false,
	"displayLength":  -1,
	"lengthMenu": [[-1, 100, 50, 25], ["All", 100, 50, 25]],
	"dom":            'Bfrtip',
	"select":         'multi',
 	"buttons":        ['csv'],
	"fixedHeader":    true
});



});
</script>
);
#		"aButtons": [ "select_all", "select_none" ]

print q(
<style type="text/css">
table.dataTable tr.odd  { background-color: #f9f9f1; }
table.dataTable tr.even { background-color: #ffffff; }
table.dataTable tr.odd  td.sorting_1 { background-color: #efefef; }
table.dataTable tr.even td.sorting_1 { background-color: #f9f9f5; }
table.dataTable td {padding: 2px; }
table.dataTable th { background-color: #efefef; }
</style>
);

}
########################################################################
# printHeader
########################################################################

sub printHeader {
my $self        = shift;
my $background  = shift;
my $sessionid   = shift;
my $cgi         = new CGI;

unless ($sessionid eq "sessionid_created") {
	#print $cgi->header();
	print $cgi->header(-type=>'text/html',-charset=>'utf-8');
}

print qq(
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Solexa</title>
) ;


print qq(
	
<link rel="stylesheet" type="text/css" href="/DataTables-1.10.22/datatables.min.css">
<script type="text/javascript" src="/DataTables-1.10.22/datatables.min.js"></script>

<link rel="stylesheet" href="/DataTables-1.10.22/jquery.contextMenu.min.css">
<script src="/DataTables-1.10.22/jquery.contextMenu.min.js"></script>
<script src="/DataTables-1.10.22/jquery.ui.position.js"></script>

<link rel="stylesheet" href="/EVAdb/cal/calendar.css">
<script language="JavaScript" src="/EVAdb/cal/calendar_db.js"></script>

<meta name="viewport" content="width=device-width, height=device-height,  initial-scale=1, minimum-scale=1">

<link rel="stylesheet" type="text/css" href="/EVAdb/evadb/EVAdbtest.css">
<script type="text/javascript" src="/EVAdb/evadb/EVAdbtest.js"></script>
</head>
) ;

if ($background eq "white") {
	print qq(<body bgcolor=\"#ffffff\">);
	print qq(<div id="wrapper">);
	print qq(<div id="content">);
}
else {
	print qq(<body bgcolor=\"#CCCCCC\">);
	print qq(<div id="wrapper">);
	print qq(<div id="content">);
}

}

########################################################################
# showMenu
########################################################################

sub showMenu {

print qq|
<div id="mySidenav" class="sidenav">
<a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
<div class="subnav">Search</div>
<a href="search.pl">Search</a>
<div class="subnav">Libraries</div>
<a href="importLibInfo.pl">Import Libsheet</a>
<div class="subnav">Taqman</div>
<a href="taqmanDo.pl">Taqman</a>
<a href="importTaqman.pl">Import Taqman</a>
<div class="subnav">Pooling</div>
<a href="pooling.pl">Pooling</a>
<a href="makePool.pl">Make Pool intern</a>
<a href="makePoolExtern.pl">Make Pool extern</a>
<div class="subnav">Sequencing</div>
<a href="sequencing.pl">Sequencing</a>
<a href="run.pl">New Run</a>
<div class="subnav">Barcodes</div>
<a href="checkBarcode.pl">Check Pool Barcode</a>
<div class="subnav">Indices</div>
<a href="tag.pl">New Index</a>
<a href="listTags.pl">List Indices</a>
<div class="subnav">Stocks</div>
<a href="stock.pl">New Stock</a>
<a href="searchStocks.pl">Search Stocks</a>
<div class="subnav">Kits</div>
<a href="kit.pl">New Kit</a>
<a href="kitList.pl">List Kits</a>
<a href="listKits.pl">List Exome Kits</a>
<a href="listAssays.pl">List Assays</a>
<div class="subnav">Statistics</div>
<a href="statistics.pl">Statistics</a>
<a href="yield.pl">Yield</a>
<div class="subnav">Order</div>
<a href="shopping.pl">New Order</a>
<a href="searchShopping.pl">Search Order</a>
<div class="subnav">Logout</div>
<a href="login.pl">Logout</a>
</div>

<!-- Use any element to open the sidenav -->
<span style="padding:20px;font-size:24px;cursor:pointer" onclick="openNav()">&#9776; Menu</span>

<!-- Add all page content inside this div if you want the side nav to push page content to the right (not used if you only want the sidenav to sit on top of the page -->
<div id="main">

|;

}
########################################################################
# printFooter
########################################################################

sub printFooter {
my $self        = shift;
my $dbh         = shift;

my $item  = "";
my $value = "";
my %logins = ();
# select footer from exomevcfe.textmodules
#select password from file
if ($dbh eq "") {
	open(IN, "$text");
	while (<IN>) {
		chomp;
		($item,$value)=split(/\:/);
		$logins{$item}=$value;
	}
	close IN;
	$dbh = DBI->connect("DBI:mysql:$maindb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
}

my $query = "SELECT module FROM $exomevcfe.textmodules WHERE name='footer'";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
my $footer = $out->fetchrow_array;


print qq(
<br><br>
</div>
</div>
<div id="footer">
<br>
<div style="position:relative; left:270px; ">
$footer
</div>
</div>
</div>
</body>
</html>
);

}
########################################################################



1;
__END__
