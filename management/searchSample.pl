#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Snvedit;
use DBI;

my $snv         = new Snvedit;
my $cgiquery    = new CGI;
my $project    = $cgiquery->param('project');

$snv->printHeader("","cgisessid");
$snv->loadSessionId();
my $search      = $snv->initSearchSample($project);
	
$snv->showMenu("searchsample");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchSampleDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
