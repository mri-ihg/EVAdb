#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Snv;
use DBI;

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;

my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu('searchDiffPeak');
print "<span class=\"big\">Search results</span><br><br>" ;

print"<form name=\"myform\" action =\"searchDiffPeakDoDo.pl\" method=\"post\">";

$snv->searchDiffPeak($dbh,$ref);

print "</form>";

$dbh->disconnect;

$snv->printFooter();
