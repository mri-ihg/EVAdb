#!/usr/bin/perl 

########################################################################
# Riccardo Berutti 2023
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgiquery    = new CGI;

$snv->printHeader();
my ($dbh,$dummy1, $dummy2, $dbhLIMS) = $snv->loadSessionId();

$snv->showMenu("searchFlowCells");
$snv->pageTitle("Flow Cells");


$snv->flowCellList($dbhLIMS);


$snv->printFooter($dbh);
