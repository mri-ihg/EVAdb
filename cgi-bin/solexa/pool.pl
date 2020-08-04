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
my $solexa    = new Solexa;
my $cgiquery  = new CGI;
my $pool      = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$pool = $solexa->initPool();

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Pool</span><br><br>" ;
	$solexa->showPool2library($dbh,$id);
}
else {
	$solexa->showMenu("pool");
	print "<span class=\"big\">New Pool</span><br><br>" ;
}

print qq(<form action="poolInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowPool($dbh,$id,$pool,'noprint');
}

print "<input type='submit' name='recalculation' value='Recalculation'><br><br>";

$solexa->drawMask($pool);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
