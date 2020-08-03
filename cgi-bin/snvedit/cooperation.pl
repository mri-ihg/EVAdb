#!/usr/bin/perl

########################################################################
# Tim M Strom   June 2010
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $mode      = "";
my $id        = "";
my $snv       = new Snvedit;
my $cgiquery  = new CGI;
my $project   = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$project = $snv->initCooperation();

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

if ($mode eq 'edit') {
	$snv->showMenu("");
	print "<span class=\"big\">Edit Cooperation</span><br><br>" ;
}
else {
	$snv->showMenu("cooperation");
	print "<span class=\"big\">New Cooperation</span><br><br>" ;
}

print qq(<form action="cooperationInsert.pl" method="post">);

if ($mode eq 'edit') {
	$snv->getShowCooperation($dbh,$id,$project,'noprint');
}

$snv->drawMask($project);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$snv->printFooter($dbh);
