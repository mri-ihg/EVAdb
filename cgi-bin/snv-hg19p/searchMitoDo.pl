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

$snv->showMenu('searchMito');
print "<span class=\"big\">Mitochondria</span><br><br>" ;

$snv->searchResultsMito($dbh,$ref);


$snv->printFooter($dbh);
