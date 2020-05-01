#!/usr/bin/perl

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $cgi = new CGI;
my $ref = $cgi->Vars;
my $snv = new Snv;

########################################################################
# main
########################################################################
$ref = $snv->htmlencodehash($ref);
my $burdentest = $ref->{burdentest};

if ($burdentest eq "0") {
	$snv->printHeader();
	my ($dbh) = $snv->loadSessionId(); 
	$snv->showMenu('searchDiseaseGene');
	print "<span class=\"big\">Search results</span><br><br>" ;
	$snv->searchResultsDiseaseGene($dbh,$ref);
	$dbh->disconnect;
	$snv->printFooter();
}
else { # because of fork no header
	my ($dbh) = $snv->loadSessionId();
	$snv->burden($dbh,$ref,$cgi);
}
