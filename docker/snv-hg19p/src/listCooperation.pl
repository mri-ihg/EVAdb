#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgi          = new CGI;
my $ref          = $cgi->Vars;
my $snv          = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu("listCooperation");
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->listCooperation($dbh,$ref);


$snv->printFooter($dbh);
