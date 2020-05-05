#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
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
my $samples      = new Solexa;
my $forward      = "";
my $id           = 0;
########################################################################
# main
########################################################################

$samples->printHeader();
my $dbh=$samples->loadSessionId();

#$samples->showMenu("makePool");
#print "<span class=\"big\">Make Pool2</span><br><br>" ;

$id=$samples->makePoolExtern2($ref,$dbh);
$dbh->disconnect;

$forward  = qq#<meta http-equiv="refresh" content="0;  URL=pool.pl?id=$id&mode=edit">#;
print "$forward";

$samples->printFooter();
