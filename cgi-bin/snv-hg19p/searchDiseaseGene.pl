#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $sname       = $cgiquery->param('sname');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$sname          = $snv->htmlencode($sname);
my $search      = $snv->initSearchDiseaseGene($sname,$dbh);
	
$snv->showMenu("searchDiseaseGene");
print "<span class=\"big\">Disease panels</span><br><br>" ;

print "<form action=\"searchDiseaseGeneDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
