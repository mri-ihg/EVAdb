#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Oct 2013
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

$snv->showMenu('searchTrans');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchResultsTrans($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
