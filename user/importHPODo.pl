#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Snv;
use DBI;

my $cgiquery   = new CGI;
my $ref        = $cgiquery->Vars;

my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu('importHPO');
print "<span class=\"big\">Import done</span><br><br>" ;

$snv->importHPO($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
