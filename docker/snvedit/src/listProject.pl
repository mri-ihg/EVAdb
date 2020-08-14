#!/usr/bin/perl

########################################################################
# Tim M Strom   Oct 2010
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;

my $snv          = new Snvedit;

########################################################################
# main
########################################################################

$snv ->printHeader();
my ($dbh) = $snv ->loadSessionId();

$snv ->showMenu("listProject");
print "<span class=\"big\">Search results</span><br><br>" ;

$snv ->listProject($dbh,$ref);

$snv ->printFooter($dbh);
