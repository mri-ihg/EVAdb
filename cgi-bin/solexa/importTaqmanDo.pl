#!/usr/bin/perl 

########################################################################
# Tim M Strom   April 2011
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

$samples->showMenu("importtaqman");
print "<span class=\"big\">Import Taqman results</span><br><br>" ;

$samples->importTaqman($dbh,$ref,$file);


$samples->printFooter($dbh);
