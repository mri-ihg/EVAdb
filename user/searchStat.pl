#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $search      = $snv->initSearchStatistics();

$snv->printHeader();
$snv->loadSessionId();
	
$snv->showMenu("searchStat");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchStatDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
