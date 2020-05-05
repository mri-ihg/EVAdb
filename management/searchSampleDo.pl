#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use CGI::Carp qw(fatalsToBrowser);
use Snvedit;
use DBI;

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;

my $snv       = new Snvedit;

########################################################################
# main
########################################################################

$snv->printHeader();
my $dbh = $snv->loadSessionId();

$snv->showMenu('searchsample');

$snv->searchSample($dbh,$ref);

$dbh->disconnect;

$snv->printFooter();
