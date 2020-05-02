#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $cgi          = new CGI;
my $idsamplesvcf = $cgi->param('idsamplesvcf');
my $idsnvsvcf    = $cgi->param('idsnvsvcf');
my $snv          = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$idsamplesvcf    = $snv->htmlencode($idsamplesvcf);
$idsnvsvcf       = $snv->htmlencode($idsnvsvcf);

$snv->printVCF($dbh,$idsamplesvcf,$idsnvsvcf);

$dbh->disconnect;

$snv->printFooter();
