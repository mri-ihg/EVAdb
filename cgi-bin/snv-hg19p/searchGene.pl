#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $ref         = $cgi->Vars;

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);
my $search      = $snv->initSearchGene($ref->{'g.genesymbol'});
	
$snv->showMenu("searchGene");
print "<span class=\"big\">Genes</span><br><br>" ;

print "<form action=\"searchGeneDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
