#!/usr/bin/perl 

########################################################################
# Tim M Strom   August 2017
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

my @cases        = $cgi->multi_param('cases');
my @controls     = $cgi->multi_param('controls');
#$ref             = $snv->htmlencodehash($ref);
#@cases           = $snv->htmlencodearray(@cases);
#@controls        = $snv->htmlencodearray(@controls);
my $casesref     = \@cases;
my $controlsref  = \@controls;

$snv->showMenu('searchDiffEx');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchDiffExDoDo($dbh,$ref,$casesref,$controlsref);


$snv->printFooter($dbh);
