#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

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

$snv->showMenu('searchConclusion');
print "<span class=\"big\">Case conclusions</span><br><br>" ;

$snv->searchConclusion($dbh,$ref);


$snv->printFooter($dbh);
