#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $sample      = $cgiquery->param('sample');
my $pedigree    = $cgiquery->param('pedigree');
my $autosearch  = $cgiquery->param('autosearch'); 

my $search      = $snv->initSearchStatistics($sample,$pedigree,$autosearch);

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();
	
$snv->showMenu("searchStat");
print "<span class=\"big\">Samples with quality checks</span><br><br>" ;

print "<form action=\"searchStatDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);

if ( (defined($sample) || defined($pedigree)) && defined($autosearch)  ){ print "<script>window.onload = function(){ document.forms['myform'].submit();}</script>";}
