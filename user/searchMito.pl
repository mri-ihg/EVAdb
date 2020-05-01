#!/usr/bin/perl 

########################################################################
# Tim M Strom   Juni 2010
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $pedigree    = $cgiquery->param('pedigree');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$pedigree       = $snv->htmlencode($pedigree);
my $search      = $snv->initSearchMito($pedigree,$dbh);
	
$snv->showMenu("searchMito");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchMitoDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
