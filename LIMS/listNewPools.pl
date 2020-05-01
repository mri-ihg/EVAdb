#!/usr/bin/perl 

########################################################################
# Tim M Strom   May 2008
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;
use DBI;

my $solexa     = new Solexa;
my $cgiquery    = new CGI;
my $dbh         = $solexa->dbh;

$solexa->printHeader();

$solexa->showMenu("listnewpools");
print "<span class=\"big\">New Pools</span><br><br>" ;

$solexa->listNewPools($dbh);

print "</form>" ;

$solexa->printFooter();
