#!/usr/bin/perl

########################################################################
# Tim M Strom   Oct 2013
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Snv;
use DBI;

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $sname       = $cgiquery->param('sname');
my $search      = $snv->initSearchTrans($sname);

$snv->printHeader("","cgisessid");
$snv->loadSessionId();

$snv->showMenu("searchTrans");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchTransDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
