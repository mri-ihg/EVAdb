#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use Snv;

my $snv         = new Snv;
my $cgi         = new CGI;
my $pedigree    = $cgi->param('pedigree');

$snv->printHeader();
$snv->loadSessionId();

$pedigree       = $snv->htmlencode($pedigree);
my $search      = $snv->initSearchSample($pedigree);
	
$snv->showMenu("searchSample");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchSampleDo.pl\" method=\"post\" name=\"myform\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();

