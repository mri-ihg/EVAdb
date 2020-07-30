#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2011
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $solexa      = new Snvedit;
my $importmtdnasamples = $solexa->initImportmtDNASamples();

########################################################################
# main
########################################################################

$solexa->printHeader;
my ($dbh) = $solexa->loadSessionId();

$solexa->showMenu("importmtdnasamples");
print "<span class=\"big\">Import mtDNA sample information</span><br><br>" ;

print qq#
<form action="importmtDNASamplesDo.pl" method="post" enctype="multipart/form-data">
Comma separated csv-file<br />
<input name="file" type="file" size="50" maxlength="500000" accept="text/*"><br /><br>
#;

$solexa->drawMask($importmtdnasamples);

print qq#
</form>
#;

$solexa->printFooter($dbh);
