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

$project = $snv ->initSample();

$snv ->printHeader();
my ($dbh) = $snv ->loadSessionId();

if ($mode eq 'edit') {
	$snv ->showMenu("");
	print "<span class=\"big\">Edit Sample</span><br><br>" ;
	$snv->showDisease2sample($dbh,$id);
}
else {
	$snv ->showMenu("sample");
	print "<span class=\"big\">New Sample</span><br><br>" ;
}

print qq(<form action="sampleInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$snv ->getShowSample($dbh,$id,$project,'noprint');
}

$snv ->drawMask($project);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$snv ->printFooter($dbh);
