#!/usr/bin/perl -w

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Snv;
use DBI;

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $pedigree    = $cgiquery->param('pedigree');
my $search      = $snv->initSearchDiffEx($pedigree);

$snv->printHeader("","cgisessid");
$snv->loadSessionId();
	
$snv->showMenu("searchDiffEx");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchDiffExDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
