#!/usr/local/bin/perl -w

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
my $snv          = new Solexa;

if (($ref->{name} eq '' or $ref->{password} eq '')) {
	$snv->printHeader();
	my $dbh=$snv->loadSessionId();
}
else {
	$snv->createSessionId($ref);
}

$snv->printFooter();
