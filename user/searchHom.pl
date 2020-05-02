#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $snv         = new Snv;

$snv->printHeader();
$snv->loadSessionId();

my $search      = $snv->initSearchSample();
	
$snv->showMenu("searchHom");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchHomDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
