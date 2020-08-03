#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use CGI::Session;
BEGIN {require './Snvedit.pm';}
use DBI;

my $snv         = new Snvedit;
my $cgiquery    = new CGI;

$snv->printHeader("","cgisessid");
my ($dbh) = $snv->loadSessionId();
my $search      = $snv->initInvoiceSearch();
	
$snv->showMenu("searchInvoice");
print "<span class=\"big\">Invoice</span><br><br>" ;

print "<form action=\"invoiceSearchDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
