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
#my $ref        = $cgiquery->Vars;
my $idsample   = $cgiquery->param('idsample');

my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu('searchHPO');
print "<span class=\"big\">HPO</span><br><br>" ;

$snv->showHPO($dbh,$idsample);

$dbh->disconnect;

$snv->printFooter();
