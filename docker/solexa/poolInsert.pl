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
$solexa->showMenu();

if ($ref->{recalculation} eq "Recalculation") {
		$solexa->recalculatePool($ref,$dbh);
}
else {
	if ($ref->{mode} eq "edit") {
		delete($ref->{"mode"});
		$solexa->editPool($ref,$dbh,'pool');
	}
	else {
		delete($ref->{"mode"});
		$solexa->insertIntoPool($ref,$dbh,'pool');
	}
	$solexa->showAllPool($dbh,$ref->{idpool});
}


$solexa->printFooter($dbh);


