#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Snv;

my $snv         = new Snv;
my $search      = $snv->initSearchConclusion();

$snv->printHeader();
$snv->loadSessionId();
	
$snv->showMenu("searchConclusion");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchConclusionDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
