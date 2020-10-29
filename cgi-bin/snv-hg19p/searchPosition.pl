#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $cgi         = new CGI;
my $position    = $cgi->param('position');
my $name        = $cgi->param('name');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$name           = $snv->htmlencode($name);
#$position       = $snv->htmlencode($position);
my $search      = $snv->initSearchPosition($position,$name);

$snv->showMenu("searchPosition");
print "<span class=\"big\">Region</span><br><br>" ;

print "<form action=\"searchPositionDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
