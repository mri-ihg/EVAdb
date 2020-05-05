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
my $cgi         = new CGI;
my $idsample    = $cgi->param('idsample');

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$idsample       = $snv->htmlencode($idsample);
my $search      = $snv->initConclusion($idsample,$dbh);
	
$snv->showMenu("");
print "<span class=\"big\">Conclusion</span><br><br>" ;

print "<form action=\"conclusionDo.pl\" method=\"post\">" ;
$snv->getShowConclusion($dbh,$idsample,$search,'noprint');
$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
