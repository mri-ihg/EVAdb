#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $cgi         = new CGI;
my $ref         = $cgi->Vars;
my $snv        	= new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$ref = $snv->htmlencodehash($ref);

$snv->showMenu('searchComment');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchResultsComment($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
