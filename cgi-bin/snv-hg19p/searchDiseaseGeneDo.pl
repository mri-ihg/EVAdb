#!/usr/bin/perl

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgi = new CGI;
my $ref = $cgi->Vars;
my $snv = new Snv;

########################################################################
# main
########################################################################
#$ref = $snv->htmlencodehash($ref);
my $burdentest = $ref->{burdentest};
my $iddisease = $ref->{"dg.iddisease"};
my $iddiseasegroup = $ref->{"dgr.iddiseasegroup"};


if ($burdentest eq "0") {
	$snv->printHeader();
	my ($dbh) = $snv->loadSessionId(); 
	$snv->showMenu('searchDiseaseGene');
	
	if ( $iddisease ne "" && $iddiseasegroup ne "" )
	{
		print "Select either Disease Gene list or Disease Group Gene list, not both<br>";
	}
	else
	{
		print "<span class=\"big\">Disease panels</span><br><br>" ;
		$snv->searchResultsDiseaseGene($dbh,$ref);
	}
	$snv->printFooter($dbh);
}
else { # because of fork no header
	my ($dbh) = $snv->loadSessionId();
	$snv->burden($dbh,$ref,$cgi);
}
