#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use Snv;

my $cgiquery    = new CGI;
my $ref         = $cgiquery->Vars;

my $snv        	= new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$ref = $snv->htmlencodehash($ref);

$snv->showMenu('searchTrio');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchResultsTrio($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
