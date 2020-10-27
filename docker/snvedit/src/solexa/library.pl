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
my $library   = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');
$pid             = $cgiquery->param('pid');

# Vorbelegung für neue Library
# aus alter search-Project-Tabelle
# kann eigentlich geloescht werden
$library = $solexa->initLibrary($pid); 

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("library");
	print "<span class=\"big\">Edit Library</span><br><br>" ;
	$solexa->showSample2library($dbh,$id);
	$solexa->showLibrary2pool($dbh,$id);
}
else {
	$solexa->showMenu("library");
	print "<span class=\"big\">New Library</span><br><br>" ;
}

print qq(<form action="libraryInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowLibrary($dbh,$id,$library,'noprint');
}

$solexa->drawMask($library);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
