#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;

my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);

$snv->showMenu();
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchResultsPositionVcf($dbh,$ref);


$snv->printFooter($dbh);
