#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
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

$solexa->showMenu('sequencing');

print"<form name=\"myform\" action =\"sequencingDoDo.pl\" method=\"post\">";


print "<input type=\"submit\" name=\"seq_sheet\" 
value='Sequencing Sheet' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";
print "<br><br>";
$solexa->searchSequencing($dbh,$ref);

print "</form>";

$dbh->disconnect;

$solexa->printFooter();
