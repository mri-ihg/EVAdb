#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $pedigree    = $cgi->param('pedigree');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$pedigree       = $snv->htmlencode($pedigree);
my $search      = $snv->initSearchDiffEx($pedigree);
	
$snv->showMenu("searchDiffEx");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchDiffExDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
