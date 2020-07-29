#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $name        = $cgi->param('name');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$name           = $snv->htmlencode($name);
my $search      = $snv->initSearchVcf($name,$dbh);
	
$snv->showMenu("searchVcf");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchVcfDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
