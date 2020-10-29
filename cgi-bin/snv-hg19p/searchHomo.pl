#!/usr/bin/perl 

########################################################################
# Tim M Strom   Oct 2013
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $sname       = $cgi->param('sname');
my $search      = $snv->initSearchHomozygosity($sname);

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$sname          = $snv->htmlencode($sname);
my $search      = $snv->initSearchHomozygosity($sname);

$snv->showMenu("searchHomozygosity");
print "<span class=\"big\">Homozygosity</span><br><br>" ;

print "<form action=\"searchHomoDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
