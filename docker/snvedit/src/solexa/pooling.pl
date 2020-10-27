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
my $search      = $snv->initPooling();

$snv->printHeader("","cgisessid");
my ($dbh) =$snv->loadSessionId();

	
$snv->showMenu("pooling");
print "<span class=\"big\">Pooling</span><br><br>" ;

print "<form action=\"poolingDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
