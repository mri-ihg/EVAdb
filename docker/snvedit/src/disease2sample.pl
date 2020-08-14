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
my $snvedit   = new Snvedit;
my $cgiquery  = new CGI;
my $project   = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id'); #idsample

$project = $snvedit->initDisease2sample($id);

$snvedit->printHeader();
my ($dbh) = $snvedit->loadSessionId();

if ($mode eq 'edit') {
	$snvedit->showMenu("");
	print "<span class=\"big\">Edit Disease2Sample</span><br><br>" ;
}
else {
	$snvedit->showMenu("");
	print "<span class=\"big\">New Disease2Sample</span><br><br>" ;
}

print qq(<form action="disease2sampleInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$snvedit->getShowDisease2sample($dbh,$id,$project,'noprint');
}

$snvedit->drawMask($project);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$snvedit->printFooter($dbh);
