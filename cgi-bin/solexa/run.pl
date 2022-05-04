#!/usr/bin/perl 

########################################################################
# Tim M Strom   June 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $mode      = "";
my $id        = "";
my $pid       = "";
my $lid       = "";
my $solexa    = new Solexa;
my $cgiquery  = new CGI;
my $run       = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');
$pid             = $cgiquery->param('pid');

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$run = $solexa->initRunEdit($dbh);
}
else {
	$run = $solexa->initRun($dbh);
}


if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Run</span><br><br>" ;
	$solexa->showRun2stock($dbh,$id);
}
else {
	$solexa->showMenu("run");
	print "<span class=\"big\">New Run</span><br><br>" ;
}

print qq(<form action="runInsert.pl" method="post" name=\"myform\">);

if ($mode eq 'edit') {
	$solexa->getShowRun($dbh,$id,$run,'noprint');
}

$solexa->drawMask($run,"",$dbh);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

if ($mode eq 'edit') {
	$solexa->showRunPF($dbh,$id);
}

$solexa->printFooter($dbh);
