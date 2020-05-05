#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $cgiquery     = new CGI;
my $file         = $cgiquery->param('file');
my $samples      = new Solexa;

########################################################################
# main
########################################################################

$samples->printHeader;
my $dbh=$samples->loadSessionId();

$samples->showMenu("checkBarcode");

print"<form name=\"myform\" action =\"checkBarcodeDoDo.pl\" method=\"post\" >";


print "<input type=\"submit\" name=\"update_plate_positions\" 
value='Update Plate Positions' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";
print "<br><br>";
$samples->checkBarcode($dbh,$file);

print "</form>";

$dbh->disconnect;

$samples->printFooter();
