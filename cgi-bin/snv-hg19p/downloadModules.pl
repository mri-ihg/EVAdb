#!/usr/bin/perl 

########################################################################
# Tim M Strom   Juni 2010
########################################################################

use strict;
BEGIN {require './Snv.pm';}

my $cgi         = new CGI;
my $snv         = new Snv;



$snv->printHeader();
my ($dbh) = $snv->loadSessionId();

#$pedigree       = $snv->htmlencode($pedigree);
	
$snv->showMenu("searchMito");
$snv->pageTitle("Download Modules");


$snv->tableheaderDefault();

#<div id="container">
#<table border="1" class="display compact">

print qq|

<thead>
<tr>
 <th></th><th>Category</th><th>Name</th><th>Download</th>
</tr>
</thead>
<tbody>
<tr><td></td><td>Accounts</td><td>Request account (external)</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>Accounts</td><td>Request account (internal)</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>ISO15189</td><td>IT Service report</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>ISO15189</td><td>Sample validation</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>LIMS</td><td>Sample manifest</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>Reference genome</td><td>HG19</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>Reference genome</td><td>HG19 Plus</td><td><a href="/hg19p/noPAR.hg19_decoy.fa"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>Reference genome</td><td>HG38</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>Sample import</td><td>External samplesheet</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.xlsx"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>Sample import</td><td>External samplesheet instructions</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>User manual</td><td>EVAdb Quickstart</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>User manual</td><td>EVAdb Clinical User manual</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
<tr><td></td><td>User manual</td><td>EVAdb User manual</td><td><a href="/downloads/import/IHG_External_Sample_Template_v2020.10.pdf"><img src="/EVAdb/cal/img/evadownload.png" width=25></a></td></tr>
</tbody>
</table>
</div>

|;



$snv->printFooter($dbh);
