#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2011
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

my $solexa      = new Snvedit;

########################################################################
# main
########################################################################

$solexa->printHeader;
my ($dbh) = $solexa->loadSessionId();

$solexa->showMenu('importsamples');
print "<span class=\"big\">Import sample information</span><br><br>" ;

print qq#
<form action="importSamplesDo.pl" method="post" enctype="multipart/form-data">

Barcode<br>
<input type="radio" name="withbarcode" value="F">External tubes without sample barcode<br>
<input type="radio" name="withbarcode" value="T" checked>Internal tubes with sample barcode<br><br>

Comma separated csv-file<br />
<input name="file" type="file" size="50" maxlength="500000" accept="text/*"><br /><br />

<input type="submit" name="importsamples" 
value='Import Samples' >
&nbsp;&nbsp;&nbsp;&nbsp;


</form>
#;

$solexa->printFooter($dbh);
