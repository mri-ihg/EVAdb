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

# encoded name

# delete beginning and trailing space
$solexa->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$solexa->editLibrary($ref,$dbh,'library');
}
else {
	delete($ref->{"mode"});
	$solexa->insertIntoLibrary($ref,$dbh,'library');
}

# select and display new entry
$solexa->showMenu();


$solexa->showAllLibrary($dbh,$ref->{lid});


$solexa->printFooter($dbh);


