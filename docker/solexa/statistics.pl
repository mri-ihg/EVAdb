#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session;
BEGIN {require './Solexa.pm';}

my $solexa      = new Solexa;
my $cgiquery    = new CGI;
my $statistics  = $solexa->initStatistics();

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

$solexa->showMenu("statistics");
print "<span class=\"big\">Statistics</span><br><br>" ;

print "<form action=\"statisticsDo.pl\" method=\"post\" name=\"myform\">" ;

$solexa->drawMask($statistics);

print "</form>" ;

$solexa->printFooter($dbh);
