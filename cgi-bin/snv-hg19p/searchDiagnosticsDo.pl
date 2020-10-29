#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgi        = new CGI;
my $ref        = $cgi->Vars;
my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);

$snv->showMenu('searchDiagnostics');
print "<span class=\"big\">Coverage lists</span><br><br>" ;

$snv->searchResultsDiagnostics($dbh,$ref);


$snv->printFooter($dbh);
