#!/usr/bin/perl 

########################################################################
# Tim M Strom   April 2011
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

$solexa->printHeader();
my $dbh=$solexa->loadSessionId();

$solexa->showMenu();
print "<span class=\"big\">Update Plate Positions</span><br><br>" ;

$solexa->updateplatepositions($ref,$dbh);


$solexa->printFooter();
