#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

########################################################################
# global variables
########################################################################

my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $solexa          = new Solexa;

########################################################################
# main
########################################################################

$solexa->printHeader;
my ($dbh) =$solexa->loadSessionId();

# delete beginning and trailing space
$solexa->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$solexa->editStock($ref,$dbh,'stock');
}
else {
	delete($ref->{"mode"});
	$solexa->insertIntoStock($ref,$dbh,'stock');
}

# select and display new entry
$solexa->showMenu();


$solexa->showAllStock($dbh,$ref->{sid});


$solexa->printFooter($dbh);


