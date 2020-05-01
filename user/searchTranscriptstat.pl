#!/usr/bin/perl -w

########################################################################
# Tim M Strom   Juni 2010
########################################################################

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
use Snv;
use DBI;

my $snv         = new Snv;
my $cgiquery    = new CGI;

my $search      = $snv->initTranscriptstat();

$snv->printHeader("","cgisessid");
my ($dbh) = $snv->loadSessionId();
	
$snv->showMenu("searchTranscriptstat");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchTranscriptstatDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter();
