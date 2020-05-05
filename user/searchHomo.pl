#!/usr/bin/perl 

########################################################################
# Tim M Strom   Oct 2013
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use Snv;

my $snv         = new Snv;
my $cgi         = new CGI;
my $sname       = $cgi->param('sname');
my $search      = $snv->initSearchHomozygosity($sname);

$snv->printHeader();
$snv->loadSessionId();

$sname          = $snv->htmlencode($sname);
my $search      = $snv->initSearchHomozygosity($sname);

$snv->showMenu("searchHomozygosity");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchHomoDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
