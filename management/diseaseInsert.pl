#!/usr/bin/perl

########################################################################
# Tim M Strom   Juni 2010
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Snvedit;
use DBI;

########################################################################
# global variables
########################################################################

my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $snv             = new Snvedit;
my $personref       = "";
my $dbh             = "";
my @fields          =();
my @values          =();

my $sql             = "";
my $sth             = "";

########################################################################
# main
########################################################################

$snv ->printHeader;
$dbh = $snv ->loadSessionId();

# encoded name

# delete beginning and trailing space
$snv ->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$snv->editDisease($ref,$dbh,'disease');
}
else {
	delete($ref->{"mode"});
	$snv->insertIntoDisease($ref,$dbh,'disease');
}

# select and display new entry
$snv->showMenu();


$snv->showAllDisease($dbh,$ref->{iddisease});


$snv->printFooter();


