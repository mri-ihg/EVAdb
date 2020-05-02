#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $cgi        = new CGI;
my $ref        = $cgi->Vars;
my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$ref = $snv->htmlencodehash($ref);

$snv->showMenu('importHPO');
print "<span class=\"big\">Import done</span><br><br>" ;

$snv->importHPO($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
