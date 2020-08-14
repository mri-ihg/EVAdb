#!/usr/bin/perl 

########################################################################
# Tim M Strom   May 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $solexa     = new Solexa;
my $cgiquery    = new CGI;

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();
my $search      = $solexa->initSearchShopping();

$solexa->showMenu("shoppingsearch");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchShoppingDo.pl\" method=\"post\" name=\"myform\">" ;

$solexa->drawMask($search);

print "</form>" ;


$solexa->printFooter($dbh);
