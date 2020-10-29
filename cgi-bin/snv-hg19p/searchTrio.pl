#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $pedigree    = $cgi->param('pedigree');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$pedigree       = $snv->htmlencode($pedigree);
my $search      = $snv->initSearchTrio($pedigree,$dbh);

$snv->showMenu("searchTrio");
print "<span class=\"big\">De novo Trio</span><br><br>" ;

print "<form action=\"searchTrioDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
