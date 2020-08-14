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
my $user      = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$user = $solexa->initShopping();

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Order</span><br><br>" ;
}
else {
	$solexa->showMenu("user");
	print "<span class=\"big\">New Order</span><br><br>" ;
}

print qq(<form action="shoppingInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowShopping($dbh,$id,$user,'noprint');
}

$solexa->drawMask($user);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
