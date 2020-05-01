#!/usr/bin/perl -w

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Snv;
use DBI;

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $search      = $snv->initSearchSample();

$snv->printHeader("","cgisessid");
$snv->loadSessionId();
	
$snv->showMenu("searchHom");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchHomDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
