########################################################################
# Tim M Strom June 2010
# Institute of Human Genetics
# Helmholtz Zentrum Muenchen
########################################################################

package Snvedit;

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;
use XML::Simple;
use Crypt::Eksblowfish::Bcrypt;
use Date::Calc qw/check_date/;
use Data::Dumper;
use Text::ParseWords;
use File::Basename;

my $demo = 0;

my $gapplication   = "ExomeEdit";
my $solexa         = "solexa";
my $humanexomedb   = "database=exomehg19;host=localhost";
my $logindb        = "exomevcfe";
my $exomevcfe      = "exomevcfe";
my $text           = "/srv/tools/text.txt"; #database
my $text2          = "/srv/tools/textreadonly2.txt"; #yubikey id and api
my $cgidir         = "/cgi-bin/mysql/snvedit";
#should be '1' for real data. '0' only for demo data
my $cookie_only_when_https = 1;
my $noyubikey      = 1;
my $maxFailedLogin = 6;
my $igvport        = ""; #not used
my $user           = ""; 
my $iduser         = ""; 
my $role           = ""; #not used
my $warningtdbg   = "class='warning'";
my $extFilesBasePath = "/data/isilon/seq/analysis/external";
my $extFilesBasePathStaging = "/data/isilon/seq/analysis/external/staging";

if ($demo) {
	$humanexomedb   = "database=exomecore;host=localhost";
	$logindb        = "exomewrite";
	$cookie_only_when_https = 0;
}

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
my $dbh = DBI->connect("DBI:mysql:$humanexomedb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
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
		   -secure => $cookie_only_when_https
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

	my $dbh = DBI->connect("DBI:mysql:$humanexomedb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
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
# showAllSample
########################################################################

sub showAllSample {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initSample   ();
$self->getShowSample($dbh,$id,$ref,'Y');

}
########################################################################
# showAllInvoice
########################################################################

sub showAllInvoice {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initInvoice   ();
$self->getShowInvoice($dbh,$id,$ref,'Y');

}
########################################################################
# showAllDisease
########################################################################

sub showAllDisease {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initDisease   ();
$self->getShowDisease($dbh,$id,$ref,'Y');

}
########################################################################
# showAllCooperation
########################################################################

sub showAllCooperation {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initCooperation   ();
$self->getShowCooperation($dbh,$id,$ref,'Y');

}

########################################################################
# showAllInvoiceitem
########################################################################

sub showAllInvoiceitem {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

$ref = $self->initInvoiceitem   ();
$self->getShowInvoiceitem($dbh,$id,$ref,'Y');

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
# init for edit Sample
########################################################################
sub initSample {
my $self         = shift;

my $ref          = "";
my $date=&actualDate;


my @AoH = (
	  {
	  	label       => "Id",
	  	type        => "readonly2",
		name        => "idsample",
	  	value       => "",
		size        => "20",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample id",
	  	type        => "text",
		name        => "name",
	  	value       => "",
		size        => "50",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Foreign ID",
	  	type        => "text",
		name        => "foreignid",
	  	value       => "",
		size        => "50",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Father",
	  	type        => "selectdb",
		name        => "father",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mother",
	  	type        => "selectdb",
		name        => "mother",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ChIPseq control<br>sample name",
	  	type        => "text",
		name        => "chipseqcontrol",
	  	value       =>  "",
		size        => "50",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Matched control or tumor<br>sample name",
	  	type        => "text",
		name        => "tumorcontrol",
	  	value       =>  "",
		size        => "50",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "scomment",
	  	value       =>  "",
		size        => "100",
		maxlength   => "254",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sex",
	  	labels      => "unknown, male, female",
	  	type        => "radio",
		name        => "sex",
	  	value       => "unknown",
	  	values      => "unknown, male, female",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Affected",
	  	labels      => "unknown, affected, unaffected",
	  	type        => "radio",
		name        => "saffected",
	  	value       => "2",
	  	values      => "2, 1, 0",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Organism",
	  	type        => "selectdb",
		name        => "idorganism",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Tissue",
	  	type        => "selectdb",
		name        => "idtissue",
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
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Concentration (ng/ul)",
	  	type        => "text",
		name        => "snanodrop",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Volume (ul)",
	  	type        => "text",
		name        => "volume",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "A260/280",
	  	type        => "text",
		name        => "a260280",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "A260/230",
	  	type        => "text",
		name        => "a260230",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Barcode",
	  	type        => "text",
		name        => "sbarcode",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Plate",
	  	type        => "text",
		name        => "splate",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Row",
	  	type        => "select1",
		name        => "srow",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Column",
	  	type        => "select1",
		name        => "scolumn",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Analysis",
	  	labels      => "other, exome",
	  	type        => "radio",
		name        => "analysis",
	  	value       => "exome",
	  	values      => "other, exome",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sequencing",
	  	labels      => "To sequence, Not to sequence",
	  	type        => "radio",
		name        => "nottoseq",
	  	value       => "0",
	  	values      => "0, 1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "BAM file",
	  	type        => "text",
		name        => "sbam",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Accounting",
	  	type        => "text",
		name        => "accounting",
	  	value       =>  "",
		size        => "50",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Invoice",
	  	type        => "selectdb",
		name        => "idinvoice",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "user",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered",
	  	type        => "jsdate",
		name        => "entered",
	  	value       =>  "$date",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for edit Invoice
########################################################################
sub initInvoice {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Id",
	  	type        => "readonly2",
		name        => "idinvoice",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "My invoice no",
	  	type        => "text",
		name        => "my",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "mydate",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "FA invoice no",
	  	type        => "text",
		name        => "fa",
	  	value       =>  "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "FA Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "fadate",
	  	value       =>  "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ILV Institute",
	  	type        => "text",
		name        => "ilvinstitute",
	  	value       =>  "",
		size        => "45",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Invoice",
	  	type        => "text",
		name        => "sum",
	  	value       =>  "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Third party funds",
	  	type        => "text",
		name        => "funds",
	  	value       =>  "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ILV Costs",
	  	type        => "text",
		name        => "costs",
	  	value       =>  "",
		size        => "45",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "comment",
	  	value       =>  "",
		size        => "45",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for edit Disease
########################################################################
sub initDisease {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Id",
	  	type        => "readonly2",
		name        => "iddisease",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Name",
	  	type        => "text",
		name        => "name",
	  	value       => "",
		size        => "100",
		maxlength   => "50",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Symbol",
	  	type        => "text",
		name        => "symbol",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "OmimID",
	  	type        => "text",
		name        => "omimid",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease group",
	  	type        => "selectdb",
		name        => "iddiseasegroup",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for edit Cooperation
########################################################################
sub initCooperation {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Id",
	  	type        => "readonly2",
		name        => "idcooperation",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Name",
	  	type        => "text",
		name        => "name",
	  	value       => "",
		size        => "100",
		maxlength   => "250",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Prename",
	  	type        => "text",
		name        => "prename",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Institution",
	  	type        => "text",
		name        => "institution",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Department",
	  	type        => "text",
		name        => "department",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "comment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Email",
	  	type        => "text",
		name        => "email",
	  	value       =>  "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Phone",
	  	type        => "text",
		name        => "phone",
	  	value       =>  "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Send email for accounting",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "sendemail",
	  	value       => "0",
	  	values      => "0, 1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Send email for status",
	  	labels      => "No, Yes",
	  	type        => "radio",
		name        => "sendstatus",
	  	value       => "0",
	  	values      => "0, 1",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Sample
########################################################################
sub initSearchSample {
my $self         = shift;
my $project      = shift;

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
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Foreign ID",
	  	type        => "text",
		name        => "foreignid",
	  	value       => "",
		size        => "30",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "5",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Organism",
	  	type        => "selectdb",
		name        => "s.idorganism",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Tissue",
	  	type        => "selectdb",
		name        => "ti.idtissue",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "To sequence",
	  	labels      => "Yes, No, All",
	  	type        => "radio",
		name        => "nottoseq",
	  	value       => "0",
	  	values      => "0, 1, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library",
	  	labels      => "All,  Without library",
	  	type        => "radio",
		name        => "withoutlib",
	  	value       => "",
	  	values      => ", 1, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library failed",
	  	labels      => "No, Yes, All",
	  	type        => "radio",
		name        => "l.lfailed",
	  	value       => "0",
	  	values      => "0, 1, ",
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
	  	label       => "Status",
	  	type        => "selectdb",
		name        => "lstatus",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "For pool",
	  	labels      => "No, Yes, All",
	  	type        => "radio",
		name        => "lforpool",
	  	value       => "",
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
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "s.idproject",
	  	value       => "$project",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Sample, Pedigree, Status",
	  	type        => "radio",
		name        => "myorder",
	  	value       => "pedigree",
	  	values      => "sample, pedigree, status",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mode",
	  	labels      => "Samples and libraries, Samples only",
	  	type        => "radio",
		name        => "mode",
	  	value       => " ",
	  	values      => " , 1",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}
########################################################################
# init for statistics
########################################################################
sub initStatistics {
my $self         = shift;
my $project      = shift;

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
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Organism",
	  	type        => "selectdb",
		name        => "s.idorganism",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Group by",
	  	labels      => "Lane, Pool",
	  	type        => "radio",
		name        => "groupby",
	  	value       => "'od.rname,od.lane'",
	  	values      => "'od.rname,od.lane', o.idpool",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}
########################################################################
# init for overview
########################################################################
sub initOverview {
my $self         = shift;
my $project      = shift;

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
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sequenced",
	  	labels      => "All, All to do > 0",
	  	type        => "radio",
		name        => "not_sequenced",
	  	value       => "",
	  	values      => ", not_sequenced",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}

########################################################################
# init for invoiceSearch
########################################################################
sub initInvoiceSearch {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "mydate",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Item",
	  	type        => "selectdb",
		name        => "idservice",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}

########################################################################
# init for initCreateLibrary
########################################################################
sub initCreateLibrary {
my $self         = shift;
my $project      = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Foreign ID",
	  	type        => "text",
		name        => "foreignid",
	  	value       => "",
		size        => "30",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "5",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Library",
	  	labels      => "All,  Without library",
	  	type        => "radio",
		name        => "withoutlib",
	  	value       => "",
	  	values      => ", 1, ",
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
	  	label       => "Status",
	  	type        => "selectdb",
		name        => "lstatus",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "For pool",
	  	labels      => "No, Yes, All",
	  	type        => "radio",
		name        => "lforpool",
	  	value       => "",
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
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "s.idproject",
	  	value       => "$project",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Sample, Pedigree, Status, Date",
	  	type        => "radio",
		name        => "myorder",
	  	value       => "pedigree",
	  	values      => "sample, pedigree, status, date",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}

########################################################################
# init for new project
########################################################################
sub initProject {
my $self         = shift;

my $ref          = "";
my $date=&actualDate;
my @AoH = (
	  {
	  	label       => "Project ID",
	  	type        => "readonly2",
		name        => "idproject",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project Name",
	  	type        => "text",
		name        => "pname",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Description",
	  	type        => "text",
		name        => "pdescription",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "pcomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Contact",
	  	type        => "text",
		name        => "pcontact",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Institution for invoice",
	  	type        => "text",
		name        => "institution",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Department for invoice",
	  	type        => "text",
		name        => "department",
	  	value       => "",
		size        => "100",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Entered from",
	  	type        => "readonly2",
		name        => "user",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "pdate",
	  	value       => "$date",
		size        => "15",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Menuflag",
	  	labels      => "False, True",
	  	type        => "radio",
		name        => "pmenuflag",
	  	value       => "T",
	  	values      => "F, T",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "pversion",
	  	type        => "hidden",
		name        => "pversion",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}

#######################################################################
# init for new init Disease2sample
########################################################################
sub initDisease2sample {
my $self         = shift;
my $idsample     = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Disease2Sample ID",
	  	type        => "readonly2",
		name        => "iddisease2sample",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample",
	  	type        => "readonly2",
		name        => "idsample",
	  	value       => "$idsample",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "iddisease",
	  	value       => "$idsample",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for importSamplesExternal
########################################################################
sub initImportSamplesExternal {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Comma separated csv-file",
	  	type        => "file",
		name        => "file",
	  	value       => "",
		size        => "30",
		maxlength   => "500000",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Analysis type",
	  	labels      => "Exome, Other, Automatic from library type",
	  	type        => "radio",
		name        => "analysis",
	  	value       => "auto",
	  	values      => "exome, other, auto",
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
		name        => "s.idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "File Extension<br>If no files, lib is created without looking for data",
		labels      => "no files, bam, fastq.gz",
	  	type        => "radio",
		name        => "fileextension",
	  	value       => "fastq.gz",
		values      => ", bam, fastq.gz",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Look for files in staging area<br>They will need to be moved to the respective folders<br>String will be generated at the end.<br>Then reimport with option disabled.",
		labels      => "True, False",
	  	type        => "radio",
		name        => "filesinstagingarea",
	  	value       => "F",
		values      => "T, F",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allow existing samples<br><br>For libraries prepared in-house<br>or already existing samples",
	  	labels      => "True, False",
	  	type        => "radio",
	  	name        => "allowexisting",
	  	value       => "F",
	  	values      => "T, F",
	  	bgcolor     => "formbg",
          },
	  {
	  	label       => "Project and cooperation in samplesheet <br>version 09.2020",
	  	labels      => "True, False",
	  	type        => "radio",
	  	name        => "projcoopinsamplesheet",
	  	value       => "F",
	  	values      => "T, F",
	  	bgcolor     => "formbg",
          },
	  {
	  	label       => "Trio information<br>in samplesheet version 10.2020",
	  	labels      => "True, False",
	  	type        => "radio",
	  	name        => "trioinfoinsamplesheet",
	  	value       => "F",
	  	values      => "T, F",
	  	bgcolor     => "formbg",
          },
	  {
	  	label       => "External sequencing center ID in",
	  	labels      => "Samplesheet, Filename, Not applicable",
	  	type        => "radio",
	  	name        => "externalseqidlocation",
	  	value       => "none",
	  	values      => "samplesheet, filename, none",
	  	bgcolor     => "formbg",
          },
	  {
	  	label       => "Simulate import<br>To check samplesheet",
		labels      => "True, False",
	  	type        => "radio",
		name        => "simulateimport",
	  	value       => "F",
		values      => "T, F",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}
########################################################################
# init for importmtDNASamples
########################################################################
sub initImportmtDNASamples {
my $self         = shift;

my $ref          = "";
my $date=&actualDate;

my @AoH = (
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
		name        => "s.idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Flowcell name",
	  	type        => "text",
		name        => "flowcell",
	  	value       => "",
		size        => "30",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Run date",
	  	type        => "jsdate",
		name        => "rundate",
	  	value       =>  "$date",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}

########################################################################
# init for invoiceitem
########################################################################
sub initInvoiceitem {
my $self         = shift;
my $idinvoice    = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "IDinvoice",
	  	type        => "readonly2",
		name        => "idinvoice",
	  	value       => "$idinvoice",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "IDinvoiceitem",
	  	type        => "readonly2",
		name        => "idinvoiceitem",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Item",
	  	type        => "selectdb",
		name        => "idservice",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Quantity",
	  	type        => "text",
		name        => "count",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);

}
########################################################################
# insertIntoDisease2sample
########################################################################

sub insertIntoDisease2sample {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";


$ref->{iddisease2sample} = 0 ;
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};


$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{iddisease2sample}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editSample2library
########################################################################

sub editDisease2sample {
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


$sql = sprintf "UPDATE %s SET %s WHERE iddisease2sample=$ref->{iddisease2sample}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$sth->finish;

}
########################################################################
# getShowDisease2sample
########################################################################

sub getShowDisease2sample {
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
	SELECT  ds.iddisease2sample,ds.idsample,ds.iddisease
	FROM disease2sample ds
	INNER JOIN disease  i   ON ds.iddisease = i.iddisease
	WHERE   ds.idsample = $id
	";
	
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

#print "$sql<br>";

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Disease2Sample</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		#print "$href->{name} $href->{value}<br>";
		if ($mode eq 'Y') {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}

########################################################################
# showDisease2sample
########################################################################

sub showDisease2sample {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my @labels       = ();


$sql = "
	SELECT  ds.idsample,i.name,i.symbol,i.omimid
	FROM  disease2sample  ds 
	INNER JOIN disease     i  ON ds.iddisease = i.iddisease
	WHERE   ds.idsample = $id
	";
#print "$sql<br>";
	
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
if ($sth->rows == 0) {
	print "<a href=\"disease2sample.pl?id=$id\">Add disease</a><br><br>"; 
}
else {

@labels	= (
	'id',
	'Disease',
	'Symbol',
	'OMIM'
	);

print q(<table border="1" cellspacing="0" cellpadding="1"> );
print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr>";
while ($resultref = $sth->fetchrow_hashref) {
	print "<tr>";
	print "<td><a href=\"disease2sample.pl?id=$resultref->{idsample}&mode=edit\">$resultref->{idsample}</a></td>"; 
	print "<td>$resultref->{name}</td>"; 
	print "<td align=\"center\">$resultref->{symbol}</td>"; 
	print "<td>$resultref->{omimid}</td>"; 
	print "</tr>";
}
print "</table><br>";

}
}

########################################################################
# getShowSample
########################################################################

sub getShowSample {
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
	FROM sample 
	WHERE idsample = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Sample</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idsample') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="sample.pl?id=$resultref->{idsample}&amp;mode=edit">$resultref->{idsample} </a></td></tr>);
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
# getShowInvoice
########################################################################

sub getShowInvoice {
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
	FROM invoice 
	WHERE idinvoice = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Invoice</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$resultref->{$href->{name}} =~ s/^0.00$//;
		$resultref->{$href->{name}} =~ s/^0.000$//;
		$resultref->{$href->{name}} =~ s/^0000-00-00$//;
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idinvoice') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="invoice.pl?id=$resultref->{idinvoice}&amp;mode=edit">$resultref->{idinvoice} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td>$resultref->{$href->{name}}  &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

# invoiceitem
my @row = ();
my $i   = 0;



$sql = qq#
SELECT
concat('<a href="invoiceitem.pl?idinvoiceitem=',ii.idinvoiceitem,'&mode=edit">',ii.idinvoiceitem,'</a>'),
se.name,
se.description,
ii.count
FROM invoice i
INNER JOIN invoiceitem  ii ON i.idinvoice=ii.idinvoice
LEFT JOIN service      se ON ii.idservice=se.idservice
WHERE i.idinvoice = $id
#;

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";

print "<br>\n";
if ($mode ne 'Y') {
	print qq#<a href="invoiceitem.pl?idinvoice=$id">Add_item</a>#;
}

if ($sth->rows > 0){
	print "<br><br>\n";
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
	while (@row = $sth->fetchrow_array) {
		print "<tr>";
		$i=0;
		foreach (@row) {
			print "<td> $row[$i]</td>";
			$i++;
		}
		print "</tr>\n";
	}
	print "</table>";
}
print "<br><br>\n";

$sth->finish;

}
########################################################################
# getShowInvoiceitem
########################################################################

sub getShowInvoiceitem {
my $self           = shift;
my $dbh            = shift;
my $idinvoiceitem  = shift;
my $ref            = shift;
my $mode           = shift;

my $sth            = "";
my $resultref      = "";
my $sql            = "";
my $href           = "";

$sql = "
	SELECT *
	FROM invoiceitem 
	WHERE idinvoiceitem = $idinvoiceitem
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Invoice</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idinvoiceitem') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="invoiceitem.pl?idinvoiceitem=$resultref->{idinvoiceitem}&amp;mode=edit">$resultref->{idinvoiceitem} </a></td></tr>);
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td>$resultref->{$href->{name}}  &nbsp;</td></tr>";		
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
# getShowDisease
########################################################################

sub getShowDisease {
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
	FROM disease 
	WHERE iddisease = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Disease</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'iddisease') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="disease.pl?id=$resultref->{iddisease}&amp;mode=edit">$resultref->{iddisease} </a></td></tr>);
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
# getShowCooperation
########################################################################

sub getShowCooperation {
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
	FROM cooperation 
	WHERE idcooperation = $id
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Sample</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		if ($mode eq 'Y') {
			if ($href->{name} eq 'idcooperation') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="cooperation.pl?id=$resultref->{idcooperation}&amp;mode=edit">$resultref->{idcooperation} </a></td></tr>);
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
# getShowProject
########################################################################

sub getShowProject {
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
	WHERE idproject = $id
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
			if ($href->{name} eq 'idproject') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="project.pl?id=$resultref->{idproject}&amp;mode=edit">$resultref->{idproject} </a></td></tr>);
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
# insertIntoSample
########################################################################

sub insertIntoSample {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{idsample} = 0 ;
$ref->{name}     = uc($ref->{name});
$ref->{user}     = $iduser;
if ($ref->{idinvoice} eq "") {
	$ref->{idinvoice} = undef;
}

if ($ref->{sbarcode} eq "") {
	undef($ref->{sbarcode});
}
if ($ref->{splate} eq "") {
	undef($ref->{splate});
}
if ($ref->{srow} eq "") {
	undef($ref->{srow});
}
if ($ref->{scolumn} eq "") {
	undef($ref->{scolumn});
}

my $sql = "";
my $sth = "";

#check_before_update($ref,$dbh);
if ($ref->{name} eq "") {
	showMenu("");
	print "Please fill in sample id. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}
if ($ref->{idproject} eq "") {
	showMenu("");
	print "Please fill in a project. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idsample}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editSample
########################################################################

sub editSample {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";


$ref->{name} = uc($ref->{name});
$ref->{user} = $iduser;

#check_before_update($ref,$dbh);
if ($ref->{name} eq "") {
	showMenu("");
	print "Please fill in a sample id. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}
if ($ref->{idproject} eq "") {
	showMenu("");
	print "Please fill in a project. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

if ($ref->{idcooperation} eq "") {
	$ref->{idcooperation} = undef;
}

if ($ref->{idinvoice} eq "") {
	$ref->{idinvoice} = undef;
}

if ($ref->{sbarcode} eq "") {
	undef($ref->{sbarcode});
}
if ($ref->{splate} eq "") {
	undef($ref->{splate});
}
if ($ref->{srow} eq "") {
	undef($ref->{srow});
}
if ($ref->{scolumn} eq "") {
	undef($ref->{scolumn});
}

#print "refpversion $ref->{pversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

$sql = sprintf "UPDATE %s SET %s WHERE idsample=$ref->{idsample}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";


$sth->finish;

}
########################################################################
# insertIntoInvoice
########################################################################

sub insertIntoInvoice {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{idinvoice} = 0 ;

my $sql = "";
my $sth = "";

#check_before_update($ref,$dbh);
if ($ref->{my} eq "") {
	showMenu("");
	print "Please fill in invoice no.Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idinvoice}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editInvoice
########################################################################

sub editInvoice {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";



#check_before_update($ref,$dbh);
if ($ref->{my} eq "") {
	showMenu("");
	print "Please fill in a invoice no.Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

if ($ref->{idcooperation} eq "") {
	delete($ref->{idcooperation});
}

#print "refpversion $ref->{pversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

$sql = sprintf "UPDATE %s SET %s WHERE idinvoice=$ref->{idinvoice}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";


$sth->finish;

}
########################################################################
# insertIntoDisease
########################################################################

sub insertIntoDisease {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{iddisease} = 0 ;

my $sql = "";
my $sth = "";

#check_before_update($ref,$dbh);
if ($ref->{name} eq "") {
	showMenu("");
	print "Please fill in name. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}
if ($ref->{symbol} eq "") {
	showMenu("");
	print "Please fill in symbol. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{iddisease}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editDisease
########################################################################

sub editDisease {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";



#check_before_update($ref,$dbh);
if ($ref->{name} eq "") {
	showMenu("");
	print "Please fill in name. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}
if ($ref->{symbol} eq "") {
	showMenu("");
	print "Please fill in symbol. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}


#print "refpversion $ref->{pversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

$sql = sprintf "UPDATE %s SET %s WHERE iddisease=$ref->{iddisease}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";


$sth->finish;

}
########################################################################
# insertIntoCooperation
########################################################################

sub insertIntoCooperation {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{idcooperation} = 0 ;

my $sql = "";
my $sth = "";

#check_before_update($ref,$dbh);
if ($ref->{name} eq "") {
	showMenu("");
	print "Please fill in 'Name'.Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idcooperation}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editCooperation
########################################################################

sub editCooperation {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";



#check_before_update($ref,$dbh);
if ($ref->{name} eq "") {
	showMenu("");
	print "Please fill in a 'Name'.Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}


#print "refpversion $ref->{pversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

$sql = sprintf "UPDATE %s SET %s WHERE idcooperation=$ref->{idcooperation}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";


$sth->finish;

}
########################################################################
# insertIntoInvoiceitem
########################################################################

sub insertIntoInvoiceitem {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{idinvoiceitem} = 0 ;

my $sql = "";
my $sth = "";

#check_before_update($ref,$dbh);
if ($ref->{idservice} eq "") {
	showMenu("");
	print "Please fill in 'Item'.Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idinvoiceitem}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editInvoiceitem
########################################################################

sub editInvoiceitem {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";



#check_before_update($ref,$dbh);
if ($ref->{idservice} eq "") {
	showMenu("");
	print "Please fill in a 'Item'.Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}


#print "refpversion $ref->{pversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

$sql = sprintf "UPDATE %s SET %s WHERE idinvoiceitem=$ref->{idinvoiceitem}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";


$sth->finish;

}
########################################################################
# insertIntoProject
########################################################################

sub insertIntoProject {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;

$ref->{idproject} = 0 ;
$ref->{pname} = uc($ref->{pname});
$ref->{user} = $iduser;

my $sql = "";
my $sth = "";

#check_before_update($ref,$dbh);
if ($ref->{pname} eq "") {
	showMenu("");
	print "Please fill in a project name. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}
my @fields           = sort keys %$ref;
my @values           = @{$ref}{@fields};

$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$ref->{idproject}=$sth->{mysql_insertid};
$sth->finish;

}
########################################################################
# editProject
########################################################################

sub editProject {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $sql       = "";
my $sth       = "";
my @fields2   = ();
my $field     = "";
my $value     = "";


$ref->{pname} = uc($ref->{pname});
$ref->{user} = $iduser;
#check_before_update($ref,$dbh);
if ($ref->{pname} eq "") {
	showMenu("");
	print "Please fill in a project name.Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

$dbh->{AutoCommit}=0;
eval {
$ref->{pversion}=&checkVersion($dbh,$table,"idproject","pversion",$ref->{idproject},$ref->{pversion});
#print "refpversion $ref->{pversion}<br>";
my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
foreach $field (@fields) {
	$value=$field . " = ?";
	push(@fields2,$value);
}

$sql = sprintf "UPDATE %s SET %s WHERE idproject=$ref->{idproject}",
         $table, join(",", @fields2);

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
};
if ($@) {
	eval { $dbh->rollback };
	showMenu("");
	print "Rollback done.<br>";
	printFooter("",$dbh);
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
	printFooter("",$dbh);
	exit(0);
}
else {
	$actversion++;
}
$actversion;
}

########################################################################
# searchSample called by searchSampleDo.pl resultssample
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
my $mode      = 0;

my $myorder = "d.name,s.name";
if ($ref->{myorder} eq "pedigree") {
	$myorder = "d.name,s.pedigree,s.name";
}
elsif ($ref->{myorder} eq "status") {
	$myorder = "l.lstatus,s.splate,s.srow,s.scolumn,s.name,o.oname";
}
delete($ref->{myorder});

if ($ref->{withoutlib} == 1) {
	delete($ref->{'l.lfailed'});
	delete($ref->{libtype});
	delete($ref->{lstatus});
	delete($ref->{lforpool});
}

# samples only
if ($ref->{mode} == 1) {		
	delete($ref->{'l.lfailed'});
	delete($ref->{libtype});
	delete($ref->{lstatus});
	delete($ref->{lforpool});
	delete($ref->{withoutlib});
	$mode = 1;
}
delete($ref->{mode});

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};


foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "withoutlib") {
			$where .= " ISNULL(l.lid) "
		}
		elsif ($field eq "datebegin") {
			$where .= " s.entered >= '$values[$i]' ";
		}
		elsif ($field eq "dateend") {
			$where .= " s.entered <= '$values[$i]' ";
		}
		else {
			$where .= $field . " = ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
if ($where ne "") {
	$where = "WHERE  $where";
}

if ($mode==1) {	 #samples only	
$i=0;
$query = qq#
SELECT
concat('<a href="sample.pl?id=',s.idsample,'&amp;mode=edit">',s.idsample,'</a>'),
s.name,splate,srow,scolumn,
s.foreignid,s.externalseqid,s.pedigree,s.sex,s.saffected,org.orname,ti.name,
d.name,
s.analysis,s.entered,u.name,s.scomment,p.pdescription,c.name,
s.nottoseq,s.accounting
FROM
sample s 
LEFT JOIN cooperation                        c ON s.idcooperation = c.idcooperation
LEFT JOIN invoice                            i ON s.idinvoice     = i.idinvoice
LEFT JOIN disease2sample                    ds ON s.idsample      = ds.idsample
LEFT JOIN disease                            d ON ds.iddisease    = d.iddisease
LEFT JOIN project                            p ON s.idproject     = p.idproject
LEFT JOIN organism                         org ON s.idorganism    = org.idorganism
LEFT JOIN tissue                            ti ON s.idtissue      = ti.idtissue
LEFT JOIN $logindb.user                      u ON s.user          = u.iduser
$where
GROUP BY
s.idsample
ORDER BY
$myorder
#;
#print "query = $query<br>";
#print "values @values2<br>";
#AND l.lfailed=0
#print "$query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'id',
	'DNA',
	'Plate',
	'Row',
	'Column',
	'Foreign ID',
	'External<br>SeqID',
	'Pedigree',
	'Sex',
	'Affected',
	'Organism',
	'Tissue',
	'Disease',
	'Analysis',
	'Entered',
	'Entered<br>from',
	'Comment',
	'Project',
	'Cooperation',
	'Nottoseq',
	'Accounting'
	);
}

else {
$i=0;
$query = qq#
SELECT
concat('<a href="sample.pl?id=',s.idsample,'&amp;mode=edit">',s.idsample,'</a>'),
s.name,splate,srow,scolumn,
s.foreignid,s.externalseqid,s.pedigree,s.sex,s.saffected,org.orname,ti.name,
d.name,
s.analysis,s.entered,u.name,s.scomment,p.pdescription,c.name,
concat('<a href="../solexa/library.pl?id=',l.lid,'&amp;mode=edit">',l.lname,'</a>'),
lt.ltlibtype,
lp.lplibpair,
t.tname,t.ttag,l.lstatus,s.nottoseq,l.lfailed,
s.accounting
FROM
sample s 
LEFT JOIN cooperation                        c ON s.idcooperation = c.idcooperation
LEFT JOIN invoice                            i ON s.idinvoice     = i.idinvoice
LEFT JOIN disease2sample                    ds ON s.idsample      = ds.idsample
LEFT JOIN disease                            d ON ds.iddisease    = d.iddisease
LEFT JOIN project                            p ON s.idproject     = p.idproject
LEFT JOIN $solexa.sample2library            sl ON s.idsample      = sl.idsample
LEFT JOIN $solexa.library                    l ON sl.lid          = l.lid
LEFT JOIN $solexa.tag                        t ON l.idtag         = t.idtag
LEFT JOIN $solexa.libpair                   lp ON l.libpair       = lp.lpid
LEFT JOIN $solexa.libtype                   lt ON l.libtype       = lt.ltid
LEFT JOIN $solexa.library2pool              pl ON l.lid           = pl.lid
LEFT JOIN $solexa.pool                       o ON pl.idpool       = o.idpool
LEFT JOIN organism                         org ON s.idorganism    = org.idorganism
LEFT JOIN tissue                            ti ON s.idtissue      = ti.idtissue
LEFT JOIN $logindb.user                      u ON s.user          = u.iduser
$where
GROUP BY
l.lid,s.idsample
ORDER BY
$myorder
#;
#print "query = $query<br>";
#print "values @values2<br>";
#AND l.lfailed=0

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'id',
	'DNA',
	'Plate',
	'Row',
	'Column',
	'Foreign Id',
	'External<br>SeqID',
	'Pedigree',
	'Sex',
	'Affected',
	'Organism',
	'Tissue',
	'Disease',
	'Analysis',
	'Entered',
	'Entered<br>from',
	'Comment',
	'Project',
	'Cooperation',
	'Library',
	'LibType',
	'paired-end',
	'Index',
	'Tag',
	'Status',
	'Nottoseq',
	'Failed',
	'Accounting'
	);
}

&tableheaderDefault("1500px");
$i=0;

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
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
&tablescript;

$out->finish;
}
########################################################################
# listCooperation
########################################################################
sub listCooperation {
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
concat("<a href='cooperation.pl?mode=edit&amp;id=",idcooperation,"'>",idcooperation,"</a>"),
name,prename,institution,department,comment,email,phone,sendemail,sendstatus
FROM
cooperation
ORDER BY
name
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'id',
	'Name',
	'Prename',
	'Institution',
	'Department',
	'Comment',
	'Email',
	'Phone',
	'Send email',
	'Send status'
	);

&tableheader("");
$i=0;

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
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
&tablescript;




$out->finish;
}

########################################################################
# listDisease
########################################################################
sub listDisease {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

			
$i=0;
$query = qq#
SELECT
concat("<a href='disease.pl?mode=edit&amp;id=",iddisease,"'>",iddisease,"</a>"),
d.name,d.symbol,d.omimid,dg.name
FROM
disease d
LEFT JOIN diseasegroup dg ON d.iddiseasegroup=dg.iddiseasegroup
ORDER BY
d.name
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'Id',
	'Name',
	'Symbol',
	'Omim',
	'Disease group'
	);

&tableheader("1000px");
$i=0;

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
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
&tablescript;


$out->finish;
}

########################################################################
# listProject
########################################################################
sub listProject {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

			
$i=0;
$query = qq#
SELECT
concat("<a href='project.pl?mode=edit&amp;id=",idproject,"'>",idproject,"</a>"),
pname,pdescription,concat(co.name,', ',co.prename),co.institution,co.department,p.pcomment,p.pcontact,p.institution,p.department
FROM
project p
LEFT JOIN cooperation co ON p.idcooperation = co.idcooperation
ORDER BY
pdescription
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'Id',
	'Name',
	'Description',
	'Principal investigator',
	'Institution',
	'Department',
	'Comment',
	'Contact',
	'Institution old',
	'Department old'
	);

&tableheader("1300px");
$i=0;

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
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
&tablescript;




$out->finish;
}

########################################################################
# searchStatistics resultsStatistics wrapper
########################################################################
sub searchStatistics {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $groupby = $ref->{'groupby'};
$groupby =~ s/\'//g;

if ($groupby eq "od.rname,od.lane") {
	&searchStatisticsPerLane($self,$dbh,$ref);
}
else {
	&searchStatisticsPerPool($self,$dbh,$ref);
}

}

########################################################################
# searchStatistics resultsStatisticsPerLane
########################################################################
sub searchStatisticsPerLane {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

use Statistics::R;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my $where     = "";
my $whereR    = "";
my @prepare   = ();
my $groupby = $ref->{'groupby'};
$groupby =~ s/\'//g;

if ($ref->{'datebegin'} ne "") {
	$where  = " AND es.date >= ? ";
	$whereR = " AND es.date >= '$ref->{datebegin}' ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where  .= " AND es.date <= ? ";
	$whereR .= " AND es.date <= '$ref->{dateend}' ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'libtype'} ne "") {
	$where  .= " AND l.libtype = ? ";
	$whereR .= " AND l.libtype = '$ref->{libtype}' ";
	push(@prepare, $ref->{'libtype'});
}
if ($ref->{'s.idorganism'} ne "") {
	$where  .= " AND s.idorganism = ? ";
	$whereR .= " AND s.idorganism = $ref->{'s.idorganism'} ";
	push(@prepare, $ref->{'s.idorganism'});
}
if ($ref->{'ti.idtissue'} ne "") {
	$where .= " AND ti.idtissue = ? ";
	push(@prepare, $ref->{'ti.idtissue'});
}

$query=
"SELECT 
group_concat(DISTINCT r.rinstrument),
group_concat(DISTINCT r.rname) as flowcell,
r.rdate,
group_concat(DISTINCT o.odescription),
od.lane,
e.originalReadLength,
lt.ltlibtype,
round(avg(e.clusterCountRaw)),
round(avg(e.clusterCountPF)),
round(avg(e.clusterCountPF/e.clusterCountRaw),2),
round(avg(od.duplicates),2),
round(avg(od.opticalduplicates),2) as opticalDuplicates,
round(avg(es.mix),3) as contamination
FROM sample s 
INNER JOIN $solexa.sample2library sl ON s.idsample=sl.idsample
INNER JOIN $solexa.library         l ON sl.lid=l.lid
INNER JOIN $solexa.library2pool   lo ON l.lid=lo.lid
INNER JOIN $solexa.pool            o ON lo.idpool=o.idpool
INNER JOIN $solexa.lane            a ON o.idpool=a.idpool
INNER JOIN $solexa.rread           e ON a.aid=e.aid
INNER JOIN $solexa.run             r ON r.rid=a.rid
INNER JOIN exomestat              es ON s.idsample=es.idsample
INNER JOIN $solexa.opticalduplicates od ON r.rname=od.rname and a.alane=od.lane
LEFT  JOIN $solexa.libtype        lt ON es.idlibtype=lt.ltid
WHERE 
a.aread1failed='F'
$where
GROUP BY $groupby
ORDER BY $groupby
";
#print "$query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Instrument',
	'Flowcell',
	'Flowcell<br>date',
	'Pool',
	'Lane',
	'Read<br>length',
	'Libtype',
	'Raw<br>cluster',
	'Perfect<br>cluster',
	'perfect/raw',
	'Duplicates',
	'Opitcal<br>duplicates',
	'Contamination'
	);

&tableheader("1800px");
$i=0;
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
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
&tablescript;

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

my $R = Statistics::R->new();

$query=
"SELECT 
r.rinstrument,
group_concat(DISTINCT r.rname) as flowcell,
r.rdate,
o.odescription,
od.lane as lane,
e.originalReadLength,
es.idlibtype,
e.clusterCountRaw,
e.clusterCountPF,
e.clusterCountPF/e.clusterCountRaw,
avg(od.duplicates),
avg(od.opticalduplicates) as opticalDuplicates,
avg(es.mix) as contamination
FROM sample s 
INNER JOIN $solexa.sample2library    sl ON s.idsample=sl.idsample
INNER JOIN $solexa.library            l ON sl.lid=l.lid
INNER JOIN $solexa.library2pool      lo ON l.lid=lo.lid
INNER JOIN $solexa.pool               o ON lo.idpool=o.idpool
INNER JOIN $solexa.lane               a ON o.idpool=a.idpool
INNER JOIN $solexa.rread              e ON a.aid=e.aid
INNER JOIN $solexa.run                r ON r.rid=a.rid
INNER JOIN exomestat   es ON s.idsample=es.idsample
INNER JOIN $solexa.opticalduplicates od ON r.rname=od.rname and a.alane=od.lane
WHERE 
a.aread1failed='F'
$whereR
GROUP BY $groupby
ORDER BY r.rdate
";

$R->run(qq`library(lattice)`);
$R->run(qq`library(RMySQL)`);
$R->run(qq`library(ggplot2)`);

my $dbname   = "exomehg19";

$R->run(qq`con <- dbConnect(MySQL(), user="$logins{dblogin}", password="$logins{dbpasswd}", dbname="$dbname")`);

$R->run(qq`mydata<-dbGetQuery(con, "$query")`);

$R->run(qq`png("/srv/www/htdocs/tmp/test.png", width=1800, height=500)`);
$R->run(qq`q<-ggplot(na.omit(mydata))`);
$R->run(qq`q<- q+geom_point(aes(x=paste(rdate,flowcell),y=opticalDuplicates,color=odescription),show.legend=F)`);
$R->run(qq`q<- q+theme(axis.text.x = element_text(angle = 90, hjust = 1))`);
$R->run(qq`q<- q+geom_text(aes(x=paste(rdate,flowcell),y=opticalDuplicates,label=paste(flowcell,lane)),hjust=0,vjust=0)`);
$R->run(qq`q<- q+labs(x='Date',y='Optical duplicates')`);
$R->run(qq`q`);

$R->stop();

print"<img src='/tmp/test.png'>";

}
########################################################################
# searchStatistics resultsStatisticsPerPool
########################################################################
sub searchStatisticsPerPool {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

use Statistics::R;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my $where     = "";
my $whereR    = "";
my @prepare   = ();
my $groupby = $ref->{'groupby'};

if ($ref->{'datebegin'} ne "") {
	$where  = " AND es.date >= ? ";
	$whereR = " AND es.date >= '$ref->{datebegin}' ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where  .= " AND es.date <= ? ";
	$whereR .= " AND es.date <= '$ref->{dateend}' ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'libtype'} ne "") {
	$where  .= " AND l.libtype = ? ";
	$whereR .= " AND l.libtype = '$ref->{libtype}' ";
	push(@prepare, $ref->{'libtype'});
}
if ($ref->{'s.idorganism'} ne "") {
	$where  .= " AND s.idorganism = ? ";
	$whereR .= " AND s.idorganism = $ref->{'s.idorganism'} ";
	push(@prepare, $ref->{'s.idorganism'});
}
if ($ref->{'ti.idtissue'} ne "") {
	$where .= " AND ti.idtissue = ? ";
	push(@prepare, $ref->{'ti.idtissue'});
}

$query=
"SELECT 
group_concat(DISTINCT r.rinstrument),
group_concat(DISTINCT r.rname) as flowcell,
r.rdate,
group_concat(DISTINCT o.odescription),
group_concat(DISTINCT a.alane ORDER BY a.alane),
e.originalReadLength,
lt.ltlibtype,
round(avg(e.clusterCountRaw)),
round(avg(e.clusterCountPF)),
round(avg(e.clusterCountPF/e.clusterCountRaw),2),
round(avg(es.duplicates),2),
round(avg(es.opticalduplicates),2) as opticalDuplicates,
round(avg(es.mix),3) as contamination
FROM sample s 
INNER JOIN $solexa.sample2library sl ON s.idsample=sl.idsample
INNER JOIN $solexa.library         l ON sl.lid=l.lid
INNER JOIN $solexa.library2pool   lo ON l.lid=lo.lid
INNER JOIN $solexa.pool            o ON lo.idpool=o.idpool
INNER JOIN $solexa.lane            a ON o.idpool=a.idpool
INNER JOIN $solexa.rread           e ON a.aid=e.aid
INNER JOIN $solexa.run             r ON r.rid=a.rid
INNER JOIN exomestat              es ON s.idsample=es.idsample
LEFT  JOIN $solexa.libtype        lt ON es.idlibtype=lt.ltid
WHERE 
a.aread1failed='F'
$where
GROUP BY $groupby
";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Instrument',
	'Flowcell',
	'Flowcell<br>date',
	'Pool',
	'Lane',
	'Read<br>length',
	'Libtype',
	'Raw<br>cluster',
	'Perfect<br>cluster',
	'perfect/raw',
	'Duplicates',
	'Opitcal<br>duplicates',
	'Contamination'
	);

&tableheader("1800px");
$i=0;
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
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
&tablescript;

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

my $R = Statistics::R->new();

$query=
"SELECT 
r.rinstrument,
group_concat(DISTINCT r.rname) as flowcell,
r.rdate,
o.odescription,
a.alane,
e.originalReadLength,
es.idlibtype,
e.clusterCountRaw,
e.clusterCountPF,
e.clusterCountPF/e.clusterCountRaw,
avg(es.duplicates),
avg(es.opticalduplicates) as opticalDuplicates,
avg(es.mix) as contamination
FROM sample s 
INNER JOIN $solexa.sample2library sl ON s.idsample=sl.idsample
INNER JOIN $solexa.library         l ON sl.lid=l.lid
INNER JOIN $solexa.library2pool   lo ON l.lid=lo.lid
INNER JOIN $solexa.pool            o ON lo.idpool=o.idpool
INNER JOIN $solexa.lane            a ON o.idpool=a.idpool
INNER JOIN $solexa.rread           e ON a.aid=e.aid
INNER JOIN $solexa.run             r ON r.rid=a.rid
INNER JOIN exomestat   es ON s.idsample=es.idsample
WHERE 
a.aread1failed='F'
$whereR
GROUP BY $groupby
";

$R->run(qq`library(lattice)`);
$R->run(qq`library(RMySQL)`);
$R->run(qq`library(ggplot2)`);

my $dbname   = "exomehg19";

$R->run(qq`con <- dbConnect(MySQL(), user="$logins{dblogin}", password="$logins{dbpasswd}", dbname="$dbname")`);

$R->run(qq`mydata<-dbGetQuery(con, "$query")`);

$R->run(qq`png("/srv/www/htdocs/tmp/test.png", width=1800, height=500)`);
$R->run(qq`q<-ggplot(na.omit(mydata))`);
$R->run(qq`q<- q+geom_point(aes(x=rdate,y=opticalDuplicates,color=odescription),show.legend=F)`);
$R->run(qq`q<- q+theme(axis.text.x = element_text(angle = 90, hjust = 1))`);
$R->run(qq`q<- q+geom_text(aes(x=rdate,y=opticalDuplicates,label=odescription),hjust=0,vjust=0)`);
$R->run(qq`q<- q+labs(x='Date',y='Optical duplicates')`);
$R->run(qq`q`);

$R->stop();

print"<img src='/tmp/test.png'>";

}
########################################################################
# overviewnew
########################################################################
sub overviewnew {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $project   = "";
my $tmp       = "";
my $where1    = "";
my $where2    = "";
my @where     = ();

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
my $not_sequenced = $ref->{'not_sequenced'};

if ($ref->{'datebegin'} ne "") {
	$where1  .= " AND ss.entered >= ? ";
	push(@where, $ref->{'datebegin'});
	push(@where, $ref->{'datebegin'});
	push(@where, $ref->{'datebegin'});
	push(@where, $ref->{'datebegin'});
	push(@where, $ref->{'datebegin'});
	push(@where, $ref->{'datebegin'});
	push(@where, $ref->{'datebegin'});
	push(@where, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where1  .= " AND ss.entered <= ? ";
	push(@where, $ref->{'dateend'});
	push(@where, $ref->{'dateend'});
	push(@where, $ref->{'dateend'});
	push(@where, $ref->{'dateend'});
	push(@where, $ref->{'dateend'});
	push(@where, $ref->{'dateend'});
	push(@where, $ref->{'dateend'});
	push(@where, $ref->{'dateend'});
}
if ($ref->{'libtype'} ne "") {
	$where1  .= " AND sol.libtype = ? ";
	push(@where, $ref->{'libtype'});
	push(@where, $ref->{'libtype'});
	push(@where, $ref->{'libtype'});
	push(@where, $ref->{'libtype'});
	push(@where, $ref->{'libtype'});
	push(@where, $ref->{'libtype'});
	push(@where, $ref->{'libtype'});
	push(@where, $ref->{'libtype'});
}

if ($ref->{'datebegin'} ne "") {
	$where2  .= " AND s.entered >= ? ";
	push(@where, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where2  .= " AND s.entered <= ? ";
	push(@where, $ref->{'dateend'});
}
if ($ref->{'libtype'} ne "") {
	$where2  .= " AND l.libtype = ? ";
	push(@where, $ref->{'libtype'});
}	
	
			
$i=0;
$query = qq#
SELECT
p.pname,
p.pdescription,
concat(c.name,', ',c.prename),
c.institution,
c.department,
group_concat(DISTINCT o.orname),
lt.ltlibtype,
lp.lplibpair,
(SELECT 
count(DISTINCT ss.name)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND ss.nottoseq = 0
$where1
),
count(DISTINCT l.lid),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'to do'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'lib in process'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'library prepared'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
INNER JOIN $solexa.library2pool   loo  ON sol.lid   = loo.lid
INNER JOIN $solexa.pool           oo   ON loo.idpool = oo.idpool
WHERE  (s.idproject = ss.idproject AND sol.libtype  = l.libtype AND sol.libpair=l.libpair AND o.idpool=oo.idpool)
AND sol.lstatus = 'pooled'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
(
SELECT 
CONCAT( oo.idpool, ' ', oo.olanestosequence, ' ', count(oo.idpool), ' ',
(SELECT count(isol.lid) FROM $solexa.library2pool isol where isol.idpool = o.idpool) )
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library        sol  ON sosl.lid  = sol.lid
INNER JOIN $solexa.library2pool   loo  ON sol.lid   = loo.lid
INNER JOIN $solexa.pool           oo   ON loo.idpool = oo.idpool
WHERE  (s.idproject = ss.idproject AND sol.libtype  = l.libtype AND sol.libpair=l.libpair AND o.idpool=oo.idpool)
AND sol.lstatus = 'pooled'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
AND oo.oflowcell != ''
$where1
GROUP BY
oo.idpool
),
(
SELECT 
CONCAT( oo.olanestosequence * count(oo.idpool) /
(SELECT count(isol.lid) FROM $solexa.library2pool isol where isol.idpool = o.idpool) )
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library        sol  ON sosl.lid  = sol.lid
INNER JOIN $solexa.library2pool   loo  ON sol.lid   = loo.lid
INNER JOIN $solexa.pool           oo   ON loo.idpool = oo.idpool
WHERE  (s.idproject = ss.idproject AND sol.libtype  = l.libtype AND sol.libpair=l.libpair AND o.idpool=oo.idpool)
AND sol.lstatus = 'pooled'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
AND oo.oflowcell != ''
$where1
GROUP BY
oo.idpool
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'sequenced'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
count(DISTINCT e.idsample),
GROUP_CONCAT(DISTINCT s.accounting),
s.idproject
FROM
sample s 
LEFT JOIN $solexa.sample2library   sl ON s.idsample = sl.idsample
LEFT JOIN $solexa.library          l  ON sl.lid = l.lid
LEFT JOIN exomestat                e  ON (s.idsample = e.idsample AND e.idlibtype=l.libtype AND e.idlibpair=l.libpair)
INNER JOIN project                 p  ON s.idproject = p.idproject
LEFT  JOIN cooperation             c  ON c.idcooperation = p.idcooperation
INNER JOIN organism                o  ON s.idorganism = o.idorganism
LEFT JOIN $solexa.libtype          lt ON l.libtype = lt.ltid
LEFT JOIN $solexa.libpair          lp ON l.libpair = lp.lpid 
LEFT JOIN $solexa.library2pool     lo ON l.lid   = lo.lid
LEFT JOIN $solexa.pool             o  ON lo.idpool = o.idpool
WHERE
l.lfailed  = 0
AND s.nottoseq  = 0
AND l.lstatus != 'external'
AND o.oflowcell != ''
$where2
GROUP BY s.idproject,o.idpool,l.libtype,l.libpair
ORDER BY
p.pname desc
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@where) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Id',
	'Name',
	'Cooperation',
	'Institution',
	'Department',
	'Organism',
	'Libtype',
	'Libpair',
	'Samples',
	'Libraries',
	'to do',
	'lib in process',
	'library prepared',
	'pooled',
	'all to do',
	'Pooled lanes',
	'Pooled lanes',
	'sequenced',
	'Exomestat',
	'Accounting'
	);

$i=0;

&tableheader("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
while (@row = $out->fetchrow_array) {
	if ($not_sequenced eq "not_sequenced") {
		$tmp = $row[13] + $row[12] + $row[11] + $row[10];
	}
	else {
		$tmp = 1;
	}
	$tmp = "$tmp > 0";
	if ($tmp > 0) { # all to do > 0
	print "<tr>";
	$i=0;
	$project=$row[-1];
	pop(@row);
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print "<td><a href='project.pl?id=$project&mode=edit'>$row[$i]</a></td>";
		}
		elsif ($i == 13) { # all to do
			print "<td> $row[$i]</td>";
			$tmp = $row[$i] + $row[$i-1] + $row[$i-2] + $row[$i-3];
			print "<td> $tmp</td>";
		}
		elsif ($i == 14) { #sequenced ungleich libraries
			if ($row[$i-5] != $row[$i]) {
				#print "<td $warningtdbg>$row[$i]</td>";
				print "<td> $row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
	}
}
print "</tbody></table></div>";
&tablescript;



$out->finish;
}

########################################################################
# overview
########################################################################
sub overview {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $project   = "";
my $tmp       = "";
my $where1    = "";
my $where2    = "";
my @where     = ();

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
my $not_sequenced = $ref->{'not_sequenced'}; #only 'when all to do' > 0

if ($ref->{'datebegin'} ne "") {
	$where1  .= " AND ss.entered >= ? ";
}
if ($ref->{'dateend'} ne "") {
	$where1  .= " AND ss.entered <= ? ";
}
if ($ref->{'libtype'} ne "") {
	$where1  .= " AND sol.libtype = ? ";
}
for ($i=0;$i<10;$i++) {
if ($ref->{'datebegin'} ne "") {
	push(@where, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	push(@where, $ref->{'dateend'});
}
if ($ref->{'libtype'} ne "") {
	push(@where, $ref->{'libtype'});
}
}

if ($ref->{'datebegin'} ne "") {
	$where2  .= " AND s.entered >= ? ";
	push(@where, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where2  .= " AND s.entered <= ? ";
	push(@where, $ref->{'dateend'});
}
if ($ref->{'libtype'} ne "") {
	$where2  .= " AND l.libtype = ? ";
	push(@where, $ref->{'libtype'});
}	
	
			
$i=0;
$query = qq#
SELECT
p.pname,
p.pdescription,
concat(c.name,', ',c.prename),
c.institution,
c.department,
group_concat(DISTINCT o.orname),
lt.ltlibtype,
lp.lplibpair,
(SELECT 
count(DISTINCT ss.name)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus != 'external'
AND ss.nottoseq = 0
$where1
),
(SELECT 
MAX(ss.entered)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus != 'external'
AND ss.nottoseq = 0
$where1
),
count(DISTINCT l.lid),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'to do'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'lib in process'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'library prepared'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'pooled'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
if (l.libtype != 5,
(SELECT GROUP_CONCAT(DISTINCT x.flowcells) FROM  (
SELECT 
GROUP_CONCAT(DISTINCT oo.oflowcell) as flowcells,
ss.idproject,sol.libtype,sol.libpair
FROM sample ss
INNER JOIN solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN solexa.library        sol  ON sosl.lid  = sol.lid
INNER JOIN solexa.library2pool   loo  ON sol.lid   = loo.lid
INNER JOIN solexa.pool           oo   ON loo.idpool = oo.idpool
WHERE  ( (sol.lstatus = 'pooled') or  (sol.lstatus = 'library prepared') )
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
AND oo.oflowcell != ''
$where1
GROUP BY ss.idproject,sol.libtype,sol.libpair,oo.idpool
) as x
WHERE s.idproject = x.idproject
AND   l.libtype = x.libtype
AND   l.libpair = x.libpair
), 'NovaSeqS2'),

if (l.libtype != 5,
(SELECT sum(x.lanes) FROM  (
SELECT 
( oo.olanestosequence * count(oo.idpool) /
(SELECT count(isol.lid) FROM solexa.library2pool isol where isol.idpool = oo.idpool) ) as lanes,
ss.idproject,sol.libtype,sol.libpair
FROM sample ss
INNER JOIN solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN solexa.library        sol  ON sosl.lid  = sol.lid
INNER JOIN solexa.library2pool   loo  ON sol.lid   = loo.lid
INNER JOIN solexa.pool           oo   ON loo.idpool = oo.idpool
WHERE  ( (sol.lstatus = 'pooled') or  (sol.lstatus = 'library prepared') )
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
AND oo.oflowcell != ''
$where1
GROUP BY ss.idproject,sol.libtype,sol.libpair,oo.idpool
) as x
WHERE s.idproject = x.idproject
AND   l.libtype = x.libtype
AND   l.libpair = x.libpair
),
(SELECT sum(y.libs/35) FROM  (
SELECT 
( count(sol.lid) ) as libs,
ss.idproject,sol.libtype,sol.libpair
FROM sample ss
INNER JOIN solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN solexa.library        sol  ON sosl.lid  = sol.lid
WHERE  ( (sol.lstatus = 'to do') or  (sol.lstatus = 'lib in process') or  (sol.lstatus = 'library prepared') or (sol.lstatus = 'pooled') )
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
GROUP BY ss.idproject,sol.libtype,sol.libpair
) as y
WHERE s.idproject = y.idproject
AND   l.libtype = y.libtype
AND   l.libpair = y.libpair
)
),
(
SELECT 
count(DISTINCT sol.lid)
FROM sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
WHERE  (s.idproject = ss.idproject AND sol.libtype=l.libtype AND sol.libpair=l.libpair)
AND sol.lstatus = 'sequenced'
AND sol.lstatus != 'external'
AND ss.nottoseq  = 0
AND sol.lfailed  = 0
$where1
),
count(DISTINCT e.idsample),
GROUP_CONCAT(DISTINCT s.accounting SEPARATOR ' '),
s.idproject
FROM
sample s 
LEFT JOIN $solexa.sample2library   sl ON s.idsample = sl.idsample
LEFT JOIN $solexa.library          l  ON sl.lid = l.lid
LEFT JOIN exomestat                e  ON (s.idsample = e.idsample AND e.idlibtype=l.libtype AND e.idlibpair=l.libpair)
INNER JOIN project                 p  ON s.idproject = p.idproject
LEFT  JOIN cooperation             c  ON c.idcooperation = p.idcooperation
INNER JOIN organism                o  ON s.idorganism = o.idorganism
LEFT JOIN $solexa.libtype          lt ON l.libtype = lt.ltid
LEFT JOIN $solexa.libpair          lp ON l.libpair = lp.lpid 
WHERE
l.lfailed  = 0
AND s.nottoseq  = 0
AND l.lstatus != 'external'
$where2
GROUP BY s.idproject,l.libtype,l.libpair
ORDER BY
p.pname desc
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@where) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Id',
	'Name',
	'Cooperation',
	'Institution',
	'Department',
	'Organism',
	'Libtype',
	'Libpair',
	'Samples',
	'Last sample',
	'Libraries',
	'to do',
	'lib in process',
	'library prepared',
	'pooled',
	'all to do',
	'Flowcells',
	'Pooled lanes',
	'sequenced',
	'Exomestat',
	'Accounting'
	);

$i=0;

&tableheader("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
while (@row = $out->fetchrow_array) {
	if ($not_sequenced eq "not_sequenced") {
		$tmp = $row[14] + $row[13] + $row[12] + $row[11];
	}
	else {
		$tmp = 1;
	}
	$tmp = "$tmp > 0";
	if ($tmp > 0) { # all to do > 0
	print "<tr>";
	$i=0;
	$project=$row[-1];
	pop(@row);
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print "<td><a href='project.pl?id=$project&mode=edit'>$row[$i]</a></td>";
		}
		elsif ($i == 14) { # all to do
			print "<td> $row[$i]</td>";
			$tmp = $row[$i] + $row[$i-1] + $row[$i-2] + $row[$i-3];
			print "<td> $tmp</td>";
		}
		elsif ($i == 17) { #sequenced ungleich libraries
			if ($row[$i-5] != $row[$i]) {
				#print "<td $warningtdbg>$row[$i]</td>";
				print "<td> $row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
	}
}
print "</tbody></table></div>";
&tablescript;



$out->finish;
}
########################################################################
# searchInvoice resultsinvoice
########################################################################
sub searchInvoice {
my $self        = shift;
my $dbh         = shift;
my $ref         = shift;

my @labels      = ();
my $out         = "";
my @row         = ();
my $query       = "";
my $i           = 0;
my $n           = 1;
my $count       = 1;
my $tmp         = "";
my @individuals = ();
my $individuals = "";
my $where       = "WHERE 1=1";
my @where       = ();
#my @fields      = sort keys %$ref;
#my @values      = @{$ref}{@fields};


if ($ref->{'mydate'} ne "") {
	$where  .= " AND i.mydate >= ? ";
	push(@where, $ref->{'mydate'});
}
if ($ref->{'idcooperation'} ne "") {
	$where  .= " AND i.idcooperation = ? ";
	push(@where, $ref->{'idcooperation'});
}
if ($ref->{'idservice'} ne "") {
	$where  .= " AND ii.idservice = ? ";
	push(@where, $ref->{'idservice'});
}
		
$i=0;
$query = qq#
SELECT
concat("<a href='invoice.pl?mode=edit&amp;id=",i.idinvoice,"'>",i.idinvoice,"</a>"),
my,
mydate,
substr(ii.lastdate,1,10),
fa,replace(i.fadate,'0000-00-00',''),
sum,
funds,
costs,
ilvinstitute,
concat(c.name,', ',c.prename),
i.comment,
se.name,
se.description,
ii.count
FROM
invoice i 
LEFT JOIN cooperation   c ON i.idcooperation = c.idcooperation
LEFT JOIN invoiceitem  ii ON i.idinvoice = ii.idinvoice
LEFT JOIN service      se ON ii.idservice = se.idservice
$where
ORDER BY
mydate DESC, my, se.name
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@where) || die print "$DBI::errstr";


@labels	= (
	'n',
	'Id',
	'My no',
	'Date',
	'Last change',
	'FA no',
	'FA Date',
	'Invoices',
	'Third-party funds',
	'ILV',
	'ILV Institute',
	'Cooperation',
	'Comment',
	'Service Name',
	'Service Description',
	'Service Quantity'
	);

$i=0;

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
		$row[$i]=~s/^0.00$//;
		$row[$i]=~s/^0.000$//;
		if ($i == 0) { #edit
			print "<td align=\"center\">$n</td>";
		}
		if (($i == 6) or ($i == 7)  or ($i == 8) or ($i == 14) ) {
			print "<td align=\"right\"> $row[$i]</td>";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
&tablescript;


$out->finish;
}
########################################################################
# importmtDNASamples called by importmtDNASamplesDo.pl
########################################################################
sub importmtDNASamples {
my $self        = shift;
my $dbh         = shift;
my $ref         = shift;
my $file        = shift;

my $sth           = "";
my $idcooperation = 53;
my $idproject     = 106;
my $iddisease     = 10;
my $flowcell      = $ref->{flowcell};	
my $rundate       = $ref->{rundate};

#Check date: (if format is not YYYY-MM-DD it doesn't split correctly)
my @datearray=split("-", $rundate);
eval{
	check_date(@datearray);
} or die "Bad date format: $rundate \n";

print "Flow cell $flowcell<br>";
print "Run date  $rundate<br>";

# Load all samples in a transaction, if something fail, fail.
my $sql="START TRANSACTION;";
$dbh->do($sql) || die print "$DBI::errstr";

if ($flowcell eq "") {
	print "No flow cell name. Nothing done.";
	exit;
}
	
	#skip header
	while(<$file>){
		$_ =~ s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		last if $_ =~ /^Sample_ID/;
	}
	
	#read samples and insert them
    # if samples / library / cross-key-entries between disease and sample and between library and bool exist get them and continue
	my $insertPool = 1;
	my $idpool     = 0;
	while(<$file>){
		$_ =~ s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		my ($sample,@dummy) = split(",");
		$sample=uc($sample);

		# Trim sample string
		$sample=~s/^\s+|\s+$//g;
		$sample=~s/\s+/\_/g;
		
		if (($sample !~ /^[a-zA-Z0-9_-]*$/) || ( $sample eq "" )) {
			print "$sample contains non-alphanumeric characters or sample name empty.\n";
			exit(1);
		}
		
		$idpool = &insertPoolAndRun($dbh,$flowcell,$rundate) if $insertPool;
		$insertPool = 0;
		
		#insert sample
		$sql = "insert into exomehg19.sample (foreignid,name,sex,pedigree,idcooperation,analysis,scomment,saffected,idproject,idorganism,entered) values 
		('$sample','$sample','unknown','$sample',$idcooperation,'other','mtDNA; entered automatically',1,$idproject ,3,now() );"; #No duplicate admissible -> ON DUPLICATE KEY UPDATE idsample=LAST_INSERT_ID(idsample);";
		
		$sth = $dbh->prepare($sql) || die "Can't prepare statement: $DBI::errstr";
		$sth->execute() || die $DBI::errstr;
		my $idsample = $dbh->last_insert_id(undef, undef, qw($params->{coredb}->{sampletable} idsample)) or die $DBI::errstr;
		
		#insert disease2sample 
		$sql = "insert into exomehg19.disease2sample (idsample,iddisease) values ($idsample,$iddisease);"; # ON DUPLICATE KEY UPDATE iddisease2sample=LAST_INSERT_ID(iddisease2sample);";
		#print "$sql\n";
		$sth = $dbh->prepare($sql) || die "Can't prepare statement: $DBI::errstr";
		$sth->execute() || die $DBI::errstr;
		
		#insert library
		$sql = "insert into solexa.library (lname,ldescription,lcomment,libtype,libpair,lstatus) values ('$sample\_LIB1','mtDNA','mtDNA; entry generated automatically',8,2,'sequenced');"; # ON DUPLICATE KEY UPDATE lid=LAST_INSERT_ID(lid);";
		#print "$sql\n";
		$dbh->do($sql) || die print "$DBI::errstr";
		my $lid = $dbh->last_insert_id(undef, undef, qw(library lid)) or die $DBI::errstr;
		
		#insert sample2library
		$sql = "insert into solexa.sample2library (idsample,lid) values ($idsample,$lid);";# ON DUPLICATE KEY UPDATE idsample2library=LAST_INSERT_ID(idsample2library);";
		#print "$sql\n";
		$sth = $dbh->prepare($sql) || die "Can't prepare statement: $DBI::errstr";
		$sth->execute() || die $DBI::errstr;
		
		#add library to pool
		$sql = "insert into solexa.library2pool (idpool,lid) values ($idpool,$lid);";# ON DUPLICATE KEY UPDATE idlibrary2pool=LAST_INSERT_ID(idlibrary2pool);";
		#print "$sql\n";
		$sth = $dbh->prepare($sql) || die "Can't prepare statement: $DBI::errstr";
		$sth->execute() || die $DBI::errstr;
	}
	if ($insertPool == 1) {
		print "No sample names found. Nothing done.";
		exit;
	}
	
	# Commit
	my $sql="COMMIT;";
	$dbh->do($sql) || die print "$DBI::errstr";
}

sub insertPoolAndRun {
	my $dbh      = shift;
	my $flowcell = shift;
	my $rundate  = shift;

    	#create pool / run / lane. if exist, just get their ids.

	#create pool
	my $sql = "insert into solexa.pool (oname,odescription,omenuflag,olanestosequence) values ('mtDNA_$flowcell','mtDNA pool; entry generated automatically','T','1') ON DUPLICATE KEY UPDATE idpool=LAST_INSERT_ID(idpool);";
	my $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	my $idpool = $dbh->last_insert_id(undef, undef, qw(pool idpool)) or die $DBI::errstr;
		
	#create run
	$sql = "insert into solexa.run (rname,rcomment,rdate, rdaterun) values ('$flowcell','mtDNA MiSeq flowcell', '$rundate', '$rundate' ) ON DUPLICATE KEY UPDATE rid=LAST_INSERT_ID(rid);";
	$dbh->do($sql) || die print "$DBI::errstr";
	my $idrun = $dbh->last_insert_id(undef, undef, qw(run rid)) or die $DBI::errstr;
	
	#create lane
	$sql = "insert into solexa.lane (alane,rid,idpool) values (1,$idrun,$idpool) ON DUPLICATE KEY UPDATE aid=LAST_INSERT_ID(aid);";
	$dbh->do($sql) || die print "$DBI::errstr";
	
	return $idpool;
}

########################################################################
# importSamples called by importSamplesDo.pl
########################################################################

sub importSamples {
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
my $date        = &actualDate;
my $withbarcodeflag = $ref->{withbarcode};

%assignment=
(
"Sample ID"                 => "name",
"Foreign ID"                => "foreignid",
"Pedigree"                  => "pedigree",
"Comment"                   => "scomment",
"Sex"                       => "sex",
"Affected"                  => "saffected",
"Disease"                   => "iddisease",
"Concentration (ng/ul)"     => "snanodrop",
"Volume (ul)"               => "volume",
"A260/280"                  => "a260280",
"A260/230"                  => "a260230",
"Barcode"                   => "sbarcode",
"Plate"                     => "splate",
"Row"                       => "srow",
"Column"                    => "scolumn",
"Analysis"                  => "analysis",
"Cooperation"               => "idcooperation",
"Project"                   => "idproject",
"Organism"                  => "idorganism",
"Tissue"                    => "idtissue",
"Accounting"                => "accounting",
);

$i = 0;
if ($file ne "") {
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		if (/^\s*$/) {next;}
		s/\"//g;
		$line = $_;
		print "<tr>";
		print "$line<br>";
		if ($i == 0) {
			(@labels) = split(/\,/,$line);
			for $j (0..$#labels) {
				if (!exists($assignment{$labels[$j]})) {
					print "<td>Wrong column label $labels[$j]?<br>";
					exit(1);
				}
				$labels[$j]=$assignment{$labels[$j]};
			}
			&check_labels;
		}
		else {	
			(@values) = split(/\,/,$line);
			&intodb($i-1,$withbarcodeflag);
		}
		$i++;
		print "</tr>";
	}
}




sub check_labels {
	my %labels = ();
	# check if all values of assignment are keys of values, 
	for $i (0..$#labels) {
		$labels{$labels[$i]}=$labels[$i];
	}
	foreach (keys %assignment) {
		if (!exists($labels{$assignment{$_}})) {
			print "Error: Column '$_' missing.<br>";
			exit(1);
		}
	}
}

sub intodb { #library and pool
	my $ntag        = shift;
	$withbarcodeflag= shift;
	my $sql         = "";
	my $sth         = "";
	my %values      = ();
	my $field       = "";
	my $value       = "";
	my @fields2     = ();
	my $tmp         = "";
	my $idsample    = "";
	my $iddisease   = "";
	my $diseasename = "";

	# convert arrays label and values in hash
	for $i (0..$#labels) {
		$values{$labels[$i]}=$values[$i];
	}
	$values{'name'}=uc($values{'name'});
	$values{'name'}=~s/\s+/\_/g;
	$values{'pedigree'}=~s/\s+/\_/g;
	$values{'foreignid'}=~s/\s+/\_/g;
	if ($values{'name'} !~ /^[a-zA-Z0-9]*$/) {
		print "$values{'name'} contains non-alphanumeric characters.\n";
		exit(1);
	}
	
	if ($values{'name'} eq "") {
		print "Sample ID missing.<br>";
		exit(1);
	}
	if ($withbarcodeflag eq "T") {
	if ($values{'sbarcode'} eq "") {
		print "Barcode missing.<br>";
		exit(1);
	}
	else {
		if (length($values{'sbarcode'})<10) {
			$values{'sbarcode'} = substr("0000000000",0,10-length($values{'sbarcode'})) . $values{'sbarcode'};
			print "Warning: Barcode $values{'sbarcode'} less than 10 characters. Leading zero added.<br>";
		}
	}
	}
	else {
		$values{'sbarcode'} = undef;
	}
	#if ($values{'iddisease'} eq "") {
	#	print "Disease missing.<br>";
	#	exit(1);
	#}
	if ($values{'idcooperation'} eq "") {
		print "Cooperation missing.<br>";
		exit(1);
	}
	if ($values{'idproject'} eq "") {
		print "Project missing.<br>";
		exit(1);
	}
	if ($values{'idorganism'} eq "") {
		print "Organism missing.<br>";
		exit(1);
	}
	if ($values{'snanodrop'} ne "") {
		unless ($values{'snanodrop'} =~ /^(\d+\.?\d*|\.\d+)$/) {
			print "Nonodrop is not a number.<br>";
			exit(1);
		}
	}
	if ($values{'snanodrop'} ne "") {
		unless ($values{'volume'} =~ /^(\d+\.?\d*|\.\d+)$/) {
			print "Volume is not a number.<br>";
			exit(1);
		}
	}
	if ($values{'a260280'} ne "") {
		unless ($values{'a260280'} =~ /^(\d+\.?\d*|\.\d+)$/) {
			print "A260/280 is not a number.<br>";
			exit(1);
		}
	}
	if ($values{'srow'} ne "") {
		unless ($values{'srow'} =~ /[ABCDEFGH]/) {
			print "Wrong row.<br>";
			exit(1);
		}
	}
	if ($values{'scolumn'} ne "") {
		if (length($values{'scolumn'})<10) {
			$values{'scolumn'} = substr("00",0,2-length($values{'scolumn'})) . $values{'scolumn'};
			print "Warning: Columns $values{'scolumn'} less than 2 characters. Leading zero added.<br>";
		}
		unless ($values{'scolumn'} =~ /(01|02|03|04|05|06|07|08|09|10|11|12)/) {
			print "Wrong column.<br>";
			exit(1);
		}
	}
	#if (($values{sex} ne "male") and ($values{sex} ne "female") 
	#	and ($values{sex} ne "unknown")) {
	#	print "Sex 'male', 'female' or 'unknown'.<br>";
	#	exit(1);
	#}
	if (($values{analysis} ne "other") and ($values{analysis} ne "exome")) {
		print "Analysis 'exome' or 'other'.<br>";
		exit(1);
	}
	#if (($values{saffected} != 0) and ($values{saffected} != 1) 
	#	and ($ref->{Affected} != 2)) {
	#	print "Affected 1 for affected, 0 for unaffected, and  2 for unkown.<br>";
	#	exit(1);
	#}

	# check foreign ID
	$sql = "SELECT foreignid FROM sample
		WHERE foreignid = '$values{foreignid}'",
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$tmp = $sth->fetchrow_array;
	if ($tmp ne "") {
		print "<b>Warning: ForeignID $values{foreignid} already in database.</b><br>.";
		#exit();
	}
	
	# Get cooperation
	$sql = "SELECT idcooperation FROM cooperation
		WHERE name = '$values{idcooperation}'",
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$tmp = $sth->fetchrow_array;
	if ($tmp eq "") {
		print "Cooperation not in database.<br>.";
		exit();
	}
	$values{idcooperation}=$tmp;
	
	# Get project
	$sql = "SELECT idproject FROM project
		WHERE pdescription = '$values{idproject}'",
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$tmp = $sth->fetchrow_array;
	if ($tmp eq "") {
		print "Project not in database.<br>.";
		exit();
	}
	$values{idproject}=$tmp;

	# Get organism
	$sql = "SELECT idorganism FROM organism
		WHERE orname = '$values{idorganism}'",
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$tmp = $sth->fetchrow_array;
	if ($tmp eq "") {
		print "Organism not in database.<br>.";
		exit();
	}
	$values{idorganism}=$tmp;

	# Get tissue
	$sql = "SELECT idtissue FROM tissue
		WHERE name = '$values{idtissue}'",
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$tmp = $sth->fetchrow_array;
	if ($tmp eq "") {
		print "Tissue not in database.<br>.";
		exit();
	}
	$values{idtissue}=$tmp;

	# Check if sample name already exists
	$sql = "SELECT name FROM sample
		WHERE name = '$values{name}'",
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$tmp = $sth->fetchrow_array;
	if ($tmp ne "") {
		print "Sample name already in database.<br>.";
		exit();
	}
	$values{entered} = $date;
	$values{user}    = $iduser;
	
	# Get disease
	if ($values{'iddisease'} ne "") {
		$diseasename=$values{'iddisease'};
		delete($values{iddisease});
	}
	# into sample
	my @fields    = sort keys %values;
	my @values    = @values{@fields};
	#print join("<td></td>",@values);
	foreach $field (@fields) {
		$value=$field . " = ?";
		push(@fields2,$value);
	}
	#print "@fields<br>";
	#print "@values<br>";
	$sql = sprintf "INSERT INTO sample (%s) VALUES (%s)",
        	join(",", @fields), join(",", ("?")x@fields);
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	print "$sql<br>";
	$sth->execute(@values) || die print "$DBI::errstr";
	$idsample=$sth->{mysql_insertid};

	# Get disease
	if ($diseasename ne "") {
	$sql = "SELECT iddisease FROM disease
		WHERE name = '$diseasename'",
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute() || die print "$DBI::errstr";
	$tmp = $sth->fetchrow_array;
	if ($tmp eq "") {
		print "Disease not in database.<br>.";
		exit();
	}
	$iddisease=$tmp;
	}
	
	# into disease2sample
	if ($iddisease ne "") {
		if ($iddisease eq "") {
			print "Error: ExomeDB not present!";
			exit(1);
		}
		$sql = "
			INSERT INTO disease2sample
			(iddisease2sample,iddisease,idsample)
			VALUES
			('','$iddisease','$idsample')
			";
		#print "sql $sql<br>";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute() || die print "$DBI::errstr";
	}
}

}
########################################################################
# importSamplesExternal called by importSamplesExternalDo.pl
########################################################################


sub importSamplesExternal {
my $self        = shift;
my $dbh         = shift;
my $ref         = shift;
my $file	= shift;
my $line        = "";
my $i           = 0;
my $j           = 0;
my @labels      = ();
my @slice       = ();
my @values      = ();
my %assignment  = ();
my @row         = ();
my @tag         = ();
my $date        =&actualDate;

#my $file          = $ref->{file};
my $analysis      = $ref->{'analysis'};
my $idcooperation = $ref->{'s.idcooperation'};
my $idproject     = $ref->{'s.idproject'};
my $createlibrary = 1; # ( $ref->{createlibrary} eq "yes" ? 1 : 0 );
my $fileextension = $ref->{'fileextension'};
my $filesinstagingarea = ( $ref->{'filesinstagingarea'} eq "T" ? 1 : 0 );
	my $commandMoveOutOfStagingArea = ""; 
my $allowexisting = ( $ref->{'allowexisting'} eq "T" ) ? 1 : 0;

my $projcoopinsamplesheet = ( $ref->{'projcoopinsamplesheet'} eq "T" ) ? 1 : 0;
my $trioinfoinsamplesheet = ( $ref->{'trioinfoinsamplesheet'} eq "T" ) ? 1 : 0;

my $externalseqidlocation = ( $ref->{'externalseqidlocation'} );

my $simulatedimport = ( $ref->{'simulateimport'} eq "T" ? "1" : 0 );
   $simulatedimport = ( $filesinstagingarea ? "1" : $simulatedimport );


print "Allow existing samples: $allowexisting<br>File extension: $fileextension<br>Project and Cooperation in Samplesheet: $projcoopinsamplesheet<br>External Sequencing Center ID: $externalseqidlocation<br>";
print "<b>Simulated import</b>" if $simulatedimport;

# Library creation auxiliaries
my $libextens="LIB1";


# Standard fields:
%assignment=
(
	"Sample ID"                 => "name",
	"Foreign ID"                => "foreignid",
	"Pedigree"                  => "pedigree",
	"Comment"                   => "scomment",
	"Sex"                       => "sex",
	"Affected"                  => "saffected",
	"Organism"                  => "idorganism",
	"Tissue"                    => "idtissue",
	"Disease"                   => "iddisease",
	"Library Type"              => "libtype",
	"Read Type"                 => "readtype",
	"Exome Assay"               => "exomeassay"
	#"Concentration (ng/ul)"     => "snanodrop",
	#"Volume (ul)"               => "volume",
	#"A260/280"                  => "a260280",
	#"Barcode"                   => "sbarcode",
	#"Plate"                     => "splate",
	#"Row"                       => "srow",
	#"Column"                    => "scolumn",
	#"Analysis"                  => "analysis",
	#"Cooperation"               => "idcooperation",
	#"Project"                   => "idproject",
);


# Append extra values to samplesheet hash according to version:

if ( $projcoopinsamplesheet )
{
	$assignment{"Cooperation"} = "idcooperation";
	$assignment{"Project"}	   = "idproject";
}

if ( $trioinfoinsamplesheet )
{
	$assignment{'Foreign ID Father'} = "foreignidfather";
	$assignment{'Foreign ID Mother'} = "foreignidmother"; 
}

if ( $externalseqidlocation eq "samplesheet" )
{
	$assignment{"External ID"} = "externalseqid";
}
elsif ( $externalseqidlocation eq "filename" )
{
	if ( $fileextension eq "" )
	{
		print "<td>External sequencing center ID cannot be inferred from filenames if you allow for samples to be created without files being imported</td>"; exit(1);
	} 
}



# Load all samples in a transaction, if something fail, fail.
my $sql="START TRANSACTION;";
$dbh->do($sql) || die print "$DBI::errstr";

my %trioinfo;
my $triocount=0;

my %insertedsamples;
my %gender;

$i = 0;
if ($file ne "") {

	print "<br><br><b>Inserting samples</b>";
	print "<table>";
	while  (<$file>) {
		s/\015\012|\015|\012/\n/g; #change operating system dependent newlines to \n
		chomp;
		if (/^\s*$/) {next;}
		#s/\"//g;
		$line = $_;
		print "<tr>";
		if ($i == 0) {
			print "<td>#</td><td><b>Sample</b></td>";
			(@labels)=quotewords(',', 1, $line);
			for $j (0..$#labels) {
				$labels[$j] =~ s/\"//g;
				$labels[$j] =~ s/^\s+|\s+$//g;
				if (!exists($assignment{$labels[$j]})) {
					print "<td>Wrong column label $labels[$j]?<br>";
					exit(1);
				}
				$labels[$j]=$assignment{$labels[$j]};
			}
			&check_labels_external;
		}
		else {	
			print "<td>$i</td><td>";
			#print "<br>$line<br>";
			(@values) = quotewords(',', 1, $line);
			for $j (0..$#values) {
				$values[$j] =~ s/\"//g;
				$values[$j] =~ s/^\s+|\s+$//g;
			}
			&intodb_external($i-1);
			print "</td>";
		}
		$i++;
		print "</td></tr>";
	}

	print "</table>";


	if ( $trioinfoinsamplesheet )
	{
		&intodb_trio();
	}

}

# If no exit event : commit transaction
#my $sql="commit;";
$sql="commit;"; 
$sql="rollback;" if ( $simulatedimport );
$dbh->do($sql) || die print "$DBI::errstr";

print "<br><b>Import successful!</b><br>" if (! $simulatedimport );

if ( $filesinstagingarea )
{
	print "<br><br><b>Command lines to move files out of staging area</b><pre>$commandMoveOutOfStagingArea</pre>";
	print "<br><b>ALL SETTLED:</b> You can proceed to import<br>" if ( $commandMoveOutOfStagingArea eq "" ); 
}

# If no error and library insertion is selected, give command


	#Sub-subs...
	sub check_labels_external {
		my %labels = ();
		# check if all values of assignment are keys of values, 
		for $i (0..$#labels) {
			$labels{$labels[$i]}=$labels[$i];
		}
		foreach (keys %assignment) {
			if (!exists($labels{$assignment{$_}})) {
				print "Error: Column '$_' missing.<br>";
				exit(1);
			}
		}
	}

	
	sub intodb_external { #library and pool
		my $ntag        = shift;
		my $sql         = "";
		my $sth         = "";
		my %values      = ();
		my $field       = "";
		my $value       = "";
		my @fields2     = ();
		my $tmp         = "";
		my $idsample    = "";
		my $iddisease   = "";
		my $diseasename = "";

		# If Library prepared in lab sample might exist - if $allowexisting == 1 
		my $sampleexists = 0;

		# convert arrays label and values in hash
		for $i (0..$#labels) {
			$values{$labels[$i]}=$values[$i];
		}
		$values{'name'}=uc($values{'name'});
		$values{'name'}=~s/\s+/\_/g;
		$values{'pedigree'}=~s/\s+/\_/g;
		$values{'foreignid'}=~s/\s+/\_/g;
		if ($values{'name'} !~ /^[a-zA-Z0-9_-]*$/) {
			print "$values{'name'} contains non-alphanumeric characters.\n";
			exit(1);
		}

		print "<b>".$values{'name'}."</b><br>";
		print "Foreign ID: ".$values{'foreignid'}."<br>";

		my $father="";
		my $mother="";

		if ( $trioinfoinsamplesheet)
		{			
			$father=$values{'foreignidfather'};
				$father=~s/\s+/\_/g;
				delete $values{'foreignidfather'};

			$mother=$values{'foreignidmother'};
			$mother=~s/\s+/\_/g;
				delete $values{'foreignidmother'};
		}

		# Analysis type (legacy value) - automatic recognition if selected:
		if ($analysis eq "auto")
		{
			if ( $values{'libtype'} eq "exomic" )
			{
				$analysis="exome";
			}
			else
			{
				$analysis="other";
			}
		}
		$values{'analysis'}=$analysis;

		
		if ($values{'name'} eq "") {
			print "Sample ID missing.<br>";
			exit(1);
		}

		if (($values{'idcooperation'} eq "") && ( $projcoopinsamplesheet)) {
			print "Cooperation missing.<br>";
		#	exit(1);
		}
		if (($values{'idproject'} eq "") && ( $projcoopinsamplesheet)) {
			print "Project missing.<br>";
		#	exit(1);
		}
		if ($values{'idorganism'} eq "") {
			print "Organism missing.<br>";
			exit(1);
		}
		if (($values{analysis} ne "other") and ($values{analysis} ne "exome")) {
			print "Analysis 'exome' or 'other'.<br>";
			exit(1);
		}
	
	
		my ($tmpidproject, $tmpprojectname, $tmpidcooperation);
	
		if ( $projcoopinsamplesheet ) {
			# Proj / Coop from Samplesheet
			# Get project
			$sql = "SELECT idproject, pname, idcooperation FROM project
				WHERE pdescription = '$values{idproject}'",
			$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
			$sth->execute() || die print "$DBI::errstr";
			($tmpidproject, $tmpprojectname, $tmpidcooperation) = $sth->fetchrow_array;
			if ($tmpidproject eq "") {
				print "Project not in database.<br>.";
				exit();
			}
			$values{idproject}=$tmpidproject;

			# If no cooperation provided, pick the default cooperation 
			if ( $values{idcooperation} eq "" ) {
				if ( $tmpidcooperation eq "" || $tmpidcooperation eq "NULL" )
				{
					print "Please specify cooperation or set default cooperation for project.<br>.";
					exit();	
				}
				$values{idcooperation}=$tmpidcooperation;
			
			}
			else
			{
				# TODO: POTENTIAL error where two surnames are equal
				# Get cooperation
				$sql = "SELECT idcooperation FROM cooperation
					WHERE name = '$values{idcooperation}'",
				$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
				$sth->execute() || die print "$DBI::errstr";
				$tmp = $sth->fetchrow_array;
				if ($tmp eq "") {
					print "Cooperation not in database.<br>.";
					exit();
				}
				$values{idcooperation}=$tmp;
				}
		
		}
		else
		{
			# Proj / Coop from FORM POST
						
			$values{'idcooperation'}=$idcooperation;
			$values{'idproject'}=$idproject;	
			
			# Get project
			$sql = "SELECT idproject, pname FROM project
				WHERE idproject = '$values{idproject}'",
			$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
			$sth->execute() || die print "$DBI::errstr";
			($tmpidproject, $tmpprojectname) = $sth->fetchrow_array;
			if ($tmpidproject eq "") {
				print "Project not in database.<br>.";
				exit();
			}
			$values{idproject}=$tmpidproject;

	
			# Get cooperation
			$sql = "SELECT idcooperation FROM cooperation
				WHERE idcooperation = '$values{idcooperation}'",
			$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
			$sth->execute() || die print "$DBI::errstr";
			$tmp = $sth->fetchrow_array;
			if ($tmp eq "") {
				print "Cooperation not in database.<br>.";
				exit();
			}
			$values{idcooperation}=$tmp;
			
		}

		if ( $externalseqidlocation eq "none" )
		{
			$values{externalseqid}="";
		}
			
		
		# Get organism
		$sql = "SELECT idorganism FROM organism
			WHERE orname = '$values{idorganism}'",
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute() || die print "$DBI::errstr";
		$tmp = $sth->fetchrow_array;
		if ($tmp eq "") {
			print "Organism not in database.<br>.";
			exit();
		}
		$values{idorganism}=$tmp;

		# Get tissue
		$sql = "SELECT idtissue FROM tissue
			WHERE name = '$values{idtissue}'",
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute() || die print "$DBI::errstr";
		$tmp = $sth->fetchrow_array;
		if ($tmp eq "") {
			print "Tissue not in database.<br>.";
			exit();
		}
		$values{idtissue}=$tmp;

		# Check if sample name already exists
		$sql = "SELECT name FROM sample
			WHERE name = '$values{name}'",
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute() || die print "$DBI::errstr";
		$tmp = $sth->fetchrow_array;
		if ($tmp ne "") {
			if ( $allowexisting == 0 )
			{
				print "Sample name ".$values{name}." already in database.<br>.";
				exit();
			}
			else
			{
				print "WARN: Sample ".$values{name}." exists: going on<br>";
				$sampleexists=1;
			}
		}

		# Check that the existing sample has not been analyzed
		$sql = "SELECT name FROM sample
                        WHERE name = '$values{name}' and not( sbam='' or sbam is null ) ";
                $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
                $sth->execute() || die print "$DBI::errstr";
                $tmp = $sth->fetchrow_array;
                if ($tmp ne "") {
                	print "Sample name ".$values{name}." has been analyzed already. Cannot import data on it.<br>.";
                        exit();
                }


		$values{entered} = $date;
		$values{user}    = $iduser;
	
		# Get disease
		if ($values{'iddisease'} ne "") {
			$diseasename=$values{'iddisease'};
			delete($values{iddisease});
		}
		
		# Get Lib details
		my $assay=$values{'exomeassay'};
			delete($values{'exomeassay'});
		my $libtype=$values{'libtype'};
			delete($values{'libtype'});
		my $libpair=$values{'readtype'};
			delete($values{'readtype'});
		
		# into sample
		my @fields    = sort keys %values;
		my @values    = @values{@fields};
		#print join("<td></td>",@values);
		foreach $field (@fields) {
			$value=$field . " = ?";
			push(@fields2,$value);
		}
		#print "@fields<br>";
		#print "@values<br>";

		if ( $sampleexists )
		{
			$sql = "SELECT idsample FROM sample where name = '$values{name}'";
			$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	        	$sth->execute() || die print "$DBI::errstr";
        		$idsample = $sth->fetchrow_array;
			if ( $idsample eq "" ) 
			{
				print ("Something happened processing sample ".$values{name}.". It might have been deleted. Please retry.\n");
				exit();
			}
		}
		else
		{
			$sql = sprintf "INSERT INTO sample (%s) VALUES (%s)",
			 join(",", @fields), join(",", ("?")x@fields);
			$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	                #print "$sql<br>";

			$sth->execute(@values) || die print "$DBI::errstr";
			$idsample=$sth->{mysql_insertid};
		}

		print "Project ID: ".$tmpprojectname." (".$values{'idproject'}.") - Cooperation ID: ".$values{'idcooperation'}."<br>";

		# Get disease
		if ($diseasename ne "") {
			#$exomedb = &exomedb($dbh,$idsample);
			$sql = "SELECT iddisease FROM disease
				WHERE name = '$diseasename'",
			$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
			$sth->execute() || die print "$DBI::errstr";
			$tmp = $sth->fetchrow_array;
			if ($tmp eq "") {
				print "Disease not in database.<br>.";
				exit();
			}
			$iddisease=$tmp;
		}
	
		# into disease2sample
		if ($iddisease ne "") {
			#$exomedb = &exomedb($dbh,$idsample);
			if ($iddisease eq "") {
				print "Error: ExomeDB not present!";
				exit(1);
			}
			$sql = "
				INSERT IGNORE INTO disease2sample
				(iddisease,idsample)
				VALUES
				('$iddisease','$idsample')
				";
			#print "sql $sql<br>";
			$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
			$sth->execute() || die print "$DBI::errstr";
		}

		# Check if sample files have been placed correctly (here because i have to check anyway all the rest before and i have to get the project name)
		# External base path: $extFilesBasePath    -  Staging Base Path  $extFilesBasePathStaging

		my $samplename=$values{'name'};
		my $foreignid=$values{'foreignid'};
		my $externalSamplesDir="$extFilesBasePath/$tmpprojectname"; 
		
		#TW 30.03.2016: changed "glob" to find because fastq files can be in sub folders
		
		my $bams = "";			#File list
		my $nameinfiles = "";		#Sample name ( foreign id or sample name ) found in files
		my $externalseqidinfiles = "";	#External seqcenter ID if found in files

		if($fileextension && $fileextension ne "" && $demo == 0) {
			
			my $foreignidsearch = $foreignid eq "" ? $samplename : $foreignid;

			# If files in Staging area they must be 
			if ( $filesinstagingarea ){

				my @bamsStaging;
				my $fileDestinationBase = "$externalSamplesDir/$samplename/";

				open IN,"find $extFilesBasePathStaging -name \"*$foreignidsearch\_*$fileextension\" | sort |";
				while(<IN>){
					chomp;
					push(@bamsStaging, $_);
				}
	
				if ( (scalar @bamsStaging ) == 0 ) 
				{
					my $tmp = $values{'name'};
					open IN,"find $extFilesBasePathStaging -name \"*$tmp\_*$fileextension\" | sort |";
					while(<IN>){
						chomp;
						push(@bamsStaging, $_);
					}
				}

				my $command = "";
				foreach my $bam ( @bamsStaging ){

					$command .= "mv $bam $fileDestinationBase;\n";

				}

				if ( $command ne "" ){
					# Execute: 
					$command = "#Sample $samplename\nmkdir -p $fileDestinationBase;\n".$command;
					print "Required to move files from staging area to $fileDestinationBase:<br>&nbsp;&nbsp;".join("<br>&nbsp;&nbsp;", @bamsStaging)."<br>";
					#print "<br>$command<br>";
					$commandMoveOutOfStagingArea.=$command;
				}

			}
			else
			{

				open IN,"find $externalSamplesDir -name \"*$foreignidsearch\_*$fileextension\" | sort |";
				while(<IN>){
					chomp;
					$bams .= $_.",";
				}
				$bams =~ s/,$//;
				$nameinfiles="$foreignidsearch";

				if ( $bams eq "" ) 
					{
					my $tmp = $values{'name'};
					open IN,"find $externalSamplesDir -name \"*$tmp\_*$fileextension\" | sort |";
					while(<IN>){
						chomp;
						$bams .= $_.",";
					}
					$bams =~ s/,$//;
					# 
					$nameinfiles="$tmp";
				
					if ( $bams eq "" ) {
						print "$foreignid files expected in path $externalSamplesDir\n";
						exit(1);
					}
				}

				# Extract external sequencing center ID from filenames: expected SAMPLEID_EXTERNALSEQID[._]* or FOREIGNID_EXTERNALSEQID[._]*
				if ( $externalseqidlocation eq "filename" )
				{
					my @tmp_bams = split (",", $bams);
					my $tmpname="";
					foreach my $tmp_bam ( @tmp_bams )
					{
						#print "$tmp_bam || ";
						$tmp_bam=basename($tmp_bam);

						my @tmp_items = split("[_\.]", $tmp_bam);
						if ( defined $tmp_items[1] )
						{
							$values{externalseqid}=$tmp_items[1];

							#Check that it's consistent
							if ( $tmpname ne "" && ( $tmpname ne $values{externalseqid} ) )
							{
								print "<td>External Seq ID inconsistent across same sample $samplename</td>"; 
								exit(1);
							}

							$tmpname=$values{externalseqid};

							#print "&nbsp;&nbsp;$tmpname<br>";

						}
						else
						{
							print "<td>Filename format unexpected, should contain SAMPLEID_EXTERNALSEQCENTERID_*</td>";
							exit(1);
						}
					}
				}

				my @bamlist=split(",",$bams);
				print "Files: <br>";
				foreach my $bam ( @bamlist)
				{
					print "&nbsp;&nbsp;&nbsp;&nbsp;".$bam."<br>";
				}
			}
		}


		# Update external sequencing ID if applicable
		if ( $externalseqidlocation ne "none" )
		{
			if ( $values{externalseqid} ne "" )
			{
				$sql = "UPDATE sample SET externalseqid=\"".$values{externalseqid}."\" where name=\"".$samplename."\"";
				$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	        	        #print "$sql<br>";
				$sth->execute() || die print "$DBI::errstr";
				print "External sequencing center ID: ".$values{externalseqid}."<br>";
			}
		
		}

		# Create library:
		# RB:20180511 changed foreignid to samplename to create library names: potential problems otherwise. values ('$samplename\_$libextens'
		$sql = "insert into $solexa.library (lname,lcomment,libtype,libpair,lstatus,idassay,lextfilepath) values ('$samplename\_$libextens','external library; entry generated automatically',(select ltid from $solexa.libtype where ltlibtype='$libtype'),(select lpid from $solexa.libpair where lplibpair='$libpair'),'external',(select idassay from $solexa.assay where name='$assay'),'$bams')";

		if ( $allowexisting )
		{
			$sql.= " ON DUPLICATE KEY UPDATE lstatus='external', lextfilepath='$bams'"; 
		}

		$dbh->do($sql) || die print "$DBI::errstr";
				
		# Connect library entry and sample
		my $lid = $dbh->last_insert_id(undef, undef, "$solexa.library", "lid") or die $DBI::errstr;
		$sql = "insert ignore into $solexa.sample2library (idsample,lid) values ($idsample,$lid);";
 		$dbh->do($sql) or die $DBI::errstr;

		#Sample is created along with its library. #NEXT sample

         	$sql = "SELECT * from $solexa.library where lid =$lid"; 
                $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
                $sth->execute() || die print "$DBI::errstr";
                my @vals = $sth->fetchrow_array;
		#print "LIB: "; foreach my $val (@vals){ print $val." | "; };print "<br>";
		print "Library name: ".$vals[1]."<br>";



		# If trio information provided in samplesheet then collect it for later insertion
		if ( $trioinfoinsamplesheet )
		{
			# Mother and father can be independently specified
			if ( $father ne "" ){
				$trioinfo{$values{'name'}}{'idsample'}=$idsample;
				$trioinfo{$values{'name'}}{'father'}=$father;
			}
			if ( $mother ne "" ){
				$trioinfo{$values{'name'}}{'idsample'}=$idsample;
				$trioinfo{$values{'name'}}{'mother'}=$mother;
			}
		}

		# Store idsample for trio insertion (both samplename and foreignid)
		$insertedsamples{$samplename}=$idsample;
			$gender{$samplename}=$values{'sex'};
		$insertedsamples{$foreignid}=$idsample if ( $foreignid ne "" );
			$gender{$foreignid}=$values{'sex'} if ( $foreignid ne "" );

	}

	sub intodb_trio { # Insert trio information

		print "<br><br><br><b>Inserting trios</b>";
		print "<table><tr><td><b>Index</b> (ID)</td><td>Father (ID)</td><td>Mother (ID)</td></tr>";

		foreach my $samplename ( keys %trioinfo )
		{

			my $idsample = $trioinfo{$samplename}{'idsample'};
			print "<tr>";
			print "<td><b>".$samplename."</b> ($idsample)</td>";
	
			print "<td>";		
			if ( defined $trioinfo{$samplename}{'father'} )
			{
				my $fathername = $trioinfo{$samplename}{'father'};
				my $fatherid = "";
					$fatherid = $insertedsamples{$trioinfo{$samplename}{'father'}} if defined $insertedsamples{$trioinfo{$samplename}{'father'}};
				if ( $fatherid eq "" ){
					print "</table><br>ERROR: check father data for sample $samplename<br>";
					exit(-1);
				}
				if ( $gender{$fathername} ne "male" ){
					print "</table><br>ERROR: father cannot be female for sample $samplename<br>";
					exit(-1);
				}

				print "$fathername (ID: $fatherid )";

				my $sql = "UPDATE sample SET father=".$fatherid." where idsample=".$idsample." and name='".$samplename."'";
				my $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
                		$sth->execute() || die print "$DBI::errstr";
			}

			print "</td><td>";
			if ( defined $trioinfo{$samplename}{'mother'} )
			{
				my $mothername = $trioinfo{$samplename}{'mother'};
				my $motherid = "";
					$motherid = $insertedsamples{$trioinfo{$samplename}{'mother'}} if defined $insertedsamples{$trioinfo{$samplename}{'mother'}};
				if ( $motherid eq "" ){
					print "</table><br>ERROR: check mother data for sample $samplename<br>";
					exit(-1);
				}
				if ( $gender{$mothername} ne "female" ){
					print "</table><br>ERROR: mother cannot be male for sample $samplename<br>";
					exit(-1);
				}

				print "$mothername (ID: $motherid )";

				my $sql = "UPDATE sample SET mother=".$motherid." where idsample=".$idsample." and name='".$samplename."'";
				my $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
                		$sth->execute() || die print "$DBI::errstr";
			}
			print "</td></tr>";

		}

		print "</table>";
	}

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
<table  border="1" cellspacing="0" cellpadding="2" class="display" id="example"> 
);

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
# tablescript
########################################################################
sub tablescript {

print q(
<script type="text/javascript" charset="utf-8">
$(document).ready(function() {
 var oTable = $('#example').dataTable({
 	"paginate":      true,
  	"lengthChange":  true,
	"filter":        true,
 	"sort":          true,
	"info":          true,
	"autoWidth":     false,
	"displayLength": -1,
	"lengthMenu":    [[-1, 100, 50, 25], ["All", 100, 50, 25]],
	"dom":           'Bfrtip',
	"select":         'multi',
	"buttons":       ['pageLength','csv'],
	"fixedHeader":    true
});
//oTable.fnAdjustColumnSizing(); 
//oTable.width("auto");
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
table.dataTable th { background-color: #efefef; }
</style>
);

}

########################################################################
# drawMask
########################################################################

sub drawMask {
my $self     = shift;
my $AoH      = shift;
my $mode     = shift;

my $href   = "";

print qq(
<table border="1" cellspacing="0" cellpadding="3">
);

my @tmp = @{$AoH}; #idsample and pedigree for selectdb mother and father
foreach $href (@{$AoH}) {
	if ($href->{type} eq 'readonly' ) {
		&readonly($href->{label},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'readonly2') {
		&text($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},'readonly');
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
		&selectdb($href->{label},$href->{name},$href->{value},$href->{bgcolor},$tmp[3]->{value},$tmp[0]->{value});
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

sub select1 {
	my $label    = shift;
	my $name     = shift;
	my $value    = shift;
	my $bgcolor  = shift;
	my @row      = ();
	my $row      = ();
	
	if ($name eq "srow") {
		@row = ("","A","B","C","D","E","F","G","H");
	}
	elsif  ($name eq "scolumn") {
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
	my $label    = shift;
	my $name     = shift;
	my $value    = shift;
	my $bgcolor  = shift;
	my $pedigree = shift;
	my $idsample = shift;
	my $sql      = "";
	my $sth      = "";
	my @row      = ();
	my ($dbh)    = &loadSessionId();
	my $htmltext = "";
	my $menuflag = "";
	
	if ($name eq "lstatus") {
		$sql = "SELECT lstatus,lstatus,lstatus
			FROM $solexa.library 
			WHERE lstatus != ''
			GROUP BY
			lstatus
			ORDER BY lstatus";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}

	if ($name eq "s.idcooperation") { # for search
		$sql = "SELECT idcooperation,name,concat(name,', ',prename)
			FROM cooperation
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "idcooperation") { # for insert
		$sql = "SELECT idcooperation,name,concat(name,', ',prename)
			FROM cooperation
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "idinvoice") { # for insert
		$sql = "SELECT idinvoice,my,my
			FROM invoice
			ORDER BY mydate DESC";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "analysis") { # for insert
		$sql = "SELECT analysis,analysis,analysis
			FROM sample
			GROUP BY
			analysis
			ORDER BY analysis";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if  ($name eq "ds.iddisease") { # for search
		$sql = "SELECT iddisease,name,name
			FROM disease
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "iddisease") { # for insert
		$sql = "SELECT iddisease,name,name
			FROM disease
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if (($name eq "idproject") or ($name eq "s.idproject")){ # for search
		$sql = "SELECT idproject,pmenuflag,CONCAT(pname,' - ',pdescription)
			FROM project
			ORDER BY pname DESC";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "iddiseasegroup") {
		$sql = "SELECT iddiseasegroup,name,name 
			FROM diseasegroup 
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if (($name eq "idorganism") or ($name eq "s.idorganism")) {
		$sql = "SELECT idorganism,ormenuflag,orname 
			FROM organism 
			ORDER BY orname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "libtype")  {
		$sql = "SELECT DISTINCT ltid,ltlibtype, ltlibtype
			FROM $solexa.libtype 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif (($name eq "idtissue") or ($name eq "ti.idtissue")) {
		$sql = "SELECT DISTINCT idtissue, menuflag, name
			FROM tissue 
			ORDER BY name;
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "father") {
	#print "pedigree $pedigree<br>";
		$sql = "SELECT idsample,idsample,CONCAT(pedigree,', ',name,', ',foreignid) 
			FROM sample
			WHERE sex='male' 
			AND pedigree='$pedigree'
			AND idsample!='$idsample'
			ORDER BY pedigree,name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "mother") {
		$sql = "SELECT idsample,idsample,CONCAT(pedigree,', ',name,', ',foreignid) 
			FROM sample
			WHERE sex='female' 
			AND pedigree='$pedigree'
			AND idsample!='$idsample'
			ORDER BY pedigree,name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	elsif ($name eq "idservice") {
		$sql = "SELECT DISTINCT idservice, menuflag, concat(name,', ', description)
			FROM service 
			WHERE menuflag=1
			ORDER BY name;
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
#	elsif (($name eq "uidreceived") or ($name eq "entered") or ($name eq "tentered") or 
#	($name eq "uid") or ($name eq "l.uid") or ($name eq "oentered") or ($name eq "buser")) {
#		$sql = "SELECT uid,umenuflag,CONCAT(uname,', ',uprename) 
#			FROM $solexa.user 
#			ORDER BY uname,uprename";
#		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
#		$sth->execute || die print "$DBI::errstr";
#	}
	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	<td  class="$bgcolor">
	);
	print"<select name=\"$name\">";	
	print "<option value =''> ";
	while (@row = $sth->fetchrow_array) {
		if ($row[0] eq $value) {
			print"<option selected value ='$row[0]'> $row[2]";
		}
		elsif ($row[1] ne 'F') { # das ist fuer die Flag-Felder
			print"<option value ='$row[0]'> $row[2]";
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
# printHeader
########################################################################

sub printHeader {
my $self        = shift;
my $background  = shift;
my $sessionid   = shift;
my $cgi         = new CGI;

unless ($sessionid eq "sessionid_created") {
	#print $cgi->header(-type=>'text/html',-charset=>'ISO-8859-1');
	print $cgi->header(-type=>'text/html',-charset=>'utf-8');
}

print qq(
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>ExomeEdit</title>
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
  <div class="subnav">Samples Libraries</div>
  <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
  <a href="searchSample.pl">Sample search</a>
  <a href="sample.pl">New sample</a>
  <a href="createLibraries.pl">Create libraries</a>
<div class="subnav">Diseases</div>
  <a href="disease.pl">New disease</a>
  <a href="listDisease.pl">List diseases</a>
<div class="subnav">Cooperations</div>
  <a href="cooperation.pl">New cooperation</a>
  <a href="listCooperation.pl">List cooperations</a>
<div class="subnav">Projects</div>
  <a href="project.pl">New project</a>
  <a href="listProject.pl">List projects</a>
<div class="subnav">Invoices</div>
  <a href="invoice.pl">New invoice</a>
  <a href="invoiceSearch.pl">Search invoices</a>
<div class="subnav">Sample sheet import</div>
  <a href="importSamples.pl">Import internal samples</a>
  <a href="importSamplesExternal.pl">Import external samples</a>
  <a href="importmtDNASamples.pl">Import mtDNA samples</a>
<div class="subnav">Statistics</div>
  <a href="overview.pl">Overview</a>
  <a href="statistics.pl">Statistics</a>
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
	$dbh = DBI->connect("DBI:mysql:$humanexomedb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
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
