#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Snv;

my $snv         = new Snv;
my $search      = $snv->initSearchRnaStat();

$snv->printHeader();
$snv->loadSessionId();

my $search      = $snv->initSearchRnaStat();
	
$snv->showMenu("searchRnaStat");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchRnaStatDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
