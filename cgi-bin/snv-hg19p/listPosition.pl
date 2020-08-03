#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgiquery     = new CGI;
my $snv          = new Snv;
my $ref          = $cgiquery->Vars;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);

$snv->showMenu();
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchResultsPosition2($dbh,$ref);


$snv->printFooter($dbh);
