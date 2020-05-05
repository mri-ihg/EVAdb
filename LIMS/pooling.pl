#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $snv         = new Solexa;
my $cgiquery    = new CGI;
my $search      = $snv->initPooling();

$snv->printHeader("","cgisessid");
my $dbh=$snv->loadSessionId();

	
$snv->showMenu("pooling");
print "<span class=\"big\">Pooling</span><br><br>" ;

print "<form action=\"poolingDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
