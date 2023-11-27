#!/usr/bin/perl 

########################################################################
# Riccardo Berutti 2023
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgiquery    = new CGI;

#flowCellsDo.pl?rid=1787&rname=HLJTLDMXY&rfullname=231024_A01555_0129_AHLJTLDMXY&func=makeSampleSheet
my $runID	= $cgiquery->param('rid');
my $runName	= $cgiquery->param('rname');
my $runFullName	= $cgiquery->param('rfullname');
my $func	= $cgiquery->param('func');

$snv->printHeader();
my ($dbh,$dummy1, $dummy2, $dbhLIMS) = $snv->loadSessionId();

$snv->showMenu("searchFlowCells");

if (!( grep( /^$func$/, ( "makeSampleSheet", "makeDemultiplexing", "importRTA", "prepareFlowCell", "demultiplex", "demultiplexAndAnalyze", "startPipeline", "startNotAnalyzed" ))))
{
	print "Function not supported\n";
	exit (-1);
}

$snv->pageTitle("Flow cell action");



$snv->flowCellAction($dbhLIMS, $func, $runID, $runName, $runFullName);




print "</form>" ;

$snv->printFooter($dbh);
