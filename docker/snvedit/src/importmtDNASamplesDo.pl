#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $cgiquery     = new CGI;
my $file         = $cgiquery->param('file');
my $ref          = $cgiquery->Vars;
my $snvedit      = new Snvedit;

########################################################################
# main
########################################################################

$snvedit->printHeader;
my ($dbh) = $snvedit->loadSessionId();

$snvedit->showMenu("importmtdnatsamples");
print "<span class=\"big\">Import mtDNA sample information</span><br><br>" ;

$snvedit->importmtDNASamples($dbh,$ref,$file);


$snvedit->printFooter($dbh);
