#!/usr/bin/perl 

########################################################################
# Tim M Strom   May 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $solexa      = new Solexa;
my $cgiquery    = new CGI;
my $ref         = $cgiquery->Vars;
my @check_id    = $cgiquery->param('checkbox');
my $checkboxref = \@check_id;

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

$solexa->showMenu();
print "<span class=\"big\">Librarysheet</span><br><br>" ;

$solexa->libsheet($ref,$dbh,$checkboxref);


$solexa->printFooter($dbh);
