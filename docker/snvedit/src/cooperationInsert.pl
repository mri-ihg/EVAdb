#!/usr/bin/perl

########################################################################
# Tim M Strom   Juni 2010
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

$snv->printHeader;
my ($dbh) = $snv->loadSessionId();

# encoded name

# delete beginning and trailing space
$snv->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$snv->editCooperation($ref,$dbh,'cooperation');
}
else {
	delete($ref->{"mode"});
	$snv->insertIntoCooperation($ref,$dbh,'cooperation');
}

# select and display new entry
$snv->showMenu();


$snv->showAllCooperation($dbh,$ref->{idcooperation});


$snv->printFooter($dbh);


