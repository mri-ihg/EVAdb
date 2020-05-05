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
my $ref         = $cgi->Vars;

$snv->printHeader();
$snv->loadSessionId();

$ref = $snv->htmlencodehash($ref);
my $search      = $snv->initSearchGene($ref->{'g.genesymbol'});
	
$snv->showMenu("searchGene");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchGeneDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
