#!/usr/bin/perl 

########################################################################
# Tim M Strom   June 2008
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}
use DBI;

my $id        = "";
my $solexa    = new Solexa;
my $cgiquery  = new CGI;
my $lane      = "";

$id              = $cgiquery->param('id');

$lane = $solexa->initLane();

$solexa->printHeader();
my ($dbh) = $solexa->loadSessionId();

$solexa->showMenu("");
print "<span class=\"big\">Edit Lane</span><br><br>" ;

print qq(<form action="laneEdit.pl" method="post">);

$solexa->getShowLane($dbh,$id,$lane,'noprint');

$solexa->drawMask($lane);

print "</form>" ;

$solexa->printFooter($dbh);
