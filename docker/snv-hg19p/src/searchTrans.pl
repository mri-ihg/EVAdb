#!/usr/bin/perl

########################################################################
# Tim M Strom   Oct 2013
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $sname       = $cgi->param('sname');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$sname          = $snv->htmlencode($sname);
my $search      = $snv->initSearchTrans($sname);

$snv->showMenu("searchTrans");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchTransDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
