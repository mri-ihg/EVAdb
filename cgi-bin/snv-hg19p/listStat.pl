#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################
#obsolet

use strict;
BEGIN {require './Snv.pm';}

my $cgi          = new CGI;
my $ref          = $cgi->Vars;
my $snv          = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);

$snv->showMenu("liststat");
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->listStat($dbh,$ref);


$snv->printFooter($dbh);
