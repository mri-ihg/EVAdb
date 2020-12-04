#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}
use WWW::CSRF qw(generate_csrf_token check_csrf_token CSRF_OK);

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
my $ref          = $cgi->Vars;
my $snv          = new Snv;
my %options = ('MaxAge' => 10800); #for WWW::CSRF 3 hours, same as session cookie
#$ref = $snv->htmlencodehash($ref);
my ($dbh) = "";

my $item  = "";
my $value = "";
my %logins = ();
open(IN, "/srv/tools/textreadonly.txt");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$logins{$item}=$value;
}
close IN;
my $csrfsalt = $logins{'csrfsalt'};

if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token('test', $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);

if (($ref->{name} eq '' or $ref->{password} eq '')) {
	$snv->printHeader();
	($dbh) = $snv->loadSessionId();
}
else {
	($dbh) = $snv->createSessionId($ref);
}

$snv->printFooter($dbh);
