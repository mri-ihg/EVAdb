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

#my $showedit        = 'T';
my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $solexa          = new Solexa;
my $personref       = "";

my $id=$ref->{rid};
my $forward  = qq#<meta http-equiv="refresh" content="0;  URL=run.pl?id=$id&mode=edit">#;

########################################################################
# main
########################################################################

$solexa->printHeader();
print "$forward";
my ($dbh) =$solexa->loadSessionId();

# encoded name

# delete beginning and trailing space
$solexa->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$solexa->editRun2stock($ref,$dbh,'run2stock');
}
else {
	delete($ref->{"mode"});
	$solexa->insertIntoRun2stock($ref,$dbh,'run2stock');
}


$solexa->printFooter($dbh);


