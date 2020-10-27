#!/usr/bin/perl 

########################################################################
# Tim M Strom   April 2011
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $solexa      = new Solexa;
my $cgiquery    = new CGI;
my $ref         = $cgiquery->Vars;

$solexa->printHeader();
my ($dbh) = $solexa->loadSessionId();

$solexa->showMenu();
print "<span class=\"big\">Update Plate Positions</span><br><br>" ;

$solexa->updateplatepositions($ref,$dbh);


$solexa->printFooter($dbh);
