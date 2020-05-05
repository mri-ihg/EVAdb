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
my $pedigree    = $cgi->param();

$snv->printHeader();
my ($dbh)    = $snv->loadSessionId();

$pedigree       = $snv->htmlencode($pedigree);
my $search   = $snv->initSearchComment($pedigree,$dbh);

$snv->showMenu("searchComment");
print "<span class=\"big\">Search Comment</span><br><br>" ;

print "<form action=\"searchCommentDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
