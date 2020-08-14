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
my $kit       = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$kit = $solexa->initKit();

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Kit</span><br><br>" ;
}
else {
	$solexa->showMenu("kit");
	print "<span class=\"big\">New Kit</span><br><br>" ;
}

print qq(<form action="kitInsert.pl" method="post">);

if ($mode eq 'edit') {
	$solexa->getShowKit($dbh,$id,$kit,'noprint');
}

$solexa->drawMask($kit);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
