#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $idsample    = $cgi->param('idsample');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$idsample       = $snv->htmlencode($idsample);
my $search      = $snv->initConclusion($idsample,$dbh);
	
$snv->showMenu("");
print "<span class=\"big\">Conclusion</span><br><br>" ;

print "<form action=\"conclusionDo.pl\" method=\"post\">" ;
$snv->getShowConclusion($dbh,$idsample,$search,'noprint');
$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
