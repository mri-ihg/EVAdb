#!/usr/bin/perl 

########################################################################
# Tim M Strom   June 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $mode      = "";
my $id        = "";
my $solexa    = new Solexa;
my $cgiquery  = new CGI;
my $project   = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');
my $rid          = $cgiquery->param('rid');

$project = $solexa->initRun2stock($rid); # fuer Vorbelegung von Add Stock in EditRun

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Run2Stock</span><br><br>" ;
}
else {
	$solexa->showMenu("run2stock");
	print "<span class=\"big\">New Run2Stock</span><br><br>" ;
}

print qq(<form action="run2stockInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowRun2stock($dbh,$id,$project,'noprint');
}

$solexa->drawMask($project);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
