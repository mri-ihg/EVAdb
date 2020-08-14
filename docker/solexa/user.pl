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

$user = $solexa->initUser();

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit User</span><br><br>" ;
}
else {
	$solexa->showMenu("user");
	print "<span class=\"big\">New User</span><br><br>" ;
}

print qq(<form action="userInsert.pl" method="post">);

if ($mode eq 'edit') {
	$solexa->getShowUser($dbh,$id,$user,'noprint');
}

$solexa->drawMask($user);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
