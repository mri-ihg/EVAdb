#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();
my $search      = $snv->initSearchIbs();

	
$snv->showMenu("searchIbs");
print "<span class=\"big\">IBS</span><br><br>" ;

print "<form action=\"searchIbsDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
