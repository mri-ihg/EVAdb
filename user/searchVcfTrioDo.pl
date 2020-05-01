#!/usr/bin/perl

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Snv;

my $cgiquery    = new CGI;
my $ref         = $cgiquery->Vars;

my $snv        	= new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu('searchVcfTrio');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchResultsVcfTrio($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
