#!/usr/bin/perl 

########################################################################
# Tim M Strom   August 2017
########################################################################

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Snv;
use DBI;

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my @cases        = $cgiquery->param('cases');
my @controls     = $cgiquery->param('controls');
my $casesref     = \@cases;
my $controlsref  = \@controls;

my $snv        = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

$snv->showMenu('searchDiffEx');
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->searchDiffExDoDo($dbh,$ref,$casesref,$controlsref);

$dbh->disconnect;

$snv->printFooter();
