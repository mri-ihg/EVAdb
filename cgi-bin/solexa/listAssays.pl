#!/usr/bin/perl

########################################################################
# MRI/Berutti   Feb 2022
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;

my $snv          = new Solexa;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) =$snv->loadSessionId();

$snv->showMenu("Assays");
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->listAssays($dbh,$ref);


$snv->printFooter($dbh);
