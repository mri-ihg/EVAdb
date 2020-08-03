#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Session;
BEGIN {require './Snvedit.pm';}
use DBI;

my $snv         = new Snvedit;
my $cgiquery    = new CGI;
my $project    = $cgiquery->param('project');

$snv->printHeader("","cgisessid");
my ($dbh) = $snv->loadSessionId();
my $search      = $snv->initOverview($project);
	
$snv->showMenu("overview");
print "<span class=\"big\">Statistics</span><br><br>" ;

print "<form action=\"overviewDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
