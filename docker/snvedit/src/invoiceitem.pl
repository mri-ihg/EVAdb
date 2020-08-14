#!/usr/bin/perl

########################################################################
# Tim M Strom   June 2010
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $snv       = new Snvedit;
my $cgiquery  = new CGI;
my $item      = "";

my $mode            = $cgiquery->param('mode');
my $idinvoice       = $cgiquery->param('idinvoice');
my $idinvoiceitem   = $cgiquery->param('idinvoiceitem');

$item = $snv ->initInvoiceitem($idinvoice);

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

if ($mode eq 'edit') {
	$snv->showMenu("");
	print "<span class=\"big\">Edit Invoice Item</span><br><br>" ;
}
else {
	$snv->showMenu("");
	print "<span class=\"big\">New Invoice Item</span><br><br>" ;
}

print qq(<form action="invoiceitemDo.pl" method="post">);

if ($mode eq 'edit') {
	$snv->getShowInvoiceitem($dbh,$idinvoiceitem,$item,'noprint');
}

$snv->drawMask($item);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$snv->printFooter($dbh);
