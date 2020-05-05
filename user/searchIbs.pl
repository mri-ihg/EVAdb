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

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();
my $search      = $snv->initSearchIbs();

	
$snv->showMenu("searchIbs");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchIbsDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
