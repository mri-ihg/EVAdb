#!/usr/bin/perl 

########################################################################
# Tim M Strom   Oct 2013
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Snv;

my $snv         = new Snv;
my $cgi         = new CGI;
my $sname       = $cgi->param('sname');

$snv->printHeader();
$snv->loadSessionId();

$sname          = $snv->htmlencode($sname);
my $search      = $snv->initSearchCnv($sname);

$snv->showMenu("searchCnv");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchCnvDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
