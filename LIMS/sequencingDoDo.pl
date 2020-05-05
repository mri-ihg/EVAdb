#!/usr/bin/perl 

########################################################################
# Tim M Strom   May 2008
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $solexa      = new Solexa;
my $cgiquery    = new CGI;
my $ref         = $cgiquery->Vars;
my @check_id    = $cgiquery->param('checkbox');
my $checkboxref = \@check_id;

$solexa->printHeader();
my $dbh=$solexa->loadSessionId();

$solexa->showMenu();
print "<span class=\"big\">Sequencing sheet</span><br><br>" ;

$solexa->sequencingsheet($ref,$dbh,$checkboxref);


$solexa->printFooter();
