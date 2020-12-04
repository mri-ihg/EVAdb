#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

#use Apache2::TaintRequest ();
#my $apr = Apache::TaintRequest->new(Apache->request);

my $cgi          = new CGI;
my $ref          = $cgi->Vars;
my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);

$snv->showMenu('searchHGMD');
print "<span class=\"big\">ClinVar/HGMD</span><br><br>" ;

$snv->searchHGMD($dbh,$ref);


$snv->printFooter($dbh);
