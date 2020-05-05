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
my $position    = $cgi->param('position');
my $name        = $cgi->param('name');

$snv->printHeader();
$snv->loadSessionId();

$name           = $snv->htmlencode($name);
$position       = $snv->htmlencode($position);
my $search      = $snv->initSearchPosition($position,$name);

$snv->showMenu("searchPosition");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchPositionDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
