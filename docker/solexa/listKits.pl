#!/usr/bin/perl

########################################################################
# Tim M Strom   Oct 2010
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;

my $snv          = new Solexa;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) =$snv->loadSessionId();

$snv->showMenu("listKits");
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->listKits($dbh,$ref);


$snv->printFooter($dbh);
