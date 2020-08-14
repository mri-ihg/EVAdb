#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgi        = new CGI;
my $idsample   = $cgi->param('idsample');
my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu('searchHPO');
print "<span class=\"big\">HPO</span><br><br>" ;

#$idsample      = $snv->htmlencode($idsample);
$snv->showHPO($dbh,$idsample);


$snv->printFooter($dbh);
