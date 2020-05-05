#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Snvedit;
use DBI;

my $snv         = new Snvedit;
my $cgiquery    = new CGI;
my $project    = $cgiquery->param('project');

$snv->printHeader("","cgisessid");
$snv->loadSessionId();
my $search      = $snv->initOverview($project);
	
$snv->showMenu("overview");
print "<span class=\"big\">Statistics</span><br><br>" ;

print "<form action=\"overviewDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
