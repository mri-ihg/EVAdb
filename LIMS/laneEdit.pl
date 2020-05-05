#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use CGI::Carp qw(fatalsToBrowser);
use Solexa;
use DBI;

########################################################################
# global variables
########################################################################

my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $solexa          = new Solexa;
my $personref       = "";
my $dbh             = "";


########################################################################
# main
########################################################################

$solexa->printHeader;

$dbh = $solexa->dbh;

# encoded name

# delete beginning and trailing space
$solexa->deleteSpace($ref);

$solexa->editLane($ref,$dbh,'lane');

# select and display new entry
$solexa->showMenu();

$solexa->showAllLane($dbh,$ref->{aid});

$solexa->printFooter();


