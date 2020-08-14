#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my $snv          = new Snvedit;
my $dbh          = "";

if (($ref->{name} eq '' or $ref->{password} eq '')) {
	$snv->printHeader();
	($dbh) = $snv->loadSessionId();
}
else {
	($dbh) = $snv->createSessionId($ref);
}

$snv->printFooter($dbh);
