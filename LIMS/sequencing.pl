#!/usr/bin/perl 

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $snv         = new Solexa;
my $cgiquery    = new CGI;
my $search      = $snv->initSequencing();

$snv->printHeader();
my $dbh=$snv->loadSessionId();

$snv->showMenu("sequencing");
print "<span class=\"big\">Sequencing</span><br><br>" ;

print "<form action=\"sequencingDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
