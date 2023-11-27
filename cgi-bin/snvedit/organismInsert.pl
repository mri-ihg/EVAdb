#!/usr/bin/perl

########################################################################
# Tim M Strom       2010 - 2021
# Riccardo Berutti  2016 - 2023
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

########################################################################
# global variables
########################################################################

my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $snv             = new Snvedit;
my $personref       = "";
my @fields          =();
my @values          =();

my $sql             = "";
my $sth             = "";

########################################################################
# main
########################################################################

$snv ->printHeader;
my ($dbh) = $snv ->loadSessionId();

# encoded name

# delete beginning and trailing space
$snv ->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$snv->editOrganism($ref,$dbh,'organism');
}
else {
	delete($ref->{"mode"});
	$snv->insertIntoOrganism($ref,$dbh,'organism');
}

# select and display new entry
$snv->showMenu();


$snv->showAllOrganism($dbh,$ref->{idorganism});


$snv->printFooter($dbh);


