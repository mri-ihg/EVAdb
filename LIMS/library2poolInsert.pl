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
use DBI;

########################################################################
# global variables
########################################################################

#my $showedit        = 'F';
my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $solexa          = new Solexa;
my $personref       = "";
my $dbh             = "";
my @fields          =();
my @values          =();

my $sql             = "";
my $sth             = "";
my $id=$ref->{idpool};
my $forward  = qq#<meta http-equiv="refresh" content="0;  URL=pool.pl?id=$id&mode=edit">#;
########################################################################
# main
########################################################################

$solexa->printHeader($forward);

$dbh = $solexa->dbh;

# encoded name

# delete beginning and trailing space
$solexa->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$solexa->editLibrary2pool($ref,$dbh,'library2pool');
}
else {
	delete($ref->{"mode"});
	$solexa->insertIntoLibrary2pool($ref,$dbh,'library2pool');
}

# select and display new entry
#my $pool = "";
#my $id="";

#if ($showedit eq 'F') {
#	$solexa->showMenu("library2pool");
#	$solexa->showAllLibrary2pool($dbh,$ref->{idlibrary2pool});
#}
#else {
#	$pool = "";
#	$id=$ref->{idpool};
#	$pool = $solexa->initPool();
#	$solexa->showMenu("");
#	print "<span class=\"big\">Edit Pool</span><br><br>" ;
#	$solexa->showPool2library($dbh,$id);
#	print qq(<form action="poolInsert.pl" method="post" name=\"myform\">);
#	$solexa->getShowPool($dbh,$id,$pool,'noprint');
#	$solexa->drawMask($pool);
#	print $cgiquery->hidden(-name=>'mode',-default=>'edit');
#	print "</form>";
#}

$solexa->printFooter();


