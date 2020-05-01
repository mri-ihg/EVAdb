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
my $name        = $cgiquery->param('name');
my $search      = $snv->initSearchRpkm($name);

$snv->printHeader();
$snv->loadSessionId();
	
$snv->showMenu("searchRpkm");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchRpkmDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
