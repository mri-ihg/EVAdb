#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $solexa      = new Solexa;
my $cgiquery    = new CGI;
my $yield       = $solexa->initYield();

#$solexa->printHeader("","cgisessid");
$solexa->printHeader("","cgisessid");
my $dbh=$solexa->loadSessionId();
	
$solexa->showMenu("yield");
print "<span class=\"big\">Yield</span><br><br>" ;

print "<form action=\"yieldDo.pl\" method=\"post\" name=\"myform\">" ;

$solexa->drawMask($yield);

print "</form>" ;

$solexa->printFooter();
