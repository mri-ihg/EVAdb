#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Snv;

my $cgiquery     = new CGI;
my $idsamplesvcf = $cgiquery->param('idsamplesvcf');
my $idsnvsvcf    = $cgiquery->param('idsnvsvcf');

my $snv          = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->printVCF($dbh,$idsamplesvcf,$idsnvsvcf);

$dbh->disconnect;

$snv->printFooter();
