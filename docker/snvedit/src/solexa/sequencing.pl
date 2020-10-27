#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Session;
BEGIN {require './Solexa.pm';}

my $snv         = new Solexa;
my $cgiquery    = new CGI;
my $search      = $snv->initSequencing();

$snv->printHeader();
my ($dbh) =$snv->loadSessionId();

$snv->showMenu("sequencing");
print "<span class=\"big\">Sequencing</span><br><br>" ;

print "<form action=\"sequencingDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
