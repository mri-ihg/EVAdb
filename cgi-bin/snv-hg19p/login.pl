#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
BEGIN {require './Snv.pm';}
use WWW::CSRF qw(generate_csrf_token check_csrf_token CSRF_OK);

my $snv         = new Snv;

my ($csrf_field) = $snv->printHeader();
$snv->showMenu("login");
$snv->deleteSessionId();

my $demo = 0;

my $item  = "";
my $value = "";
my %logins = ();
open(IN, "/srv/tools/textreadonly.txt");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$logins{$item}=$value;
}
close IN;
my $csrfsalt = $logins{'csrfsalt'};

print "<span class=\"big\">Login</span><br><br>" ;

print qq(
<form action="loginDo.pl" method="post">
);

print $csrf_field, "\n<br>";

my $csrf_token = generate_csrf_token("test", $csrfsalt);
print qq(
<input name="wwwcsrf" type= "hidden" value="$csrf_token"><br>
);

print qq(
<table border="1" cellspacing="0" cellpadding="3">

	<tr>
	<td class="formbg">Name</td>
	<td class="formbg"><input name="name" value="" size="50" maxlength="100" autofocus></td>
	</tr>
	
	<tr>
	<td class="formbg">Password</td>
	<td class="formbg"><input name="password" type= "password" value="" size="50" maxlength="100"></td>
	</tr>

	<tr>
	<td class="formbg">YubiKey OTP</td>
	<td class="formbg"><input name="yubikey" type= "password" value="" size="50" maxlength="100"></td>
	</tr>

	<tr>
	<td class="formbg">&nbsp;</td>
	<td class="formbg">
	<input type="submit" value="Submit">
	<input type="reset"  value="Reset">
	</td>
	</tr>

</table>
</form>
);

# database access for exomevcfe.textmodules for footer and login_message

my ($dbh,$login_message) = $snv->login_message();

if($demo){
	
print qq(
<br><br>
<table class="help_table" width="700px" ><tbody>

<tr><td colspan="2">
<b><div class="big">Login</div></b>
<br>
Use <b>TestUser1</b> as name and password 
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
and copy-number variations are missing. Also, external data sets of <b>gnomAD</b>,
<b>OMIM</b>, <b>HGMD</b> and the functional predictions of <b>PolyPhen2</b>, 
<b>SIFT</b> and <b>CADD</b> are not installed in the demo version.
<br><br>
The application is available at <a href='https://github.com/mri-ihg'>GitHub</a>. Permission to use this work is granted under the
<a href="http://opensource.org/licenses/MIT">MIT License</a>.
<p style="text-align:center;"><img src="/EVAdb/evadb_images/exome-database-help-figure.png" width="600px"></p>
</td></tr>

<tr><td colspan="2">
<br>
<b><div class="big">Brief description of the 'Search Menu'</div></b>
<br>
</td></tr>

<tr><td>
<b>Samples with quality</b>
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
<b>De novo trio</b>
</td>
<td>
Search for de novo variants in trios of child and parents.
</td></tr>

<tr><td>
<b>Disease panels</b>
</td>
<td>
Search for all variants in a list of disease genes. 
List of disease genes can be added by datatbase administrators
and provide the functionality of in-silico panels. The demo version
contains the DDG2P gene list.
</td></tr>

<tr><td>
<b>Genes</b>
</td>
<td>
Search for all variants in a single gene.
</td></tr>

<tr><td>
<b>ClinVar/HGMD</b>
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
<b>Same variants</b>
</td>
<td>
Search for the same variants in different individuals.
</td></tr>

<tr><td>
<b>Region</b>
</td>
<td>
Search for all variants in a genomic region. 
</td></tr>

<tr><td>
<b>CNVs</b>
</td>
<td>
Not implemented in the demo version. Search for copy-number variations. 
</td></tr>

<tr><td>
<b>Coverage of genes</b>
</td>
<td>
Not implemented in the demo version. Shows the average sequence depth per exon.
</td></tr>

<tr><td>
<b>Coverage of panels</b>
</td>
<td>
Not implemented in the demo version. Shows the average sequence depth per exon
for all genes of a disease panel.
</td></tr>

<tr><td>
<b>Homozygosity</b>
</td>
<td>
Not implemented in the demo version. Regions of homozygosity.
</td></tr>

<tr><td>
<b>IBS</b>
</td>
<td>
Fuzzy search to find the proportion of shared rare variants between two individuals. 
</td></tr>

<tr><td>
<b>Variant annotations</b>
</td>
<td>
Single variants can be annotated by the user in respect of accuracy, allelic composition, inheritance and pathogenicity. 
Data cannot be entered in the demo version.  
</td></tr>

<tr><td>
<b>Case conclusions</b>
</td>
<td>
Exomes can be annotated in respect to analysis work flow.
Data cannot be entered in the demo version.  
</td></tr>

</tbody></table>
);
	
}
else{

print qq(
$login_message
);

my $news ="
<h1>News</h1>
21 August 2016. Variant Effect Predictor (Ensembl) added to Variant Detail Page (release 85).<br><br>
27 July 2016. ClinVar updated to version 20160707<br><br>
27 July 2016. HGMD updated to version 2016.2<br><br>
11 May 2016. Haploinsufficiency index substituted by ExAC pLI scores.<br><br>
09 September 2015. Haploinsufficiency index updated to version 3. DDG2P genes updated to version 20141118.<br><br>
09 September 2015. HGMD updated to version 2015.2<br><br>
08 September 2015. ClinVar annotations are now based on vcf-format. Detected variants should exactely
match ClinVar entries.<br><br>
07 September 2015. RNA seach added.<br><br>
24 July 2015. Integration of the IGV Browser into the user management so that a separate login is not required any longer.<br><br>
27 May 2015. The new version of the OMIM search uses the same full text search engine (Solr) as OMIM.<br> 
The search syntax is described at
<a href='http://omim.org/help/search'>OMIM Search Help</a>.<br>
Solr returns scores. The output is arranged from the highest to the lowest score.
";
}

$snv->printFooter($dbh);
