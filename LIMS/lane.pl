#!/usr/bin/perl 

########################################################################
# Tim M Strom   June 2008
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use CGI::Carp qw(fatalsToBrowser);
use Solexa;
use DBI;

my $id        = "";
my $solexa    = new Solexa;
my $cgiquery  = new CGI;
my $lane      = "";
my $dbh       = $solexa->dbh;

$id              = $cgiquery->param('id');

$lane = $solexa->initLane();

$solexa->printHeader();

$solexa->showMenu("");
print "<span class=\"big\">Edit Lane</span><br><br>" ;

print qq(<form action="laneEdit.pl" method="post">);

$solexa->getShowLane($dbh,$id,$lane,'noprint');

$solexa->drawMask($lane);

print "</form>" ;

$solexa->printFooter();
