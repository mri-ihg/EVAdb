#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $sname       = $cgi->param('sname');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$sname       = $snv->htmlencode($sname);
my $search      = $snv->initSearchOmim($sname,$dbh);
	
$snv->showMenu("searchOmim");
print "<span class=\"big\">OMIM</span><br><br>" ;

print "<form action=\"searchOmimDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
