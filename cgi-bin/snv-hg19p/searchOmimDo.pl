#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgiquery   = new CGI;
my $ref        = $cgiquery->Vars;
my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);

$snv->showMenu('searchOmim');
print "<span class=\"big\">OMIM</span><br><br>" ;

$snv->searchResultsOmim($dbh,$ref);


$snv->printFooter($dbh);
