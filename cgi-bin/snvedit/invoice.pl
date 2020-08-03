#!/usr/bin/perl

########################################################################
# Tim M Strom   June 2010
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $mode      = "";
my $id        = "";
my $snv       = new Snvedit;
my $cgiquery  = new CGI;
my $project   = "";

$mode            = $cgiquery->param('mode');
$id              = $cgiquery->param('id');

$project = $snv->initInvoice();

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

if ($mode eq 'edit') {
	$snv->showMenu("");
	print "<span class=\"big\">Edit Invoice</span><br><br>" ;
}
else {
	$snv->showMenu("invoice");
	print "<span class=\"big\">New Invoice</span><br><br>" ;
}

print qq(<form action="invoiceInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$snv->getShowInvoice($dbh,$id,$project,'noprint');
}

$snv->drawMask($project);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$snv->printFooter($dbh);
