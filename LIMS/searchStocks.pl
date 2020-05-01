#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $solexa      = new Solexa;
my $cgiquery    = new CGI;
my $search      = $solexa->initSearchStocks();

$solexa->printHeader();
my $dbh=$solexa->loadSessionId();
	
$solexa->showMenu("searchstock");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchStocksDo.pl\" method=\"post\">" ;

$solexa->drawMask($search);

print "</form>" ;

$solexa->printFooter();
