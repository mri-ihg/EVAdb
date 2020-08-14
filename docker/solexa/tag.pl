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
my $tag       = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$tag = $solexa->initTag();

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Tag</span><br><br>" ;
}
else {
	$solexa->showMenu("tag");
	print "<span class=\"big\">New Tag</span><br><br>" ;
}

print qq(<form action="tagInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowTag($dbh,$id,$tag,'noprint');
}

$solexa->drawMask($tag);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
