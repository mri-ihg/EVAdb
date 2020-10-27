#!/usr/bin/perl

########################################################################
# Tim M Strom   Sept 2010
########################################################################

use strict;
use CGI;
BEGIN {require './Solexa.pm';}

my $cgiquery     = new CGI;
my $ref          = $cgiquery->Vars;
my $solexa       = new Solexa;

########################################################################
# main
########################################################################

$solexa->printHeader();
my ($dbh) =$solexa->loadSessionId();

$solexa->showMenu('searchSample');

print"<form name=\"myform\" action =\"libsheet.pl\" method=\"post\" >";

print "<input type=\"submit\" name=\"create_exome\" 
value='Create Libraries for Exome' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<input type=\"submit\" name=\"create_genome\" 
value='Create Libraries for Genome' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<input type=\"submit\" name=\"create_rnaseq\" 
value='Create Libraries for RNAseq' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<input type=\"submit\" name=\"create_chipseq\" 
value='Create Libraries for ChIPseq' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<input type=\"submit\" name=\"exome_sheet\" 
value='Exome Sheet' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<input type=\"submit\" name=\"genome_sheet\" 
value='Genome Sheet' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<input type=\"submit\" name=\"rnaseq_sheet\" 
value='RNAseq Sheet' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<input type=\"submit\" name=\"chipseq_sheet\" 
value='ChIPseq Sheet' >";
print "&nbsp;&nbsp;&nbsp;&nbsp;";

print "<br><br>";


my $mask = $solexa->initLibrarySheet();
$solexa->drawMask($mask,"nosubmit");
print "<br><br>";
$solexa->searchSample($dbh,$ref);

print "</form>";


$solexa->printFooter($dbh);
