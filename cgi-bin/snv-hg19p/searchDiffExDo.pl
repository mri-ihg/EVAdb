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

$snv->showMenu('searchDiffEx');
print "<span class=\"big\">Search results</span><br><br>" ;

print"<form name=\"myform\" action =\"searchDiffExDoDo.pl\" method=\"post\">";

$snv->searchDiffEx($dbh,$ref);

print "</form>";


$snv->printFooter($dbh);
