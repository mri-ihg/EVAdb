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

$solexa->printHeader();
my ($dbh) = $solexa->loadSessionId();
my $search      = $solexa->initSearchProjects();
	
$solexa->showMenu("search");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchDo.pl\" method=\"post\" name=\"myform\">" ;

$solexa->drawMask($search);

print "</form>" ;

$solexa->printFooter($dbh);
