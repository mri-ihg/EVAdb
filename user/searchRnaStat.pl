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
my $search      = $snv->initSearchRnaStat();

$snv->printHeader();
$snv->loadSessionId();
	
$snv->showMenu("searchRnaStat");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchRnaStatDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
