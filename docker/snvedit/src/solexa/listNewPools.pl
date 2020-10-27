#!/usr/bin/perl 

########################################################################
# Tim M Strom   May 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}
use DBI;

my $solexa     = new Solexa;
my $cgiquery    = new CGI;

$solexa->printHeader();
my ($dbh) = $solexa->loadSessionId();

$solexa->showMenu("listnewpools");
print "<span class=\"big\">New Pools</span><br><br>" ;

$solexa->listNewPools($dbh);

print "</form>" ;

$solexa->printFooter($dbh);
