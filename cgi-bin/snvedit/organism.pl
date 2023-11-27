#!/usr/bin/perl

########################################################################
# Tim M Strom       2010 - 2021
# Riccardo Berutti  2016 - 2023
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $mode      = "";
my $id        = "";
my $snv       = new Snvedit;
my $cgiquery  = new CGI;
my $organism    = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$organism = $snv ->initOrganism();

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

if ($mode eq 'edit') {
	$snv->showMenu("");
	print "<span class=\"big\">Edit Organism</span><br><br>" ;
}
else {
	$snv->showMenu("disease");
	print "<span class=\"big\">New Organism</span><br><br>" ;
}

print qq(<form action="organismInsert.pl" method="post">);

if ($mode eq 'edit') {
	$snv->getShowOrganism($dbh,$id,$organism,'noprint');
}

$snv->drawMask($organism);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$snv->printFooter($dbh);
