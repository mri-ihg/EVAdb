#!/usr/bin/perl 

########################################################################
# Tim M Strom   June 2008
########################################################################

use strict;
use CGI;
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use CGI::Carp qw(fatalsToBrowser);
use Solexa;
use DBI;

my $mode      = "";
my $id        = "";
my $solexa    = new Solexa;
my $cgiquery  = new CGI;
my $project   = "";
my $dbh       = $solexa->dbh;

$mode         = $cgiquery->param('mode');
$id           = $cgiquery->param('id');
my $lid       = $cgiquery->param('lid');    # fuer Vorbelegung von Add to Pool in Edit library
my $idpool    = $cgiquery->param('idpool'); # fuer Vorbelegung von Add to Pool in Edit pool

$project = $solexa->initLibrary2pool($lid,$idpool);

$solexa->printHeader();

if ($mode eq 'edit') {
	$solexa->showMenu("");
	print "<span class=\"big\">Edit Library2Pool</span><br><br>" ;
}
else {
	$solexa->showMenu("library2pool");
	print "<span class=\"big\">New Library2Pool</span><br><br>" ;
}

print qq(<form action="library2poolInsert.pl" method="post" name="myform">);

if ($mode eq 'edit') {
	$solexa->getShowLibrary2pool($dbh,$id,$project,'noprint');
}

$solexa->drawMask($project);

print $cgiquery->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$solexa->printFooter();
