#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI::Carp qw(fatalsToBrowser);
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

$snv->showMenu('searchGeneInd');
print "<span class=\"big\">Autosomal recessive</span><br><br>" ;

$snv->searchResultsGeneInd($dbh,$ref);


$snv->printFooter($dbh);
