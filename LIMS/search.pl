#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $solexa      = new Solexa;
my $cgiquery    = new CGI;

$solexa->printHeader();
my $dbh=$solexa->loadSessionId();
my $search      = $solexa->initSearchProjects();
	
$solexa->showMenu("search");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchDo.pl\" method=\"post\" name=\"myform\">" ;

$solexa->drawMask($search);

print "</form>" ;

$solexa->printFooter();
