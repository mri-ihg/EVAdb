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
my $stock     = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$stock = $solexa->initStock();

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Stock</span><br><br>" ;
}
else {
	$solexa->showMenu("stock");
	print "<span class=\"big\">New Stock</span><br><br>" ;
}

print qq(<form action="stockInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowStock($dbh,$id,$stock,'noprint');
}

$solexa->drawMask($stock);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
