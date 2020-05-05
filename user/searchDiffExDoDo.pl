#!/usr/bin/perl 

########################################################################
# Tim M Strom   August 2017
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use Snv;

my $cgi          = new CGI;
my $ref          = $cgi->Vars;
my $snv          = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

my @cases        = $cgi->param('cases');
my @controls     = $cgi->param('controls');
$ref             = $snv->htmlencodehash($ref);
@cases           = $snv->htmlencodearray(@cases);
@controls        = $snv->htmlencodearray(@controls);
my $casesref     = \@cases;
my $controlsref  = \@controls;

$snv->showMenu('searchDiffEx');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchDiffExDoDo($dbh,$ref,$casesref,$controlsref);

$dbh->disconnect;

$snv->printFooter();
