#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $solexa      = new Solexa;
my $cgiquery    = new CGI;
my $statistics  = $solexa->initStatistics();

$solexa->printHeader();
my $dbh=$solexa->loadSessionId();

$solexa->showMenu("statistics");
print "<span class=\"big\">Statistics</span><br><br>" ;

print "<form action=\"statisticsDo.pl\" method=\"post\" name=\"myform\">" ;

$solexa->drawMask($statistics);

print "</form>" ;

$solexa->printFooter();
