#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my $solexa        = new Solexa;

########################################################################
# main
########################################################################

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

$solexa->showMenu('statistics');
#print "<span class=\"big\">Statistics</span><br><br>" ;

$solexa->searchErrorRate($dbh,$ref);


$solexa->printFooter($dbh);
