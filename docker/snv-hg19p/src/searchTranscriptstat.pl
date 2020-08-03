#!/usr/bin/perl 

########################################################################
# Tim M Strom   Juni 2010
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;
my $search      = $snv->initTranscriptstat();

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();
	
$snv->showMenu("searchTranscriptstat");
print "<span class=\"big\">Search</span><br><br>" ;

print "<form action=\"searchTranscriptstatDo.pl\" method=\"post\">" ;

$snv->drawMask($search);

print "</form>" ;

$snv->printFooter($dbh);
