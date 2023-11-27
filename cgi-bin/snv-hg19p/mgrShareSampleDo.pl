#!/usr/bin/perl

########################################################################
# Riccardo Berutti 2023
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

my $terminate= $ref->{"terminate"};
$snv->showMenu("admin");

if ( $terminate ne "" )
{
	if ( $terminate =~ /^[0-9]+$/ )
	{
		$snv->pageTitle("Terminate authorization");
		$snv->authorizationTerminate($dbh, $terminate);
	}
	else
	{
		print "Invalid entry\n";
		exit(-1);
	}
}
else
{
	$snv->pageTitle("Add authorization");
	$snv->authorizationAdd($dbh, $ref);

}
####$snv->insertIntoAdmin($ref,$dbh,'user',$mode);

# select and display new entry





$snv->printFooter($dbh);


