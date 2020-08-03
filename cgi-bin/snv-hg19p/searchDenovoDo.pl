#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
BEGIN {require './Snv.pm';}
use DBI;

my $cgiquery    = new CGI;
my $ref         = $cgiquery->Vars;

my $snv        	= new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu('searchDenovo');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchDenovoResults($dbh,$ref);


$snv->printFooter($dbh);
