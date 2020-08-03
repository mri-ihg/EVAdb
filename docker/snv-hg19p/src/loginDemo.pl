#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI::Carp qw(fatalsToBrowser);
BEGIN {require './Snv.pm';}

my $snv         = new Snv;

$snv->printHeader();
$snv->showMenu("login");
$snv->deleteSessionId();

print "<font size = 6>Login</font><br><br>" ;

print qq(
<form action="loginDo.pl" method="post">

<table border="1" cellspacing="0" cellpadding="3">

	<tr>
	<td class="cytoMaterial">Name</td>
	<td class="cytoMaterial"><input name="name" value="" size="50" maxlength="100" autofocus></td>
	</tr>
	
	<tr>
	<td class="cytoMaterial">Password</td>
	<td class="cytoMaterial"><input name="password" type= "password" value="" size="50" maxlength="100"></td>
	</tr>

	<tr>
	<td class="cytoMaterial">YubiKey OTP</td>
	<td class="cytoMaterial"><input name="yubikey" type= "password" value="" size="50" maxlength="100"></td>
	</tr>

	<tr>
	<td class="cytoMaterial">&nbsp;</td>
	<td class="cytoMaterial">
	<input type="submit" value="Submit">
	<input type="reset"  value="Reset">
	</td> 
	</tr>

</table>
</form>
);

print qq(
<br><br>
<table class="help_table" width="700px" ><tbody>

<tr><td colspan="2">
<b><div class="big">Login</div></b>
<br>
Use <b>TestUser1</b> for name and password 
to log into the demo version.
<br>
Leave the 'Yubikey' field blank. It can be
used for one-time password authentication.
<br><br>
</td></tr>

<tr><td colspan="2">
<b><div class="big">Functionality</div></b>
<br>
The <b>Exome Variant and Annotation Database</b> combines variant calls with external data.
The web application is focused on the analysis of rare disease-causing variants
in single individuals. 
<br><br>
Only part of the functionality is implemented in the demo version. 
It uses simulated <b>SNVs</b> and <b>small indels</b> whereas regions of homozygosity
and copy-number variations are missing. Also, external data sets of <b>ExAC</b>,
<b>OMIM</b>, <b>HGMD</b> and the functional predictions of <b>PolyPhen2</b>, 
<b>SIFT</b> and <b>CADD</b> are not installed in the demo version.
<br><br>
A download page for the database and web application is in preparation.
<p style="text-align:center;"><img src="/gif/exome-database-help-figure.png" width="600px"></p>
</td></tr>

<tr><td colspan="2">
<br>
<b><div class="big">Brief description of the 'Search buttons'</div></b>
<br>
</td></tr>
<tr><td>
<b>Autosomal dominant</b>
</td>
<td>
Search for heterozygous and hemizygous variants.
</td></tr>

<tr><td>
<b>Autosomal recessive</b>
</td>
<td>
Search for homozygous and compound heterozygous variants.
</td></tr>

<tr><td>
<b>Same variants</b>
</td>
<td>
Search for the same variants in different individuals.
</td></tr>

<tr><td>
<b>De novo trio</b>
</td>
<td>
Search for de novo variants in trios of child and parents.
</td></tr>

<tr><td>
<b>Genes</b>
</td>
<td>
Search for all variants in a single gene.
</td></tr>

<tr><td>
<b>Disease genes</b>
</td>
<td>
Search for all variants in a list of disease genes. 
List of disease genes can be added by datatbase administrators
and provide the functionality of in-silico panels. The demo version
contains the DDG2P gene list.
</td></tr>

<tr><td>
<b>Coverage</b>
</td>
<td>
Not implemented in the demo version. Shows the average sequence depth per exon.
</td></tr>

<tr><td>
<b>Coverage list</b>
</td>
<td>
Not implemented in the demo version. Shows the average sequence depth per exon
for all genes of a disease gene list.
</td></tr>

<tr><td>
<b>Region</b>
</td>
<td>
Search for all variants in a genomic region. 
</td></tr>

<tr><td>
<b>Homozygosity</b>
</td>
<td>
Not implemented in the demo version. Regions of homozygosity.
</td></tr>

<tr><td>
<b>CNVs</b>
</td>
<td>
Not implemented in the demo version. Search for copy-number variations. 
</td></tr>

<tr><td>
<b>HGMD</b>
</td>
<td>
Not implemented in the demo version. Search for variants contained in the Human Gene Mutation Database. 
</td></tr>

<tr><td>
<b>OMIM</b>
</td>
<td>
Not implemented in the demo version. Full-text search in order to select genes from the OMIM database by phenotypic features. 
</td></tr>

<tr><td>
<b>IBS</b>
</td>
<td>
Fuzzy search to find the proportion of shared rare variants between two individuals. 
</td></tr>

<tr><td>
<b>Comments</b>
</td>
<td>
Single variants can be annotated by the user in respect of accuracy, allelic composition, inheritance and pathogenicity. 
Data cannot be entered in the demo version.  
</td></tr>

<tr><td>
<b>Conclusions</b>
</td>
<td>
Exomes can be annotated in respect to analysis work flow.
Data cannot be entered in the demo version.  
</td></tr>

<tr><td>
<b>Exomes</b>
</td>
<td>
List all exomes and displays quality control measures. Right click on the sample ID
provides a <b>short cut</b> to the different search pages. This page is the most convenient
way to start an analysis.
</td></tr>

<tr><td>
<b>Samples</b>
</td>
<td>
List all sample information. Disease is a required feature.
</td></tr>

</tbody></table>
);

$snv->printFooter($dbh);
