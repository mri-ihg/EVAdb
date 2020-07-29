#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
BEGIN {require './Snv.pm';}
use DBI;

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $search      = $snv->initSearchDenovo();

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();
	
$snv->showMenu("searchDenovo");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchDenovoDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
