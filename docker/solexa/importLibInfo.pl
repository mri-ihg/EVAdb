#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2011
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $solexa      = new Solexa;

########################################################################
# main
########################################################################

$solexa->printHeader;
my ($dbh) =$solexa->loadSessionId();

$solexa->showMenu("importLibInfo");
print "<span class=\"big\">Import library information (Bioanalyzer ....)</span><br>" ;
print "A click onto a button triggers the data import.<br>" ;
print "Data will be replaced by a second import.<br><br>" ;

print qq#
<form action="importLibInfoDo.pl" method="post" enctype="multipart/form-data">

To pool<br>
<input type="radio" name="forpool" value="F">False<br>
<input type="radio" name="forpool" value="T" checked>True<br><br>

Barcode<br>
<input type="radio" name="withbarcode" value="F">External tubes without pool barcode<br>
<input type="radio" name="withbarcode" value="T" checked>Internal tubes with pool barcode<br><br>

Comma separated csv-file<br />
<input name="file" type="file" size="50" maxlength="500000" accept="text/*"><br /><br />

<input type="submit" name="sheet" 
value='Exome Sheet' >
&nbsp;&nbsp;&nbsp;&nbsp;

<input type="submit" name="sheet" 
value='Genome Sheet' >
&nbsp;&nbsp;&nbsp;&nbsp;

<input type="submit" name="sheet" 
value='RNAseq Sheet' >
&nbsp;&nbsp;&nbsp;&nbsp;

<input type="submit" name="sheet" 
value='ChIPseq Sheet' >
&nbsp;&nbsp;&nbsp;&nbsp;

</form>
#;

$solexa->printFooter($dbh);
