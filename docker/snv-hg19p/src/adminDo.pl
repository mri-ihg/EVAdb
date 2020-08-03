#!/usr/bin/perl

########################################################################
# Tim M Strom   Juni 2010
########################################################################

use strict;
BEGIN {require './Snv.pm';}

########################################################################
# global variables
########################################################################

my $cgi             = new CGI;
my $ref             = $cgi->Vars;
my $snv             = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader;
my ($dbh) = $snv->loadSessionId();

#$ref = $snv->htmlencodehash($ref);

# delete beginning and trailing space
$snv->deleteSpace($ref);

my $mode= $ref->{"mode"};
delete($ref->{"mode"});
$snv->insertIntoAdmin($ref,$dbh,'user',$mode);

# select and display new entry
$snv->showMenu("admin");


$snv->showAllAdmin($dbh,$ref->{iduser});


$snv->printFooter($dbh);


