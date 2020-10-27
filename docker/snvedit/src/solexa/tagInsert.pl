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
	$solexa->editTag($ref,$dbh,'tag');
}
else {
	delete($ref->{"mode"});
	$solexa->insertIntoTag($ref,$dbh,'tag');
}

# select and display new entry
$solexa->showMenu();


$solexa->showAllTag($dbh,$ref->{idtag});


$solexa->printFooter($dbh);


