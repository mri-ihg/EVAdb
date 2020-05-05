#!/usr/bin/perl 

########################################################################
# Tim M Strom   April 2011
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use CGI::Carp qw(fatalsToBrowser);
use Solexa;

my $cgiquery     = new CGI;
my $file         = $cgiquery->param('file');
my $ref          = $cgiquery->Vars;
my $samples      = new Solexa;

########################################################################
# main
########################################################################

$samples->printHeader;
my $dbh=$samples->loadSessionId();

$samples->showMenu("importtaqman");
print "<span class=\"big\">Import Taqman results</span><br><br>" ;

$samples->importTaqman($dbh,$ref,$file);

$dbh->disconnect;

$samples->printFooter();
