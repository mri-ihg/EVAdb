#!/usr/bin/perl -w

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgi          = new CGI;
#my $ref          = $cgi->Vars;
my $snv          = new Snv;
my $sname        = $cgi->param('sname');

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

my $search      = $snv->initSearchReport($sname);

$snv->showMenu("report");

print "<span class=\"big\">Report</span><br><br>" ;
print "The report requires the fields in the 'Variant annotation form' to be filled in.<br><br>";

print "<form action=\"reportDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;



$snv->printFooter($dbh);
