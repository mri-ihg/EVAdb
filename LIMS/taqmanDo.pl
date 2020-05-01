#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my $solexa       = new Solexa;

########################################################################
# main
########################################################################

$solexa->printHeader();
my $dbh=$solexa->loadSessionId();

$solexa->showMenu('taqman');

print"<form name=\"myform\" action =\"taqmanDoDo.pl\" method=\"post\" >";


print "<input type=\"submit\" name=\"pool_sheet\" 
value='Taqman Sheet' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";
print "<br><br>";
$solexa->searchTaqman($dbh,$ref);

print "</form>";

$dbh->disconnect;

$solexa->printFooter();
