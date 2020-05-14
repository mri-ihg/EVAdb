#!/usr/local/bin/perl -w

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my $snv          = new Solexa;

if (($ref->{name} eq '' or $ref->{password} eq '')) {
	$snv->printHeader();
	my $dbh=$snv->loadSessionId();
}
else {
	$snv->createSessionId($ref);
}

$snv->printFooter();
