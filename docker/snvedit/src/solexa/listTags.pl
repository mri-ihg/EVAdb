#!/usr/bin/perl 

########################################################################
# Tim M Strom   May 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $solexa     = new Solexa;
my $cgiquery    = new CGI;

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

$solexa->showMenu("listtags");
print "<span class=\"big\">Indices</span><br><br>" ;

$solexa->listTags($dbh);

print "</form>" ;

$solexa->printFooter($dbh);
