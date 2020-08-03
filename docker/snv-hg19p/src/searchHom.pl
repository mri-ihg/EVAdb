#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

my $search      = $snv->initSearchSample();
	
$snv->showMenu("searchHom");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchHomDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
