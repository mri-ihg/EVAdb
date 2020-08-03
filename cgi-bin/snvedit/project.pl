#!/usr/bin/perl 

########################################################################
# Tim M Strom   June 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $mode      = "";
my $id        = "";
my $solexa    = new Snvedit;
my $cgiquery  = new CGI;
my $project   = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$project = $solexa->initProject();

$solexa->printHeader();
my ($dbh) = $solexa->loadSessionId();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Project</span><br><br>" ;
}
else {
	$solexa->showMenu("project");
	print "<span class=\"big\">New Project</span><br><br>" ;
}

print qq(<form action="projectInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowProject($dbh,$id,$project,'noprint');
}

$solexa->drawMask($project);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter($dbh);
