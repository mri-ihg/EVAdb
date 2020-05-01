#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
#use lib '/srv/www/cgi-bin/mysql/test';
use Snv;

my $snv         = new Snv;
my $cgi         = new CGI;
my $mode        = $cgi->param('mode');
my $id          = $cgi->param('id');

$snv->printHeader();
my ($dbh)       = $snv->loadSessionId();
my $mask        = $snv->initAdmin();

$mode           = $snv->htmlencode($mode);
$id             = $snv->htmlencode($id);
	
$snv->showMenu("admin");
print "<span class=\"big\">Admin</span><br><br>" ;

print "<form action=\"adminDo.pl\" method=\"post\">" ;

if ($mode eq 'edit') {
	$snv->getShowAdmin($dbh,$id,$mask,'noprint');
}

$snv->drawMask($mask);

print $cgi->hidden(-name=>'mode',-default=>$mode);

print "</form>" ;

$snv->printFooter();
