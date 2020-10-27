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
	$solexa->editUser($ref,$dbh,'user');
}
else {
	delete($ref->{"mode"});
	$solexa->insertIntoUser($ref,$dbh,'user');
}

# select and display new entry
$solexa->showMenu();


$solexa->showAllUser($dbh,$ref->{uid});


$solexa->printFooter($dbh);


