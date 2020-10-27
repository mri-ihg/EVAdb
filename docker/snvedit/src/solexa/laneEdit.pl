#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}
use DBI;

########################################################################
# global variables
########################################################################

my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $solexa          = new Solexa;
my $personref       = "";


########################################################################
# main
########################################################################

$solexa->printHeader;
my ($dbh) = $solexa->loadSessionId();

# encoded name

# delete beginning and trailing space
$solexa->deleteSpace($ref);

$solexa->editLane($ref,$dbh,'lane');

# select and display new entry
$solexa->showMenu();

$solexa->showAllLane($dbh,$ref->{aid});

$solexa->printFooter($dbh);


