#!/usr/bin/perl

########################################################################
# Tim M Strom   August 2016
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $snv         = new Snv;

$snv->printHeader();
my ($dbh) = $snv->loadSessionId();


	
$snv->showMenu("help");
print "<span class=\"big\">Help</span><br><br>" ;

print "<ul><li><a href=\"#one\">Functionality</a></li>";
print "<li><a href=\"#two\">Analysis start</a></li>";
print "<li><a href=\"#three\">Searches</a></li>";
print "<li><a href=\"#four\">IGV, Variant Effect Predictor (VEP), SOLR</a></li>";
print "<li><a href=\"#five\">Comments</a></li>";
print "<li><a href=\"#six\">Conclusions</a></li>";
print "<li><a href=\"#seven\">Disease gene panels</a></li>";
print "<li><a href=\"#eight\">Brief description of 'Search buttons'</a></li>";
print "<li><a href=\"#nine\">Brief description of 'Result tables'</a></li>";
print "<li><a href=\"#ten\">Database schema</a></li></ul><br>";


print "<table class=\"outer\" width=\"600\">";

print "<tr ><td class=\"outer\">";
print "<hr id=\"one\" align=\"left\">";
print "<h1 >Functionality</h1>";
print "<hr align=\"left\">";
print "The <b>Exome Variant and Annotation Database (EVAdb)</b> combines variant calls with external data.
The web application is focused on the analysis of rare disease-causing variants
in single individuals or families.";
print "<p style=\"text-align:center;\"><img src=\"/EVAdb/evadb_images/exome-database-help-figure.png\" width=\"600px\" style=\"border-radius:20px\"></p>";
print "</td></tr>";

print "<tr ><td class=\"outer\">";
print "<hr id=\"two\" align=\"left\">";
print "<h1>Analysis start</h1>";
print "<hr align=\"left\">";
print "<p>Start your analysis with the menu item 'Samples with quality' to display quality measures.
Check whether the values are plausible (sex, contamination, sequencing amout, coverage, and number of variants).</p>";
print "<img src=\"/EVAdb/evadb_images/ExomeStat.png\" width=\"200\" style=\"border-radius:10px\"><br>";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<hr id=\"three\" align=\"left\">";
print "<h1>Searches</h1>";
print "<hr align=\"left\">";
print "<p>Start your searches with a 'left click' on the drop down icon.
The menu provides links to the most frequently used queries
and fills the search form with default values. The same context drop down menu is available in the menu item 'Samples'.</p>";
print "<img src=\"/EVAdb/evadb_images/PopUpMenu.png\" width=\"200\" style=\"border-radius:10px\"><br>";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<hr id=\"four\" align=\"left\">";
print "<h1>IGV, VEP, SOLR</h1>";
print "<hr align=\"left\">";
print "<p>Three external applications are integrated into EVAdb.<br><br>
All sequencing reads can be displayed in the <b>Integrative Genomics Viewer (IGV)</b>
by a 'left click' on the sample ID.
IGV has to be installed on the local computer and to be started before sequencing reads can be displayed.
A wrapper around IGV is used so that the same credential can be used as for EVAdb.
</p>";
print "<img src=\"/EVAdb/evadb_images/igv.png\" width=\"200\" style=\"border-radius:10px\"><br>";
print "<p><b>Variant Effect Predictor (VEP)</b> as provided by Ensembl can be display by invoking the
variant detail page by a click on 'idsnv' in every search result table.<br><br>
The OMIM search utilizes the same full-text seach engine <b>SOLR</b> as used by OMIM.
</p>";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<hr id=\"five\" align=\"left\">";
print "<h1>Comments</h1>";
print "<hr align=\"left\">";
print "<p>A 'left/middle click' on the 'browser window' icon opens the 'Variant annotation' page.
One can annotate the variant according to inheritance, and pathogenicity.
All annotated variants can be listed with the menu item 'Variant annotation'.</p>";
print "<img src=\"/EVAdb/evadb_images/comment.png\" width=\"200\" style=\"border-radius:10px\"><br>";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<hr id=\"six\" align=\"left\">";
print "<h1>Conclusions</h1>";
print "<hr align=\"left\">";
print "<p>Users can store conclusions for each sample. This feature can also be used to organize the analysis workflow.
All conclusions can be listed with the menu item 'Conclusions'.</p>";
print "<img src=\"/EVAdb/evadb_images/PopUpMenu.png\" width=\"200\" style=\"border-radius:10px\"><br>";
print "</td></tr>";
######################## Disease gene color ##############################################

print "<tr><td class=\"outer\">";
print "<hr id=\"seven\" align=\"left\">";
print "<h1>Disease gene panels</h1>";
print "<hr align=\"left\">";

print "
A color code can be used for the inheritance mode in disease gene
panels. It is currently implemented for the DDG2P panel which has been published by Decipher.
In EVAdb, the panel is currently named 'Mental retardation' and has been supplemented
with candidate genes.<br><br>";

print "<table class=\"vep_table2\" width=\"100%\">";
print qq(
<tr><th class='grey'>
Score
</th>
<th class='grey'>
Inheritance mode
</th></tr>

<tr><td class='diseaseGene1'>
1
</td>
<td class='grey'>
autosomal dominant confirmed
</td></tr>

<tr><td class='diseaseGene2'>
5
</td>
<td class='grey'>
autosomal dominant probable
</td></tr>

<tr><td class='diseaseGene3'>
9
</td>
<td class='grey'>
autosomal dominant possible
</td></tr>

<tr><td class='diseaseGene4'>
2
</td>
<td class='grey'>
autosomal recessive confirmed
</td></tr>

<tr><td class='diseaseGene5'>
6
</td>
<td class='grey'>
autosomal recessive probable
</td></tr>

<tr><td class='diseaseGene6'>
10
</td>
<td class='grey'>
autosomal recessive possible
</td></tr>

<tr><td class='diseaseGene7'>
3
</td>
<td class='grey'>
X-linked dominant confirmed
</td></tr>

<tr><td class='diseaseGene8'>
7
</td>
<td class='grey'>
X-linked dominant probable
</td></tr>

<tr><td class='diseaseGene9'>
11
</td>
<td class='grey'>
X-linked dominant possible
</td></tr>

<tr><td class='diseaseGene10'>
4
</td>
<td class='grey'>
X-linked recessive confirmed
</td></tr>

<tr><td class='diseaseGene11'>
8
</td>
<td class='grey'>
X-linked recessive probable
</td></tr>

<tr><td class='diseaseGene12'>
12
</td>
<td class='grey'>
X-linked recessive possible
</td></tr>

<tr><td class='diseaseGene13'>
13
</td>
<td class='grey'>
other i.e candidate
</td></tr>

</table><br>
);


######################## Result tables ###################################################
print "<tr><td class=\"outer\">";
print "<hr id=\"eight\" align=\"left\">";
print "<h1>Search buttons</h1>";
print "<hr align=\"left\">";

print "<table class=\"help_table\" width=\"100%\">";

print "<tr><td class=\"outer\">";
print "<b>Autosomal dominant</b>";
print "</td>";
print "<td class=\"outer\">";
print "Search for heterozygous and hemizygous variants.";
print "</td></tr>";

print qq(
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
and provide the functionality of in-silico panels.
</td></tr>

<tr><td>
<b>Coverage</b>
</td>
<td>
Shows the average sequence depth per exon.
</td></tr>

<tr><td>
<b>Coverage list</b>
</td>
<td>
Shows the average sequence depth per exon
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
Regions of homozygosity.
</td></tr>

<tr><td>
<b>CNVs</b>
</td>
<td>
Search for copy-number variations. 
</td></tr>

<tr><td>
<b>HGMD</b>
</td>
<td>
Search for variants contained in the Human Gene Mutation Database. 
</td></tr>

<tr><td>
<b>OMIM</b>
</td>
<td>
Full-text search in order to select genes from the OMIM database by phenotypic features. 
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
</td></tr>

<tr><td>
<b>Conclusions</b>
</td>
<td>
Exomes can be annotated in respect to analysis work flow and final assesment. 
</td></tr>

<tr><td>
<b>Quality control</b>
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

</table><br>
);



######################## Result tables ###################################################

print "<tr><td class=\"outer\">";
print "<hr id=\"nine\" align=\"left\">";
print "<h1>Result tables</h1>";
print "<hr align=\"left\">";
print "<table class=\"help_table\" width=\"100%\">";

print "<tr><td class=\"outer\">";
print "<b>n</b>";
print "</td>";
print "<td class=\"outer\">";
print "Numbering.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>idsnv</b>";
print "</td>";
print "<td class=\"outer\">";
print "Internal variant identifier (not stable).";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>IGV Comment</b>";
print "</td>";
print "<td class=\"outer\">";
print "Internal stable sample ID. Link to IGV (left click). Link to the 'Comment' page (right click) which provides a basis to annotate variants.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Chr</b>";
print "</td>";
print "<td class=\"outer\">";
print "Genomic position. Link to the UCSC Genome Browser.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Gene symbol</b>";
print "</td>";
print "<td class=\"outer\">";
print "Gene symbol. Variants can be attached to more than one gene. Intergenic variants are annotated with the upstream and downstream gene.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>NonSyn/Gene</b>";
print "</td>";
print "<td class=\"outer\">";
print "Number of non-synonymous variants in the EVAD. Number of loss-of-function variants in parenthesis.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>DGV</b>";
print "</td>";
print "<td class=\"outer\">";
print "Number of overlapping entries of the 'Database of Genomic Variants' (DGV).";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>OMIM</b>";
print "</td>";
print "<td class=\"outer\">";
print "Link to OMIM displaying genes with disease phenotype.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Mouse</b>";
print "</td>";
print "<td class=\"outer\">";
print "Link to Mouse Genome Informatics (MGI) displaying genes with mouse phenotypes.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Class</b>";
print "</td>";
print "<td class=\"outer\">";
print "SNVs and indels are called by SAMtools or GATK, deletions are called by Pindel, cnvs are called by ExomeDepth.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Function</b>";
print "</td>";
print "<td class=\"outer\">";
print "The following functional annotations are used. Annotations are performed by custom scripts. Alternative transcripts can lead to multiple annotations for a single variant. 
unknown, synonymous, missense, nonsense, stoploss, splice, nearsplice (+-50 bp), frameshift, indel, 5utr, 3utr, non-coding, miRNA, intronic, intergenic, regulation.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>ExAC pLI</b>";
print "</td>";
print "<td class=\"outer\">";
print "Link to the ExAC Browser. pLI = probability of LoF intolerance (values from 0 to 1).";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>pph2</b>";
print "</td>";
print "<td class=\"outer\">";
print "Functional prediction classification by PolyPhen2.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>pph2 prob</b>";
print "</td>";
print "<td class=\"outer\">";
print "Functional prediction scores by PolyPhen2.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Sift</b>";
print "</td>";
print "<td class=\"outer\">";
print "Functional prediction scores by Sift.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>CADD</b>";
print "</td>";
print "<td class=\"outer\">";
print "Functional prediction scores by CADD.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Cases</b>";
print "</td>";
print "<td class=\"outer\">";
print "Each sample belongs to a 'disease group'. 'Cases' denotes the number of samples in the disease group having the same variant.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Controls</b>";
print "</td>";
print "<td class=\"outer\">";
print "Each sample belongs to a 'disease group'. All samples belonging to other 'disease groups' are used as controls. 
'Controls' denotes the number of samples in the control groups having the same variant.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Variant alleles</b>";
print "</td>";
print "<td class=\"outer\">";
print "1=heterozygous, 2=homozygous.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>dbSNP</b>";
print "</td>";
print "<td class=\"outer\">";
print "Variant is listed in dbSNP. Link to dbSNP.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>avHet</b>";
print "</td>";
print "<td class=\"outer\">";
print "Average heterozygosity according to dbSNP";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>HGMD</b>";
print "</td>";
print "<td class=\"outer\">";
print "Variant is listed in the 'Human Gene Mutation Database' (HGMD). Link to HGMD.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>ClinVar</b>";
print "</td>";
print "<td class=\"outer\">";
print "Variant is listed in the ClinVar. Link to ClinVar.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>1000 Genomes AF</b>";
print "</td>";
print "<td class=\"outer\">";
print "Allele frequency according to the 1000 Genomes Project.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>ExAC ea</b>";
print "</td>";
print "<td class=\"outer\">";
print "Genotype count according to the ExAC Browser in the European population.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>ExAC aa</b>";
print "</td>";
print "<td class=\"outer\">";
print "Genotype count according to the ExAC Browser in the African population.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Kaviar AC</b>";
print "</td>";
print "<td class=\"outer\">";
print "Allele count according to the Kaviar database. Total number of alleles in parenthesis.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>SNV qual</b>";
print "</td>";
print "<td class=\"outer\">";
print "SNV callling quality according to SAMtools or GATK.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Genotype qual</b>";
print "</td>";
print "<td class=\"outer\">";
print "Genotype quality according to SAMtools or GATK.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>MapQual</b>";
print "</td>";
print "<td class=\"outer\">";
print "Mapping quality according to SAMtools or GATK.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Depth</b>";
print "</td>";
print "<td class=\"outer\">";
print "Number of reads covering the variant site.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>% Var</b>";
print "</td>";
print "<td class=\"outer\">";
print "Percentage of reads carrying the variant.";
print "</td></tr>";

print "<tr><td class=\"outer\">";
print "<b>Primer</b>";
print "</td>";
print "<td class=\"outer\">";
print "Link to ExonPrimer. Primers can be designed to amplify the variant for confirmation by Sanger sequencing.";
print "</td></tr>";

print "</table>";
print "</td></tr>";

######################## Database schema ###################################################

print qq(
<tr><td class="outer">
<hr id="ten" align="left">
<h1>Database scheme</h1>
<hr align="left">
<p>The scheme shows the core tables of EVAdb.</p>
<p style="text-align:center;"><img src="/EVAdb/evadb_images/EVAdb.png" width="600px" style="border-radius:20px"></p>
</td></tr>
);

print "</table>";

$snv->printFooter($dbh);
