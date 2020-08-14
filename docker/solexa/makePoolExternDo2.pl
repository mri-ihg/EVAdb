#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my $samples      = new Solexa;
my $forward      = "";
my $id           = 0;
########################################################################
# main
########################################################################

$samples->printHeader();
my ($dbh) =$samples->loadSessionId();

#$samples->showMenu("makePool");
#print "<span class=\"big\">Make Pool2</span><br><br>" ;

$id=$samples->makePoolExtern2($ref,$dbh);

$forward  = qq#<meta http-equiv="refresh" content="0;  URL=pool.pl?id=$id&mode=edit">#;
print "$forward";

$samples->printFooter($dbh);
