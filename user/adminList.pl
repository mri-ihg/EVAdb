#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $cgi          = new CGI;
my $ref          = $cgi->Vars;
my $snv          = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu("adminList");
print "<span class=\"big\">Search results</span><br><br>" ;

$ref = $snv->htmlencodehash($ref);

$snv->adminList($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
