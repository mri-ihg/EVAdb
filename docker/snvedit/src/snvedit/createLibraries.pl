#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Session;
BEGIN {require './Snvedit.pm';}
use DBI;

my $snv         = new Snvedit;
my $cgiquery    = new CGI;
my $search      = $snv->initCreateLibrary();

$snv->printHeader("","cgisessid");
my ($dbh) = $snv->loadSessionId();
	
$snv->showMenu("createlibraries");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"../solexa/searchSampleDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
