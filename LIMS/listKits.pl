#!/usr/bin/perl

########################################################################
# Tim M Strom   Oct 2010
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;

my $snv          = new Solexa;

########################################################################
# main
########################################################################

$snv->printHeader();
my $dbh=$snv->loadSessionId();

$snv->showMenu("listKits");
print "<span class=\"big\">Search results</span><br><br>" ;

$snv->listKits($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
