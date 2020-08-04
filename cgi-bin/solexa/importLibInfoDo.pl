#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $file         = $cgiquery->param('file');
my $ref          = $cgiquery->Vars;
my $samples      = new Solexa;

########################################################################
# main
########################################################################

$samples->printHeader;
my ($dbh) =$samples->loadSessionId();

$samples->showMenu("importLibInfo");
print "<span class=\"big\">Import library information</span><br><br>" ;

$samples->importLibInfo($dbh,$ref,$file);


$samples->printFooter($dbh);
