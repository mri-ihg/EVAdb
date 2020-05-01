#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session qw/-ip-match/;
use CGI::Carp qw(fatalsToBrowser);
use Snv;

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $name        = $cgiquery->param('name');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();
my $search      = $snv->initSearchVcf($name,$dbh);

	
$snv->showMenu("searchVcf");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchVcfDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
