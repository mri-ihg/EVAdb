#!/usr/bin/perl

########################################################################
# Tim M Strom   Juni 2010
########################################################################

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path(-e));
use Snv;

########################################################################
# global variables
########################################################################

my $cgi             = new CGI;
my $ref             = $cgi->Vars;
my $snv             = new Snv;

########################################################################
# main
########################################################################

$snv->printHeader;
my ($dbh) = $snv->loadSessionId();

$ref = $snv->htmlencodehash($ref);

# delete beginning and trailing space
$snv->deleteSpace($ref);

my $mode= $ref->{"mode"};
delete($ref->{"mode"});
$snv->insertIntoAdmin($ref,$dbh,'user',$mode);

# select and display new entry
$snv->showMenu("admin");


$snv->showAllAdmin($dbh,$ref->{iduser});


$snv->printFooter();


