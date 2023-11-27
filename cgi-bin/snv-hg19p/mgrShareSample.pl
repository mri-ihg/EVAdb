#!/usr/bin/perl 

########################################################################
# Riccardo Berutti 2023
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $pedigree    = $cgi->param('pedigree');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$pedigree       = $snv->htmlencode($pedigree);
my $search      = $snv->initShareSample($pedigree);
	
$snv->showMenu("mgrShareSample");
#print "<span class=\"big\">Share Samples / Projects </span><br><br>" ;
$snv->pageTitle("Share samples / projects");

print "<form action=\"mgrShareSampleDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

print "<br><br><span class=\"big\">Active Shares<span><br><br>";


$snv->authorizationList($dbh);



$snv->printFooter($dbh);

