#!/usr/bin/perl

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my $solexa       = new Solexa;

########################################################################
# main
########################################################################

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();
my $search = $solexa->initPoolingDo();

$solexa->showMenu('pooling');

print"<form name=\"myform\" action =\"poolingDoDo.pl\" method=\"post\">";


print "<input type=\"submit\" name=\"pool_sheet\" 
value='Pooling Sheet' >";
print "<br><br>";
$solexa->drawMask($search,"nosubmit");
print "&nbsp;&nbsp;&nbsp;&nbsp;";
print "<br><br>";
$solexa->searchPooling($dbh,$ref);

print "</form>";


$solexa->printFooter($dbh);
