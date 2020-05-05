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
my ($dbh)       = $snv->loadSessionId();

$pedigree       = $snv->htmlencode($pedigree);
my $search      = $snv->initSearchFam($pedigree,$dbh);
	
$snv->showMenu("search");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
