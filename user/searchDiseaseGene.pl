#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use Snv;

my $snv         = new Snv;
my $cgiquery    = new CGI;
my $sname       = $cgiquery->param('sname');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$sname          = $snv->htmlencode($sname);
my $search      = $snv->initSearchDiseaseGene($sname,$dbh);
	
$snv->showMenu("searchDiseaseGene");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchDiseaseGeneDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
