########################################################################
# Tim M Strom June 2010-2020
# Institute of Human Genetics
# Helmholtz Zentrum Muenchen
# Klinikum rechts der Isar, Technische Universitaet Muenchen
########################################################################

use strict;
package Snv;
#use warnings;

####### change only here #############

my $vcf                = 0;
my $hg19p              = 1;
my $genomegatk         = 0;
my $multisampletest    = 0;
my $multisampletesthardfilter    = 0;
my $mtdnagatk          = 0;
my $mm10               = 0;
my $genomemm10         = 0;
my $test               = 0;
my $demo               = 0;
my $mip                = 0;
my $mipcad             = 0;
my $rnahg19            = 0;
my $perspective        = 0;
my $fhcl               = 0;

my $rna_menu           = 1;

######################################
my $translocation_menu = 0;
my $sv_menu        = 0;
my $mtdna_menu     = 0;
my $cgidir         = "";
my $logindb        = "";
our $sampledb       = "";
my $maindb         = "";
my $rnadb          = "";
my $rnagenedb      = "";
our $coredb         = "exomehg19";
our $exomevcfe      = "";
my $solexa         = "solexa";
my $hgmdserver     = "SERVERNAME";
my $igvserver      = "";
my $igvdir         = "";
my $igvrnadir      = "/path/to/seq/analysis/exomehg19/";
my $igvgenomedir   = "/path/to/seq/analysis/exomehg19plus/";
my $snvqual        = "";
my $gtqual         = "";
my $popmax_af      = "";
my $solrurl        = "http://localhost:8983/solr/omim";
my $maxFailedLogin = 6;
my $vep            = 1; #use Variant Effect Predictor
our $vep_cmd         = "/usr/local/packages/seq/ensembl-tools-release-102/ensembl-vep/vep";
our $vep_fasta       = "/data/mirror/vep/homo_sapiens/102_GRCh37/Homo_sapiens.GRCh37.75.dna_sm.primary_assembly.fa";
our $vep_genesplicer = "/usr/local/packages/seq/GeneSplicer";
# should be changed only for demo data
my $cookie_only_when_https = 1;
my $libtype_default = 5; # initsearchfor exome,  select * from solexa.libtype
my $hg             = "hg19";
my $contextM       = "contextM";
my $giabradio      = 0;
my $giabform       = "";
my $performDEAnalysis = "/path/to/users/scripts/eclipse_workspace_wieland/Pipeline/performDEAnalysis.pl";
my $performDiffPeakCalling = "/path/to/users/scripts/eclipse_workspace_wieland/Pipeline/performDiffPeakCalling.pl";
my $wholegenome = "wholegenomehg19";

my $bamFileName = "merged.rmdup.bam";
my $bamIndexFileName = "merged.rmdup.bam.bai";
my $vcfRawFileName = "gatk.ontarget.haplotypecaller.vcf";


# Overload variables if necessary
if ($vcf) {
	$cgidir     = "/cgi-bin/mysql/snv-vcf";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=exomevcf;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-vcf/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19/";
	$snvqual    = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$vcfRawFileName = "ontarget.varfilter.vcf";
}
elsif ($hg19p) {
	$cgidir     = "/cgi-bin/mysql/snv-hg19p";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=exomehg19plus;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-hg19p/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 1;
}
elsif ($genomegatk) {
	$cgidir     = "/cgi-bin/mysql/snv-genomegatk";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=genomegatk;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-genomegatk/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 1;
	$sv_menu    = 1;
	$translocation_menu = 1;
	$libtype_default = 1; #genome
	$contextM   = "contextMg"; #contextmenu for genomes
	$giabradio  = 1;
	$giabform   = 1;
}
elsif ($multisampletest) {
	$cgidir     = "/cgi-bin/mysql/snv-multisampletest";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=multisampletest;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-multisampletest/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 1;
	$sv_menu    = 1;
	$translocation_menu = 1;
	$libtype_default = 1; #genome
	$contextM   = "contextMg";
	$giabradio  = 1;
	$giabform   = 1;
}
elsif ($multisampletesthardfilter) {
	$cgidir     = "/cgi-bin/mysql/snv-multisampletesthardfilter";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=multisampletesthardfilter;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-multisampletesthardfilter/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 1;
	$sv_menu    = 1;
	$translocation_menu = 1;
	$libtype_default = 1; #genome
	$contextM   = "contextMg";
	$giabradio  = 1;
	$giabform   = 1;
}
elsif ($mtdnagatk) {
	$cgidir     = "/cgi-bin/mysql/snv-mtdnagatk";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=mtdnagatk;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-mtdnagatk/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/mtdnagatk/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 1;
	$libtype_default = 8; #mtDNA
}
elsif ($mm10) {
	$cgidir     = "/cgi-bin/mysql/snv-mm10";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=exomemm10;host=localhost";
	$coredb     = "mm10";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-hg19p/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$hg         = "mm10";
	$vep        = 0;
	#$rnadb      = "rnahg19";
	#$rnagenedb  = "exomevcf";
	#$mtdna_menu = 1;
}
elsif ($genomemm10) {
	$cgidir     = "/cgi-bin/mysql/snv-genomemm10";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=mm10genomegatk;host=localhost";
	$coredb     = "mm10";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-genomemm10/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$hg         = "mm10";
	$vep        = 0;
	$sv_menu    = 1;
	$translocation_menu = 1;
	$libtype_default = 1; #genome
}
elsif ($test) {
	$cgidir     = "/cgi-bin/mysql/test";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=exomevcf;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/test/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19/";
	$snvqual    = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 0;
	$vcfRawFileName = "ontarget.varfilter.vcf";
}
elsif ($demo) {
	$cgidir     = "/cgi-bin/mysql/snv-vcf";
	$logindb    = "exomewrite";
	$sampledb   = "exomecore";
	$maindb     = "database=exomevariant;host=localhost";
	$exomevcfe  = "exomewrite";
	$coredb     = "hg19";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-vcf/wrapper.pl";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevariant";
	$vep        = 0;
	$cookie_only_when_https = 0;
	$rna_menu   = 0;
	$maxFailedLogin = 10000;
}
elsif ($mip) {
	$cgidir     = "/cgi-bin/mysql/snv-mip";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=MIP_RLS;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-mip/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$libtype_default = 9; #mip
}
elsif ($mipcad) {
	$cgidir     = "/cgi-bin/mysql/snv-mipcad";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=MIP_CAD;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-mipcad/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$libtype_default = 9; #mip
}
elsif ($rnahg19) {
	$cgidir     = "/cgi-bin/mysql/snv-rnahg19";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=rnahg19;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-rnahg19/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$libtype_default = 2; #rna
}
elsif ($perspective) {
	$cgidir     = "/cgi-bin/mysql/snv-perspective";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=PERSPECTIVE;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-perspective/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 1;
}
elsif ($fhcl) {
	$cgidir     = "/cgi-bin/mysql/snv-fhcl";
	$logindb    = "exomevcfe";
	$sampledb   = "exomehg19";
	$maindb     = "database=fhcl;host=localhost";
	$coredb     = "hg19";
	$exomevcfe  = "exomevcfe";
	$igvserver  = "https://SERVERNAME/cgi-bin/mysql/snv-fhcl/wrapper.pl";
	$igvdir     = "/path/to/seq/analysis/exomehg19plus/";
	$gtqual     = "30";
	$rnadb      = "rnahg19";
	$rnagenedb  = "exomevcf";
	$mtdna_menu = 0;
	$popmax_af  = 0.01;
}
else { ();
	exit;
}
    
my $hgmito        = "hg38";
my $dbsnp         = "dbSNP 142";
my $ucscSite      = "genome-euro";
my $hg19_coords   = "hgmd_hg19_vcf"; # hgmd table
my $rssnplink     = qq{"<a href='https://www.ncbi.nlm.nih.gov/SNP/snp_ref.cgi?type=rs&rs=",v.rs,"' title='dbSNP'>",v.rs,"&nbsp;</a>"};
my $exac_link  = qq{"<a href='https://gnomad.broadinstitute.org/variant/",evs.chrom,"-",evs.start,"-",evs.refallele,"-",evs.allele,"' title='ExAC'>",evs.homref,"--",evs.het,"--",evs.homalt,"</a>"};
my $exac_ae_link  = qq{"<a href='https://gnomad.broadinstitute.org/variant/",evs.chrom,"-",evs.start,"-",evs.refallele,"-",evs.allele,"' title='ExAC'>",evs.ea_homref,"--",evs.ea_het,"--",evs.ea_homalt,"</a>"};
my $exac_aa_link  = qq{"<a href='https://gnomad.broadinstitute.org/variant/",evs.chrom,"-",evs.start,"-",evs.refallele,"-",evs.allele,"' title='ExAC'>",evs.aa_homref,"--",evs.aa_het,"--",evs.aa_homalt,"</a>"};
my $exac_gene_link= qq{"<a href='http://gnomad.broadinstitute.org/awesome?query=",exac.transcript,"' title='gnomAD'>",ROUND(exac.pLI,2),"</a>"};
my $kaviar_link   = qq{"<a href='http://db.systemsbiology.net/kaviar/cgi-pub/Kaviar.pl?chr=",k.chrom,"&frz=$hg&onebased=1&pos=",k.start,"' title='Kaviar'>",k.ac,"&nbsp;&nbsp;(",k.an,")</a>"};
my $omimlink      = qq{"<a href='https://www.ncbi.nlm.nih.gov/omim/",g.omim,"' title='OMIM'>",g.omim,"</a>"};
my $ucsclink      = qq{"<a href='https://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hg\&highlight=$hg.",v.chrom,":",v.start-1,"-",v.end,"\&position=",v.chrom,":",v.start-1,"-",v.end,"' title='UCSC Browser'>",v.chrom,":",v.start,"-",v.end-1,"</a>"," "};
my $ucsclinkmito  = qq{"<a href='https://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hgmito\&highlight=$hgmito.",v.chrom,":",v.start-1,"-",v.end,"\&position=",v.chrom,":",v.start-1,"-",v.end,"' title='UCSC Browser'>",v.chrom,":",v.start,"-",v.end-1,"</a>"," "};
my $genelink      = qq{"<a href='searchGene.pl?g.genesymbol=",g.genesymbol,"' title='All in-house variants per gene'>",g.genesymbol,"</a>"};
my $mgiID         = qq{"<a href='http:///www.informatics.jax.org/marker/",mo.mgiID,"' title='MGI mouse database'>",mo.mgiID,"</a>"};
my $primer        = qq{"<a href='https://ihg.helmholtz-muenchen.de/cgi-bin/primer/ExonPrimerPos.pl?db=hg19&chrom=",v.chrom,"&start=",v.start,"&end=",v.end-1,"' title='Primer design'>Primer</a>"};
my $clinvarlink   = qq{"<a href='https://www.ncbi.nlm.nih.gov/clinvar/?term=",cv.rcv,"[alleleid]'>",cv.path,"</a>"};
my @allowedprojects = ();
my $text          = "/srv/tools/textreadonly.txt"; #database
my $text2         = "/srv/tools/textreadonly2.txt"; #yubikey id and api
#my $usersxml      = "/srv/tools/users.xml";
my $user          = "";
my $role          = "";
my $burdentests   = "";
my $dbedit        = 0;
my $csrfsalt      = "";
my %options = ('MaxAge' => 10800); #for WWW::CSRF 3 hours, same as session cookie

my $glabels       = "";
my $gvalue        = "";
my $gvalueall     = "";
my $gvalues       = "";
my $warningbg     = "#e5cab5";
my $warningtdbg   = "class='warning'";
my $green         = "class='green'";


$glabels          = "unknown, syn, missense, nonsense, stoploss, splice, nearsplice, frameshift, indel, 5-UTR, 3-UTR, non-coding, mirna, intronic, intergenic, regulation";
$gvalue           = "unknown, no, missense, nonsense, stoploss, splice, no, frameshift, indel, no, no, no";
$gvalueall        = "unknown, syn, missense, nonsense, stoploss, splice, nearsplice, frameshift, indel, 5utr, 3utr, noncoding, mirna, intronic, intergenic, regulation";
$gvalues          = "unknown, syn, missense, nonsense, stoploss, splice, nearsplice, frameshift, indel, 5utr, 3utr, noncoding, mirna, intronic, intergenic, regulation";

my $dominant_col  = "#ffeddc";
my $recessiv_col  = "#bac7db";
my $candidate_col = "#d7e2be";

use CGI;
use CGI::Plus;
use CGI::Session qw/-ip-match/;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use DBI::Profile;
use Crypt::Eksblowfish::Bcrypt;
use File::Basename;
use Auth::Yubikey_WebClient;
use Tie::IxHash;
use Apache::Solr;
use HTML::Entities;
use WWW::CSRF qw(generate_csrf_token check_csrf_token CSRF_OK);


my $gapplication="Exome";
my $igvport=60151;
my $cgi = new CGI;
#my $sess_id = $cgi->cookie($gapplication);
my $sess_id =  ( defined  ($cgi->cookie($gapplication)) ?  $cgi->cookie($gapplication) : "" );
my $igvserver2         = "'$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam','\&index=$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam.bai','\&locus=',v.chrom,'\:',v.start,'-',v.end,'\&merge=true\&name=',s.name";
my $igvserver2vcf      = "'$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam','\&index=$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam.bai','\&locus=',v.chrom,'\:',v.pos,'-',v.pos+1,'\&merge=true\&name=',s.name";
my $igvserver2vcftumor = "'$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam,','$igvserver%3Fsid=$sess_id%26sname=',s.tumorcontrol,'%26file=merged.rmdup.bam','\&locus=',v.chrom,'\:',v.pos,'-',v.pos+1,'\&merge=true\&name=',s.name,',',s.tumorcontrol";
my $igvserversv        = "'$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam','\&index=$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam.bai','\&locus=',sv.chrom,'\:',sv.start,'-',sv.end,'\&merge=true\&name=',s.name";
my $igvserverTrans1    = "'$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam','\&index=$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam.bai','\&locus=',t.chrom1,'\:',t.pos1,'-',t.pos1,'\&merge=true\&name=',s.name";
my $igvserverTrans2    = "'$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam','\&index=$igvserver%3Fsid=$sess_id%26sname=',s.name,'%26file=merged.rmdup.bam.bai','\&locus=',t.chrom2,'\:',t.pos2,'-',t.pos2,'\&merge=true\&name=',s.name";

##my $session     = CGI::Session->load($sess_id) or die CGI::Session->errstr;
#$igvport        = $session->param('igvport');

#my $igvpos      = qq#group_concat(DISTINCT '<a href="http://localhost:$igvport/goto?locus=',v.chrom,'\:',v.start,'-',v.end, '"', ' title="Navigate within IGV">igv</a>' separator '<br>')#;

sub new {
	my $class = shift;
	my $self = {};
	bless $self,$class;
	return $self;
}
########################################################################
# igv
########################################################################
sub igv {
my $sample = shift;
my $bam    = "";
#(SELECT ss.sbam FROM $sampledb.sample ss WHERE ss.name = $sample)
#my $igv = "'<a href=http://localhost:$igvport/load?file=$bam\&genome=mm9\&merge=true>$sample</a>'";
my $igv = qq#'<a href="http://localhost:$igvport/load?file=https://$igvserver',(SELECT ss.sbam FROM $sampledb.sample ss WHERE ss.name = \'$sample\'),'\&genome=hg19\&merge=true">$sample</a>'#;
return($igv);
}

########################################################################
# igvfile
########################################################################
sub igvfile {
my $sample      = shift;
my $file        = shift;
my $dbh         = shift;
my $noprint     = shift;
my $out         = "";
my $dir         = "";
my $tmpdir      = "";
my $tmp         = "";
my $igvfile     = "";

my $query = "
SELECT sbam FROM $sampledb.sample WHERE name = '$sample'
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$dir = $out->fetchrow_array;
if ($dir ne "") {
	$dir = dirname($dir);
	$dir = $dir . "/" . $file;
	$tmpdir = $igvdir . $dir;
	
	if (-e $tmpdir) {

		if ($file eq "trio.seg") {
			$tmp = "Trio_";
		}
		if ($file eq "allele_ratio.seg") {
			$tmp = "Allele_Ratio_";
		}
		if ($file eq "ExomeCount.seg") {
			$tmp = "CNV_";
		}
		if ($file eq "ExomeDepthSingle.seg") {
			$tmp = "CNV_";
		}
		if ($file eq "refSeqCoveragePerTarget.seg") {
			$tmp = "RefSeqCov_";
		}
		$igvfile = "<a href=\"http://localhost:$igvport/load?file=$igvserver%3Fsid=$sess_id%26sname=$sample%26file=$file&merge=true\" title=\"IGV\">$tmp$sample</a>";
		if ($noprint ne 'noprint') {
			print " $igvfile";
		}
	}
}
return($igvfile);
}
########################################################################
# cnvfile
########################################################################
sub cnvfile {
my $sample      = shift;
my $dbh         = shift;
my $out         = "";
my $dir         = "";
my $tmpdir      = "";
my $cnvfile     = "";
my $file        = "exomeDepth.intersect2.html";

my $query = "
SELECT sbam FROM $sampledb.sample WHERE name = '$sample'
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$dir = $out->fetchrow_array;
if ($dir ne "") {
	$dir = dirname($dir);
	$dir =  $dir . "/" . $file;
	$tmpdir = $igvdir . $dir;
	if (-e $tmpdir) {
		$cnvfile = "<a href=$igvserver?sid=$sess_id&sname=$sample&file=$file>$sample</a>";
	}
}
return($cnvfile);
}

########################################################################
# getBamByName called from wrapper.pl, provided path to file, check authorization
########################################################################
sub getBamByName {
my $dbh   = shift;
my $name  = shift;
my $out   = "",
my $dir   = "";
my $allowedprojects = &allowedprojects();
my $query = "
SELECT sbam FROM $sampledb.sample WHERE name = ?
AND $allowedprojects
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($name) || die print "$DBI::errstr";
$dir = $out->fetchrow_array;
return($dir);
}

########################################################################
# readPng called from wrapper.pl, provided path to file, check authorization
########################################################################
sub readPng {
my $self      = shift;
my $dbh       = shift;
my $file      = shift;
my $name      = shift;
my $dir       = "";

$file =~ s/[^A-Za-z0-9.\-_\/]*//g;
$dir  = &getBamByName($dbh,$name);
$dir  = dirname($dir);
$file = $igvdir . "/" . $dir . $file;

open (IN, "<", "$file");
while (<IN>) {
	binmode STDOUT;
	print;
}

}
########################################################################
# readPng2 called from wrapper.pl, provided path to file, check authorization
########################################################################
sub readPng2 {
my $self      = shift;
my $dbh       = shift;
my $file      = shift;
my $name      = shift;
my $dir       = "";

$file =~ s/[^A-Za-z0-9.\-_\/]*//g;
#$dir  = &getBamByName($dbh,$name);
#$dir  = dirname($dir);
#$file = $igvdir . "/" . $dir . $file;

open (IN, "<", "$file");
while (<IN>) {
	binmode STDOUT;
	print;
}

}
########################################################################
# checkigv called from wrapper.pl, provided path to file, check authorization
########################################################################

sub checkigv {
my $self      = shift;
my $sname     = shift;
my $dbh       = shift;
my $allowedprojects = &allowedprojects();
my $libtype   = "";
my $dir       = "";

my $query   = "
SELECT sbam,es.idlibtype
FROM      $sampledb.sample s
LEFT JOIN $sampledb.exomestat es ON s.idsample=es.idsample
WHERE $allowedprojects
AND name = ?
LIMIT 1
";
my $out   = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($sname) || die print "$DBI::errstr";
($dir,$libtype)   = $out->fetchrow_array;
if ($dir eq "") {
	return 'NOT_ALLOWED';
}
$dir      = dirname($dir);
if ($libtype == 2) {
	$dir      = "$igvrnadir/$dir";
}
elsif ($libtype == 1) {
	$dir      = "$igvgenomedir/$dir";
}
else {
	$dir      = "$igvdir/$dir";
}

return $dir;
}
########################################################################
# cnvnator
########################################################################
sub cnvnator {
my $sample      = shift;
my $dbh         = shift;
my $filetype    = shift;
my $out         = "";
my $dir         = "";
my $tmpdir      = "";
my $cnvfile     = "";
my $file        = "";

my $query = "
SELECT sbam FROM $sampledb.sample WHERE name = '$sample'
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$dir = $out->fetchrow_array;
if ($dir ne "") {
	$dir = dirname($dir);
	if ($filetype eq 'breakdancer') {
		$file = "breakdancer/breakdancer.html";
		$dir = $dir . "/breakdancer/breakdancer.html";
		$tmpdir = $igvdir . $dir;
	}
	else {
		$file = "merged.rmdup.cnvnator.unique.minusGAP.minusDup.minusDGV.html";
		$dir = $dir . "/merged.rmdup.cnvnator.unique.minusGAP.minusDup.minusDGV.html";
		$tmpdir = $igvdir . $dir;
		if (!-e $tmpdir) {
			$file = "merged.rmdup.cnvnator.unique.minusGAP.minusDup.minusDGV.exons.html";
			$dir =~ s/minusDGV/minusDGV.exons/;
			$tmpdir = $igvdir . $dir;
		}
		$filetype = 'cnvnator';
	}
	if (-e $tmpdir) {
		$cnvfile = "<a href='$igvserver?sid=$sess_id&sname=$sample&file=$file'>$filetype\_$sample</a>";
	}
}
return($cnvfile);
}
########################################################################
# ucsclink
########################################################################
sub ucsclink{
my $pos  = shift;
my $show = shift;

my $link = "<a href='http://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hg\&position=$pos' title='UCSC Browser'>$show</a>";
return($link);
}
########################################################################
# igvlink
########################################################################
sub igvlink{
my $dbh      = shift;
my $name     = shift;
my $chromtmp = shift;
my $link     = "";
my ($chrom,$start,$end,$class,$ref,$alt) = split(/\s+/,$chromtmp);
my (@name)   = split(/\s+/,$name); 
my $query    = "";
my $out      = "";
my $tmplink  = "";
my $bam      = "";


foreach $name (@name) {
	#$query = "SELECT sbam FROM $sampledb.sample WHERE name = ?";
	#$out = $dbh->prepare($query) || die print "$DBI::errstr";
	#$out->execute($name) || die print "$DBI::errstr";
	#$bam = $out->fetchrow_array;
	$tmplink = qq(<a href="http://localhost:$igvport/load?
	file=$igvserver%3Fsid=$sess_id%26sname=$name%26file=merged.rmdup.bam&
	index=$igvserver%3Fsid=$sess_id%26sname=$name%26file=merged.rmdup.bam.bai&
	locus=$chrom:$start-$end&merge=true&name=$name"
	title="Open sample in IGV">$name </a> );
	$link .= "$tmplink<br>";
}

return($link);
}
########################################################################
# igvlinkRNA
########################################################################
sub igvlinkRNA{
my $dbh      = shift;
my $name     = shift;
my $chromtmp = shift;
my $link     = "";
my ($chrom,$start,$end,$class,$ref,$alt) = split(/\s+/,$chromtmp);
my (@name)   = split(/\s+/,$name); 
my $query    = "";
my $out      = "";
my $tmplink  = "";
my $bam      = "";


foreach $name (@name) {
	#$query = "SELECT sbam FROM $sampledb.sample WHERE name = ?";
	#$out = $dbh->prepare($query) || die print "$DBI::errstr";
	#$out->execute($name) || die print "$DBI::errstr";
	#$bam = $out->fetchrow_array;
	$tmplink = qq(<a href="http://localhost:$igvport/load?
	file=$igvserver%3Fsid=$sess_id%26sname=$name%26file=merged.rmdup.bam&
	index=$igvserver%3Fsid=$sess_id%26sname=$name%26file=merged.rmdup.bam.bai&
	merge=true&name=$name"
	title="Open sample in IGV">$name </a> );
	$link .= "$tmplink<br>";
}

return($link);
}
########################################################################
# ucsclink2
########################################################################
sub ucsclink2{
my $all     = shift;
my $link    = "";
my ($chrom,$start,$end,$class,$ref,$alt);
my $startm1;
my $startp1;
my $endm1;
my $endp1;
my $indel;
my (@all)=split(/\|/,$all); # if more than one link

foreach $all (@all) {
($chrom,$start,$end,$class,$ref,$alt)=split(/\s+/,$all);
if (!defined($class)) {$class = "";}
if (!defined($ref)) {$ref = "";}
if (!defined($alt)) {$alt = "";}
$startm1 = $start-1;
$startp1 = $start+1;
$endm1   = $end-1;
$endp1   = $end+1;
$indel   = length($alt)-length($ref);

if ($class eq "indel") {
	if ($indel > 0) { #insertion
		if ($link ne "") { #if more than one link
			$link .= "<br>"
		}
		$link .= "<a href='http://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hg\&highlight=$hg.$chrom:$start-$end\&position=$chrom:$start-$end' title='UCSC Browser'>$chrom:$start-$end</a>";
	}
	if ($indel < 0) { #deletion
		if ($link ne "") { #if more than one link
			$link .= "<br>"
		}
		$link .= "<a href='http://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hg\&highlight=$hg.$chrom:$start-$endp1\&position=$chrom:$start-$endp1' title='UCSC Browser'>$chrom:$startp1-$end</a>";
	}
}
else {
	if ($link ne "") { #if more than one link
		$link .= "<br>"
	}
	$link .= "<a href='http://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hg\&highlight=$hg.$chrom:$startm1-$end\&position=$chrom:$startm1-$end' title='UCSC Browser'>$chrom:$start-$endm1</a>";
}
} #end foreach

return($link);
}
########################################################################
# ucsclinksv
########################################################################
sub ucsclinksv{
my $all     = shift;
my $link    = "";
my ($chrom,$start,$end);

($chrom,$start,$end)=split(/\s+/,$all);

$link .= "<a href='http://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hg\&highlight=$hg.$chrom:$start-$end\&position=$chrom:$start-$end' title='UCSC Browser'>$chrom:$start-$end</a>";

return($link);
}
########################################################################
# ucsclinkTrans
########################################################################
sub ucsclinkTrans{
my $all     = shift;
my $link    = "";
my ($chrom,$start,$end);
my $start_window;
my $end_window;
my (@all)=split(/\|/,$all); # if more than one link

foreach $all (@all) {
($chrom,$start,$end)=split(/\s+/,$all);
$end          = $end+1;
$start_window = $start-99;
$end_window   = $end+98;

if ($link ne "") { #if more than one link
	$link .= "<br>"
}
$link .= "<a href='http://$ucscSite.ucsc.edu/cgi-bin/hgTracks?db=$hg\&highlight=$hg.$chrom:$start-$end\&position=$chrom:$start_window-$end_window' title='UCSC Browser'>$chrom:$start-$end</a>";

} #end foreach

return($link);
}
########################################################################
# omim
########################################################################
sub omim {
my $dbh         = shift;
my $omim        = shift;
my @omim        = ();
my $tmp         = "";
my $query       = "";
my $out         = "";
my @res         = "";
my $mode        = "";
my $diseases    = "";

if (($omim ne "") and ($omim ne "0")) {
	$_=$omim;
	s/^\s+//g;
	s/\s+$//g;
	$omim     = $_;
	@omim     = split(/\s+/,$omim);
	$omim     = "";
	$diseases = "";
	$mode     = "";
	foreach $tmp (@omim) {
		if ($tmp != 0) {
		$query = "SELECT 
			  GROUP_CONCAT(DISTINCT omimdisease,' ',inheritance,' ',disease separator '\n'),
			  GROUP_CONCAT(DISTINCT inheritance separator ' '),
			  GROUP_CONCAT(DISTINCT inheritance,' ',disease separator '<br>')
			  FROM $sampledb.omim WHERE omimgene=$tmp";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute() || die print "$DBI::ersessionrstr";
		@res = $out->fetchrow_array;
		$omim .= "<a href='http://www.ncbi.nlm.nih.gov/omim/$tmp' title='$res[0]'>$tmp</a><br>";
		$mode .= "$res[1]<br>";
		$diseases .= "$res[2]<br>";
		}
	}
}
else {
	$omim     = "";
	$mode     = "";
	$diseases = "";
}

return($omim,$mode,$diseases);
}

########################################################################
# omim solr
########################################################################

sub querySolr(){
     my $query   = shift;
     my $prefix  = shift;
     
     if ($prefix ne "") {
     	$query = "$prefix:($query)";
     }

     my $solr    = Apache::Solr->new(server => $solrurl);
     
     my $results = $solr->select(q => $query, fl => "idgene", fl =>"score");
     unless ($results->errors =~ /OK/) {
	print "<br>";
     	print $results->errors;
	print "<br>Is the server running?";
	exit(1);
     }
     #print Dumper($results);

     if(%{$results->{ASR_decoded}->{spellcheck}->{suggestions}}){
         my %suggestions = %{$results->{ASR_decoded}->{spellcheck}->{suggestions}};
         my $spellchecked = $query;
         foreach my $key(keys %suggestions){
             $spellchecked =~ s/$key/$suggestions{$key}->{suggestion}[0]/;
;
         }
         print "Did you mean $spellchecked instead of $query?<br>";
     }

     my %idgenes;
     while(my $doc = $results->nextSelected()){
         foreach(@{$doc->{ASD_fields_h}->{idgene}}){
             unless($idgenes{$_->{content}}){
		 $idgenes{$_->{content}} =$doc->{ASD_fields_h}{score}[0]->{content};
             }
         }
     }
     return \%idgenes;
}
########################################################################
# login_succeeded
########################################################################
sub login_succeeded {
my $user         = shift;
my $dbh          = shift;
my $failed_last  = "";
my $mylocaltime  = &mylocaltime;

#$dbh->{Profile} = 4;
#$dbh->{LongTruncOk} = 1;
my $query = "SELECT failed_last FROM $logindb.user WHERE name=?";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";
$failed_last = $out->fetchrow_array;

# set login counter in exomehg19.user
if ($failed_last <= $maxFailedLogin) {
	$query = "update $logindb.user
		SET succeeded_all=succeeded_all+1, failed_last=0, lastlogin='$mylocaltime'
		WHERE name=?";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($user) || die print "$DBI::errstr";
}
else {
	printHeader();
	print "Account disabled<br>";
	exit(1);
}


}
########################################################################
# login_failed
########################################################################
sub login_failed {
my $user         = shift;
my $dbh          = shift;
my $failed_last  = "";

my $query = "update $logindb.user
	SET failed_all=failed_all+1, failed_last=failed_last+1
	WHERE name=?";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";

}

########################################################################
# create authentication sessionid
########################################################################

sub createSessionId {
my $self      = shift;
my $ref       = shift;
my $user      = $ref->{name};
my $password  = $ref->{password};
my $otp       = $ref->{yubikey};
my $yubikeyOK = 0;
my %yubikey   = ();
my $item      = "";
my $value     = "";
my %logins    = ();
my $yubikey   = "";
my $password_stored = "";
my $yubikey_stored  = "";
my $igvport_stored  = "";
my $cgi             = new CGI::Plus;
$cgi->csrf(1);

#for login database
open(IN, "$text");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$logins{$item}=$value;
}
close IN;

# for yubikey server
open(IN, "$text2");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$yubikey{$item}=$value;
}
close IN;
my $id        = $yubikey{id};
my $api       = $yubikey{api};
my $nonce     = "";

#select password and yubikey from user table
my $dbh = DBI->connect("DBI:mysql:$maindb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
#$dbh->{Profile} = 4;
#$dbh->{LongTruncOk} = 1;
my $query = "SELECT password,yubikey,igvport,role,edit,burdentests FROM $logindb.user WHERE name=?";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";
($password_stored,$yubikey_stored,$igvport_stored,$role,$dbedit,$burdentests) = $out->fetchrow_array;

# user darf nicht leer sein, passiert wenn man loginDo.pl direkt aufruft
# password_stored is empty when no entry in database
if (($user eq '') or ($password eq '') or ($password_stored eq '')) {
	$self->printHeader();
	print qq(<meta http-equiv="refresh" content="0; URL=login.pl">);
	$self->showMenu;
}	
else {
# encrypt password
$password = Crypt::Eksblowfish::Bcrypt::bcrypt($password,$password_stored) ;

# if yubikey_stored is 0: do not check yubikey server
if ( ($yubikey_stored eq 0) and ($yubikey_stored ne "") ) {
	$yubikeyOK = "OK";
}
else {
	$yubikeyOK = Auth::Yubikey_WebClient::yubikey_webclient($otp,$id,$api,$nonce);
	#$self->printHeader();
	#print "yubikeyOK $yubikeyOK<br>";
	unless ($yubikey_stored eq substr($otp,0,12)) {
		$yubikeyOK = "ERR"
	}
}


my $session   = "";
my $newcookie = "";
if ( ($password_stored eq $password) and ($yubikeyOK eq "OK") ) {
	# authorization OK check for maxFailedLogin
	&login_succeeded($user,$dbh);
	$igvport=$igvport_stored;
	# create sessionkey
	CGI::Session->name($gapplication);
	$session  = CGI::Session->new() or die CGI::Session->errstr;
	$session->expire('+180m');     # expire after 180 minutes
	$session->param('application',$gapplication);
	$session->param('user',$user);
	$session->param('igvport',$igvport);
	
	# create cookie
	$newcookie = $cgi->cookie( 
		   -name     => $session->name,
                   -value    => $session->id,
		   -path     => "$cgidir",
		   -secure   => 1,
		   -samesite => "Strict",
		   -httponly => 1
		   );
	my $cookie = $cgi->new_send_cookie( $session->name);
                   $cookie->{values}    = $session->id;
		   $cookie->{path}     = "$cgidir";
		   $cookie->{secure}   = 1;
		   $cookie->{samesite} = "Strict";
		   $cookie->{httponly} = 1;

	print $cgi->header(-cookie=>[$newcookie]);
	#print $cgi->header_plus;
	$self->printHeader("","sessionid_created");
	$self->showMenu;
	#print "<font size = 6>$newcookie</font><br>" ;
	print "<font size = 6>Login successful</font><br>" ;
	print "<font size = 6>IGVport $igvport</font><br>" ;
	print "<font size = 6>YubiKey $yubikeyOK<br>";
	my $mylocaltime = &mylocaltime;
	print "$mylocaltime<br>";
	print qq#
	<br><br><br>
	<a href='searchStat.pl'>Search for samples and quality checks</a>
	#;
}
else {
	# login failed
	$self->printHeader();
	$self->showMenu;
	if (($password_stored ne '') and ($user ne '')) {
		&login_failed($user,$dbh);
	}
	print "<font size = 6>Login failed</font><br><br>" ;
}
}

return($dbh);
}
########################################################################
# delete sessionid
########################################################################

sub deleteSessionId {
my $self     = shift;
my $cgi      = new CGI;
my $sess_id  = $cgi->cookie($gapplication);

my $session  = CGI::Session->new($sess_id) or die CGI::Session->errstr;;
$session->delete;  

}
########################################################################
# load sessionid
########################################################################

sub loadSessionId {
my $self        = shift;
my $sess_id     = shift;
my $application = "";
my $item        = "";
my $value       = "";
my %logins      = ();
my $projects    = "";
my $tmp         = "";
my $i           = 0;
my @tmp         = ();
my $cooperation = "";
my $project     = "";
my $cooperations= "";
my $cgi         = new CGI;

if (!defined($sess_id)) {
	$sess_id = "";
}
if ($sess_id eq "") {
	$sess_id = $cgi->cookie($gapplication);
}
#print "$sess_id<br>";
my $session     = CGI::Session->load($sess_id) or die CGI::Session->errstr;
	if ( $session->is_expired ) {
 		showMenu("login");
		#print "Your session is expired. Please login.";
		print qq(<meta http-equiv="refresh" content="0; URL=login.pl">);
		exit(1);
	}
	if ( $session->is_empty ) {
 		showMenu("login");
        	#print "Your sessionid is empty. Please login.";
		print qq(<meta http-equiv="refresh" content="0; URL=login.pl">);
		exit(1);
	}
	$application = $session->param('application');
	$user        = $session->param('user');
	$igvport     = $session->param('igvport');
	#print "application $gapplication<br>";
	#print "session $session->is_expired <br>";
	if ($application ne $gapplication) {
 		showMenu("login");
		print "<font size = 6>Wrong application.</font> <br>";
		exit(1);
	}
	open(IN, "$text");
	while (<IN>) {
		chomp;
		($item,$value)=split(/\:/);
		$logins{$item}=$value;
	}
	close IN;
	$csrfsalt = $logins{'csrfsalt'};

	my $dbh = DBI->connect("DBI:mysql:$maindb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
	my $query = "SET SESSION group_concat_max_len = 1000000";
	my $out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute() || die print "$DBI::errstr";
	
	$query = "SELECT cooperations,projects,role,edit,burdentests FROM $logindb.user WHERE name=?";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($user) || die print "$DBI::errstr";
	($cooperations,$projects,$role,$dbedit,$burdentests) = $out->fetchrow_array;
	
	# search for allowed projects with cooperation
	(@tmp)=split(/::/,$cooperations);
	foreach $tmp (@tmp) {
		if ($i > 0) {
			$cooperation .= " OR ";
		}
		$cooperation .= " co.name = '$tmp'";
		$i++;
	}
	#print "co $cooperation<br>";
	
	if ($cooperation ne "") {
		$query = "
		SELECT distinct(p.idproject)
		FROM $sampledb.project p
		INNER JOIN $sampledb.sample s ON s.idproject=p.idproject
		INNER JOIN $sampledb.cooperation co ON s.idcooperation=co.idcooperation
		WHERE  $cooperation
		";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute() || die print "$DBI::errstr";
		@allowedprojects = ();
		while ($tmp = $out->fetchrow_array) {
			push(@allowedprojects,$tmp);
		}
	}
	# avoid complete access if database contains wrong cooperations
	if ( ($cooperation ne "") and  ($#allowedprojects == -1) ) {
		push(@allowedprojects,'-999');
	}
	
	# search for allowed projects with projects
	$i=0;
	(@tmp)=split(/::/,$projects);
	foreach $tmp (@tmp) {
		if ($i > 0) {
			$project .= " OR ";
		}
		$project .= " p.pname = '$tmp'";
		$i++;
	}
	#$project ="p.pname = 'S0100'";
	#print "project $project<br>";
	if ($project ne "") {
		$query = "
		SELECT distinct(s.idproject)
		FROM $sampledb.sample s
		INNER JOIN $sampledb.project p ON s.idproject=p.idproject
		WHERE  $project
		";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute() || die print "$DBI::errstr";
		while ($tmp = $out->fetchrow_array) {
			push(@allowedprojects,$tmp);
		}
	}
	# avoid complete access if database contains wrong project
	if ( ($projects ne "") and  ($#allowedprojects == -1) ) {
		push(@allowedprojects,'-999');
	}
	#print "$#allowedprojects\n";
	#print "all @allowedprojects<br>";

return($dbh,$user,$csrfsalt);
}

########################################################################
# allowedprojects
########################################################################
sub allowedprojects {
	my $prefix = shift;
	my $allowedprojects = " 1=1  ";
	my $tmp = "";
	my $i   = 0;
	my $n   = $#allowedprojects;
	$prefix = $prefix . 'idproject';
	
	if ($n>=0) {
		$allowedprojects = " ( ";
	}
	foreach $tmp (@allowedprojects) {
		if ($i > 0) {
			$allowedprojects .= " OR  ";
		}
		$allowedprojects .= "  ($prefix = $tmp) ";
		$i++;
	}
	if ($n>=0) {
		$allowedprojects .= " ) ";
	}
	return ($allowedprojects);
}

########################################################################
# defaultAoH
########################################################################
sub defaultAoH {
my $mode = shift;
my @AoH = ();
my $filter = 'filtered';

if ($mode eq 'clinvar') {
	$snvqual = "";
	$gtqual  = "";
	$filter  = 'all';
	$gvalue  = $gvalueall;
}
if ($mode eq 'omim') {
	$snvqual = "";
	$gtqual  = "";
	$filter  = 'all';
}
if ($mode eq 'hpo') {
	$snvqual = "";
	$gtqual  = "";
}

unless (($mode eq 'recessive') or ($mode eq 'clinvar') or ($mode eq 'omim') or ($mode eq 'hpo') or ($mode eq 'tumor') or ($mode eq 'vcftumor') or ($mode eq 'vcfdenovo')) {
push(@AoH,({
	  	label       => "Affecteds",
	  	labels      => "Only affecteds, Only unaffecteds, All",
	  	type        => "radio",
		name        => "affecteds",
	  	value       => "onlyaffecteds",
	  	values      => "onlyaffecteds, onlyunaffecteds, ",
	  	bgcolor     => "formbg",
	  },
));
}

push(@AoH,(
	  {
	  	label       => "gnomAD Africans heterozygous <= (n)",
	  	type        => "text",
		name        => "aa_het",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "gnomAD alternative homozygous <= (n)",
	  	type        => "text",
		name        => "homalt",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "gnomAD heterozygous <= (n)",
	  	type        => "text",
		name        => "het",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "gnomAD maximum minor allele frequency of all populations <= (ratio)",
	  	type        => "text",
		name        => "popmax_af",
	  	value       => "$popmax_af",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
));

if (($mode eq 'vcftumor') or ($mode eq 'vcfdenovo')) {
	return(@AoH);
}

push(@AoH,(
	  {
	  	label       => "SNV calling Filter (GATK or SAMtools)",
	  	labels      => "Filtered, All",
	  	type        => "radio",
		name        => "filter",
	  	value       => "$filter",
	  	values      => "filtered, all",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SNV quality >= (0-255)",
	  	type        => "text",
		name        => "snvqual",
	  	value       =>  $snvqual,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Genotype quality >= (0-99)",
	  	type        => "text",
		name        => "gtqual",
	  	value       =>  $gtqual,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mapping quality >= (0-60)",
	  	type        => "text",
		name        => "mapqual",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Variant length >= (bp)",
	  	type        => "text",
		name        => "minlength",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Variant length <= (bp)",
	  	type        => "text",
		name        => "maxlength",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Class",
	  	labels      => "SNV, indel, Pindel, ExomeDepth",
	  	type        => "checkbox",
		name        => "class",
	  	value       => "snp, indel, deletion",
	  	values      => "snp, indel, deletion, cnv",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Function",
	  	labels      => "$glabels",
	  	type        => "checkbox",
		name        => "function",
	  	value       => "$gvalue",
	  	values      => "$gvalues",
	  	bgcolor     => "formbg",
	  },
));

return(@AoH);

}
########################################################################
# defaultwhere
########################################################################
sub defaultwhere {
my $ref     = shift;
my $where   = shift;
my @prepare = @_;

if ($ref->{'aa_het'} ne "") {
	#$where .= " AND ((evs.aa_het+2*evs.aa_homalt) <= ? or ISNULL(evs.aa_het))";
	$where .= " AND (evs.aa_het <= ? or ISNULL(evs.aa_het))";
	push(@prepare,$ref->{'aa_het'});
}
if ($ref->{'het'} ne "") {
	#$where .= " AND ((evs.het+2*evs.homalt) <= ? or ISNULL(evs.het))";
	$where .= " AND (evs.het <= ? or ISNULL(evs.het))";
	push(@prepare,$ref->{'het'});
}
if ($ref->{'homalt'} ne "") {
	$where .= " AND (evs.homalt <= ? or ISNULL(evs.homalt))";
	push(@prepare,$ref->{'homalt'});
}
if ($ref->{'popmax_af'} ne "") {
	$where .= " AND (evs.popmax_af <= ? or ISNULL(evs.popmax_af))";
	push(@prepare,$ref->{'popmax_af'});
}
if ($ref->{'affecteds'} eq "onlyaffecteds") {
	$where .= " AND s.saffected = 1 ";
}
if ($ref->{'affecteds'} eq "onlyunaffecteds") {
	$where .= " AND s.saffected = 0 ";
}
if ($ref->{'snvqual'} ne "") {
	$where .= " AND x.snvqual >= ? ";
	push(@prepare,$ref->{'snvqual'});
}
if ($ref->{'gtqual'} ne "") {
	$where .= " AND x.gtqual >= ? ";
	push(@prepare,$ref->{'gtqual'});
}
if ($ref->{'mapqual'} ne "") {
	$where .= " AND x.mapqual >= ? ";
	push(@prepare,$ref->{'mapqual'});
}
if ($ref->{'minlength'} ne "") {
	$where .= "AND v.length >= ? ";
	push(@prepare,$ref->{'minlength'});
}
if ($ref->{'maxlength'} ne "") {
	$where .= "AND v.length <= ? ";
	push(@prepare,$ref->{'maxlength'});
}
if ($ref->{'filter'} eq "filtered") {
	$where .= " AND FIND_IN_SET('PASS',x.filter)";
}

return($where,@prepare);
}
########################################################################
# init for searchFam dominant initsearchdominant
########################################################################
sub initSearchFam {
my $self         = shift;
my $pedigree     = shift;
my $dbh          = shift;
my $ref          = "";

#if ($pedigree eq "") {
#	$pedigree="ZIMPARK005";
#}
#value       => "no, no, missense, nonsense, stoploss, splice, no, frameshift, indel, no, no",

if (($demo) and ($pedigree eq "")) {
	$pedigree = "S0001";
}

my @AoH = (
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "s.pedigree",
	  	value       => "$pedigree",
		size        => "20",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "x.alleles",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases within pedigrees",
	  	type        => "text",
		name        => "ncases",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal pedigrees",
	  	type        => "text",
		name        => "npedigrees",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house controls <= (n)",
	  	type        => "text",
		name        => "ncontrols",
	  	value       =>  2,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH));

push(@AoH,(
	  {
	  	label       => "Show",
	  	labels      => "All genes, Only disease genes",
	  	type        => "radio",
		name        => "showall",
	  	value       => "1",
	  	values      => "1, 0",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for searchSameVariant
########################################################################
sub initSearchSameVariant {
my $self         = shift;
my $name         = shift;
my $dbh          = shift;
my $ref          = "";

if (($demo) and ($name eq "")) {
	$name = "S0001";
}

my @AoH = (
	  {
	  	label       => "Individuals (space separated)",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$name",
		size        => "100",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Chromosome (i.e. 'chr1:1000000-2000000')",
	  	type        => "text",
		name        => "chrom",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "x.alleles",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases",
	  	type        => "text",
		name        => "ncases",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house controls <= (n)",
	  	type        => "text",
		name        => "ncontrols",
	  	value       =>  2,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH));


push(@AoH,({
	  	label       => "Genome in a bottle (only for genomes)",
	  	labels      => "All, callable, not callable",
	  	type        => "radio",
		name        => "giab",
	  	value       => "$giabform",
	  	values      => ", 1, 0",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for initSearchVcfTumor
########################################################################
sub initSearchVcf {
my $self         = shift;
my $name         = shift;
my $dbh          = shift;
my $ref          = "";

if (($demo) and ($name eq "")) {
	$name = "S0001";
}

my @AoH = (
	  {
	  	label       => "Label disease genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Individuals (space separated)",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$name",
		size        => "100",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Chromosome (i.e. 'chr1:1000000-2000000')",
	  	type        => "text",
		name        => "chrom",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "x.alleles",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases",
	  	type        => "text",
		name        => "ncases",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal variants in gene",
	  	type        => "text",
		name        => "ngenes",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH('vcftumor')));


push(@AoH,(
	  {
	  	label       => "Mapping quality >= (0-60)",
	  	type        => "text",
		name        => "mapqual",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Class",
	  	labels      => "SNV, indel",
	  	type        => "checkbox",
		name        => "class",
	  	value       => "snp, indel",
	  	values      => "snp, indel",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Function",
	  	labels      => "$glabels",
	  	type        => "checkbox",
		name        => "function",
	  	value       => "$gvalue",
	  	values      => "$gvalues",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for initSearchVcfTrio initSearchVcfDenovo
########################################################################
sub initSearchVcfTrio {
my $self         = shift;
my $name         = shift;
my $dbh          = shift;
my $ref          = "";

if (($demo) and ($name eq "")) {
	$name = "S0001";
}

my @AoH = (
	  {
	  	label       => "Label disease genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Individuals (space separated)",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$name",
		size        => "100",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Chromosome (i.e. 'chr1:1000000-2000000')",
	  	type        => "text",
		name        => "chrom",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "x.alleles",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases",
	  	type        => "text",
		name        => "ncases",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal variants in gene",
	  	type        => "text",
		name        => "ngenes",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH('vcfdenovo')));

push(@AoH,(
	  {
	  	label       => "Mapping quality >= (0-60)",
	  	type        => "text",
		name        => "mapqual",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "High confidence de novo",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "hiConfDeNovo",
	  	value       => "yes",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Low confidence de novo",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "loConfDeNovo",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Class",
	  	labels      => "SNV, indel",
	  	type        => "checkbox",
		name        => "class",
	  	value       => "snp, indel",
	  	values      => "snp, indel",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Function",
	  	labels      => "$glabels",
	  	type        => "checkbox",
		name        => "function",
	  	value       => "$gvalue",
	  	values      => "$gvalues",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for searchTrio de novo denovo initsearchdenovo
########################################################################
sub initSearchTrio {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;
my $ref          = "";
my $excluded     = "";
my $sql          = "";
my $out          = "";
my @pedigree     = ();

if (!defined($sname)) {$sname = "";}
if (($demo) and ($sname eq "")) {
	$sname = "S0001";
}

my @AoH = (
	  {
	  	label       => "Child sample ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sname",
		size        => "20",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "x.alleles",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal pedigrees",
	  	type        => "text",
		name        => "npedigrees",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house controls <= (n)",
	  	type        => "text",
		name        => "ncontrols",
	  	value       =>  4,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Only confirmed <br>or correct SNVs",
	  	labels      => "All, Only confirmed or correct SNVs, Only not annotated SNVs",
	  	type        => "radio",
		name        => "correct",
	  	value       => "",
	  	values      => ", correct, notannotated",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH));

push(@AoH,({
	  	label       => "Genome in a bottle (only for genomes)",
	  	labels      => "All, callable, not callable",
	  	type        => "radio",
		name        => "giab",
	  	value       => "$giabform",
	  	values      => ", 1, 0",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for searchMito
########################################################################
sub initSearchMito {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;
my $ref          = "";
my $excluded     = "";
my $sql          = "";
my $out          = "";
my @pedigree     = ();


my @AoH = (
	  {
	  	label       => "Analysis date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Analysis date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sname",
		size        => "20",
		maxlength   => "200",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "x.alleles",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases",
	  	type        => "text",
		name        => "ncases",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house exomes <= (n)",
	  	type        => "text",
		name        => "nall",
	  	value       =>  10000,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mitomap confirmed",
	  	labels      => "all, confirmed",
	  	type        => "radio",
		name        => "cfrm",
	  	value       => "",
	  	values      => ", cfrm",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SNV quality >= (0-255)",
	  	type        => "text",
		name        => "snvqual",
	  	value       =>  $snvqual,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Genotype quality >= (0-99)",
	  	type        => "text",
		name        => "gtqual",
	  	value       =>  $gtqual,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mapping quality >= (0-60)",
	  	type        => "text",
		name        => "mapqual",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Coverage >=",
	  	type        => "text",
		name        => "coverage",
	  	value       =>  "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Class",
	  	labels      => "SNV, indel, Pindel, ExomeDepth",
	  	type        => "checkbox",
		name        => "class",
	  	value       => "snp, indel, deletion",
	  	values      => "snp, indel, deletion, cnv",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Function",
	  	labels      => "$glabels",
	  	type        => "checkbox",
		name        => "function",
	  	value       => "$gvalueall",
	  	values      => "$gvalues",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for searchTumor
########################################################################
sub initSearchTumor {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;
my $excluded     = "";
my $ref          = "";
my $sql          = "";
my $out          = "";
my $tmp          = ();
my @row          = ();


if ($sname ne "") {
	$sql = "
	SELECT pedigree
	FROM $sampledb.sample 
	WHERE name = ?
	";
	$out = $dbh->prepare($sql) || die print "$DBI::errstr";
	$out->execute($sname) || die print "$DBI::errstr";
	$tmp = $out->fetchrow_array;


	# excluded: search for all non-affected pedigree members
	$sname = "";
	$sql = "
	SELECT s.name,s.saffected
	FROM $sampledb.sample s
	INNER JOIN variantstat vs ON s.idsample=vs.idsample
	WHERE s.pedigree = ?
	AND nottoseq = 0
	";
	$out = $dbh->prepare($sql) || die print "$DBI::errstr";
	$out->execute($tmp) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		if ($row[1]) {  #affected
			if ($sname ne "") {
				$sname .= " ";
			}
			$sname .= $row[0];
		}
		else {
			if ($excluded ne "") {
				$excluded .= " ";
			}
			$excluded .= $row[0];
		}
	
	}
}

if (($demo) and ($sname eq "")) {
	$sname    = "S0001";
	$excluded = "S0301";
}

my @AoH = (
	  {
	  	label       => "Label disease genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "129",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Samples (space separated)",
	  	type        => "text",
		name        => "sample",
	  	value       => "$sname",
		size        => "150",
		maxlength   => "250",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Excluded samples (space separated)",
	  	type        => "text",
		name        => "excluded",
	  	value       => "$excluded",
		size        => "150",
		maxlength   => "250",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "x.alleles",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases",
	  	type        => "text",
		name        => "ncases",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house controls <= (n)",
	  	type        => "text",
		name        => "ncontrols",
	  	value       =>  2,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Only confirmed <br>or correct SNVs",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "correct",
	  	value       => "",
	  	values      => ", correct",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH('tumor')));

push(@AoH,(
	  {
	  	label       => "Genome in a bottle (only for genomes)",
	  	labels      => "All, callable, not callable",
	  	type        => "radio",
		name        => "giab",
	  	value       => "$giabform",
	  	values      => ", 1, 0",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search GeneInd recessive initsearchrecessive
########################################################################
sub initSearchGeneInd {
my $self         = shift;
my $name         = shift;
my $dbh          = shift;
my $trio         = 0;
my $tmp          = 0;
my $ref          = "";
my $sql          = "";
my $out          = "";
my @names        = ();
my $iddisease    = "";
if (($demo) and ($name eq "")) {
	$name = "S0002";
}
my $sname        = $name;

if (!defined($name)) {$name = "";}

if ($name ne "") {
	$sql = "
	SELECT GROUP_CONCAT(s.name separator ' ')
	FROM $sampledb.sample s
	WHERE s.pedigree IN
	(SELECT ss.pedigree 
	FROM $sampledb.sample ss 
	WHERE ss.name = ? )
	";
	$out = $dbh->prepare($sql) || die print "$DBI::errstr";
	$out->execute($name) || die print "$DBI::errstr";
	$name = $out->fetchrow_array;
	
	@names= split(/\s+/,$name);
	($tmp)=&childInTrio(\@names,$dbh);
	if ($tmp ne "") {
		$trio = 1;
	}
}
if ($sname ne "") {
	$sql = "
	SELECT DISTINCT d.iddisease
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample   = ds.idsample
	INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
	INNER JOIN disease2gene             dg ON d.iddisease  = dg.iddisease
	WHERE s.name = ?
	";
	$out = $dbh->prepare($sql) || die print "$DBI::errstr";
	$out->execute($sname) || die print "$DBI::errstr";
	$iddisease = $out->fetchrow_array;
}

my @AoH = (
	  {
	  	label       => "Label disease genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "$iddisease",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Individuals",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$name",
		size        => "50",
		maxlength   => "500",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles",
	  	type        => "text",
		name        => "x.alleles",
	  	value       => 2,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases",
	  	type        => "text",
		name        => "v.idsnv",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house controls <= (n)",
	  	type        => "text",
		name        => "ncontrols",
	  	value       =>  200,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Homozygous",
	  	labels      => "compound heterozygous/homozygous, homozygous only",
	  	type        => "radio",
		name        => "homozygous",
	  	value       => "0",
	  	values      => "0, 1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Trio",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "trio",
	  	value       => "$trio",
	  	values      => "0, 1",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH('recessive')));


push(@AoH,({
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Position
########################################################################
sub initSearchPosition {
my $self         = shift;
my $position     = shift;
my $name         = shift;
my $ref          = "";

if (($demo) and ($name eq "")) {
	$name     = "S0001";
	$position = "chr18:35000000-43400000";
}

my @AoH = (
	  {
	  	label       => "Label disease genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Position<br>chrX:start-end",
	  	type        => "text",
		name        => "position",
	  	value       => "$position",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA Id",
	  	type        => "text",
		name        => "name",
	  	value       => "$name",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SNV quality >= (0-255)",
	  	type        => "text",
		name        => "snvqual",
	  	value       =>  $snvqual,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Genotype quality >= (0-99)",
	  	type        => "text",
		name        => "gtqual",
	  	value       =>  $gtqual,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mapping quality >= (0-60)",
	  	type        => "text",
		name        => "mapqual",
	  	value       =>  50,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Filter",
	  	type        => "text",
		name        => "filter",
	  	value       => "PASS",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search CNV
########################################################################
sub initSearchCnv {
my $self         = shift;
my $sname        = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Analysis date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Analysis date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA Id",
	  	type        => "text",
		name        => "name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Number of exons >=",
	  	type        => "text",
		name        => "percentvar",
	  	value       => "1",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Number of exons <=",
	  	type        => "text",
		name        => "percentvar2",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Dosage <=",
	  	type        => "text",
		name        => "percentfor1",
	  	value       =>  "0.65",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Dosage >=",
	  	type        => "text",
		name        => "percentfor2",
	  	value       => "1.35",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Number of samples <=",
	  	type        => "text",
		name        => "nsamples",
	  	value       => "7",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ExomeDepth noise (Rs) <=",
	  	type        => "text",
		name        => "exomedepthrsd",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Filter",
	  	type        => "text",
		name        => "filter",
	  	value       => "PASS",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Exclude tumor samples",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "tumor",
	  	value       => "yes",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Structural variants initsearchstructural
########################################################################
sub initSearchSv {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;
my $excluded     = "";
my $ref          = "";
my $sql          = "";
my $out          = "";
my $tmp          = ();
my @row          = ();

if ($sname ne "") {
	$sql = "
	SELECT pedigree
	FROM $sampledb.sample
	WHERE name = ?
	";
	$out = $dbh->prepare($sql) || die print "$DBI::errstr";
	$out->execute($sname) || die print "$DBI::errstr";
	$tmp = $out->fetchrow_array; #pedigree
	
		
	# excluded: search for all non-affected pedigree members
	$sname = "";
	$sql = "
	SELECT s.name,s.saffected
	FROM $sampledb.sample s
	INNER JOIN variantstat vs ON s.idsample=vs.idsample
	WHERE s.pedigree = ?
	AND nottoseq = 0
	";
	$out = $dbh->prepare($sql) || die print "$DBI::errstr";
	$out->execute($tmp) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		if ($row[1]) {  #affected
			if ($sname ne "") {
				$sname .= " ";
			}
			$sname .= $row[0];
		}
		else {
			if ($excluded ne "") {
				$excluded .= " ";
			}
			$excluded .= $row[0];
		}
	
	}
}


my @AoH = (
	  {
	  	label       => "Analysis date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Analysis date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA Id (space separated)",
	  	type        => "text",
		name        => "name",
	  	value       => "$sname",
		size        => "100",
		maxlength   => "250",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Excluded DNA Id (space separated)",
	  	type        => "text",
		name        => "excluded",
	  	value       => "$excluded",
		size        => "100",
		maxlength   => "250",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Minimal cases",
	  	type        => "text",
		name        => "mincases",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SV type",
	  	labels      => "All, DEL, DUP, INS, INV, CNV, mCNV",
	  	type        => "radio",
		name        => "svtype",
	  	value       => "",
	  	values      => ", DEL, DUP, INS, INV, CNV, mCNV",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Chromosome (i.e. 'chr1:1000000-2000000')",
	  	type        => "text",
		name        => "chrom",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "max SV length <=",
	  	type        => "text",
		name        => "svlenmax",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "min SV length >=",
	  	type        => "text",
		name        => "svlenmin",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Number of in-house genomes <=",
	  	type        => "text",
		name        => "freq",
	  	value       => "10",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allele frequency 1000 Genomes <=",
	  	type        => "text",
		name        => "af1KG",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Overlap with annotation",
	  	labels      => "All, Promotor, Coding_Region",
	  	type        => "radio",
		name        => "annotation",
	  	value       => "",
	  	values      => ", Promotor, Coding_Region",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "OMIM genes",
	  	labels      => "All, OMIM",
	  	type        => "radio",
		name        => "omim",
	  	value       => "",
	  	values      => ", omim",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Overlap with Gap regions <= ratio",
	  	type        => "text",
		name        => "gapoverlap",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Overlap with 'Genome in a Bottle' regions >= ratio",
	  	type        => "text",
		name        => "giaboverlap",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Overlap with 'Low complexity' regions <= ratio",
	  	type        => "text",
		name        => "lowcomploverlap",
	  	value       => "0.2",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Overlap with 'n' DGV regions <= n",
	  	type        => "text",
		name        => "dgvoverlap",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Overlap with 'n' 'Genomic super-duplication' regions <= n",
	  	type        => "text",
		name        => "gensupdupsoverlap",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Genes >= n",
	  	type        => "text",
		name        => "ngenes",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "CNVnator uniqueness <=",
	  	type        => "text",
		name        => "cnunique",
	  	value       => "0.5",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "CNVnator dosage <=",
	  	type        => "text",
		name        => "cndosagedel",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "CNVnator dosage >=",
	  	type        => "text",
		name        => "cndosagedup",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pindel depth >= n",
	  	type        => "text",
		name        => "pidp",
	  	value       => "3",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Breakdancer depth >= n",
	  	type        => "text",
		name        => "bddp",
	  	value       => "3",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Caller >= n",
	  	type        => "text",
		name        => "ncaller",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Caller",
	  	labels      => "All, Pindel, Lumpy-sv, Breakdancer, Manta, CNVnator, whamg",
	  	type        => "checkbox",
		name        => "caller",
	  	value       => "",
	  	values      => ", pindel, lumpy-sv, breakdancer, manta, cnvnator, whamg",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	labels      => "All, Correct SVs",
	  	type        => "radio",
		name        => "comment",
	  	value       => "",
	  	values      => ", correct",
	  	bgcolor     => "formbg",
	  },
);

print qq#
<button id='cnvnator'>'Reliable' large (>5000 bp) CNVnator SVs</button> 
<button id='pindel'>'Reliable' small (<5000 bp) Pindel SVs</button> 
#;

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Translocations
########################################################################
sub initSearchTrans {
my $self         = shift;
my $sname        = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Analysis date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Analysis date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA Id",
	  	type        => "text",
		name        => "name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Count gene 1 <=",
	  	type        => "text",
		name        => "countgene1",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Count gene 2 <=",
	  	type        => "text",
		name        => "countgene2",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "N discordant >=",
	  	type        => "text",
		name        => "num_discordant",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SC1 >=",
	  	type        => "text",
		name        => "sc1",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SC2 >=",
	  	type        => "text",
		name        => "sc2",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Homozygosity
########################################################################
sub initSearchHomozygosity {
my $self         = shift;
my $sname        = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "DNA Id",
	  	type        => "text",
		name        => "name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Number of SNVs >=",
	  	type        => "text",
		name        => "count",
	  	value       => "10",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Number of SNVs <=",
	  	type        => "text",
		name        => "count2",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allele ratio<br>for all chromosomes",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "alleleratio",
	  	value       => "0",
	  	values      => "0, 1",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Sample
########################################################################
sub initSearchSample {
my $self         = shift;
my $pedigree     = shift;

if (!defined($pedigree)) {$pedigree = ""};
my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Foreign ID",
	  	type        => "text",
		name        => "foreignid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "$pedigree",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Status",
	  	type        => "selectdb",
		name        => "lstatus",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "To sequence",
	  	labels      => "yes, no, all",
	  	type        => "radio",
		name        => "nottoseq",
	  	value       => "0",
	  	values      => "0, 1,",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search DiffEx
########################################################################
sub initSearchDiffEx {
my $self         = shift;
my $pedigree     = shift;

if (!defined($pedigree)) {$pedigree = ""};
my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Foreign ID",
	  	type        => "text",
		name        => "foreignid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "$pedigree",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Status",
	  	type        => "selectdb",
		name        => "lstatus",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "To sequence",
	  	labels      => "yes, no, all",
	  	type        => "radio",
		name        => "nottoseq",
	  	value       => "0",
	  	values      => "0, 1,",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search DiffPeak
########################################################################
sub initSearchDiffPeak {
my $self         = shift;
my $pedigree     = shift;

if (!defined($pedigree)) {$pedigree = ""};
my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Foreign ID",
	  	type        => "text",
		name        => "foreignid",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "$pedigree",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Status",
	  	type        => "selectdb",
		name        => "lstatus",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "To sequence",
	  	labels      => "yes, no, all",
	  	type        => "radio",
		name        => "nottoseq",
	  	value       => "0",
	  	values      => "0, 1,",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search homozygous
########################################################################
sub initSearchHomozygous {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Conclusions
########################################################################
sub initSearchConclusion {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Affecteds",
	  	labels      => "Only affecteds, Affecteds and unaffecteds",
	  	type        => "radio",
		name        => "saffected",
	  	value       => "",
	  	values      => "1, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Solved",
	  	labels      => "Not processed, Solved, Not solved, New candidate, Follow-up pending, All",
	  	type        => "radio",
		name        => "solved",
	  	value       => "",
	  	values      => "0, 1, 2, 3, 4, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Rating",
	  	labels      => "correct, All",
	  	type        => "radio",
		name        => "rating",
	  	value       => "",
	  	values      => "correct, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pathogenicity",
	  	labels      => "all but unknown, All",
	  	type        => "radio",
		name        => "patho",
	  	value       => "",
	  	values      => "notunknown, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Pedigree, Sample ID, Timestamp",
	  	type        => "radio",
		name        => "order",
	  	value       => "s.pedigree\,s.name",
	  	values      => "s.pedigree\,s.name, s.name, substr(cl.indate,1,10)\,s.pedigree\,s.name",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Statistics initsearchexomestat
########################################################################
sub initSearchStatistics {
my $self         = shift;
my $sample       = shift;
my $pedigree     = shift;
my $autosearch   = shift;

if (!defined($sample)) {$sample = ""};
if (!defined($pedigree)) {$pedigree = ""};
if (defined($autosearch)){$libtype_default = ""};

my $ref          = "";

my @AoH = (
	  {
	  	label       => "First analysis date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "First analysis date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Last analysis date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebeginlast",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Last analysis date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateendlast",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sample",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "libtype",
	  	value       => "$libtype_default",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Organism",
	  	type        => "selectdb",
		name        => "idorganism",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "$pedigree",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Status",
	  	type        => "selectdb",
		name        => "lstatus",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Pedigree, Sample ID, Sequence output, SRY, Library date, Timestamp",
	  	type        => "radio",
		name        => "order",
	  	value       => "s.pedigree\,s.name",
	  	values      => "s.pedigree\,s.name, s.name, e.seq, s.sex\,e.sry DESC, max(l.ldate)\,s.pedigree\,s.name, substr(e.date,1,10)\,s.pedigree,s.name",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mode",
	  	labels      => "Table, Figures",
	  	type        => "radio",
		name        => "mode",
	  	value       => "table",
	  	values      => "table, figure",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search RNAStatistics initsearchrnastat
########################################################################
sub initSearchRnaStat {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Organism",
	  	type        => "selectdb",
		name        => "s.idorganism",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Tissue",
	  	type        => "selectdb",
		name        => "s.idtissue",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Pedigree, Sample ID, Sequence output, Timestamp",
	  	type        => "radio",
		name        => "order",
	  	value       => "s.pedigree\,s.name",
	  	values      => "s.pedigree\,s.name, s.name, r.seq, substr(r.date,1,10)\,s.pedigree\,s.name",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search RPKM initsearchRPKM
########################################################################
sub initSearchRpkm {
my $self         = shift;
my $name         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$name",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Gene symbol",
	  	type        => "text",
		name        => "g.genesymbol",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Transcript Statistics Coverage
########################################################################
sub initTranscriptstat {
my $self         = shift;

my $ref          = "";

my @AoH = (
	  {
	  	label       => "Gene symbol",
	  	type        => "text",
		name        => "g.genesymbol",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "refSeq",
	  	type        => "text",
		name        => "t.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "50",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Type material",
	  	type        => "selectdb",
		name        => "ts.idlibtype",
	  	value       => "5",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Assay type",
	  	type        => "selectdb",
		name        => "ts.idassay",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Normalization",
	  	labels      => "no, per gene, per exome",
	  	type        => "radio",
		name        => "normalization",
	  	value       => "exome",
	  	values      => "no, gene, exome",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Order",
	  	labels      => "Pedigree, Sample ID, Gene Symbol",
	  	type        => "radio",
		name        => "order",
	  	value       => "s.name",
	  	values      => "s.pedigree\,s.name, s.name, g.geneSymbol",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search HGMD
########################################################################
sub initSearchHGMD {
my $self         = shift;
my $sname        = shift;

my $ref          = "";
my @AoH = ();

if (($demo) and ($sname eq "")) {
	$sname = "S0001";
}


@AoH = (
	  {
	  	label       => "Inheritance",
	  	labels      => "All, AD OMIM genes, AR OMIM genes, XL OMIM genes",
	  	type        => "radio",
		name        => "selection",
	  	value       => "all",
	  	values      => "all, ad, ar, x",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mode",
	  	labels      => "All, Homozygous/Compound heterozygous",
	  	type        => "radio",
		name        => "mode",
	  	value       => "all",
	  	values      => "all, homozygous",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "AGMD",
	  	labels      => "All, ACMG (73 genes)",
	  	type        => "radio",
		name        => "agmd",
	  	value       => "",
	  	values      => ", 1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Clinvar",
	  	labels      => "All, Pathogenic / likely Pathogenic, Uncertain Significance",
	  	type        => "radio",
		name        => "clinvar",
	  	value       => "1",
	  	values      => ", 1, 2",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pedigree",
	  	type        => "text",
		name        => "pedigree",
	  	value       =>  "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house exomes <= (n)",
	  	type        => "text",
		name        => "freq",
	  	value       => "100",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH('clinvar')));


$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Gene initSearchGenes
########################################################################
sub initSearchGene {
my $self         = shift;
my $genesymbol   = shift;
my $ref          = "";

if (($demo) and ($genesymbol eq "")) {
	$genesymbol = "IFT52";
}

my @AoH = (
	  {
	  	label       => "UCSC Gene Symbol (comma separated list)",
	  	type        => "text",
		name        => "g.genesymbol",
	  	value       => $genesymbol,
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house exomes <= (n)",
	  	type        => "text",
		name        => "v.freq",
	  	value       => "100",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mode",
	  	labels      => "Heterozygous/Homozygous, Compound heterozygous/Homozygous",
	  	type        => "radio",
		name        => "mode",
	  	value       => "all",
	  	values      => "all, homozygous",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH));


$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Omim
########################################################################
sub initSearchOmim {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;

my $ref          = "";
my $hpo          = "";
my $query        = "";
my $out          = "";
my $tmp          = "";


if (!defined($sname)) {$sname = "";}

if ($sname ne "") {
	$query = "SELECT symptoms FROM $exomevcfe.hpo WHERE samplename = ? AND active=1";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($sname) || die print "$DBI::errstr";
	while ($tmp = $out->fetchrow_array) {
		if ($hpo ne "") {
			$hpo .= " ";
		}
		$hpo .= "$tmp";
	}
	encode_entities($hpo);
}

my @AoH = (
	  {
	  	label       => "Version",
	  	labels      => "Old (full-text MySQL), New (full-text Solr)",
	  	type        => "radio",
		name        => "version",
	  	value       => "new",
	  	values      => ", new",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allelic requirements (only for Solr)",
	  	labels      => "All, recessive diseases only when 2 alternative alleles are present",
	  	type        => "radio",
		name        => "ar",
	  	value       => "",
	  	values      => ", ar",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Search mode (only for Solr)",
	  	labels      => "Full-text, Title, Synopsis, References, Allelic variants, MIM number prefix",
	  	type        => "radio",
		name        => "mode",
	  	value       => "",
	  	values      => ", title, synopsis, reference, allelic_variants, type",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Old version: Phrases contained in text or synopsis.<br>Boolean operator AND is supported.<br>New version: OMIM search syntax",
	  	type        => "text",
		name        => "omim",
	  	value       => "$hpo",
		size        => "100",
		maxlength   => "250",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house exomes <= (n)",
	  	type        => "text",
		name        => "v.freq",
	  	value       => "100",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH('omim')));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search HPO
########################################################################
sub initSearchHPO {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;
my $ref          = "";
my $hpo          = "";
my $query        = "";
my $out          = "";
my $tmp          = "";

if (!defined($sname)) {$sname = "";}

if (($demo) and ($sname eq "")) {
	$sname = "S0001";
}

if ($sname ne "") {
	$query = "SELECT hpo FROM $exomevcfe.hpo WHERE samplename = ? AND active=1";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($sname) || die print "$DBI::errstr";
	while ($tmp = $out->fetchrow_array) {
		if ($hpo ne "") {
			$hpo .= " ";
		}
		$hpo .= "$tmp";
	}
}

my @AoH = (
	  {
	  	label       => "Allelic requirements",
	  	labels      => "All, recessive diseases only when 2 alternative alleles are present",
	  	type        => "radio",
		name        => "ar",
	  	value       => "",
	  	values      => ", ar",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "HPO terms (space or comma separated)",
	  	type        => "text",
		name        => "hpo",
	  	value       => "$hpo",
		size        => "100",
		maxlength   => "250",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house exomes <= (n)",
	  	type        => "text",
		name        => "v.freq",
	  	value       => "100",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);

push(@AoH,(&defaultAoH('hpo')));


$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Disease Gene
########################################################################
sub initSearchDiseaseGene {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;
my $ref          = "";
my $sql          = "";
my $out          = "";
my $iddisease  = "";

if (($demo) and ($sname eq "")) {
	$sname = "S0001";
}

if ($sname ne "") {
	$sql = "
	SELECT DISTINCT d.iddisease
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample   = ds.idsample
	INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
	INNER JOIN disease2gene             dg ON d.iddisease  = dg.iddisease
	WHERE s.name = ?
	";
	$out = $dbh->prepare($sql) || die print "$DBI::errstr";
	$out->execute($sname) || die print "$DBI::errstr";
	$iddisease = $out->fetchrow_array;
}


my @AoH = (
	  {
	  	label       => "Analysis date >= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "datebegin",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Analysis date <= (yyyy-mm-dd)",
	  	type        => "jsdate",
		name        => "dateend",
	  	value       => "",
		size        => "10",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Test disease genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "$iddisease",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease gene score <=",
	  	type        => "text",
		name        => "score",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  	autofocus   => "autofocus",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house exomes <= (n)",
	  	type        => "text",
		name        => "nall",
	  	value       =>  10,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);
	  
push(@AoH,(&defaultAoH));
	  
push(@AoH,({
	  	label       => "Genome in a bottle (only for genomes)",
	  	labels      => "All, callable, not callable",
	  	type        => "radio",
		name        => "giab",
	  	value       => "$giabform",
	  	values      => ", 1, 0",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Burden statistics",
	  	labels      => "No, Dominant, Recessive",
	  	type        => "radio",
		name        => "burdentest",
	  	value       => "0",
	  	values      => "0, 1, 2",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for search Comment
########################################################################
sub initSearchComment {
my $self         = shift;
my $ref          = "";


my @AoH = (
	  {
	  	label       => "Mode",
	  	labels      => "Details , Summary",
	  	type        => "radio",
		name        => "mode",
	  	value       => "details",
	  	values      => "details, summary",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Label disease genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease",
	  	type        => "selectdb",
		name        => "ds.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperation",
	  	type        => "selectdb",
		name        => "s.idcooperation",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Project",
	  	type        => "selectdb",
		name        => "idproject",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Gene symbol",
	  	type        => "text",
		name        => "g.genesymbol",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Number of cases >=",
	  	type        => "text",
		name        => "ncases",
	  	value       =>  1,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "To do",
	  	labels      => "unknown , no, yes, all",
	  	type        => "radio",
		name        => "checked",
	  	value       => "",
	  	values      => "unknown, no, yes, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Confirmed",
	  	labels      => "Correct or confirmed, Confirmed, Unknown, All",
	  	type        => "radio",
		name        => "confirmed",
	  	value       => "correctconfirmed",
	  	values      => "correctconfirmed, confirmed, unknown, ",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Genotype",
	  	labels      => "unknown, heterozygous, compound heterozygous, homozygous, hemizygous",
	  	type        => "checkbox",
		name        => "genotype",
	  	value       => "no, no, no, no, no",
	  	values      => "unknown, heterozygous, compound_heterozygous, homozygous, hemizygous",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Inheritance",
	  	labels      => "unknown, mother, father, mother and father, matched control, de novo, somatic",
	  	type        => "checkbox",
		name        => "inheritance",
	  	value       => "no, no, no, no, no, no, no",
	  	values      => "unknown, mother, father, mo_fa, matched_control, de_novo, somatic",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease gene",
	  	labels      => "unknown, not to decide, no candidate, candidate, known_gene, known_mutation",
	  	type        => "checkbox",
		name        => "gene",
	  	value       => "no, no, no, no, no, no",
	  	values      => "unknown, not_to_decide, no_candidate, candidate, known_gene, known_mutation",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pathogenicity",
	  	labels      => "Unknown, Pathogenic, Likely pathogenic, Unknown significance, Likely benign, Benign",
	  	type        => "checkbox",
		name        => "patho",
	  	value       => "",
		values      => "unknown, pathogenic, likely pathogenic, unknown significance, likely benign, benign",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Allowed in in-house exomes <= (n)",
	  	type        => "text",
		name        => "freq",
	  	value       =>  10,
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
);	  

push(@AoH,(&defaultAoH));

push(@AoH,(
	  {
	  	label       => "Print query",
	  	labels      => "no, yes",
	  	type        => "radio",
		name        => "printquery",
	  	value       => "no",
	  	values      => "no, yes",
	  	bgcolor     => "formbg",
	  },
));

$ref = \@AoH;
return($ref);
}
########################################################################
# init for genelist diagnostics
########################################################################
sub initSearchDiagnostics {
my $self         = shift;
my $sname        = shift;
my $ref          = "";


my @AoH = (
	  {
	  	label       => "Disease Genes",
	  	type        => "selectdb",
		name        => "dg.iddisease",
	  	value       => "",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease gene score <=",
	  	type        => "text",
		name        => "dg.class",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "s.name",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for report initreport
########################################################################
sub initSearchReport {
my $self         = shift;
my $sname        = shift;
my $ref          = "";

if ($demo and $sname eq "") {
	$sname = "S0001";
}

my @AoH = (
	  {
	  	label       => "DNA ID",
	  	type        => "text",
		name        => "samplename",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Salutation",
	  	labels      => "Sehr geehrte Frau Kollegin , Sehr geehrter Herr Kollege, Sehr geehrte KollegInnen",
	  	type        => "radio",
		name        => "salutation",
	  	value       => "kollegin",
	  	values      => "kollegin, kollege, kolleginnen",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "CNV filter",
	  	labels      => "CNV filter, No because of different protocol, No because of bad quality",
	  	type        => "radio",
		name        => "cnvfilter",
	  	value       => "yes",
	  	values      => "yes, noprotocol, noquality",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Write report for<br>likely/pathgenic variants or VUS.<br>Overwrites automatic selection.",
	  	labels      => "automatically, likely/pathogenic, Variant of unknown significance (VUS)",
	  	type        => "radio",
		name        => "userprobability",
	  	value       => "",
	  	values      => ", pathogenic, vus",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for searchIbs
########################################################################
sub initSearchIbs {
my $self         = shift;
my $ref          = "";


my @AoH = (
	  {
	  	label       => "Sample 1",
	  	type        => "text",
		name        => "sample1",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Sample 2",
	  	type        => "text",
		name        => "sample2",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Alleles >= (n)",
	  	type        => "text",
		name        => "alleles",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Frequency (n) > ",
	  	type        => "text",
		name        => "freq",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Frequency (n) < ",
	  	type        => "text",
		name        => "freqmax",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Depth >= ",
	  	type        => "text",
		name        => "coverage",
	  	value       => "10",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SNV quality >= (0-255)",
	  	type        => "text",
		name        => "snvqual",
	  	value       => "$snvqual",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Genotype quality >= (0-99)",
	  	type        => "text",
		name        => "gtqual",
	  	value       => "$gtqual",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Mapping quality >= (0-60)",
	  	type        => "text",
		name        => "mapqual",
	  	value       => "50",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Percent alternative allele",
	  	type        => "text",
		name        => "percentvar",
	  	value       => "",
		size        => "20",
		maxlength   => "20",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Filter",
	  	type        => "text",
		name        => "filter",
	  	value       => "PASS",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for comment
########################################################################
sub initComment {
my $self         = shift;
my $idsnv        = shift;
my $idsample     = shift;
my $reason       = shift;
my $dbh          = shift;
my $table        = shift; #introduced for the new VCF tables which have no default database
my $ref          = "";
my $chrom        = "";
my $start        = "";
my $end          = "";
my $refallele    = "";
my $altallele    = "";
my $query        = "";
my @AoH          = ();

# changed 2020-01-28 in order to add end position. In order to be able to distinghish CNV with the same start position
# changed 2020-07-16 in order to add cause (primary disease) and omimphenotype

if ($table eq "wholegenomehg19.variant") {
$query = "
SELECT chrom,pos,0,ref,alt 
FROM $table
WHERE   idvariant = ?
";
}
elsif ($table eq "svsample") {
$query = "
SELECT chrom,start,0,end 
FROM $table
WHERE   idsvsample = ?
";
}
else {
$query = "
SELECT chrom,start,end,refallele,allele 
FROM snv
WHERE   idsnv = ?
";
}

my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsnv) || die print "$DBI::errstr";
($chrom,$start,$end,$refallele,$altallele) = $out->fetchrow_array;

if ($table eq "svsample") {
	$end = $refallele;
	$refallele = "";
}

@AoH = (
	  {
	  	label       => "ID SNV",
	  	type        => "readonly2",
		name        => "idsnv",
	  	value       => "$idsnv",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ID Sample",
	  	type        => "readonly2",
		name        => "idsample",
	  	value       => "$idsample",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "User",
	  	type        => "readonly2",
		name        => "user",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Context",
	  	type        => "readonly2",
		name        => "reason",
	  	value       => "$reason",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Chromosome",
	  	type        => "readonly2",
		name        => "chrom",
	  	value       => "$chrom",
		size        => "30",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Start",
	  	type        => "readonly2",
		name        => "start",
	  	value       => "$start",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "End",
	  	type        => "readonly2",
		name        => "end",
	  	value       => "$end",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Refallele",
	  	type        => "readonly2",
		name        => "refallele",
	  	value       => "$refallele",
		size        => "30",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Altallele",
	  	type        => "readonly2",
		name        => "altallele",
	  	value       => "$altallele",
		size        => "30",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "SNV rating",
	  	labels      => "unknown, wrong, in mother, in father, in matched control, possible, low coverage, complex, repeat, low mapping quality, correct minortranscript, correct",
	  	type        => "radio",
		name        => "rating",
	  	value       => "unknown",
	  	values      => "unknown, wrong, in_mother, in_father, in_matched_control, possible, low_coverage, complex, repeat, map_low, correct_minortranscript, correct",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "To check",
	  	labels      => "unknown, no, yes",
	  	type        => "radio",
		name        => "checked",
	  	value       => "unknown",
	  	values      => "unknown, no, yes",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Confirmed",
	  	labels      => "unknown, no (variant not confirmed), yes (variant confirmed)",
	  	type        => "radio",
		name        => "confirmed",
	  	value       => "unknown",
	  	values      => "unknown, no, yes",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Genotype",
	  	labels      => "unknown, heterozygous, compound heterozygous, homozygous, hemizygous",
	  	type        => "radio",
		name        => "genotype",
	  	value       => "unknown",
	  	values      => "unknown, heterozygous, compound_heterozygous, homozygous, hemizygous",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Inheritance",
	  	labels      => "unknown, mother, father, mother and father, matched control, de novo, somatic",
	  	type        => "radio",
		name        => "inheritance",
	  	value       => "unknown",
	  	values      => "unknown, mother, father, mo_fa, matched_control, de_novo, somatic",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Confirmed comment",
	  	type        => "text",
		name        => "confirmedcomment",
	  	value       => "",
		size        => "100",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease gene",
	  	labels      => "unknown, not to decide, no candidate, candidate, known_gene, known_mutation",
	  	type        => "radio",
		name        => "gene",
	  	value       => "unknown",
	  	values      => "unknown, not_to_decide, no_candidate, candidate, known_gene, known_mutation",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Functional prediction",
	  	labels      => "unknown, not to decide, benign, possibly damaging, damaging, deleterious",
	  	type        => "radio",
		name        => "disease",
	  	value       => "unknown",
	  	values      => "unknown, not_to_decide, benign, poss_damaging, damaging, deleterious",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Disease comment (max 1500 char)",
	  	type        => "textArea",
		name        => "diseasecomment",
	  	value       => "",
		cols        => "80",
		rows        => "10",
		maxlength   => "1500",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pathogenicity",
	  	labels      => "Unknown, Pathogenic, Likely pathogenic, Unknown significance, Likely benign, Benign",
	  	type        => "radio",
		name        => "patho",
	  	value       => "unknown",
		values      => "unknown, pathogenic, likely pathogenic, unknown significance, likely benign, benign",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cause for ...<br>Required for Report<br>and ClinVar submission",
	  	labels      => "Unknown, Primary disease, Incidental finding",
	  	type        => "radio",
		name        => "causefor",
	  	value       => "unknown",
		values      => "unknown, primary, incidental",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "MIM Phenotype (phenotype number, not gene number)<br>Required for Report<br>and ClinVar submission",
	  	type        => "text",
		name        => "omimphenotype",
	  	value       => "",
		size        => "20",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PubMedID if the variant is published<br>Required for ClinVar submission",
	  	type        => "text",
		name        => "pmid",
	  	value       => "",
		size        => "20",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Affected gene symbol",
	  	type        => "text",
		name        => "genesymbol",
	  	value       => "",
		size        => "80",
		maxlength   => "150",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Pathogenicity comment (max 255 char)",
	  	type        => "textArea",
		name        => "pathocomment",
	  	value       => "",
		cols        => "80",
		rows        => "5",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
);

if ($user eq "tim") {
push(@AoH,(
	  {
	  	label       => "ClinVar SCV",
	  	type        => "text",
		name        => "clinvarscv",
	  	value       => "",
		size        => "100",
		maxlength   => "12",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ClinVar Date",
	  	type        => "text",
		name        => "clinvardate",
	  	value       => "",
		size        => "100",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ClinVar Localkey",
	  	type        => "text",
		name        => "clinvarlocalkey",
	  	value       => "",
		size        => "100",
		maxlength   => "12",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ClinVar SampleID",
	  	type        => "text",
		name        => "clinvarsampleid",
	  	value       => "",
		size        => "100",
		maxlength   => "12",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ClinVar PedigreeID",
	  	type        => "text",
		name        => "clinvarpedid",
	  	value       => "",
		size        => "100",
		maxlength   => "12",
	  	bgcolor     => "formbg",
	  },
));
}

$ref = \@AoH;
return($ref);
}
########################################################################
# insertIntoComment updateComment insertComment
########################################################################

sub insertIntoComment {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $field     = "";
my $value     = "";
my @values    = ();
my @fields    = ();
my @fields2   = ();
my $sql       = "";
my $sth       = "";
my $tmp       = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});
$ref->{omimphenotype} =~ s/\#//;
$ref->{omimphenotype} =~ s/\s+//;

@values = ($ref->{'idsample'},$ref->{'idsnv'});
$sql = "
SELECT idsample 
FROM $exomevcfe.comment
WHERE idsample = ?
AND   idsnv    = ?
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$tmp = $sth->fetchrow_array;
@values = ();
$ref->{user} = $user;
if ($tmp eq "") { # insert
	print "insert<br>";
	$ref->{idcomment} = 0 ;
	@fields           = sort keys %$ref;
	@values           = @{$ref}{@fields};

	$sql = sprintf "insert into %s (%s) values (%s)",
         "$exomevcfe.$table", join(",", @fields), join(",", ("?")x@fields);

	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute(@values) || die print "$DBI::errstr";
	$ref->{idcomment}=$sth->{mysql_insertid};
}
else { # update
	print "update<br>";
	@fields           = sort keys %$ref;
	@values           = @{$ref}{@fields};
	foreach $field (@fields) {
		$value=$field . " = ?";
		push(@fields2,$value);
	}

	$sql = sprintf "UPDATE %s SET %s WHERE idsample=$ref->{idsample}
	               AND idsnv=$ref->{idsnv}",
                       "$exomevcfe.$table", join(",", @fields2);

	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute(@values) || die print "$DBI::errstr";
}
$sql =  "UPDATE $exomevcfe.$table SET changedate=NOW() WHERE idsample=$ref->{idsample}
	               AND idsnv=$ref->{idsnv}";

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";

$sth->finish;

}

########################################################################
# getShowComment
########################################################################

sub getShowComment {
my $self         = shift;
my $dbh          = shift;
my $idsnv        = shift;
my $idsample     = shift;
my $ref          = shift;
my $mode         = shift;
my $table        = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

#$sql = "
#	SELECT c.*
#	FROM $exomevcfe.comment c
#	INNER JOIN snv v ON (c.chrom=v.chrom and c.start=v.start
#	                     and c.refallele=v.refallele and
#			     c.altallele=v.allele)
#	INNER JOIN (SELECT idsnv,idsample,max(indate) indate 
#		   FROM $exomevcfe.comment GROUP BY idsnv,idsample) cc ON 
#		   (c.idsnv=cc.idsnv AND c.idsample=cc.idsample 
#		   AND c.indate=cc.indate)
#	WHERE v.idsnv    = $idsnv
#	AND   c.idsample = $idsample
#	";
if ($table eq "wholegenomehg19.variant") {
$sql = "
	SELECT c.*
	FROM $exomevcfe.comment c
	INNER JOIN $table v ON (c.chrom=v.chrom and c.start=v.pos
	                     and c.refallele=v.ref and
			     c.altallele=v.alt)
	WHERE v.idvariant = $idsnv
	AND   c.idsample  = $idsample
	";
}
if ($table eq "svsample") {
$sql = "
	SELECT c.*
	FROM $exomevcfe.comment c
	INNER JOIN $table svs ON (c.chrom=svs.chrom and c.start=svs.start and c.end=svs.end)
	WHERE svs.idsvsample = $idsnv
	AND   c.idsample  = $idsample
	";
}
else {
$sql = "
	SELECT c.*
	FROM $exomevcfe.comment c
	INNER JOIN snv v ON (c.chrom=v.chrom and c.start=v.start
	                     and c.refallele=v.refallele and
			     c.altallele=v.allele)
	WHERE v.idsnv     = $idsnv
	AND   c.idsample  = $idsample
	";
}
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
#if ($mode eq 'Y') {
#	print "<span class=\"big\">Invoice</span><br><br>" ;
#	print qq(<table border="1" cellspacing="0" cellpadding="3">);
#}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		#if ($mode eq 'Y') {
		#	if ($href->{name} eq 'idinvoice') {
		#		print qq(<tr><td>$href->{label}</td>
		#		<td class="person"><a href="invoice.pl?id=$resultref->{idinvoice}&amp;mode=edit">$resultref->{idinvoice} </a></td></tr>);
		#	}
		#	else {
		#		print "<tr><td>$href->{label}</td>
		#		<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
		#	}
		#}
	}
}

#if ($mode eq 'Y') {
#	print "</table>";
#}

$sth->finish;

}

########################################################################
# init for conclusion
########################################################################
sub initConclusion {
my $self         = shift;
my $idsample     = shift;
my $dbh          = shift;
my $ref          = "";
my $sname        = "";

my $query = "
SELECT name
FROM $sampledb.sample
WHERE   idsample = ?
";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsample) || die print "$DBI::errstr";
($sname) = $out->fetchrow_array;


my @AoH = (
	  {
	  	label       => "Internal ID",
	  	type        => "readonly2",
		name        => "idsample",
	  	value       => "$idsample",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "ID Sample",
	  	type        => "readonly",
		name        => "sname",
	  	value       => "$sname",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "User",
	  	type        => "readonly2",
		name        => "user",
	  	value       => "",
		size        => "30",
		maxlength   => "30",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Solved",
	  	labels      => "not processed, follow-up pending, yes, no, new candidate",
	  	type        => "radio",
		name        => "solved",
	  	value       => "0",
	  	values      => "0, 4, 1, 2, 3",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "MIM phenotype (values must be diseases, but not genes)<br>Use the new fields in the comment form",
	  	type        => "readonly2",
		name        => "omimphenotype",
	  	value       => "",
		size        => "20",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "PubMedID if the case is published<br>Use the new fields in the comment form",
	  	type        => "readonly2",
		name        => "pmid",
	  	value       => "",
		size        => "20",
		maxlength   => "10",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Affected gene symbol",
	  	type        => "readonly2",
		name        => "genesymbol",
	  	value       => "",
		size        => "80",
		maxlength   => "150",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Conclusion (max 4000 char)",
	  	type        => "textArea",
		name        => "conclusion",
	  	value       => "",
		cols        => "80",
		rows        => "10",
		maxlength   => "1500",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment (max 4000 char)",
	  	type        => "textArea",
		name        => "comment",
	  	value       => "",
		cols        => "80",
		rows        => "10",
		maxlength   => "1500",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# init for admin
########################################################################
sub initAdmin {
my $self         = shift;
my $ref          = "";

if ($role ne "admin") {print "Not admin";exit(1);}

my @AoH = (
	  {
	  	label       => "Id",
	  	type        => "readonly2",
		name        => "iduser",
	  	value       => "",
		size        => "20",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Name",
	  	type        => "text",
		name        => "name",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Password (at least <br>8 characters, <br>1 upper case character, <br>1 numeral.)",
	  	type        => "text",
		name        => "password",
	  	value       => "",
		size        => "45",
		maxlength   => "100",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Yubikey",
	  	type        => "text",
		name        => "yubikey",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "IGV port",
	  	type        => "text",
		name        => "igvport",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Cooperations '::' limited",
	  	type        => "text",
		name        => "cooperations",
	  	value       => "",
		size        => "80",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Projects '::' limited",
	  	type        => "text",
		name        => "projects",
	  	value       => "",
		size        => "80",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Role (only admin)",
	  	type        => "text",
		name        => "role",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Gene search (0/1)",
	  	type        => "text",
		name        => "genesearch",
	  	value       => "",
		size        => "45",
		maxlength   => "45",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Burdentests (0 or 1)",
	  	type        => "text",
		name        => "burdentests",
	  	value       => "",
		size        => "45",
		maxlength   => "1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Edit (0 or 1)",
	  	type        => "text",
		name        => "edit",
	  	value       => "",
		size        => "45",
		maxlength   => "1",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Failed last",
	  	type        => "text",
		name        => "failed_last",
	  	value       => "",
		size        => "45",
		maxlength   => "5",
	  	bgcolor     => "formbg",
	  },
	  {
	  	label       => "Comment",
	  	type        => "text",
		name        => "comment",
	  	value       => "",
		size        => "80",
		maxlength   => "255",
	  	bgcolor     => "formbg",
	  },
);

$ref = \@AoH;
return($ref);
}
########################################################################
# insertIntoAdmin
########################################################################

sub insertIntoAdmin {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $mode      = shift;
my $sql       = "";
my $sth       = "";
my @fields    = ();
my @fields2   = ();
my @values    = ();
my $field     = "";
my $value     = "";
my $username  = "";
my $password  = "";
my $salt      = "";
my $yubikey   = "";
my $settings  = "";
my $bcryptpassword = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


use Crypt::Random;

if ($role ne "admin") {print "Not admin";exit(1);}

$username    = $ref->{name};
$password    = $ref->{password};
$yubikey     = $ref->{yubikey};
delete($ref->{password});

if ($ref->{name} eq "") {
	showMenu("");
	print "Please fill in Name. Nothing done.<br>";
	printFooter("",$dbh);
	exit(1);
}

unless ($username =~ /^[a-zA-Z0-9_]+$/) {print "Users must only contain characters, numerals and underscores.\n";exit;}

if ($password ne "") {
if (length($password)<8) {print "Passwords too short.\n";exit;}
	unless ($password=~/\d/) {print "Passwords contains no numbers.\n";exit;}
	unless ($password=~/\D/) {print "Passwords contains no characters.\n";exit;}
	unless ($password=~/[A-Z]/) {print "Passwords contains no upper characters.\n";exit;}
}
if (($yubikey ne "") and ($yubikey ne "0")) {
	if (length($yubikey)!=12) {print "Yubikey must contain 12 characters\n";exit;}
	unless ($yubikey =~ /^[a-z]+$/) {print "Yubikey must only contain lower case characters.\n";exit;}
}
if ($ref->{cooperations} ne "") {
	unless ($ref->{cooperations} =~ /^[a-zA-Z0-9:_]+$/) {print "Cooperations must only contain characters, numerals, colons and underscores.\n";exit;}
}
if ($ref->{projects} ne "") {
	unless ($ref->{projects} =~ /^[a-zA-Z0-9:_]+$/) {print "Projects must only contain characters, numerals, colons and underscores.\n";exit;}
}

unless ($password eq '') {
	$salt            = Crypt::Eksblowfish::Bcrypt::en_base64(Crypt::Random::makerandom_octet(Length=>16));
	$settings        = '$2a$08$'.$salt;
	$bcryptpassword  = Crypt::Eksblowfish::Bcrypt::bcrypt($password,$settings);
}

$table=$exomevcfe . '.' . $table;

if ($mode eq "edit") {

	@fields    = sort keys %$ref;
	@values    = @{$ref}{@fields};
	foreach $field (@fields) {
		$value=$field . " = ?";
		push(@fields2,$value);
	}
	unless ($password eq '') {
		push(@fields2,"password = ?");
		push(@values,$bcryptpassword);
	}

	$sql = sprintf "UPDATE %s SET %s WHERE iduser=?",
         $table, join(",", @fields2);
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute(@values,$ref->{'iduser'}) || die print "$DBI::errstr";

}
else { # insert
	if ($password eq "") {
		showMenu("");
		print "Please fill in Password. Nothing done.<br>";
		printFooter("",$dbh);
		exit(1);
	}

	$ref->{iduser} = 0 ;
	@fields           = sort keys %$ref;
	@values           = @{$ref}{@fields};
	push(@fields,"password");
	push(@values,$bcryptpassword);


	$sql = sprintf "insert into %s (%s) values (%s)",
         $table, join(",", @fields), join(",", ("?")x@fields);
		 
	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute(@values) || die print "$DBI::errstr";
	$ref->{iduser}=$sth->{mysql_insertid};
	
}

}
########################################################################
# showAllAdmin
########################################################################

sub showAllAdmin {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = "";

if ($role ne "admin") {print "Not admin";exit(1);}

$ref = $self->initAdmin   ();
$self->getShowAdmin($dbh,$id,$ref,'Y');

}

########################################################################
# getShowAdmin
########################################################################

sub getShowAdmin {
my $self         = shift;
my $dbh          = shift;
my $id           = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

my $table = $exomevcfe . '.user';

if ($role ne "admin") {print "Not admin";exit(1);}

$sql = "
	SELECT *
	FROM $table 
	WHERE iduser = ?
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute($id) || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
if ($mode eq 'Y') {
	print "<span class=\"big\">Admin</span><br><br>" ;
	print qq(<table border="1" cellspacing="0" cellpadding="3">);
}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		# do not show password hash 
		unless ($href->{name} eq 'password') {
			$href->{value} = $resultref->{$href->{name}};
		}
		if ($mode eq 'Y') {
			if ($href->{name} eq 'iduser') {
				print qq(<tr><td>$href->{label}</td>
				<td class="person"><a href="admin.pl?id=$resultref->{iduser}&amp;mode=edit">$resultref->{iduser} </a></td></tr>);
			}
			# do not show password hash 
			elsif ($href->{name} eq 'password') {
			}
			else {
				print "<tr><td>$href->{label}</td>
				<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
			}
		}
	}
}

if ($mode eq 'Y') {
	print "</table>";
}

$sth->finish;

}
########################################################################
# vcf2mutalyzer
########################################################################

sub vcf2mutalyzer {
	my $dbh   = shift;
	my $idsnv = shift;
	#$a[0] = chrom
	#$a[1] = start
	#$a[3] = refallele
	#$a[4] = allele 
	my $query = "
	SELECT chrom,start,class,refallele,allele
	FROM snv
	WHERE idsnv=$idsnv
	";
	my $out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	my @a = $out->fetchrow_array;
	my $rk = "$a[0]:g.";
	
	# exclude large deletions and inserstions
	if (($a[3] eq "LD") or ($a[3] eq "LI")) {
		return $a[2],
	}
	else {
	if (length($a[3]) == 1 && length($a[4]) == 1) {
		$rk .= $a[1]; #+1?
		$rk .= $a[3] . ">" . $a[4];
	}
	else {
		#check if insertion or deletion
		if (length($a[3]) > length($a[4])) {
			#deletion
			$rk .= ($a[1] + 1) . "_" . ($a[1]+
			(length($a[3])-length($a[4]))) ;
			$rk .= "del";
			$rk .= substr($a[3], 1, (length($a[3])-length($a[4])));
		}
		else {
			#insertion
			$rk .= ($a[1] ) . "_" . ($a[1] + 1);
			$rk .= "ins";
			$rk .= substr($a[4], 1, (length($a[4])-length($a[3])));
		}
	}
	$rk=HTML::Entities::encode($rk);

	#$rk = "<a href=\"https://www.mutalyzer.nl/position-converter?assembly_name_or_alias=GRCh37&amp;description=$rk\">$a[2]</a>";
	$rk = "<a href=\"https://www.mutalyzer.nl/position-converter?assembly_name_or_alias=GRCh37&amp;description=$rk\">$a[2]</a>";
	#chr10%3Ag.5254654C%3EG
	return $rk;
	}
}


########################################################################
# insertIntoConclusion updateConclusion insertConclusion
########################################################################

sub insertIntoConclusion {
my $self      = shift;
my $ref       = shift;
my $dbh       = shift;
my $table     = shift;
my $field     = "";
my $value     = "";
my @values    = ();
my @fields    = ();
my @fields2   = ();
my $sql       = "";
my $sth       = "";
my $tmp       = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});
$ref->{omimphenotype} =~ s/\#//;
$ref->{omimphenotype} =~ s/\s+//;


@values = ($ref->{'idsample'});
$sql = "
SELECT idsample 
FROM $exomevcfe.conclusion
WHERE idsample = ?
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute(@values) || die print "$DBI::errstr";
$tmp = $sth->fetchrow_array;
@values = ();
$ref->{user} = $user;
if ($tmp eq "") { # insert
	print "insert<br>";
	$ref->{idconclusion} = 0 ;
	@fields           = sort keys %$ref;
	@values           = @{$ref}{@fields};

	$sql = sprintf "insert into %s (%s) values (%s)",
         "$exomevcfe.$table", join(",", @fields), join(",", ("?")x@fields);

	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute(@values) || die print "$DBI::errstr";
	$ref->{idconclusion}=$sth->{mysql_insertid};
}
else { # update
	print "update<br>";
	@fields           = sort keys %$ref;
	@values           = @{$ref}{@fields};
	foreach $field (@fields) {
		$value=$field . " = ?";
		push(@fields2,$value);
	}

	$sql = sprintf "UPDATE %s SET %s WHERE idsample=$ref->{idsample}",
                       "$exomevcfe.$table", join(",", @fields2);

	$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
	$sth->execute(@values) || die print "$DBI::errstr";
}
$sql =  "UPDATE $exomevcfe.$table SET changedate=NOW() WHERE idsample=$ref->{idsample}";

$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";

$sth->finish;

}
########################################################################
# getShowConclusion
########################################################################

sub getShowConclusion {
my $self         = shift;
my $dbh          = shift;
my $idsample     = shift;
my $ref          = shift;
my $mode         = shift;

my $sth          = "";
my $resultref    = "";
my $sql          = "";
my $href         = "";

#$sql = "
#	SELECT c.*
#	FROM $exomevcfe.comment c
#	INNER JOIN snv v ON (c.chrom=v.chrom and c.start=v.start
#	                     and c.refallele=v.refallele and
#			     c.altallele=v.allele)
#	INNER JOIN (SELECT idsnv,idsample,max(indate) indate 
#		   FROM $exomevcfe.comment GROUP BY idsnv,idsample) cc ON 
#		   (c.idsnv=cc.idsnv AND c.idsample=cc.idsample 
#		   AND c.indate=cc.indate)
#	WHERE v.idsnv    = $idsnv
#	AND   c.idsample = $idsample
#	";
$sql = "
	SELECT cl.*
	FROM $exomevcfe.conclusion cl
	INNER JOIN $sampledb.sample s ON (cl.idsample=s.idsample)
	WHERE cl.idsample = $idsample
	";
#print "$sql\n";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute || die print "$DBI::errstr";
$resultref = $sth->fetchrow_hashref;

# fill @AoH with results
#if ($mode eq 'Y') {
#	print "<span class=\"big\">Invoice</span><br><br>" ;
#	print qq(<table border="1" cellspacing="0" cellpadding="3">);
#}

for $href ( @{$ref} ) {
	if (exists $resultref->{$href->{name}}) {
		$href->{value} = $resultref->{$href->{name}};
		#if ($mode eq 'Y') {
		#	if ($href->{name} eq 'idinvoice') {
		#		print qq(<tr><td>$href->{label}</td>
		#		<td class="person"><a href="invoice.pl?id=$resultref->{idinvoice}&amp;mode=edit">$resultref->{idinvoice} </a></td></tr>);
		#	}
		#	else {
		#		print "<tr><td>$href->{label}</td>
		#		<td> $resultref->{$href->{name}} &nbsp;</td></tr>";		
		#	}
		#}
	}
}

#if ($mode eq 'Y') {
#	print "</table>";
#}

$sth->finish;

}
########################################################################
# todaysdate
########################################################################
sub todaysdate {

my ($day,$month,$year)=(localtime)[3,4,5];
$day=sprintf("Date: %02d.%02d.%04d",$day, $month+1, $year+1900);
print "$day<br>";

}
########################################################################
# mylocaltime
########################################################################
sub mylocaltime {

my ($day,$month,$year)=(localtime)[3,4,5];
$day=sprintf("%04d-%02d-%02d",$year+1900, $month+1, $day);
return $day;

}
########################################################################
# number of samples
########################################################################
sub numberofsamples {
my $dbh   = shift;
my $query = "";
my $out   = "";
my $count = "";

# Number of samples
$query = qq#
SELECT
count(distinct idsample)
FROM
snvsample
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$count = $out->fetchrow_array;
print "Number of samples: $count<br>";
return($count);
}
########################################################################
# select region
########################################################################

sub selectregion {
my $dbh        = shift;
my $pedigree   = shift;
my @row        = ();
my $out        = "";
my $query      = "";
my $key        = "";
my @region     = ();

$query = qq#
SELECT
r.chrom, r.start, r.end
FROM
$sampledb.sample s right join $sampledb.region r on (s.idsample = r.idsample)
WHERE
pedigree = ?
GROUP BY chrom,start,end
#;
#print "$query<br>\n";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($pedigree) || die print "$DBI::errstr";

#ArrayOfArray of regions
while (@row = $out->fetchrow_array) {
	#print "@row<br>\n";
	push(@region,[@row]);
}

return(@region);
}

########################################################################
# select region of individuals
########################################################################

sub selectregionind {
my $dbh         = shift;
my $aref        = shift;
my $individuals = "";
my @row         = ();
my $out         = "";
my $query       = "";
my $key         = "";
my @region      = ();
my @prepare     = ();
my $tmp         = "";
my $i           = 0;

foreach $tmp (@$aref) {
	if ($i == 0) {
		$individuals    .= "(";
	}
	if ($i != 0) {
		$individuals    .= "OR ";
	}
	$individuals      .= "s.name = ? ";
	push(@prepare,$tmp);
	$i++;
}
$individuals    .= ") ";

$query = qq#
SELECT
r.chrom, r.start, r.end
FROM
$sampledb.sample s right join $sampledb.region r on (s.idsample = r.idsample)
WHERE
$individuals
GROUP BY chrom,start,end
#;
#print "$query<br>\n";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

#ArrayOfArray of regions
while (@row = $out->fetchrow_array) {
	#print "@row<br>\n";
	push(@region,[@row]);
}

return(@region);
}
########################################################################
# function
########################################################################
sub function {
my $function = shift;
my $dbh      = shift;
my $tt       = chr(0);
my @function = split(/$tt/,$function);
my $i        = 0;
my $tmp      = "";
my $functionprint = "";
my @row           = ();
my %row       = ();

# sanitization
my $sql = "
SHOW COLUMNS
FROM snv
WHERE field = 'func'
";
my $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
$row[1]=~s/\'//g;
$row[1]=~/set\((.*)\)$/;
@row=split(/\,/,$1);
foreach (@row) {
	$row{$_}=$_;
}

if ($function ne '') {
	$function = "AND (";
	foreach $tmp (@function) {
		if (exists $row{$tmp}) {
			if ($i > 0) {
				$function .= " OR ";
			}
			$function .= " (FIND_IN_SET('$tmp',v.func) > 0)";
			$i++;
		}
		else {
			die;
		}
	}
	$function .= ")";
}
$functionprint=" @function";
return($function,$functionprint);
}
########################################################################
# functionvcf
########################################################################
sub functionvcf {
my $function      = shift;
my $dbh           = shift;
my $tt            = chr(0);
my @function      = split(/$tt/,$function);
my $i             = 0;
my $tmp           = "";
my $functionprint = "";
my $consequence   = "";
my %e2v           = (); #EVAdb funtion mapped to vep_Consequence

$e2v{'unknown'} = ['transcript_amplification'];
$e2v{'syn'} = ['synonymous_variant'];
$e2v{'missense'} = ['missense_variant','coding_sequence_variant','protein_altering_variant'];
$e2v{'nonsense'} = ['stop_gained','NMD_transcript_variant','incomplete_terminal_codon_variant','stop_retained_variant','start_lost','transcript_ablation'];
$e2v{'stoploss'} = ['stop_lost'];
$e2v{'splice'} = ['splice_acceptor_variant','splice_donor_variant'];
$e2v{'nearsplice'} = ['splice_region_variant'];
$e2v{'frameshift'} = ['frameshift_variant'];
$e2v{'indel'} = ['inframe_insertion','inframe_deletion'];
$e2v{'5utr'} = ['5_prime_UTR_variant'];
$e2v{'3utr'} = ['3_prime_UTR_variant'];
$e2v{'mirna'} = ['mature_miRNA_variant'];
$e2v{'noncoding'} = ['non_coding_transcript_exon_variant','non_coding_transcript_variant'];
$e2v{'intronic'} = ['intron_variant'];
$e2v{'intergenic'} = ['intergenic_variant','upstream_gene_variant','downstream_gene_variant'];
$e2v{'regulation'} = ['TFBS_ablation','TFBS_amplification','TF_binding_site_variant','regulatory_region_ablation','regulatory_region_amplification','feature_elongation','regulatory_region_variant','feature_truncation'];

if ($function ne '') {
	$function = "AND (";
	foreach $tmp (@function) {
		foreach $consequence (@{$e2v{$tmp}}) {
			if ($i > 0) {
				$function .= " OR ";
			}
			$function .= " (FIND_IN_SET('$consequence',v.vep_Consequence) > 0)";
			$i++;
		}
	}
	$function .= ")";
}
$functionprint=" @function";
return($function,$functionprint);
}
########################################################################
# class
########################################################################
sub class {
my $class = shift;
my $dbh   = shift;
my $tt    = chr(0);
my @class = split(/$tt/,$class);
my $i     = 0;
my $tmp   = "";
my $classprint="";
my @row       = ();
my %row       = ();

# sanitization
my $sql = "
SHOW COLUMNS
FROM snv
WHERE field = 'class'
";
my $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
$row[1]=~s/\'//g;
$row[1]=~/enum\((.*)\)$/;
@row=split(/\,/,$1);
foreach (@row) {
	$row{$_}=$_;
}

if ($class ne '') {
	$class = "AND (";
	foreach $tmp (@class) {
		if (exists $row{$tmp}) {
			if ($i > 0) {
				$class .= " OR ";
			}
			$class .= " (v.class='$tmp')";
			$i++;
		}
		else {
			die;
		}
	}
	$class .= ")";
}
$classprint=" @class";
return($class,$classprint);
}
########################################################################
# caller
########################################################################
sub caller {
my $class = shift;
my $dbh   = shift;
my $tt    = chr(0);
my @class = split(/$tt/,$class);
my $i     = 0;
my $tmp   = "";
my $classprint="";
my @row       = ();
my %row       = ();

print "@class<br>";
# sanitization
my $sql = "
SHOW COLUMNS
FROM svsample
WHERE field = 'caller'
";
my $sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute() || die print "$DBI::errstr";
@row = $sth->fetchrow_array;
$row[1]=~s/\'//g;
$row[1]=~/set\((.*)\)$/;
@row=split(/\,/,$1);
#print "@row<br>";
foreach (@row) {
	$row{$_}=$_;
}

if ($class ne '') {
	$class = "AND (";
	foreach $tmp (@class) {
		if ((exists $row{$tmp}) and ($tmp ne '')) { # in case 'all' is checked
			if ($i > 0) {
				$class .= " OR ";
			}
			$class .= " (FIND_IN_SET('$tmp',svs.caller) > 0)";
			$i++;
		}
	}
	$class .= ")";
}
$classprint=" @class";
return($class,$classprint);
}
########################################################################
# genotype
########################################################################
sub genotype {
my $genotype = shift;
my $dbh      = shift;
my $tt       = chr(0);
my @genotype = split(/$tt/,$genotype);
my $i        = 0;
my $tmp      = "";
my $genotypeprint="";
my @row      = ('unknown', 'heterozygous', 'compound_heterozygous', 'homozygous', 'hemizygous');
my %row      = ();

#"unknown, mother, father, mo_fa, matched_control, de_novo, somatic",

foreach (@row) {
	$row{$_}=$_;
}

if ($genotype ne "") {
	$genotype = "AND (";
	foreach $tmp (@genotype) {
		if (exists $row{$tmp}) {
			if ($i > 0) {
				$genotype .= " OR ";
			}
			$genotype .= " c.genotype = '$tmp'";
			$i++;
		}
		else {
			die;
		}
	}
	$genotype .= ")";
}
$genotypeprint=" @genotype";
return($genotype,$genotypeprint);
}
########################################################################
# inheritance
########################################################################
sub inheritance {
my $genotype = shift;
my $dbh      = shift;
my $tt       = chr(0);
my @genotype = split(/$tt/,$genotype);
my $i        = 0;
my $tmp      = "";
my $genotypeprint="";
my @row      = ('unknown', 'mother', 'father', 'mo_fa', 'matched_control', 'de_novo', 'somatic');
my %row      = ();


foreach (@row) {
	$row{$_}=$_;
}

if ($genotype ne "") {
	$genotype = "AND (";
	foreach $tmp (@genotype) {
		if (exists $row{$tmp}) {
			if ($i > 0) {
				$genotype .= " OR ";
			}
			$genotype .= " c.inheritance = '$tmp'";
			$i++;
		}
		else {
			die;
		}
	}
	$genotype .= ")";
}
$genotypeprint=" @genotype";
return($genotype,$genotypeprint);
}
########################################################################
# patho
########################################################################
sub patho {
my $genotype = shift;
my $dbh      = shift;
my $tt       = chr(0);
my @genotype = split(/$tt/,$genotype);
my $i        = 0;
my $tmp      = "";
my $genotypeprint="";
my @row      = ('unknown', 'pathogenic', 'likely pathogenic', 'unknown significance', 'likely benign', 'benign');
my %row      = ();


foreach (@row) {
	$row{$_}=$_;
}

if ($genotype ne "") {
	$genotype = "AND (";
	foreach $tmp (@genotype) {
		if (exists $row{$tmp}) {
			if ($i > 0) {
				$genotype .= " OR ";
			}
			$genotype .= " c.patho = '$tmp'";
			$i++;
		}
		else {
			die;
		}
	}
	$genotype .= ")";
}
$genotypeprint=" @genotype";
return($genotype,$genotypeprint);
}
########################################################################
# diseasegene
########################################################################
sub diseasegene {
my $genotype = shift;
my $dbh      = shift;
my $tt       = chr(0);
my @genotype = split(/$tt/,$genotype);
my $i        = 0;
my $tmp      = "";
my $genotypeprint="";
my @row      = ('Unknown', 'not to decide', 'no candidate', 'candidate', 'known_gene', 'known_mutation');
my %row      = ();


foreach (@row) {
	$row{$_}=$_;
}

if ($genotype ne "") {
	$genotype = "AND (";
	foreach $tmp (@genotype) {
		if (exists $row{$tmp}) {
			if ($i > 0) {
				$genotype .= " OR ";
			}
			$genotype .= " c.gene = '$tmp'";
			$i++;
		}
		else {
			die;
		}
	}
	$genotype .= ")";
}
$genotypeprint=" @genotype";
return($genotype,$genotypeprint);
}
########################################################################
# getDiseaseById
########################################################################
sub getDiseaseById {
my $dbh       = shift;
my $iddisease = shift;
my $sql       = "";
my $sth       = "";
my @row       = ();
my $name      = "";

$sql = "
SELECT name
FROM $sampledb.disease
WHERE iddisease = ?
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute($iddisease) || die print "$DBI::errstr";
($name)=@row = $sth->fetchrow_array;

return($name);
}
########################################################################
# getDiseaseGroupById
########################################################################
sub getDiseaseGroupById {
my $dbh            = shift;
my $iddiseasegroup = shift;
my $sql            = "";
my $sth            = "";
my @row            = ();
my $name           = "";

$sql = "
SELECT name
FROM $sampledb.diseasegroup
WHERE iddiseasegroup = ?
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute($iddiseasegroup) || die print "$DBI::errstr";
($name)=@row = $sth->fetchrow_array;

return($name);
}
########################################################################
# getIdsampleByName
########################################################################
sub getIdsampleByName {
my $dbh       = shift;
my $name      = shift;
my $sql       = "";
my $sth       = "";
my @row       = ();
my $idsample  = "";

$sql = "
SELECT idsample
FROM $sampledb.sample
WHERE name = ?
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute($name) || die print "$DBI::errstr";
($idsample)=@row = $sth->fetchrow_array;

return($idsample);
}
########################################################################
# getSampleNameByIdsample
########################################################################
sub getSampleNameByIdsample {
my $dbh       = shift;
my $idsample  = shift;
my $sql       = "";
my $sth       = "";
my @row       = ();
my $samplename  = "";

$sql = "
SELECT name
FROM $sampledb.sample
WHERE idsample = ?
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute($idsample) || die print "$DBI::errstr";
($samplename)=@row = $sth->fetchrow_array;

return($samplename);
}
########################################################################
# getSamplenamesByPedigree
########################################################################
sub getSamplenamesByPedigree {
my $dbh         = shift;
my $pedigree    = shift;
my $sql         = "";
my $sth         = "";
my $row         = ();
my @samplenames = ();

$sql = "
SELECT name
FROM $sampledb.sample
WHERE pedigree = ?
";
$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
$sth->execute($pedigree) || die print "$DBI::errstr";
while ($row = $sth->fetchrow_array) {
	push(@samplenames,$row);
}

return(@samplenames);
}
########################################################################
# printqueryheader
########################################################################

sub printqueryheader {
my $ref           = shift;
my $classprint    = shift;
my $functionprint = shift;
my $tmp           = "";
print "Class: $classprint<br>\n";
print "Function: $functionprint<br>\n";
$tmp=HTML::Entities::encode($ref->{'snvqual'});
print "SNV qual: >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'gtqual'});
print "Genotype qual: >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'mapqual'});
print "MAPqual: >= $tmp<br>\n";
}

########################################################################
# searchResults same variant in pedigree autosomal dominant resultsdominant
########################################################################
sub searchResults {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my %row2      = ();
my $query     = "";
my $i         = 0;
my $r         = 0;
my $n         = 1;
my $tmp       = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint = "";
my $ncontrols = "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $position  = "";
my $diseasegroup = "";
my $allowedprojects = &allowedprojects("s.");
my $idsample  = "";
my @idsamples = ();
my $sname     = "";
my @snames    = ();
my $excluded  = "";
my @excluded  = ();
my $where     = "";
my @prepare   = ();

if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}


if ($ref->{"ds.iddisease"} ne "") {
	$query = "
	SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
	INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
	WHERE $allowedprojects
	AND ds.iddisease = ?
	$where
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($ref->{"ds.iddisease"},@prepare) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@idsamples,$row[0]);
		push(@snames,$row[1]);
		push(@excluded,$row[2]);
	}
}
else { # suche  pedigrees
	$query = "
	SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample  = ds.idsample
	INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
	WHERE $allowedprojects
	AND s.pedigree = ?
	$where
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($ref->{"s.pedigree"},@prepare) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@idsamples,$row[0]);
		push(@snames,$row[1]);
		push(@excluded,$row[2]);
	}
	if ($idsamples[0] eq "") {
		print "Pedigree does not exist.<br>";
		exit(1);
	}
}

if ($ref->{"showall"} == 0) {
	$where .= " AND dg.idgene != '' ";
}
if ($ref->{'x.alleles'} ne "") {
	$where .= " AND x.alleles >= ? ";
	push(@prepare,$ref->{'x.alleles'});
}
if ($ref->{'ncontrols'} ne "") {
	$where .= " AND (f.samplecontrols <= ? or ISNULL(f.samplecontrols) )";
	push(@prepare,$ref->{'ncontrols'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

my $explain = "";
if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}
# function
($class,$classprint)=&class($ref->{'class'},$dbh);
($function,$functionprint)=&function($ref->{'function'},$dbh);

&todaysdate;
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

my $diseasename=&getDiseaseById($dbh,$ref->{'ds.iddisease'});
if ($diseasename ne "") {
	print "Disease: $diseasename<br>\n";
}
else {
	$tmp=HTML::Entities::encode($ref->{'s.pedigree'});
	print "Pedigree: $tmp<br>\n";
}
$diseasegroup=&getDiseaseGroupById($dbh,$excluded[0]);
print "Exluded in controls: $diseasegroup<br>\n";
$tmp=HTML::Entities::encode($ref->{'x.alleles'});
print "Variant alleles >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncases'});
print "Cases   >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'npedigrees'});
print "Pedigrees   >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncontrols'});
print "Variants allowed in controls  <= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'aa_het'});
print "EVS African American (heterozygous): <= $tmp<br>\n";
&printqueryheader($ref,$classprint,$functionprint);
my $igvfile       = "";
my $cnvfile       = "";
my %nngenesymbol  = ();
my %npedigree     = ();
my %ncases        = ();
my @row2          = ();
my $nforeach      = -1;
my $cchrom        = "";
my $cstart        = "";
my $cidsnv        = "";
my $cgenesymbol   = "";
my @cgenesymbol   = ();
my $cidsample     = "";

############################# foreach pedigree #########################
foreach $idsample (@idsamples) {
$nforeach++;

$igvfile     = &igvfile($snames[$nforeach],'ExomeDepthSingle.seg',$dbh,'noprint');
print " $igvfile";
$cnvfile     = &cnvfile($snames[$nforeach],$dbh);
print " $cnvfile";
$igvfile     = &igvfile($snames[$nforeach],'refSeqCoveragePerTarget.seg',$dbh,'noprint');
print " $igvfile";
$cnvfile     = &cnvnator($snames[$nforeach],$dbh);
print " $cnvfile";
$cnvfile     = &cnvnator($snames[$nforeach],$dbh,'breakdancer');
print " $cnvfile";

$query = qq#
$explain SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree),
s.sex,
d.symbol,
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
c.rating,
c.patho,
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(DISTINCT g.omim separator ' '),
group_concat(DISTINCT $mgiID separator ' '),
v.class,
replace(v.func,',',' '),
group_concat(DISTINCT x.alleles),
f.fsample,
f.samplecontrols,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(DISTINCT g.nonsynpergene,' (', g.delpergene,')' separator '<br>'),
dgv.depth,
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT x.filter SEPARATOR ', '),
group_concat(DISTINCT x.snvqual SEPARATOR ', '),
group_concat(DISTINCT x.gtqual SEPARATOR ', '),
group_concat(DISTINCT x.mapqual SEPARATOR ', '),
group_concat(DISTINCT x.coverage SEPARATOR ', '),
group_concat(DISTINCT x.percentvar SEPARATOR ', '),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
group_concat(dg.class),
v.chrom,
v.start,
v.idsnv,
group_concat(DISTINCT g.genesymbol),
x.idsample
FROM
snv v
INNER JOIN snvsample                     x ON (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp               dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample              s ON (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample     ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease             d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup              f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN snvgene                       y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                          g ON (g.idgene = y.idgene)
LEFT  JOIN disease2gene                 dg ON (ds.iddisease=dg.iddisease AND g.idgene=dg.idgene)
LEFT  JOIN $sampledb.mouse              mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.pph3                pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift               sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd               cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs                 evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores          exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords         h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar              cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment            c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
$allowedprojects
AND x.idsample = ?
AND (f.fiddiseasegroup = ? or ISNULL(f.fiddiseasegroup) )
$where
$function
$class
GROUP BY
v.idsnv
ORDER BY
v.chrom,v.start
#;
#print "<br>where $where<br>";
#print "prepare @prepare<br>";

if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
	print "exluded $excluded[$nforeach] ";
	print "snvqual $ref->{'snvqual'} ";
	print "mapqual $ref->{'mapqual'} ";
	print "$ref->{'x.alleles'} ";
	print "$ref->{'nonsynpergene'} ";
	print "$ref->{'avhet'} ";
	print "$ref->{'aa_het'} ";
	print "$ref->{'idproject'} ";
	print "$ref->{'ncontrols'} ";
	print "$ref->{'ncases'} <br>";
}
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(
$idsample,
$excluded[$nforeach],
@prepare,
)
|| die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

# check for minimal pedigrees
# doppelte Variations pro gene muessen entfernt werden
while (@row = $out->fetchrow_array) {
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	$ncases{"$cchrom\_$cstart\_$cidsnv\_$row[2]"}++; #row[2]  == pedigree
	if ($ncases{"$cchrom\_$cstart\_$cidsnv\_$row[2]"} == $ref->{"ncases"}) {
		foreach $cgenesymbol (@cgenesymbol) {
			$npedigree{$cgenesymbol}{$row[2]}++;  #gene,pedigree 
		}
	}
	foreach $cgenesymbol (@cgenesymbol) {
		if ($npedigree{$cgenesymbol}{$row[2]} == 1 ) { #changed 2014-03-13
			$npedigree{$cgenesymbol}{$row[2]}++; # can not be counted any longer
			$nngenesymbol{$cgenesymbol}++; #gene
			#print "$cchrom\_$cstart\_$cidsnv\_$row[2] $idsample $cgenesymbol $nngenesymbol{$cgenesymbol}<br>";
		}
	}
	#push(@row2,[@row]);
	$row2{"$cchrom\_$cstart\_$cidsnv\_$cidsample"}=[@row]; #order foreach
}

} # foreach sampleid


# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $aref;
my $damaging     = 0;
my $omimmode     = "";
my $omimdiseases = "";
my $program      = "";
my $rating       = "";
my $checked      = "";
my $confirmed    = "";
my $idsamplesvcf = "";
my $idsnvsvcf    = "";
#for  $aref (@row2) { 
#	@row=@{$aref};
for  $aref (sort keys %row2) { 
	@row=@{ $row2{$aref} };
	#$i=0;
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	# bekannte Gene in disease2gene color red
	$class="default";
	if ($row[-1] ne "") {
		$class=&diseaseGeneColorNew($row[-1]);
	}
	else  {
		$class = "";
	}
	pop(@row);
	foreach $cgenesymbol (@cgenesymbol) {
	$i=0;
	foreach (@row) {
		if ( ($nngenesymbol{$cgenesymbol} >= $ref->{"npedigrees"} ) 
		and ($ncases{"$cchrom\_$cstart\_$cidsnv\_$row[2]"} >= $ref->{"ncases"}) ) {
			if ($i == 0) { 
				$idsamplesvcf .= "$cidsample,";
				$idsnvsvcf    .= "$cidsnv,";
				print "<tr>";
				print "<td align=\"center\">$n</td>";
				$n++;
			}
			if ($i == 1) {
				print qq#
				<td style='white-space:nowrap;'>
				<div class="dropdown">
				$row[$i]&nbsp;&nbsp;
				<a href="comment.pl?idsnv=$cidsnv&idsample=$cidsample&reason=ad">
				<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
				</a>
				</div>
				</td>
			#;
			}
			elsif ($i == 5) {
				$tmp=&ucsclink2($row[$i]);
				print "<td align=\"center\">$tmp</td>";
			}
			elsif ($i == 9) {
				($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
				print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
			}
			elsif ($i == 11) {
				($tmp)=&vcf2mutalyzer($dbh,$cidsnv);
				print "<td align=\"center\">$tmp</td>";
			}
			elsif (($i==24) or ($i==25)) {
				if ($i==24) {$program = 'polyphen2';}
				if ($i==25) {$program = 'sift';}
				$damaging=&damaging($program,$row[$i]);
				if ($damaging==1) {
					print "<td $warningtdbg>$row[$i]</td>";
				}
				else {
					print "<td> $row[$i]</td>";
				}
			}
			elsif ($i == 31) { # cnv exomedetph
				$tmp=$row[$i];
				if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
				}
				print "<td>$tmp</td>";
			}
			elsif ($i == 33) { # transcripts
				print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
			}
			else {
				print "<td align=\"center\">$row[$i]</td>";
			}
			if ($i == @row-1) {
				print "</tr>\n";
			}
			$i++;
		}
	}
	if ($i>0) {last;} # end each @cgenesymbol when the first one is printed
	}
}
print "</tbody></table></div>";

&callvcf($idsamplesvcf,$idsnvsvcf);


$out->finish;
}
########################################################################
# searchResultsSameVariant same variant
########################################################################
sub searchResultsSameVariant {
my $self            = shift;
my $dbh             = shift;
my $ref             = shift;

my @labels          = ();
my $out             = "";
my @row             = ();
my %row2            = ();
my $query           = "";
my $i               = 0;
my $r               = 0;
my $n               = 1;
my $tmp             = "";
my $function        = "";
my $functionprint   = "";
my $class           = "";
my $classprint      = "";
my $ncontrols       = "";
my $chrom           = "";
my $start           = "";
my $end             = "";
my $position        = "";
my $diseasegroup    = "";
my $allowedprojects = &allowedprojects("s.");
my $idsample        = "";
my @idsamples       = ();
my $sname           = "";
my @snames          = ();
my $excluded        = "";
my @excluded        = ();
my $where           = "";
my @prepare         = ();
my @individuals     = ();

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}


if ($ref->{"ds.iddisease"} ne "") {
	$query = "
	SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
	INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
	WHERE $allowedprojects
	AND ds.iddisease = ?
	$where
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($ref->{"ds.iddisease"},@prepare) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@idsamples,$row[0]);
		push(@snames,$row[1]);
		push(@excluded,$row[2]);
	}
}
elsif ($ref->{"s.name"} ne "") {
	$ref->{"s.name"}=trim($ref->{"s.name"});
	@individuals= split(/\s+/,$ref->{"s.name"});
	foreach $tmp (@individuals) {
		$query = "
		SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
		FROM $sampledb.sample s
		INNER JOIN $sampledb.disease2sample ds ON s.idsample  = ds.idsample
		INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
		WHERE $allowedprojects
		AND s.name = ?
		$where
		";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute($tmp,@prepare) || die print "$DBI::errstr";
		while (@row = $out->fetchrow_array) {
			push(@idsamples,$row[0]);
			push(@snames,$row[1]);
			push(@excluded,$row[2]);
		}
		if ($idsamples[0] eq "") {
			print "$tmp does not exist.<br>";
			exit(1);
		}
	}
}
else {
	print "Sample IDs or disease required!<br>";
	exit(1);
}

if ($giabradio == 1) {
if ($ref->{'giab'} ne "") {
	$where .= " AND v.giab = ? ";
	push(@prepare,$ref->{'giab'});
}
}
if ($ref->{'x.alleles'} ne "") {
	$where .= " AND x.alleles >= ? ";
	push(@prepare,$ref->{'x.alleles'});
}
if ($ref->{'ncontrols'} ne "") {
	$where .= " AND (f.samplecontrols <= ? or ISNULL(f.samplecontrols) )";
	push(@prepare,$ref->{'ncontrols'});
}
if ($ref->{'chrom'} ne "") { 
	$chrom=$ref->{'chrom'};
	$chrom=~s/,//g;
	$chrom=~s/\s+//g;
	($chrom,$start)=split(/\:/,$chrom);
	$where .= " AND v.chrom = ? ";
	push(@prepare,$chrom);
	($start,$end)=split(/\-/,$start);
	$where .= " AND v.start >= ? ";
	$where .= " AND v.end <= ? ";
	push(@prepare,$start);
	push(@prepare,$end);
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

my $explain = "";
if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}
# function
($class,$classprint)=&class($ref->{'class'},$dbh);
($function,$functionprint)=&function($ref->{'function'},$dbh);

&todaysdate;
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

my $diseasename=&getDiseaseById($dbh,$ref->{'ds.iddisease'});
if ($diseasename ne "") {
	print "Disease: $diseasename<br>\n";
}
else {
	$tmp=HTML::Entities::encode($ref->{'s.pedigree'});
	print "Pedigree: $tmp<br>\n";
}
$diseasegroup=&getDiseaseGroupById($dbh,$excluded[0]);
print "Exluded in controls: $diseasegroup<br>\n";
$tmp=HTML::Entities::encode($ref->{'x.alleles'});
print "Variant alleles >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncases'});
print "Cases   >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'npedigrees'});
print "Pedigrees   >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncontrols'});
print "Variants allowed in controls  <= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'aa_het'});
print "EVS African American (heterozygous): <= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'kaviar'});
print "Kaviar allele count: <= $tmp<br>\n";
&printqueryheader($ref,$classprint,$functionprint);
my $igvfile       = "";
my $cnvfile       = "";
my %nngenesymbol  = ();
my %npedigree     = ();
my %ncases        = ();
my @row2          = ();
my $nforeach      = -1;
my $cchrom        = "";
my $cstart        = "";
my $cidsnv        = "";
my $cgenesymbol   = "";
my @cgenesymbol   = ();
my $cidsample     = "";

############################# foreach sample #########################
foreach $idsample (@idsamples) {
$nforeach++;

#$igvfile     = &igvfile($snames[$nforeach],'ExomeDepthSingle.seg',$dbh,'noprint');
#print " $igvfile";
#$cnvfile     = &cnvfile($snames[$nforeach],$dbh);
#print " $cnvfile";
#$igvfile     = &igvfile($snames[$nforeach],'refSeqCoveragePerTarget.seg',$dbh,'noprint');
#print " $igvfile";
#$cnvfile     = &cnvnator($snames[$nforeach],$dbh);
#print " $cnvfile";
#$cnvfile     = &cnvnator($snames[$nforeach],$dbh,'breakdancer');
#print " $cnvfile";

$query = qq#
$explain SELECT 
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree),
s.sex,
d.symbol,
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
c.rating,
c.patho,
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(DISTINCT g.omim separator ' '),
group_concat(DISTINCT $mgiID separator ' '),
v.class,
replace(v.func,',',' '),
group_concat(DISTINCT x.alleles),
f.fsample,
f.samplecontrols,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(DISTINCT g.nonsynpergene,' (', g.delpergene,')' separator '<br>'),
dgv.depth,
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT x.filter SEPARATOR ', '),
group_concat(DISTINCT x.snvqual SEPARATOR ', '),
group_concat(DISTINCT x.gtqual SEPARATOR ', '),
group_concat(DISTINCT x.mapqual SEPARATOR ', '),
group_concat(DISTINCT x.coverage SEPARATOR ', '),
group_concat(DISTINCT x.percentvar SEPARATOR ', '),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
c.rating,
c.checked,
c.confirmed,
group_concat(dg.class),
v.chrom,
v.start,
v.idsnv,
group_concat(DISTINCT g.genesymbol),
x.idsample
FROM
snv v
INNER JOIN snvsample                     x ON (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp               dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample              s ON (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample     ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease             d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup              f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN snvgene                       y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                          g ON (g.idgene = y.idgene)
LEFT  JOIN disease2gene                 dg ON (ds.iddisease=dg.iddisease AND g.idgene=dg.idgene)
LEFT  JOIN $sampledb.mouse              mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.pph3                pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift               sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd               cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs                 evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores          exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords         h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar              cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment            c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
$allowedprojects
AND x.idsample = ?
AND (f.fiddiseasegroup = ? or ISNULL(f.fiddiseasegroup) )
$where
$function
$class
GROUP BY
v.idsnv
ORDER BY
v.chrom,v.start
#;
if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
	print "exluded $excluded[$nforeach] ";
	print "snvqual $ref->{'snvqual'} ";
	print "mapqual $ref->{'mapqual'} ";
	print "$ref->{'x.alleles'} ";
	print "$ref->{'nonsynpergene'} ";
	print "$ref->{'avhet'} ";
	print "$ref->{'aa_het'} ";
	print "$ref->{'idproject'} ";
	print "$ref->{'ncontrols'} ";
	print "$ref->{'ncases'} <br>";
	print "$idsample,@prepare<br>";
}

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(
$idsample,
$excluded[$nforeach],
@prepare,
)
|| die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

# check for minimal cases
while (@row = $out->fetchrow_array) {
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	$ncases{"$cidsnv"}++; 
	$row2{"$cchrom\_$cstart\_$cidsnv\_$cidsample"}=[@row]; #order foreach
}

} # foreach sampleid

# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $aref;
my $damaging     = 0;
my $omimmode     = "";
my $omimdiseases = "";
my $program      = "";
my $rating       = "";
my $checked      = "";
my $confirmed    = "";
my $idsamplesvcf = "";
my $idsnvsvcf    = "";
#for  $aref (@row2) { 
#	@row=@{$aref};
for  $aref (sort keys %row2) { 
	@row=@{ $row2{$aref} };
	#$i=0;
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	# bekannte Gene in disease2gene color red
	$class="default";
	if ($row[-1] ne "") {
		$class=&diseaseGeneColorNew($row[-1]);
	}
	else  {
		$class = "";
	}
	pop(@row);
	$confirmed = $row[-1];
	pop(@row); #delete confirmed
	$checked = $row[-1];
	pop(@row); #delete checked
	$rating = $row[-1];
	pop(@row); #delete rating
	foreach $cgenesymbol (@cgenesymbol) {
	$i=0;
	if ($ncases{"$cidsnv"} >= $ref->{"ncases"}) {
		foreach (@row) {
			if ($i == 0) { 
				$idsamplesvcf .= "$cidsample,";
				$idsnvsvcf    .= "$cidsnv,";
				print "<tr>";
				print "<td align=\"center\">$n</td>";
				$n++;
			}
			if ($i == 1) {
				print qq#
				<td style='white-space:nowrap;'>
				<div class="dropdown">
				$row[$i]&nbsp;&nbsp;
				<a href="comment.pl?idsnv=$cidsnv&idsample=$cidsample&reason=ad">
				<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
				</a>
				</div>
				</td>
				#;
			}
			elsif ($i == 5) {
				$tmp=&ucsclink2($row[$i]);
				print "<td align=\"center\">$tmp</td>";
			}
			elsif ($i == 9) {
				($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
				print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
			}
			elsif ($i == 11) {
				($tmp)=&vcf2mutalyzer($dbh,$cidsnv);
				print "<td align=\"center\">$tmp</td>";
			}
			elsif (($i==24) or ($i==25)) {
				if ($i==24) {$program = 'polyphen2';}
				if ($i==25) {$program = 'sift';}
				$damaging=&damaging($program,$row[$i]);
				if ($damaging==1) {
					print "<td $warningtdbg>$row[$i]</td>";
				}
				else {
					print "<td> $row[$i]</td>";
				}
			}
			elsif ($i == 31) { # cnv exomedetph
				$tmp=$row[$i];
				if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
				}
				print "<td>$tmp</td>";
			}
			elsif ($i == 33) { # transcripts
				print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
			}
			else {
				print "<td align=\"center\"> $row[$i]</td>";
			}
			if ($i == @row-1) {
				print "</tr>\n";
			}
			$i++;
		}
	}
	if ($i>0) {last;} # end each @cgenesymbol when the first one is printed
	}
}
print "</tbody></table></div>";

&callvcf($idsamplesvcf,$idsnvsvcf);


$out->finish;
}
########################################################################
# getTumorControl
########################################################################
sub getTumorControl {
	my $dbh          = shift;
	my $idsample     = shift;
	my $tumorcontrol = "";
	my $query =
	"SELECT tumorcontrol
	FROM $sampledb.sample
	WHERE idsample='$idsample'";
	my $out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute() || die print "$DBI::errstr";
	$tumorcontrol = $out->fetchrow_array;
	return($tumorcontrol);
}
########################################################################
# searchResultsVcfTumor
########################################################################
sub searchResultsVcf {
my $self            = shift;
my $dbh             = shift;
my $ref             = shift;

my @labels          = ();
my $out             = "";
my @row             = ();
my %row2            = ();
my $query           = "";
my $i               = 0;
my $r               = 0;
my $n               = 1;
my $tmp             = "";
my $function        = "";
my $functionprint   = "";
my $class           = "";
my $classprint      = "";
my $ncontrols       = "";
my $chrom           = "";
my $start           = "";
my $end             = "";
my $position        = "";
my $diseasegroup    = "";
my $allowedprojects = &allowedprojects("s.");
my $idsample        = "";
my @idsamples       = ();
my $sname           = "";
my @snames          = ();
my $excluded        = "";
my @excluded        = ();
my $where           = "";
my @prepare         = ();
my @individuals     = ();
my $dgiddisease     = "";

if ($ref->{'dg.iddisease'} ne "") {
	$dgiddisease = $ref->{'dg.iddisease'};
}
else {
	$dgiddisease = -9999999;
}

if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}


if ($ref->{"ds.iddisease"} ne "") {
	$query = "
	SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
	INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
	WHERE $allowedprojects
	AND ds.iddisease = ?
	$where
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($ref->{"ds.iddisease"},@prepare) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@idsamples,$row[0]);
		push(@snames,$row[1]);
		push(@excluded,$row[2]);
	}
}
elsif ($ref->{"s.name"} ne "") {
	$ref->{"s.name"}=trim($ref->{"s.name"});
	@individuals= split(/\s+/,$ref->{"s.name"});
	foreach $tmp (@individuals) {
		$query = "
		SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
		FROM $sampledb.sample s
		INNER JOIN $sampledb.disease2sample ds ON s.idsample  = ds.idsample
		INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
		WHERE $allowedprojects
		AND s.name = ?
		$where
		";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute($tmp,@prepare) || die print "$DBI::errstr";
		while (@row = $out->fetchrow_array) {
			push(@idsamples,$row[0]);
			push(@snames,$row[1]);
			push(@excluded,$row[2]);
		}
		if ($idsamples[0] eq "") {
			print "$tmp does not exist.<br>";
			exit(1);
		}
	}
}
else {
	print "Sample IDs or disease required!<br>";
	exit(1);
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

if ($ref->{'mapqual'} ne "") {
	$where .= " AND x.gt_MMQ >= ? ";
	push(@prepare,$ref->{'mapqual'});
}
#if ($ref->{'x.alleles'} ne "") {
#	$where .= " AND x.alleles >= ? ";
#	push(@prepare,$ref->{'x.alleles'});
#}
if ($ref->{'chrom'} ne "") { 
	$chrom=$ref->{'chrom'};
	$chrom=~s/,//g;
	$chrom=~s/\s+//g;
	($chrom,$start)=split(/\:/,$chrom);
	$where .= " AND v.chrom = ? ";
	push(@prepare,$chrom);
	($start,$end)=split(/\-/,$start);
	$where .= " AND v.pos >= ? ";
	$where .= " AND v.pos <= ? ";
	push(@prepare,$start);
	push(@prepare,$end);
}

my $explain = "";
if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}
# function
($class,$classprint)=&class($ref->{'class'},$dbh);
($function,$functionprint)=&functionvcf($ref->{'function'},$dbh);

&todaysdate;
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

my $diseasename=&getDiseaseById($dbh,$ref->{'ds.iddisease'});
if ($diseasename ne "") {
	print "Disease: $diseasename<br>\n";
}
else {
	$tmp=HTML::Entities::encode($ref->{'s.pedigree'});
	print "Pedigree: $tmp<br>\n";
}
$diseasegroup=&getDiseaseGroupById($dbh,$excluded[0]);
print "Exluded in controls: $diseasegroup<br>\n";
$tmp=HTML::Entities::encode($ref->{'x.alleles'});
print "Variant alleles >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncases'});
print "Cases   >= $tmp<br>\n";
#$tmp=HTML::Entities::encode($ref->{'npedigrees'});
#print "Pedigrees   >= $tmp<br>\n";
#$tmp=HTML::Entities::encode($ref->{'ncontrols'});
#print "Variants allowed in controls  <= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'aa_het'});
print "EVS African American (heterozygous): <= $tmp<br>\n";
#$tmp=HTML::Entities::encode($ref->{'kaviar'});
#print "Kaviar allele count: <= $tmp<br>\n";
&printqueryheader($ref,$classprint,$functionprint);
my $igvfile       = "";
my $cnvfile       = "";
my %nngenesymbol  = ();
my %npedigree     = ();
my %ncases        = ();
my %ngenes        = ();
my @row2          = ();
my $nforeach      = -1;
my $cchrom        = "";
my $cstart        = "";
my $cidsnv        = "";
my $cgenesymbol   = "";
my @cgenesymbol   = ();
my $cidsample     = "";
my $tumorcontrol  = "";

############################# foreach sample #########################
foreach $idsample (@idsamples) {
$nforeach++;

#$igvfile     = &igvfile($snames[$nforeach],'ExomeDepthSingle.seg',$dbh,'noprint');
#print " $igvfile";
#$cnvfile     = &cnvfile($snames[$nforeach],$dbh);
#print " $cnvfile";
#$igvfile     = &igvfile($snames[$nforeach],'refSeqCoveragePerTarget.seg',$dbh,'noprint');
#print " $igvfile";
#$cnvfile     = &cnvnator($snames[$nforeach],$dbh);
#print " $cnvfile";
#$cnvfile     = &cnvnator($snames[$nforeach],$dbh,'breakdancer');
#print " $cnvfile";


$query = qq#
$explain SELECT 
concat('<a href="listPositionVcf.pl?idvariant=',v.idvariant,'" title="All carriers of this variant">',v.idvariant,'</a>',' '),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2vcftumor,'" title="Open sample in IGV"','>',x.samplename,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree),
concat(v.chrom,' ',v.pos,' ',v.pos+length(v.alt),' ',v.pos,' ',v.ref,' ',v.alt),
group_concat(DISTINCT v.vep_SYMBOL SEPARATOR ', '),
v.class,
group_concat(DISTINCT v.vep_Feature_type SEPARATOR ', '),
group_concat(DISTINCT v.vep_Consequence SEPARATOR ', '),
group_concat(DISTINCT v.REF SEPARATOR ', '),
group_concat(DISTINCT v.ALT SEPARATOR ', '),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(DISTINCT $exac_aa_link separator '<br>'),
group_concat(DISTINCT evs.filter SEPARATOR ', '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT g.omim separator ' '),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT x.TLOD SEPARATOR ', '),
group_concat(DISTINCT x.gt_MBQ SEPARATOR ', '),
group_concat(DISTINCT x.gt_GT SEPARATOR ', '),
group_concat(DISTINCT x.AF SEPARATOR ', '),
group_concat(DISTINCT x.DP SEPARATOR ', '),
group_concat(DISTINCT x.FS SEPARATOR ', '),
group_concat(DISTINCT x.gt_AD SEPARATOR ', '),
group_concat(DISTINCT x.gt_F1R2_1 SEPARATOR ', '),
group_concat(DISTINCT x.gt_F1R2_2 SEPARATOR ', '),
group_concat(DISTINCT x.gt_F2R1_1 SEPARATOR ', '),
group_concat(DISTINCT x.gt_F2R1_2 SEPARATOR ', '),
group_concat(DISTINCT x.gt_MMQ SEPARATOR ', '),
c.rating,
c.checked,
c.confirmed,
group_concat(dg.class),
v.chrom,
v.pos,
v.idvariant,
group_concat(DISTINCT v.vep_SYMBOL),
x.idsample
FROM
$wholegenome.sample x
INNER JOIN $wholegenome.variant          v ON x.idvariant = v.idvariant
INNER JOIN $sampledb.sample              s ON x.idsample = s.idsample
INNER JOIN $sampledb.disease2sample     ds ON s.idsample = ds.idsample
INNER JOIN $sampledb.disease             d ON ds.iddisease = d.iddisease
LEFT  JOIN gene                          g ON v.vep_SYMBOL = g.genesymbol
LEFT  JOIN disease2gene                 dg ON (g.idgene = dg.idgene AND dg.iddisease=$dgiddisease)
LEFT  JOIN $coredb.evs                 evs ON (v.chrom=evs.chrom and v.pos=evs.start and v.ref=evs.refallele and v.alt=evs.allele)
LEFT  JOIN $exomevcfe.comment            c ON (v.chrom=c.chrom and v.pos=c.start and v.ref=c.refallele and v.alt=c.altallele and s.idsample=c.idsample)
LEFT  JOIN hgmd_pro.$hg19_coords         h ON (v.chrom = h.chrom AND v.pos = h.pos  AND v.ref=h.ref AND v.alt=h.alt)
LEFT  JOIN $coredb.clinvar              cv ON (v.chrom=cv.chrom and v.pos=cv.start and v.ref=cv.ref and v.alt=cv.alt)
LEFT  JOIN $coredb.cadd               cadd ON (v.chrom=cadd.chrom and v.pos=cadd.start and v.ref=cadd.ref and v.alt=cadd.alt)
WHERE
$allowedprojects
AND x.idsample = ?
$where
$function
$class
GROUP BY
v.idvariant
#;
if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
	print "exluded $excluded[$nforeach] ";
	print "snvqual $ref->{'snvqual'} ";
	print "mapqual $ref->{'mapqual'} ";
	print "$ref->{'x.alleles'} ";
	print "$ref->{'nonsynpergene'} ";
	print "$ref->{'avhet'} ";
	print "$ref->{'aa_het'} ";
	print "$ref->{'idproject'} ";
	print "$ref->{'ncontrols'} ";
	print "$ref->{'ncases'} <br>";
	print "$idsample,@prepare<br>";
}

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(
$idsample,@prepare
)
|| die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

# check for minimal cases
while (@row = $out->fetchrow_array) {
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	if ($cgenesymbol eq "") {
		$cgenesymbol = "nogene";
	}
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	$ncases{"$cidsnv"}++; 
	$ngenes{"$cgenesymbol"}++; 
	$row2{"$cchrom\_$cstart\_$cidsnv\_$cidsample"}=[@row]; #order foreach
}

} # foreach sampleid end

@labels	= (
	'n',
	'idsnv',
	'IGV Comment',
	'Pedigree',
	'Chr',
	'Rating',
	'ToDo',
	'Confirmed',
	'Gene symbol',
	'Class',
	'vep Feature type',
	'vep Consequence',
	'REF',
	'ALT',
	'gnomAD all',
	'gnomAD aa',
	'Filter',
	'CADD',
	'Omim',
	'HGMD',
	'ClinVar',
	'TLOD',
	'gt_MBQ',
	'gt_GT',
	'AF',
	'DP',
	'FS',
	'gt_AD',
	'gt_F1R2_1',
	'gt_F1R2_2',
	'gt_F2R1_1',
	'gt_F2R1_2',
	'gt_MMQ'
	);

$i=0;

&tableheaderDefault();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $aref;
my $damaging     = 0;
my $program      = "";
my $rating       = "";
my $checked      = "";
my $confirmed    = "";
my $idsamplesvcf = "";
my $idsnvsvcf    = "";
#for  $aref (@row2) { 
#	@row=@{$aref};
for  $aref (sort keys %row2) { # sorted by chromosome position
	@row=@{ $row2{$aref} };
	#print "@row<br>";
	#print "$ref->{ncases}";
	#print "$ref->{ngenes}";
	#$i=0;
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	if ($cgenesymbol eq "") {
		$cgenesymbol = "nogene";
	}
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
#	$tumorcontrol  = getTumorControl($dbh,$cidsample);
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	# bekannte Gene in disease2gene color red
	$class="default";
	if ($row[-1] ne "") {
		$class=&diseaseGeneColorNew($row[-1]);
	}
	else  {
		$class = "";
	}
	pop(@row);
	$confirmed = $row[-1];
	pop(@row); #delete confirmed
	$checked = $row[-1];
	pop(@row); #delete checked
	$rating = $row[-1];
	pop(@row); #delete rating
	foreach $cgenesymbol (@cgenesymbol) { #in case there are 2 genesymbols per idvariant
	$i=0;
	if (($ncases{"$cidsnv"} >= $ref->{"ncases"}) and ($ngenes{$cgenesymbol} >= $ref->{"ngenes"})) {
		foreach (@row) {
			if ($i == 0) { 
				$idsamplesvcf .= "$cidsample,";
				$idsnvsvcf    .= "$cidsnv,";
				print "<tr>";
				print "<td $class align=\"center\">$n</td>";
				$n++;
			}
			if ($i == 3) {
				$tmp=&ucsclink2($row[$i]);
				print "<td $class align=\"center\">$tmp</td>";
				print "<td $class>$rating</td>";
				print "<td $class>$checked</td>";
				print "<td $class>$confirmed</td>";
			}
			elsif ($i == 1) {
				print qq#
				<td style='white-space:nowrap;'>
				<div class="dropdown">
				$row[$i]&nbsp;&nbsp;
				<a href="comment.pl?idsnv=$cidsnv&idsample=$cidsample&reason=vcf_tumor&table=wholegenomehg19.variant">
				<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
				</a>
				</div>
				</td>
				#;
			}
			elsif (($i == 8) or ($i == 9)) {
				print "<td $class style='max-width:50px;overflow:hidden;word-wrap:break-word;'> $row[$i]</td>";
			}
			elsif ($i == 13) {
				($tmp)=&omim($dbh,$row[$i]);
				print "<td $class>$tmp</td>";
			}
			else {
				print "<td $class> $row[$i]</td>";
			}
			if ($i == @row-1) {
				print "</tr>\n";
			}
			$i++;
		}
	}
	if ($i>0) {last;} # end each @cgenesymbol when the first one is printed
	}
}
print "</tbody></table></div>";

#&callvcf($idsamplesvcf,$idsnvsvcf);


$out->finish;
}
########################################################################
# searchResultsVcfTrio searchResultsVcfdenovo 
########################################################################
sub searchResultsVcfTrio {
my $self            = shift;
my $dbh             = shift;
my $ref             = shift;

my @labels          = ();
my $out             = "";
my @row             = ();
my %row2            = ();
my $query           = "";
my $i               = 0;
my $r               = 0;
my $n               = 1;
my $tmp             = "";
my $function        = "";
my $functionprint   = "";
my $class           = "";
my $classprint      = "";
my $ncontrols       = "";
my $chrom           = "";
my $start           = "";
my $end             = "";
my $position        = "";
my $diseasegroup    = "";
my $allowedprojects = &allowedprojects("s.");
my $idsample        = "";
my @idsamples       = ();
my $sname           = "";
my @snames          = ();
my $excluded        = "";
my @excluded        = ();
my $where           = "";
my @prepare         = ();
my @individuals     = ();
my $dgiddisease     = "";

if ($ref->{'dg.iddisease'} ne "") {
	$dgiddisease = $ref->{'dg.iddisease'};
}
else {
	$dgiddisease = -9999999;
}

if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}


if ($ref->{"ds.iddisease"} ne "") {
	$query = "
	SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
	INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
	WHERE $allowedprojects
	AND ds.iddisease = ?
	AND s.saffected = 1
	$where
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($ref->{"ds.iddisease"},@prepare) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@idsamples,$row[0]);
		push(@snames,$row[1]);
		push(@excluded,$row[2]);
	}
}
elsif ($ref->{"s.name"} ne "") {
	$ref->{"s.name"}=trim($ref->{"s.name"});
	@individuals= split(/\s+/,$ref->{"s.name"});
	foreach $tmp (@individuals) {
		$query = "
		SELECT DISTINCT s.idsample,s.name,d.iddiseasegroup
		FROM $sampledb.sample s
		INNER JOIN $sampledb.disease2sample ds ON s.idsample  = ds.idsample
		INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
		WHERE $allowedprojects
		AND s.name = ?
		$where
		";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute($tmp,@prepare) || die print "$DBI::errstr";
		while (@row = $out->fetchrow_array) {
			push(@idsamples,$row[0]);
			push(@snames,$row[1]);
			push(@excluded,$row[2]);
		}
		if ($idsamples[0] eq "") {
			print "$tmp does not exist.<br>";
			exit(1);
		}
	}
}
else {
	print "Sample IDs or disease required!<br>";
	exit(1);
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

if ($ref->{'mapqual'} ne "") {
	$where .= " AND x.gt_MMQ >= ? ";
	push(@prepare,$ref->{'mapqual'});
}
if ($ref->{'hiConfDeNovo'} eq "yes") {
	$where .= " AND x.hiConfDeNovo = 1 ";
}
if ($ref->{'loConfDeNovo'} eq "yes") {
	$where .= " AND x.loConfDeNovo = 1 ";
}
#if ($ref->{'x.alleles'} ne "") {
#	$where .= " AND x.alleles >= ? ";
#	push(@prepare,$ref->{'x.alleles'});
#}
if ($ref->{'chrom'} ne "") { 
	$chrom=$ref->{'chrom'};
	$chrom=~s/,//g;
	$chrom=~s/\s+//g;
	($chrom,$start)=split(/\:/,$chrom);
	$where .= " AND v.chrom = ? ";
	push(@prepare,$chrom);
	($start,$end)=split(/\-/,$start);
	$where .= " AND v.pos >= ? ";
	$where .= " AND v.pos <= ? ";
	push(@prepare,$start);
	push(@prepare,$end);
}

my $explain = "";
if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}
# function
($class,$classprint)=&class($ref->{'class'},$dbh);
($function,$functionprint)=&functionvcf($ref->{'function'},$dbh);

&todaysdate;
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

my $diseasename=&getDiseaseById($dbh,$ref->{'ds.iddisease'});
if ($diseasename ne "") {
	print "Disease: $diseasename<br>\n";
}
else {
	$tmp=HTML::Entities::encode($ref->{'s.pedigree'});
	print "Pedigree: $tmp<br>\n";
}
$diseasegroup=&getDiseaseGroupById($dbh,$excluded[0]);
print "Exluded in controls: $diseasegroup<br>\n";
$tmp=HTML::Entities::encode($ref->{'x.alleles'});
print "Variant alleles >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncases'});
print "Cases   >= $tmp<br>\n";
#$tmp=HTML::Entities::encode($ref->{'npedigrees'});
#print "Pedigrees   >= $tmp<br>\n";
#$tmp=HTML::Entities::encode($ref->{'ncontrols'});
#print "Variants allowed in controls  <= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'aa_het'});
print "EVS African American (heterozygous): <= $tmp<br>\n";
#$tmp=HTML::Entities::encode($ref->{'kaviar'});
#print "Kaviar allele count: <= $tmp<br>\n";
&printqueryheader($ref,$classprint,$functionprint);
my $igvfile       = "";
my $cnvfile       = "";
my %nngenesymbol  = ();
my %npedigree     = ();
my %ncases        = ();
my %ngenes        = ();
my @row2          = ();
my $nforeach      = -1;
my $cchrom        = "";
my $cstart        = "";
my $cidsnv        = "";
my $cgenesymbol   = "";
my @cgenesymbol   = ();
my $cidsample     = "";
my $tumorcontrol  = "";
my $samplename    = "";
my $child         = "";
my $mother        = "";
my $father        = "";

############################# foreach sample #########################
foreach $idsample (@idsamples) {
$nforeach++;
$samplename = &getSampleNameByIdsample($dbh,$idsample);
($child,$mother,$father)  = &getparentsbysample($samplename,$dbh);
if ($child eq "") {
	#print "No child!<br>\n";
	#exit(1);
	next;
}
else {
	print "samplename $samplename<br>";
}

#$igvfile     = &igvfile($snames[$nforeach],'ExomeDepthSingle.seg',$dbh,'noprint');
#print " $igvfile";
#$cnvfile     = &cnvfile($snames[$nforeach],$dbh);
#print " $cnvfile";
#$igvfile     = &igvfile($snames[$nforeach],'refSeqCoveragePerTarget.seg',$dbh,'noprint');
#print " $igvfile";
#$cnvfile     = &cnvnator($snames[$nforeach],$dbh);
#print " $cnvfile";
#$cnvfile     = &cnvnator($snames[$nforeach],$dbh,'breakdancer');
#print " $cnvfile";

#group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2vcf,'" title="Open sample in IGV"','>',x.samplename,'</a>' SEPARATOR '<br>'),

$query = qq#
$explain SELECT 
concat('<a href="listPositionVcf.pl?idvariant=',v.idvariant,'" title="All carriers of this variant">',v.idvariant,'</a>',' '),
group_concat(distinct "<a href='http://localhost:$igvport/load?
file=$igvserver","%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam"
",$igvserver","%3Fsid=$sess_id%26sname=$mother%26file=merged.rmdup.bam",
",$igvserver","%3Fsid=$sess_id%26sname=$father%26file=merged.rmdup.bam",
"\&index=$igvserver","%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam.bai"
",$igvserver","%3Fsid=$sess_id%26sname=$mother%26file=merged.rmdup.bam.bai",
",$igvserver","%3Fsid=$sess_id%26sname=$father%26file=merged.rmdup.bam.bai",
"\&locus=",v.chrom,"\:",v.pos,"-",v.pos+1,"\&merge=true\&name=",s.name,",$mother,$father'",
">",s.name,"</a>"),
group_concat(DISTINCT s.pedigree),
concat(v.chrom,' ',v.pos,' ',v.pos+length(v.alt),' ',v.pos,' ',v.ref,' ',v.alt),
group_concat(DISTINCT v.vep_SYMBOL SEPARATOR ', '),
v.class,
group_concat(DISTINCT v.vep_Feature_type SEPARATOR ', '),
group_concat(DISTINCT v.vep_Consequence SEPARATOR ', '),
group_concat(DISTINCT v.REF SEPARATOR ', '),
group_concat(DISTINCT v.ALT SEPARATOR ', '),
group_concat(DISTINCT $exac_ae_link separator '<br>'),
group_concat(DISTINCT $exac_aa_link separator '<br>'),
group_concat(DISTINCT evs.filter SEPARATOR ', '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT g.omim separator ' '),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT x.hiConfDeNovo SEPARATOR ', '),
group_concat(DISTINCT x.loConfDeNovo SEPARATOR ', '),
group_concat(DISTINCT x.VQSLOD SEPARATOR ', '),
group_concat(DISTINCT x.MVLR SEPARATOR ', '),
group_concat(DISTINCT x.POP_AF SEPARATOR ', '),
group_concat(DISTINCT x.gt_GT SEPARATOR ', '),
group_concat(DISTINCT x.AF SEPARATOR ', '),
group_concat(DISTINCT x.DP SEPARATOR ', '),
group_concat(DISTINCT x.FS SEPARATOR ', '),
group_concat(DISTINCT x.gt_AD SEPARATOR ', '),
group_concat(DISTINCT x.gt_F1R2_1 SEPARATOR ', '),
group_concat(DISTINCT x.gt_F1R2_2 SEPARATOR ', '),
group_concat(DISTINCT x.gt_F2R1_1 SEPARATOR ', '),
group_concat(DISTINCT x.gt_F2R1_2 SEPARATOR ', '),
group_concat(DISTINCT x.gt_MMQ SEPARATOR ', '),
c.rating,
c.checked,
c.confirmed,
group_concat(dg.class),
v.chrom,
v.pos,
v.idvariant,
group_concat(DISTINCT v.vep_SYMBOL),
x.idsample
FROM
$wholegenome.sample x
INNER JOIN $wholegenome.variant          v ON x.idvariant = v.idvariant
INNER JOIN $sampledb.sample              s ON x.idsample = s.idsample
INNER JOIN $sampledb.disease2sample     ds ON s.idsample = ds.idsample
INNER JOIN $sampledb.disease             d ON ds.iddisease = d.iddisease
LEFT  JOIN gene                          g ON v.vep_SYMBOL = g.genesymbol
LEFT  JOIN disease2gene                 dg ON (g.idgene = dg.idgene AND dg.iddisease=$dgiddisease)
LEFT  JOIN $coredb.evs                 evs ON (v.chrom=evs.chrom and v.pos=evs.start and v.ref=evs.refallele and v.alt=evs.allele)
LEFT  JOIN $exomevcfe.comment            c ON (v.chrom=c.chrom and v.pos=c.start and v.ref=c.refallele and v.alt=c.altallele and s.idsample=c.idsample)
LEFT  JOIN hgmd_pro.$hg19_coords         h ON (v.chrom = h.chrom AND v.pos = h.pos  AND v.ref=h.ref AND v.alt=h.alt)
LEFT  JOIN $coredb.clinvar              cv ON (v.chrom=cv.chrom and v.pos=cv.start and v.ref=cv.ref and v.alt=cv.alt)
LEFT  JOIN $coredb.cadd               cadd ON (v.chrom=cadd.chrom and v.pos=cadd.start and v.ref=cadd.ref and v.alt=cadd.alt)
WHERE
$allowedprojects
AND x.idsample = ?
$where
$function
$class
GROUP BY
v.idvariant
#;
#print "<pre>$query</pre><br>";
if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
	print "exluded $excluded[$nforeach] ";
	print "snvqual $ref->{'snvqual'} ";
	print "mapqual $ref->{'mapqual'} ";
	print "$ref->{'x.alleles'} ";
	print "$ref->{'nonsynpergene'} ";
	print "$ref->{'avhet'} ";
	print "$ref->{'aa_het'} ";
	print "$ref->{'idproject'} ";
	print "$ref->{'ncontrols'} ";
	print "$ref->{'ncases'} <br>";
	print "$idsample,@prepare<br>";
}

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(
$idsample,@prepare
)
|| die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

# check for minimal cases
while (@row = $out->fetchrow_array) {
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	if ($cgenesymbol eq "") {
		$cgenesymbol = "nogene";
	}
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	$ncases{"$cidsnv"}++; 
	$ngenes{"$cgenesymbol"}++; 
	$row2{"$cchrom\_$cstart\_$cidsnv\_$cidsample"}=[@row]; #order foreach
}

} # foreach sampleid end

@labels	= (
	'n',
	'idsnv',
	'IGV Comment',
	'Pedigree',
	'Chr',
	'Rating',
	'ToDo',
	'Confirmed',
	'Gene symbol',
	'Class',
	'vep Feature type',
	'vep Consequence',
	'REF',
	'ALT',
	'gnomAD ea',
	'gnomAD aa',
	'Filter',
	'CADD',
	'Omim',
	'HGMD',
	'ClinVar',
	'hiConfDeNovo',
	'loConfDeNovo',
	'VQSLOD',
	'MVLR',
	'POP_AF',
	'gt_GT',
	'AF',
	'DP',
	'FS',
	'gt_AD',
	'gt_F1R2_1',
	'gt_F1R2_2',
	'gt_F2R1_1',
	'gt_F2R1_2',
	'gt_MMQ'
	);

$i=0;

&tableheaderDefault();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $aref;
my $damaging     = 0;
my $program      = "";
my $rating       = "";
my $checked      = "";
my $confirmed    = "";
my $idsamplesvcf = "";
my $idsnvsvcf    = "";
#for  $aref (@row2) { 
#	@row=@{$aref};
for  $aref (sort keys %row2) { # sorted by chromosome position
	@row=@{ $row2{$aref} };
	#print "@row<br>";
	#print "$ref->{ncases}";
	#print "$ref->{ngenes}";
	#$i=0;
	$cchrom        = $row[-5];
	$cstart        = $row[-4];
	$cidsnv        = $row[-3];
	$cgenesymbol   = $row[-2];
	if ($cgenesymbol eq "") {
		$cgenesymbol = "nogene";
	}
	@cgenesymbol   = split(/\,/,$cgenesymbol);
	$cidsample     = $row[-1];
#	$tumorcontrol  = getTumorControl($dbh,$cidsample);
	$cstart = substr("000000000",0,9-length($cstart)) . $cstart;
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	pop(@row);
	# bekannte Gene in disease2gene color red
	$class="default";
	if ($row[-1] ne "") {
		$class=&diseaseGeneColorNew($row[-1]);
	}
	else  {
		$class = "";
	}
	pop(@row);
	$confirmed = $row[-1];
	pop(@row); #delete confirmed
	$checked = $row[-1];
	pop(@row); #delete checked
	$rating = $row[-1];
	pop(@row); #delete rating
	foreach $cgenesymbol (@cgenesymbol) { #in case there are 2 genesymbols per idvariant
	$i=0;
	if (($ncases{"$cidsnv"} >= $ref->{"ncases"}) and ($ngenes{$cgenesymbol} >= $ref->{"ngenes"})) {
		foreach (@row) {
			if ($i == 0) { 
				$idsamplesvcf .= "$cidsample,";
				$idsnvsvcf    .= "$cidsnv,";
				print "<tr>";
				print "<td $class align=\"center\">$n</td>";
				$n++;
			}
			if ($i == 3) {
				$tmp=&ucsclink2($row[$i]);
				print "<td $class align=\"center\">$tmp</td>";
				print "<td $class>$rating</td>";
				print "<td $class>$checked</td>";
				print "<td $class>$confirmed</td>";
			}
			elsif ($i == 1) {
				print qq#
				<td style='white-space:nowrap;'>
				<div class="dropdown">
				$row[$i]&nbsp;&nbsp;
				<a href="comment.pl?idsnv=$cidsnv&idsample=$cidsample&reason=vcf_trio&table=wholegenomehg19.variant">
				<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
				</a>
				</div>
				</td>
				#;
			}
			elsif (($i == 8) or ($i == 9)) {
				print "<td $class style='max-width:50px;overflow:hidden;word-wrap:break-word;'> $row[$i]</td>";
			}
			elsif ($i == 13) {
				($tmp)=&omim($dbh,$row[$i]);
				print "<td $class>$tmp</td>";
			}
			else {
				print "<td $class> $row[$i]</td>";
			}
			if ($i == @row-1) {
				print "</tr>\n";
			}
			$i++;
		}
	}
	if ($i>0) {last;} # end each @cgenesymbol when the first one is printed
	}
}
print "</tbody></table></div>";

#&callvcf($idsamplesvcf,$idsnvsvcf);


$out->finish;
}
########################################################################
# damaging
########################################################################

sub damaging {
	my $program=shift;
	my $tmp=shift;
	my @tmp=split(/\s+/,$tmp);
	my $damaging = 0;
	foreach $tmp (@tmp) {
		if ($program eq 'polyphen2') {
			if ($tmp >= 0.85) {
				$damaging=1;
			}
		}
		elsif ($program eq 'sift') {
			if ($tmp < 0.05) {
				$damaging=1;
			}
		}
	}
	if (!defined($damaging)) {$damaging = "";}
return($damaging);
}


########################################################################
# getparentsbysample
########################################################################

sub getparentsbysample { 
	my $sample      = shift;
	my $dbh         = shift;
	my $out         = "";
	my $row         = "";
	my $query       = "";
	my @individuals = ();
	my $child       = "";
	my $mother      = "";
	my $father      = "";

	# etwas umstaendlich, weil geaendert
	#$query = "
	#SELECT DISTINCT s.name 
	#FROM $sampledb.sample s
	#WHERE s.name = ?
	#";
	#$out = $dbh->prepare($query) || die print "$DBI::errstr";
	#$out->execute($sample) || die print "$DBI::errstr";
	#while ($row = $out->fetchrow_array) {
	#	push(@individuals,$row);
	#}
	push(@individuals,$sample);
	($child,$mother,$father)=&childInTrio(\@individuals,$dbh);
	return($child,$mother,$father);
}

########################################################################
# childInTrio # checks if and which of the submitted names is the child
# else child = ""
########################################################################

sub childInTrio { 
	my $aref      = shift;
	my $dbh       = shift;
	my $out       = "";
	my $query     = "";
	my $name      = "";
	my $motherId  = "";
	my $fatherId  = "";
	my $mother    = "";
	my $father    = "";
	my $child     = "";
	
	
	foreach $name (@$aref) {
		$query = "
		SELECT s.mother,s.father ,ss.name,sss.name
		FROM $sampledb.sample s
		LEFT JOIN $sampledb.sample ss ON s.mother=ss.idsample
		LEFT JOIN $sampledb.sample sss ON s.father=sss.idsample
		WHERE s.name = ?
		";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute($name) || die print "$DBI::errstr";
		($motherId,$fatherId,$mother,$father) = $out->fetchrow_array;
		if (($fatherId != 0) and ($motherId != 0)) {
			$child=$name;
			last;
		}
	}
#	if ($child eq "") {
#		print "No child!<br>\n";
#		exit(1);
#	}
	if (!defined($mother)) {$mother = "";}
	if (!defined($father)) {$father = "";}
	return($child,$mother,$father);
}

########################################################################
# check parents (SNVqual can be lower than threshold
########################################################################

sub checkParents { 
	my $dbh      = shift;
	my $parent   = shift;
	my $idsnv    = shift;
	my $query    = "";
	my $out      = "";
	my $result   = "";
	
	$query = "
	SELECT x.idsnv 
	FROM snvsample x
	INNER JOIN $sampledb.sample s ON x.idsample=s.idsample
	WHERE s.name= ?
	AND   x.idsnv = ?
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($parent,$idsnv) || die print "$DBI::errstr";
	$result = $out->fetchrow_array;
	if (!defined($result)) {$result = "";}
	return($result);
}
########################################################################
# searchResultsTrio de novo denovo resultsdenovo
########################################################################
sub searchResultsTrio {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $r         = 0;
my $n         = 1;
my $while     = 0;
my $rssnp     = "";
my $tmp       = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $ncontrols = "";
my @region    = ();
my $chrom     = "";
my $start     = "";
my $end       = "";
my $position  = "";
my $idproject = "";
my $excluded  = "";
my $correct   = "";
my $diseasegroup = "";
my $child     = "";
my $idchild   = "";
my $mother    = "";
my $father    = "";
my $printout  = "";
my $igvfile   = "";
my $cnvfile   = "";
my @samples   = ();
my $sample    = "";
my $idsample  = "";
my $allowedprojects = &allowedprojects("");
my $norows    = 0;
my @prepare   = ();
my %nngenesymbol = ();
my %npedigree = ();
my @row2      = ();
my $name      = "";
my $where     = "";
my $idsnvtmp  = "";
my $result    = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});

if ($ref->{'idproject'} ne "") {
	push(@prepare,$ref->{'idproject'});
	if ($ref->{'s.idcooperation'} ne "") {
		$tmp= " AND s.idcooperation = ? ";
		push(@prepare,$ref->{'s.idcooperation'});
	}
	#$query = "
	#SELECT distinct s.pedigree
	#FROM $sampledb.sample s
	#WHERE s.idproject = ?
	#ORDER BY s.pedigree
	#";
	$query=
	"SELECT DISTINCT s.name
	FROM 	$sampledb.sample s
	INNER JOIN $sampledb.exomestat e ON s.idsample=e.idsample
	INNER JOIN $sampledb.sample   ss ON s.mother=ss.idsample
	INNER JOIN $sampledb.sample  sss ON s.father=sss.idsample
	WHERE 
	s.idproject = ?
	$tmp
	AND s.saffected=1
	AND s.mother IN (SELECT s.mother FROM $sampledb.exomestat WHERE idsample=s.mother )
	AND s.father IN (SELECT s.father FROM $sampledb.exomestat WHERE idsample=s.father )
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@prepare) || die print "$DBI::errstr";
	while ( $tmp = $out->fetchrow_array) {
		push(@samples,$tmp);
	}
	#print "$query<br>";
	@prepare = ();
}
else {
	push(@samples,$ref->{'s.name'});
}
#print "pedigrees @pedigrees<br>";

# contruct where
my $controltype = $ref->{controltype};
if ($ref->{'ncontrols'} ne "") {
	$where .= " AND (f.samplecontrols <= ? or ISNULL(f.samplecontrols) )";
	push(@prepare,$ref->{'ncontrols'});
}

if ($ref->{correct} eq 'correct') {
	$where  .= " AND (c.confirmed  = 'yes'
	            OR c.rating     = 'correct')
		    AND c.confirmed != 'no' ";
}
if ($ref->{correct} eq 'notannotated') {
	$where .= " AND ISNULL(c.chrom)";
}

if ($giabradio == 1) {
if ($ref->{'giab'} ne "") {
	$where .= " AND v.giab = ? ";
	push(@prepare,$ref->{'giab'});
}
}
if ($ref->{'x.alleles'} ne "") {
	$where .= " AND x.alleles >= ? ";
	push(@prepare,$ref->{'x.alleles'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

my $explain = "";
if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}
# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);

#print "$where<br>";
#print "@prepare<br>";


$n=1;
########## foreach ##############
foreach $sample (@samples) {
$idsample = &getIdsampleByName($dbh,$sample);

($child,$mother,$father)  = &getparentsbysample($sample,$dbh);
if ($child eq "") {
	print "No child!<br>\n";
	exit(1);
}
if ($n == 1) {
$printout  = "Trio child $child, mother $mother, father $father";
$igvfile   = &igvfile($child,'trio.seg',$dbh,'noprint');
$printout .= " $igvfile";
$igvfile   = &igvfile($child,'ExomeDepthSingle.seg',$dbh,'noprint');
$cnvfile   = &cnvfile($child,$dbh);
$printout .= " $igvfile";
$printout .= " $cnvfile";
$igvfile   = &igvfile($mother,'ExomeDepthSingle.seg',$dbh,'noprint');
$cnvfile   = &cnvfile($mother,$dbh);
$printout .= " $igvfile";
$printout .= " $cnvfile";
$igvfile   = &igvfile($father,'ExomeDepthSingle.seg',$dbh,'noprint');
$cnvfile   = &cnvfile($father,$dbh);
$printout .= " $igvfile";
$printout .= " $cnvfile<br>";
print "$printout";
}

# exluded diseasegroup for every sample different
$query = "
SELECT DISTINCT d.iddiseasegroup 
FROM $sampledb.sample s
INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
WHERE s.name = ?
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($sample) || die print "$DBI::errstr";
($excluded) = $out->fetchrow_array;
	

if ($while == 0) {
&todaysdate();
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);


$tmp=HTML::Entities::encode($sample);
print "Child: $tmp<br>\n";
$diseasegroup=&getDiseaseGroupById($dbh,$excluded);
print "Exluded in controls: $diseasegroup<br>\n";
$tmp=HTML::Entities::encode($ref->{'x.alleles'});
print "Variant alleles >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'npedigrees'});
print "Pedigrees   >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncontrols'});
print "Variants allowed in controls  <= $tmp<br>\n";
&printqueryheader($ref,$classprint,$functionprint);
}
$query = qq#
$explain SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(distinct "<a href='http://localhost:$igvport/load?
file=$igvserver","%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam"
",$igvserver","%3Fsid=$sess_id%26sname=$mother%26file=merged.rmdup.bam",
",$igvserver","%3Fsid=$sess_id%26sname=$father%26file=merged.rmdup.bam",
"\&index=$igvserver","%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam.bai"
",$igvserver","%3Fsid=$sess_id%26sname=$mother%26file=merged.rmdup.bam.bai",
",$igvserver","%3Fsid=$sess_id%26sname=$father%26file=merged.rmdup.bam.bai",
"\&locus=",v.chrom,"\:",v.start,"-",v.end,"\&merge=true\&name=",s.name,",$mother,$father'",
">",s.name,"</a>"),
s.pedigree,
s.sex,
d.symbol,
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
c.rating,
c.patho,
group_concat(distinct $genelink separator " "),
group_concat(distinct g.omim separator " "),
group_concat(distinct $mgiID separator " "),
v.class,replace(v.func,',',' '),
group_concat(distinct x.alleles),
f.fsample,
f.samplecontrols,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(distinct x.filter),
group_concat(distinct x.snvqual),
group_concat(distinct x.gtqual),
group_concat(distinct x.mapqual),
group_concat(distinct x.coverage),
group_concat(distinct x.percentvar),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
v.idsnv,
s.name,
group_concat(DISTINCT dg.class),
s.pedigree
FROM
snv v 
INNER JOIN snvsample                    x ON (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp              dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample             s ON (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample    ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease            d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup             f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN snvgene                      y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                         g ON (g.idgene = y.idgene)
LEFT  JOIN disease2gene                dg ON (ds.iddisease=dg.iddisease AND g.idgene=dg.idgene)
LEFT  JOIN $sampledb.mouse             mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.pph3               pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift              sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd              cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs                evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores         exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords        h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar             cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment           c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
s.idsample = ?
AND $allowedprojects
AND (f.fiddiseasegroup = ? or ISNULL(f.fiddiseasegroup) )
$function
$class
$where
GROUP BY
v.idsnv
ORDER BY
v.chrom,v.start
#;
if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
}

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(
$idsample,
$excluded,
@prepare
) || die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

# Now exclude parents
# Check for minimal pedigrees
@row = ();
while (@row = $out->fetchrow_array) {
	# Now exclude parents
	$name=$row[-3];
	($child,$mother,$father)  = &getparentsbysample($name,$dbh);
	$idchild   = &getIdsampleByName($dbh,$name);
	$idsnvtmp = $row[-4];
	$result=&checkParents($dbh,$mother,$idsnvtmp);
	if ($result ne "") {
		next;
	}
	$result=&checkParents($dbh,$father,$idsnvtmp);
	if ($result ne "") {
		next;
	}

	# Check for minimal pedigrees
	# doppelte Variations pro gene muessen entfernt werden
	$npedigree{$row[5]}{$row[-1]}++;  #genesymbol,pedigree !wird gebraucht fuer minmal pedigrees!
	if ($npedigree{$row[5]}{$row[-1]} == 1 ) {
		$nngenesymbol{$row[5]}++; #gene
	}
	#print "$row[-2]<br>";
	pop(@row); #s.pedigree
	push(@row2,[@row]);
}
$while++;
} #end foreach sample

# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

my $aref;
my @tmp          = ();
my $damaging     = 0;
my $program      = "";
$class           = "";
my $rating       = "";
my $checked      = "";
my $confirmed    = "";
my $idsamplesvcf = "";
my $idsnvsvcf    = "";
my $omimmode     = "";
my $omimdiseases = "";

for  $aref (@row2) { 
	@row=@{$aref};
	$i=0;
	@tmp = ();
	$class="default";
	# bekannte Gene in disease2gene
	if (!defined($row[-1])) {$row[-1] = "";}
	if ($row[-1] ne "") {
		$class=&diseaseGeneColorNew($row[-1]);
		#print "class $class<br>";
	}
	else  {
		$class = "";
	}
	pop(@row); # delete dg.class
	$idchild   = &getIdsampleByName($dbh,$row[-1]);
	pop(@row); # delete s.name
	#print "$nngenesymbol{$row[5]}<br>";
	if (!defined($row[-1])) {$row[-1] = "";}
	$idsnvtmp=$row[-1];
	pop(@row); #delete idsnv
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($nngenesymbol{$row[5]} >= $ref->{"npedigrees"} ) {
			if ($i == 0) { 
				$idsamplesvcf .= "$idchild,";
				$idsnvsvcf    .= "$idsnvtmp,";
				print "<tr>";
				print "<td align=\"center\">$n</td>";
				$n++;
			}
			if ($i == 5) {
				$tmp=&ucsclink2($row[$i]);
				print "<td>$tmp</td>";
			}
			elsif ($i == 1) {
				print qq#
				<td style='white-space:nowrap;'>
				<div class="dropdown">
				$row[$i]&nbsp;&nbsp;
				<a href="comment.pl?idsnv=$idsnvtmp&idsample=$idchild&reason=denovo">
				<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
				</a>
				</div>
				</td>
				#;
			}
			elsif ($i == 9) { #omim
				($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
				print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
			}
			elsif ($i == 11) { #class
				($tmp)=&vcf2mutalyzer($dbh,$idsnvtmp);
				print "<td align=\"center\">$tmp</td>";
			}
			elsif (($i==24) or ($i==25)) {
				if ($i==24) {$program = 'polyphen2';}
				if ($i==25) {$program = 'sift';}
				$damaging=&damaging($program,$row[$i]);
				if ($damaging==1) {
					print "<td $warningtdbg>$row[$i]</td>";
				}
				else {
					print "<td> $row[$i]</td>";
				}
			}
			elsif ($i == 31) { #in depth for cnv exomedetph
				$tmp=$row[$i];
				if ($row[11] eq "cnv") {
					$tmp=$tmp/100;
				}
				print "<td>$tmp</td>";
			}
			elsif ($i == 33) { # cnv exomedetph
				print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
			}
			else {
				print "<td align=\"center\"> $row[$i]</td>\n";
			}
			if ($i == @row-1) {
				print "</tr>\n";
			}
			$i++;
		}
	}
}

print "</tbody></table></div>";

&callvcf($idsamplesvcf,$idsnvsvcf);

$out->finish;
}
########################################################################
# searchResultsComment Comment search comment
########################################################################
sub searchResultsComment {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


if ($ref->{mode} eq "summary") {
	delete($ref->{mode});
	&searchResultsComment2($dbh,$ref);
}
else {
	delete($ref->{mode});
	&searchResultsComment1($dbh,$ref);
}

}
########################################################################
# searchResultsComment Comment search comment
########################################################################
sub searchResultsComment2 {
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $diseasename = "";
my $igvfile   = "";
my $sample    = "";
my $allowedprojects = &allowedprojects("");
my $genotype  = "";
my $genotypeprint = "";
my $inheritance  = "";
my $inheritanceprint = "";
my $patho    = "";
my $pathoprint = "";
my $diseasegene = "";
my $diseasegeneprint = "";

my @prepare   = ();
my @prepare2  = ();
my $where     = "";
my $where2    = "";
my @row2 = ();
my %npedigree = "";
my %ngenesymbol = "";
my $aref      = "";
my $ncases    = $ref->{ncases};
my $printquery =$ref->{"printquery"};
my $explain = "";
if ($printquery eq "yes") {
	$explain = " explain extended ";
}

# function
($function,$functionprint)=&function($ref->{function},$dbh);
($class,$classprint)=&class($ref->{class},$dbh);
($genotype,$genotypeprint)=&genotype($ref->{genotype},$dbh);
($inheritance,$inheritanceprint)=&inheritance($ref->{inheritance},$dbh);
($diseasegene,$diseasegeneprint)=&diseasegene($ref->{gene},$dbh);
($patho,$pathoprint)=&patho($ref->{patho},$dbh);

#label disease genes
push(@prepare, $ref->{'dg.iddisease'}); #for join



if ($ref->{confirmed} eq "correctconfirmed") {
	$where .= " AND ((c.rating = 'correct') OR (c.confirmed = 'yes'))";
}
elsif ($ref->{confirmed} eq "confirmed") {
	$where .= " AND (c.confirmed = 'yes')";
}
elsif ($ref->{confirmed} eq "unknown") {
	$where .= " AND (c.confirmed = 'unknown')";
}


if ($ref->{"dg.iddisease"}) {  #label disease genes
	$where .= "AND ds.iddisease = ? ";
	push(@prepare,$ref->{'dg.iddisease'});
}
if ($ref->{"s.name"}) {
	$where .= "AND s.name = ? ";
	push(@prepare,$ref->{'s.name'});
}
if ($ref->{"ds.iddisease"}) {
	$where .= "AND ds.iddisease = ? ";
	push(@prepare,$ref->{'ds.iddisease'});
}
if ($ref->{"s.idcooperation"}) {
	$where .= "AND s.idcooperation = ? ";
	push(@prepare,$ref->{'s.idcooperation'});
}
if ($ref->{"idproject"}) {
	$where .= "AND idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{"g.genesymbol"}) {
	$where .= "AND g.genesymbol = ? ";
	push(@prepare,$ref->{'g.genesymbol'});
}
if ($ref->{"checked"}) {  #todo
	$where .= "AND c.checked = ? ";
	push(@prepare,$ref->{'checked'});
}
if ($ref->{"freq"}) {
	$where .= "AND freq <= ? ";
	push(@prepare,$ref->{'freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

if ($ref->{"s.name"}) {
	$where2 .= "AND s.name = ? ";
	push(@prepare2,$ref->{'s.name'});
}
if ($ref->{"ds.iddisease"}) {
	$where2 .= "AND ds.iddisease = ? ";
	push(@prepare2,$ref->{'ds.iddisease'});
}
if ($ref->{"s.idcooperation"}) {
	$where2 .= "AND s.idcooperation = ? ";
	push(@prepare2,$ref->{'s.idcooperation'});
}
if ($ref->{"idproject"}) {
	$where2 .= "AND idproject = ? ";
	push(@prepare2,$ref->{'idproject'});
}


&todaysdate();
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

$tmp=HTML::Entities::encode($ref->{'s.name'});
print "Sample: $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncontrols'});
&printqueryheader($ref,$classprint,$functionprint);

$query = qq#
SELECT 
group_concat(DISTINCT s.name),
group_concat(DISTINCT s.pedigree),
group_concat(DISTINCT d.name),
(count(DISTINCT v.idsnv)),
group_concat(DISTINCT $genelink, ',',v.class, ',', replace(v.func,',',' ') ORDER BY g.genesymbol separator '<br>'),
group_concat(DISTINCT g.genesymbol)
FROM
$sampledb.sample s
LEFT  JOIN snvsample                    x ON (s.idsample = x.idsample)
LEFT  JOIN snv                          v ON (v.idsnv = x.idsnv)
LEFT  JOIN $exomevcfe.comment           c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
LEFT  JOIN $coredb.dgvbp              dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
LEFT  JOIN snvgene                      y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                         g ON (g.idgene = y.idgene)
INNER JOIN $sampledb.disease2sample    ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease            d ON (ds.iddisease = d.iddisease)
INNER JOIN snv2diseasegroup             f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN disease2gene                dg ON (dg.iddisease=? AND g.idgene=dg.idgene)
LEFT  JOIN $coredb.evs                evs ON(v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
WHERE
$allowedprojects
$where
$function
$class
$genotype
$inheritance
$patho
$diseasegene
GROUP BY
s.name
ORDER BY
s.pedigree,s.name,g.genesymbol
#;
#print "<br>query = $query<br>";
#print "<br>where = $where<br>";
#print "values = @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

my @tmp = ();
while (@row = $out->fetchrow_array) {
	@tmp = split(/\,/,$row[-1]);
	foreach $tmp (@tmp) {
		$npedigree{$tmp}{$row[1]}++;  #genesymbol,pedigree !wird gebraucht fuer minmal pedigrees!
		if ($npedigree{$tmp}{$row[1]} == 1 ) {
			$ngenesymbol{$tmp}++; #gene
		}
	}
	push(@row2,[@row]);
}

@labels	= (
	'n',
	'Sample',
	'Pedigree',
	'Disease',
	'n variants',
	'Genesymbol'
	);

&tableheaderDefault();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";


$n=1;
@tmp       = ();
my $names  = "'dummy',";
for  $aref (@row2) { 
	@row=@{$aref};
	@tmp = ();
	@tmp = split(/\,/,$row[-1]);
	pop(@row);
	foreach $tmp (@tmp) {
		if ($ngenesymbol{$tmp} >= $ncases) {
			$i=0;
			foreach (@row) {
			if ($i == 0) { 
				print "<tr><td>$n</td>";
				$n++;
				print "<td> $row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
			if ($i == @row-1) {
				print "</tr>\n";
			}
			$i++;
			$names .= " '$row[0]',";
			}
		last;
		}
	}
}

print "</tbody></table></div>";

chop($names); # delete last comma
$query = "
SELECT s.name,s.pedigree,d.name FROM $sampledb.sample s
INNER JOIN $sampledb.disease2sample ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease            d ON (ds.iddisease = d.iddisease)
WHERE
s.name NOT IN ($names)
AND s.saffected = 1
$where2
GROUP BY s.name
ORDER BY s.name
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Sample',
	'Pedigree',
	'Disease'
	);
print "<br>Remaining empty affected samples<br>";
$n=1;
print "<table border='1' cellspacing='0' cellpadding='2'><thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";
while (@row = $out->fetchrow_array) {
	print "<tr><td>$n</td>";
	foreach $tmp (@row) {
		print "<td>$tmp</td>";
	}
	$n++;
	print "</tr>";
}
print "</tbody></table>";

$out->finish;
}

########################################################################
# searchResultsComment Comment search comment
########################################################################
sub searchResultsComment1 {
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $diseasename = "";
my $igvfile   = "";
my $sample    = "";
my $allowedprojects = &allowedprojects("");
my $genotype  = "";
my $genotypeprint = "";
my $inheritance  = "";
my $inheritanceprint = "";
my $patho    = "";
my $pathoprint = "";
my $diseasegene = "";
my $diseasegeneprint = "";

my @prepare   = ();
my $where     = "";
my @row2 = ();
my %npedigree = "";
my %ngenesymbol = "";
my $aref      = "";
my $ncases    = $ref->{ncases};

my $printquery =$ref->{"printquery"};
my $explain = "";
if ($printquery eq "yes") {
	$explain = " explain extended ";
}

# function
($function,$functionprint)=&function($ref->{function},$dbh);
($class,$classprint)=&class($ref->{class},$dbh);
($genotype,$genotypeprint)=&genotype($ref->{genotype},$dbh);
($inheritance,$inheritanceprint)=&inheritance($ref->{inheritance},$dbh);
($patho,$pathoprint)=&patho($ref->{patho},$dbh);
($diseasegene,$diseasegeneprint)=&diseasegene($ref->{gene},$dbh);

#label disease genes
push(@prepare, $ref->{'dg.iddisease'});



if ($ref->{confirmed} eq "correctconfirmed") {
	$where .= " AND ((c.rating = 'correct') OR (c.confirmed = 'yes')) ";
}
elsif ($ref->{confirmed} eq "confirmed") {
	$where .= " AND c.confirmed = 'yes' ";
}
elsif ($ref->{confirmed} eq "unknown") {
	$where .= " AND c.confirmed = 'unknown' ";
}

if ($ref->{"dg.iddisease"}) {  #label disease genes
	$where .= "AND ds.iddisease = ? ";
	push(@prepare,$ref->{'dg.iddisease'});
}
if ($ref->{"s.name"}) {
	$where .= "AND s.name = ? ";
	push(@prepare,$ref->{'s.name'});
}
if ($ref->{"ds.iddisease"}) {
	$where .= "AND ds.iddisease = ? ";
	push(@prepare,$ref->{'ds.iddisease'});
}
if ($ref->{"s.idcooperation"}) {
	$where .= "AND s.idcooperation = ? ";
	push(@prepare,$ref->{'s.idcooperation'});
}
if ($ref->{"idproject"}) {
	$where .= "AND idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{"g.genesymbol"}) {
	$where .= "AND g.genesymbol = ? ";
	push(@prepare,$ref->{'g.genesymbol'});
}
if ($ref->{"checked"}) {  #todo
	$where .= "AND c.checked = ? ";
	push(@prepare,$ref->{'checked'});
}
if ($ref->{"freq"}) {
	$where .= "AND freq <= ? ";
	push(@prepare,$ref->{'freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);



&todaysdate();
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

$tmp=HTML::Entities::encode($ref->{'s.name'});
print "Sample: $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncontrols'});
&printqueryheader($ref,$classprint,$functionprint);

$query = qq#
$explain SELECT  
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(distinct s.pedigree),
group_concat(distinct $genelink separator " "),
v.class,replace(v.func,',',' '),
group_concat(DISTINCT $exac_gene_link separator ' '),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),
group_concat(distinct g.omim separator " "),
group_concat(distinct $mgiID separator " "),
(f.fsample),
(f.samplecontrols),
group_concat(distinct x.alleles),
group_concat(distinct x.snvqual),
group_concat(distinct x.gtqual),
group_concat(distinct x.mapqual),
group_concat(distinct x.coverage),
group_concat(distinct x.percentvar),
concat($rssnplink),
avhet,
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
concat(af),
group_concat(DISTINCT $exac_ae_link separator '<br>'),
group_concat(DISTINCT $exac_aa_link separator '<br>'),
valid,
v.transcript,
group_concat(DISTINCT $primer SEPARATOR '<br>'),
c.patho,
c.reason,
c.diseasecomment,
c.disease,
c.gene,
c.inheritance,
c.genotype,
c.rating,
c.checked,
c.confirmed,
v.idsnv,
s.idsample,
dg.class
FROM
snv v 
INNER JOIN snvsample                       x ON (v.idsnv = x.idsnv) 
INNER JOIN $sampledb.sample                s ON (s.idsample = x.idsample)
INNER JOIN $exomevcfe.comment              c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
LEFT  JOIN $coredb.dgvbp                 dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
LEFT  JOIN snvgene                         y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                            g ON (g.idgene = y.idgene)
LEFT  JOIN $coredb.evsscores            exac ON (g.genesymbol=exac.gene)
LEFT  JOIN $sampledb.mouse                mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN hgmd_pro.$hg19_coords           h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
INNER JOIN $sampledb.disease2sample       ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease               d ON (ds.iddisease = d.iddisease)
INNER JOIN snv2diseasegroup                f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN disease2gene                   dg ON (dg.iddisease=? AND g.idgene=dg.idgene)
LEFT  JOIN $coredb.pph3                  pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift                 sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.clinvar                cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $coredb.evs                   evs ON(v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
WHERE
$allowedprojects
$where
$function
$class
$genotype
$inheritance
$patho
$diseasegene
GROUP BY
v.idsnv,g.idgene,s.idsample
ORDER BY
s.pedigree,s.name,v.chrom,v.start
#;
#print "<br>query = $query<br>";
#print "<br>where = $where<br>";
#print "values = @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

if ($printquery eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

while (@row = $out->fetchrow_array) {
	$npedigree{$row[4]}{$row[3]}++;  #genesymbol,pedigree !wird gebraucht fuer minmal pedigrees!
	if ($npedigree{$row[4]}{$row[3]} == 1 ) {
		$ngenesymbol{$row[4]}++; #gene
	}
	push(@row2,[@row]);
}

@labels	= (
	'n',
	'idsnv',
	'chr',
	'Sample',
	'Pedigree',
	'Genesymbol',
	'Class',
	'Function',
	'ExAC pLI',
	'pph2',
	'pph2 prob',
	'Sift',
	'Genotype',
	'Inheritance',
	'Rating',
	'Conext',
	'ToDo',
	'Confirmed',
	'Disease gene',
	'Func pred',
	'Comment',
	'Patho',
	'NonSyn/ Gene',
	'DGV',
	'Omim',
	'Mouse',
	'Cases',
	'Controls',
	'Variant alleles',
	'SNV Qual',
	'Geno- type Qual',
	'Map Qual',
	'Depth',
	'%Var',
	"$dbsnp",
	'av Het',
	'HGMD',
	'ClinVar',
	'1000 genomes AF',
	'gnomAD ea',
	'gnomAD aa',
	'Valid',
	'Transcripts',
	'Primer'
	);

&tableheaderDefault();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";


$n=1;
my @tmp            = ();
my $damaging       = 0;
my $program        = "";
my $idsample       = "";
my $idsnvtmp       = "";
my $rating         = "";
my $checked        = "";
my $confirmed      = "";
$genotype          = "";
$inheritance       = "";
my $gene           = "";
my $disease        = "";
my $diseasecomment = "";
my $reason         = "";
#while (@row = $out->fetchrow_array) {
for  $aref (@row2) { 
	@row=@{$aref};
	$i=0;
	@tmp = ();
	$class="default";
	$_=$row[1];
	($chrom,$start,$end)=/\>(chr\w+)\:(\d+)\-(\d+)\</;
	# bekannte Gene in disease2gene
	if ($row[-1] ne "") {
		$class=&diseaseGeneColorNew($row[-1]);
	}
	else  {
		$class = "";
	}
	pop(@row); # delete dg.class
	$idsample=$row[-1];
	pop(@row); # delete s.name
	$idsnvtmp=$row[-1];
	pop(@row); #delete idsnv
	$confirmed = $row[-1];
	pop(@row); #delete confirmed
	$checked = $row[-1];
	pop(@row); #delete checked
	$rating = $row[-1];
	pop(@row); #delete rating
	$genotype = $row[-1];
	pop(@row); 
	$inheritance = $row[-1];
	pop(@row); 
	$gene = $row[-1]; # gene rating
	pop(@row); 
	$disease = $row[-1];
	pop(@row); 
	$diseasecomment= $row[-1];
	pop(@row); 
	$reason= $row[-1];
	pop(@row); 
	$patho= $row[-1];
	pop(@row); 
	foreach (@row) {
	if ($ngenesymbol{$row[4]} >= $ncases) {
			if ($i == 0) { 
				print "<tr>";
				print "<td $class align=\"center\"><a href='comment.pl?idsnv=$idsnvtmp&idsample=$idsample' title='Comment page'>$n</a></td>";
				$n++;
			}
			if ($i == 1) {
				$tmp=&ucsclink2($row[$i]);
				print "<td $class>$tmp</td>";
			}
			elsif ($i == 11) {
				print "<td $class>$genotype</td>";
				print "<td $class>$inheritance</td>";
				print "<td $class>$rating</td>";
				print "<td $class>$reason</td>";
				print "<td $class>$checked</td>";
				print "<td $class>$confirmed</td>";
				print "<td $class>$gene</td>";
				print "<td $class>$disease</td>";
				print "<td $class>$diseasecomment</td>";
				print "<td $class>$patho</td>";
				$tmp=$row[$i];
				print "<td $class>$tmp</td>";
			}
			# jedesmal aendern
			elsif ($i == 5) {
				($tmp)=&vcf2mutalyzer($dbh,$idsnvtmp);
				print "<td $class align=\"center\">$tmp</td>";
			}
			elsif (($i==9) or ($i==10)) {
				if ($i==9) {$program = 'polyphen2';}
				if ($i==10) {$program = 'sift';}
				$damaging=&damaging($program,$row[$i]);
				if ($damaging==1) {
					print "<td $warningtdbg>$row[$i]</td>";
				}
				else {
					print "<td $class> $row[$i]</td>";
				}
			}
			elsif ($i == 13) {
				($tmp)=&omim($dbh,$row[$i]);
				print "<td $class>$tmp</td>";
			}
			else {
				print "<td $class> $row[$i]</td>";
			}
			if ($i == @row-1) {
				print "</tr>\n";
			}
			$i++;
	}
	}
}

print "</tbody></table></div>";

$out->finish;
}

########################################################################
# trim
########################################################################
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

########################################################################
# resultlabels
########################################################################
sub resultlabels {
my @labels	= (
	'n',
	'idsnv',
	'IGV Comment',
	'Pedigree',
	'Sex',
	'Diagnosis',
	'Chr',
	'Rating',
	'Pathogenicity',
	'Gene symbol',
	'Omim',
	'Mode',
	'Omim disease',
	'Mouse',
	'Class',
	'Function',
	'Variant alleles',
	'Cases',
	'Controls',
	'gnomAD pLI',
	'missense Z-score',
	'HGMD',
	'ClinVar',
	'gnomAD',
	'NonSyn/ Gene',
	'DGV',
	'pph2',
	'pph2 prob',
	'Sift',
	'CADD',
	'Filter',
	'SNV Qual',
	'Geno- type Qual',
	'Map Qual',
	'Depth',
	'%Var',
	'Transcripts',
	'Primer'
	);
return(@labels);	
}
########################################################################
# searchResultsTumor searchtumor
########################################################################
sub searchResultsTumor {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels            = ();
my $out               = "";
my @row               = ();
my @row2              = ();
my $query             = "";
my $where             = "";
my $sample            = "";
my $idsample          = "";
my $i                 = 0;
my $n                 = 1;
my $tmp               = "";
my $function          = "";
my $functionprint     = "";
my $class             = "";
my $classprint        = "";
my $ncontrols         = "";
my $chrom             = "";
my $start             = "";
my $end               = "";
my $excluded          = "";
my $diseasegroup      = "";
my $samples           = "";
my $allowedprojects   = &allowedprojects("");
my @prepare           = ();
my $dgiddisease       = "";
my $cnvfile           = "";
my $explain           = "";
my @excludedsamples   = ();
my @excludedidsamples = ();
my %ngenesymbol       = ();
my %npedigree         = ();
my $result            = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


# split samples and excluded
$tmp=trim($ref->{"sample"});
if ($tmp eq "") {
	print "Sample IDs missing.";
	exit(1);
}
my (@samples) = split(/\s+/,$tmp);
delete($ref->{"sample"});
$tmp=trim($ref->{"excluded"});
(@excludedsamples) = split(/\s+/,$tmp);
delete($ref->{excluded});
foreach $tmp (@excludedsamples) {
	push(@excludedidsamples,&getIdsampleByName($dbh,$tmp));
}


if ($ref->{correct} eq 'correct') {
	$where .=  "AND (c.confirmed  = 'yes'
	            OR c.rating     = 'correct')
		    AND c.confirmed != 'no' ";
}

# controls
if ($ref->{'ncontrols'} ne "") {
	$where .= " AND (f.samplecontrols <= ? or ISNULL(f.samplecontrols) )";
	push(@prepare,$ref->{"ncontrols"});

}

if ($giabradio == 1) {
if ($ref->{'giab'} ne "") {
	$where .= " AND v.giab = ? ";
	push(@prepare,$ref->{'giab'});
}
}

if ($ref->{'dg.iddisease'} ne "") {
	$dgiddisease = $ref->{'dg.iddisease'};
}
else {
	$dgiddisease = -9999999;
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}


# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);

# print header
&todaysdate;
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

print "Samples: @samples<br>\n";
foreach $tmp (@samples) {
	&igvfile($tmp,'ExomeDepthSingle.seg',$dbh);
}
print "<br>\n";
foreach $tmp (@samples) {
	$cnvfile     = &cnvfile($tmp,$dbh);
	print " $cnvfile";
}
print "<br>\n";
foreach $tmp (@samples) {
	&igvfile($tmp,'allele_ratio.seg',$dbh);
}
print "<br>\n";
foreach $tmp (@samples) {
	&igvfile($tmp,'ExomeCount.seg',$dbh);
}
print "<br>\n";

print "Excluded: @excludedsamples<br>\n";
foreach $tmp (@excludedsamples) {
	&igvfile($tmp,'ExomeDepthSingle.seg',$dbh);
}
print "<br>\n";
foreach $tmp (@excludedsamples) {
	$cnvfile     = &cnvfile($tmp,$dbh);
	print " $cnvfile";
}
print "<br>\n";

print "Variant alleles >= $ref->{'x.alleles'}<br>\n";
print "Cases   >= $ref->{'ncases'}<br>\n";
print "Variants allowed in controls  <= $ref->{'ncontrols'}<br>\n";
&printqueryheader($ref,$classprint,$functionprint);
print "Exluded in controls: \n";

########################## foreach idsample #################################
$i = 0;
foreach $sample (@samples) {
$idsample = &getIdsampleByName($dbh,$sample);

# excluded disease
$query = "
SELECT DISTINCT d.iddiseasegroup 
FROM $sampledb.sample s
INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
WHERE s.idsample = ?
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsample) || die print "$DBI::errstr";
($excluded) = $out->fetchrow_array;
$diseasegroup=&getDiseaseGroupById($dbh,$excluded);
print " $diseasegroup\n";


$query = qq#
$explain SELECT 
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(distinct "<a href='http://localhost:$igvport/load?file=$igvserver",
"%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam"
",$igvserver",
"%3Fsid=$sess_id%26sname=$excludedsamples[$i]%26file=merged.rmdup.bam"
"\&index=$igvserver%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam.bai"
",$igvserver%3Fsid=$sess_id%26sname=$excludedsamples[$i]%26file=merged.rmdup.bam.bai",
"\&locus=",v.chrom,"\:",v.start,"-",v.end,"\&merge=true\&name=",s.name,",$excludedsamples[$i]'"," title='Right click for menu'",
">",s.name,"</a>"),
group_concat(distinct s.pedigree),
s.sex,
d.symbol,
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
c.rating,
c.patho,
group_concat(distinct $genelink separator '<br>'),
group_concat(distinct g.omim separator " "),
group_concat(distinct $mgiID separator " "),
v.class,
replace(v.func,',',' '),
group_concat(distinct x.alleles),
f.fsample,
f.samplecontrols,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),

group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(distinct x.filter),
group_concat(distinct x.snvqual),
group_concat(distinct x.gtqual),
group_concat(distinct x.mapqual),
group_concat(distinct x.coverage),
group_concat(distinct x.percentvar),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
group_concat(dg.class),
x.idsample,
v.idsnv
FROM
snv v 
INNER JOIN snvsample                   x ON (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample            s ON (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample   ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease           d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN snvgene                     y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                        g ON (g.idgene = y.idgene)
LEFT  JOIN disease2gene               dg ON (g.idgene = dg.idgene AND dg.iddisease=$dgiddisease)
LEFT  JOIN $sampledb.mouse            mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.pph3              pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift             sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd             cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs               evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores        exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords       h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar            cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment          c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
$allowedprojects
$function
$class
$where
AND s.idsample = ?
AND x.alleles >= ?
AND (f.fiddiseasegroup = ? or ISNULL(f.fiddiseasegroup) )
GROUP BY
v.idsnv,s.name
ORDER BY
v.chrom,v.start
#;
#print "$query<br>";
if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
}

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(
@prepare,
$idsample,
$ref->{"x.alleles"},
$excluded
) || die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

# check for minimal pedigrees (cases)
# mehrere Variations pro gene muessen entfernt werden
while (@row = $out->fetchrow_array) {
	# erst die SNVs entfernen, die in exluded samples vorkommen
	$result = "";
	$result.=&checkSamples($dbh,$excludedidsamples[$i],$row[-1]);
	if ($result ne "") {
		next;
	}
	# count for ncases, if sample.name and gene.name == 1 (nur einmal)
	#print "$row[-5]<br>";
	$npedigree{$row[2]}{$row[-5]}++;
	if ($npedigree{$row[2]}{$row[-5]} == 1 ) {
		$ngenesymbol{$row[2]}++;
	}
	push(@row2,[@row]);
}
$i++;
} # end for eache idsample


# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $aref;
my $program   = "";
my $omimmode     = "";
my $omimdiseases = "";
my $damaging  = "";
my $idsnvtmp  = "";
my $idtumor   = "";
# for vcf
my $idsamplesvcf = "";
my $idsnvsvcf    = "";
for  $aref (@row2) { 
	@row=@{$aref};
	$i=0;
	#$class="default";
	$_=$row[1];
	# color for linkage regions
	($chrom,$start,$end)=/\>(chr\w+)\:(\d+)\-(\d+)\</;
	# Now exclude @exluded (they can have a SNVqual lower than theshold, thus do again a search)
	if ($ngenesymbol{$row[2]} >= $ref->{"ncases"} ) {
	$idsnvtmp=$row[-1];
	pop(@row); #delete idsnv
	$idtumor = $row[-1];
	pop(@row); #delete idtumor
	# bekannte Gene in disease2gene color red
	if ($row[-1] ne "") {
		$class=&diseaseGeneColorNew($row[-1]);
	}
	else  {
		$class = "";
	}
	pop(@row);
	foreach (@row) {
		if ($i == 0) { 
			$idsamplesvcf .= "$idtumor,";
			$idsnvsvcf    .= "$idsnvtmp,";
			print "<tr>";
			print "<td align=\"center\">$n</td>";
			$n++;
		}
		if ($i == 1) {
			print qq#
			<td style='white-space:nowrap;'>
			<div class="dropdown">
			$row[$i]&nbsp;&nbsp;
			<a href="comment.pl?idsnv=$idsnvtmp&idsample=$idtumor&reason=tumor">
			<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
			</a>
			</div>
			</td>
			#;
		}
		elsif ($i == 5) {
			$tmp=&ucsclink2($row[$i]);
			print "<td>$tmp</td>";
		}
		elsif ($i == 9) {
			($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
			print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
		}
		elsif ($i == 11) {
			($tmp)=&vcf2mutalyzer($dbh,$idsnvtmp);
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==24) or ($i==25)) {
			if ($i==24) {$program = 'polyphen2';}
			if ($i==25) {$program = 'sift';}
			$damaging=&damaging($program,$row[$i]);
			if ($damaging==1) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 31) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		elsif ($i == 33) { # transcripts
			print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		if ($i == @row-1) {
			print "</tr>\n";
		}
		$i++;
	}
	}
}
print "</tbody></table></div>";

&callvcf($idsamplesvcf,$idsnvsvcf);


$out->finish;
}
########################################################################
# check Samples (SNVqual can be lower than threshold
########################################################################

sub checkSamples { 
	my $dbh      = shift;
	my $idsample   = shift;
	my $idsnv    = shift;
	my $query    = "";
	my $out      = "";
	my $result   = "";
	
	#$idsample = getIdsampleByName($dbh,$sample);
	
	$query = "
	SELECT x.idsnv 
	FROM snvsample x
	WHERE x.idsample  = ?
	AND   x.idsnv = ?
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($idsample,$idsnv) || die print "$DBI::errstr";
	$result = $out->fetchrow_array;
	return($result);
}
########################################################################
# searchResultsGeneInd resultsrecessive
########################################################################
sub searchResultsGeneInd {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my %row2      = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $r         = 1;
my $rssnp     = "";
my $tmp       = "";
my $tmp2 = "";
my @individuals = ();
my $individuals = "";
my $excludedDiseaseGroupId = "";
my $diseasegroup = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my @region    = ();
my $chrom     = "";
my $start     = "";
my $end       = "";
my $position  = "";
my $trio      = 0;
my $child     = "";
my $mother    = "";
my $father    = "";
my $allowedprojects = &allowedprojects("");
my $aa_het    = "";
my @prepare   = ();
my @d_prepare = ();
my $homozygous = "";
my @homozygous = ();
my $affecteds  = "";
my $idproject  = "";
my $sname      = "";
my $where      = "";
my $d_where    = "";
my $dg_iddisease = "";
my %gene_with_homozygous = ();

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});

	
# individuals for search
$ref->{"s.name"}=trim($ref->{"s.name"});
@individuals= split(/\s+/,$ref->{"s.name"});

if (($ref->{"s.name"} eq "") and ($ref->{"ds.iddisease"} eq "")) {
	print "Fill in either 'Disease' or 'Individuals'.<br>";
	exit(1);
}

#for trio
if ($ref->{trio} == 1) {
	$trio = 1;
	delete($ref->{trio});
	($child,$mother,$father)=&childInTrio(\@individuals,$dbh);
	if ($child eq "") {
		print "No child!<br>\n";
		exit(1);
	}
}

# or disease for search
if ($ref->{"ds.iddisease"} ne "") {
	if ($ref->{'idproject'} ne "") {
		$d_where .= " AND s.idproject = ? ";
		push(@d_prepare,$ref->{'idproject'});
	}
	if ($ref->{'s.idcooperation'} ne "") {
		$d_where .= " AND s.idcooperation = ? ";
		push(@d_prepare, $ref->{'s.idcooperation'});
	}
	$query = "
	SELECT DISTINCT s.name
	FROM $sampledb.sample s
	INNER JOIN $sampledb.disease2sample ds ON s.idsample=ds.idsample
	WHERE ds.iddisease = ?
	AND $allowedprojects
	$d_where
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($ref->{"ds.iddisease"},@d_prepare) || die print "$DBI::errstr";
	@individuals = ();
	while ($tmp = $out->fetchrow_array) {
		push(@individuals,$tmp);
	}	
}


if ($ref->{'dg.iddisease'} ne "") {
	$dg_iddisease .= $ref->{'dg.iddisease'};
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'homozygous'} == 1) {
	$homozygous =" HAVING
	max(x.alleles) >= ?";
	push(@homozygous,$ref->{"x.alleles"});
}
else {
	$homozygous =" HAVING
	count(distinct v.chrom,v.start) >= ?
	OR
	max(x.alleles) >= ?";
	push(@homozygous,$ref->{"x.alleles"},$ref->{"x.alleles"});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

my $explain = "";
if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}
# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);
			
&todaysdate;
print "Reference $hg<br>\n";
print "$dbsnp<br>\n";
&numberofsamples($dbh);

if ($ref->{'ds.iddisease'} ne "") {
	$tmp=&getDiseaseById($dbh,$ref->{'ds.iddisease'});
	print "Disease: $tmp<br>\n";
}
else {
	#$tmp=HTML::Entities::encode(@individuals);
	#print "Individuals $tmp<br>\n";
	print "Individuals @individuals<br>\n";
}
print "Exluded in controls: $diseasegroup<br>\n";
$tmp=HTML::Entities::encode($ref->{'x.alleles'});
print "Variant alleles >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'v.idsnv'});
print "Cases   >= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'ncontrols'});
print "Variants allowed in controls  <= $tmp<br>\n";
$tmp=HTML::Entities::encode($ref->{'aa_het'});
print "EVS African American (heterozygous): <= $tmp<br>\n";
&printqueryheader($ref,$classprint,$functionprint);
my $igvfile     = "";
my $cnvfile     = "";
my $printout    = "";

my $n_individuals = 0;
foreach $tmp (@individuals) {
	$igvfile     = &igvfile($tmp,'ExomeDepthSingle.seg',$dbh,'noprint');
	print " $igvfile";
	$cnvfile     = &cnvfile($tmp,$dbh);
	print " $cnvfile";
	$n_individuals++;
	if ($n_individuals >= 15) {
		last;
	}
}

my %ngenesymbol = ();
my %ngenesymbol_affected = ();
my %nidsnv      = (); #for trios
my %nidsnv_affected      = (); #for trios
my %npedigree   = ();
my @row2 = ();

# loop for each individual
foreach $sname (@individuals) {

$query = "
SELECT DISTINCT d.iddiseasegroup
FROM $sampledb.sample s
INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
WHERE s.name=?
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($sname) || die print "$DBI::errstr";
$excludedDiseaseGroupId = $out->fetchrow_array;
#$diseasegroup = &getDiseaseGroupById($dbh,$excludedDiseaseGroupId) . " ";
$excludedDiseaseGroupId = " (f.fiddiseasegroup = $excludedDiseaseGroupId or ISNULL(f.fiddiseasegroup) )";
#print "asdf $excludedDiseaseGroupId<br>";
#print "excluded $excluded<br>";

$tmp2=&getIdsampleByName($dbh,$sname);
if ($tmp2 eq "") {
	print "<br><br>Exome $sname does not exist.<br>";
	exit();
}
$individuals= " s.idsample = ?";


$query = qq#
$explain SELECT 
group_concat(DISTINCT v.idsnv ORDER BY v.chrom, v.start),
group_concat(DISTINCT s.idsample),
group_concat(DISTINCT g.genesymbol),
group_concat(DISTINCT s.pedigree),
group_concat(DISTINCT v.chrom),
group_concat(DISTINCT v.start),
s.mother,
s.father,
max(x.alleles),
s.saffected
FROM
snv v 
INNER JOIN snvsample                    x on (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp              dgv on (v.chrom = dgv.chrom AND v.start=dgv.start)
LEFT  JOIN $sampledb.sample             s on (s.idsample = x.idsample)
LEFT  JOIN snvgene                      y on (v.idsnv = y.idsnv)
LEFT  JOIN gene                         g on (g.idgene = y.idgene)
LEFT  JOIN $sampledb.mouse             mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN hgmd_pro.$hg19_coords        h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
INNER JOIN $sampledb.disease2sample    ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease            d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup             f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN disease2gene                dg ON (ds.iddisease=dg.iddisease AND g.idgene=dg.idgene)
LEFT  JOIN $coredb.pph3               pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift              sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.evs                evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
WHERE
$individuals
$rssnp
$where
$function
$class
$affecteds
AND (f.samplecontrols <= ? or ISNULL(f.samplecontrols) )
AND $excludedDiseaseGroupId
AND $allowedprojects
GROUP BY
g.genesymbol,s.idsample
$homozygous
ORDER BY
v.chrom,v.start
#;
if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
}

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(
$tmp2,
@prepare,
$ref->{"ncontrols"},
@homozygous
) || die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

# check for minimal cases
while (@row = $out->fetchrow_array) {
	# immer aendern
	#$npedigree{$row[3]}++; 
	# $row[0] = group_concat(v.idsnv)
	# $row[2] = group_concat(g.genesymbol)
	# $row[8] = snvsample.alleles
	# $row[8] = sample.saffected
	$ngenesymbol{$row[2]}++; # =>ref->{idsnv} (cases)
	if ($row[9] == 1) {
		$ngenesymbol_affected{$row[2]}++; # =>ref->{idsnv} (cases)
		$nidsnv_affected{$row[0]}{$row[2]}++;
	}
	# all idsnvs per idsnv (group_concat) per gene, in order to check in trios if parents have the same allele
	$nidsnv{$row[0]}{$row[2]}++;
	# for trios: if a singel homozygous snv in gene, display all snvs
	if ($row[8] >= 2) {
		$gene_with_homozygous{$row[1]}{$row[2]}++;
	}
	#push(@row2,[@row]);
	$row2{"$row[4]_$row[5]_$row[2]_$row[1]"}=[@row]; #order: foreach_chrom_start_gene_idsample
}

}

# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $omimmode     = "";
my $omimdiseases = "";
my $aref;
my $tmpchild;
my @tmp        =();
my @tmp2       =();
my $k          = 0;
my $l          = 0;
my $variant_allele = "";
my $damaging   =0;
my $program    ="";
my @row1       = ();
my @idsnv      = ();
my $idsnv      = "";
my $nidsnv     = "";
my $idsample   = "";
my $nrows      = 0;
my $genesymbol = "";
my $idsnvtmp   = "";
my $rating     = "";
my $checked    = "";
my $confirmed  = "";
my $affected   = "";
my $idsamplesvcf = "";
my $idsnvsvcf    = "";
my $diseaseflag=0;
#for  $aref (@row2) { 
	#@row1=@{$aref};
for  $aref (sort keys %row2) { 
	@row1=@{ $row2{$aref} };
	$i=0;
	(@idsnv)=split(/\,/,$row1[0]);
	$nrows = 0;
	$nrows = @idsnv; #for table spanrow
	$idsample=$row1[1];
	$mother=$row1[6];
	#sometimes mother is NULL, sometimes 0
	if ( (!defined($mother)) or ($mother == 0) ) {$mother = "";}
	if ($mother ne "") { # for igv
		$mother = &getigv($dbh,$mother,'Mother');      # obsolet for contextMenus
		$mother = qq("mother":     {name: "$mother"},); # obsolet for contextMenus
	}
	$father=$row1[7];
	if ( (!defined($father)) or ($father == 0) ) {$father = "";}
	if ($father ne "") {
		$father = &getigv($dbh,$father,'Father'); # obsolet for contextMenus
		$father = qq("father":     {name: "$father"},); # obsolet for contextMenus
	}
	#print "idsnv $row1[0]<br>";
	if ($ngenesymbol{$row1[2]} >= $ref->{"v.idsnv"} ) {
	foreach $idsnv (@idsnv) {
		$nidsnv++;
		(@row)=&singleRecessiveMain($dbh,$idsnv,$idsample,$row1[2],$dg_iddisease); # $row[2] = genesymbol
		# bekannte Gene in disease2gene
		$diseaseflag=0;
		if (!defined($row[-1])) {$row[-1] = "";}
		if ($row[-1] ne "") {
			$diseaseflag=1;
		}
		$class='';
		if ($diseaseflag) {
			$class=&diseaseGeneColorNew($row[-1]);
		}
		
		$variant_allele=$row[-2];
		$genesymbol=$row[-3];
		$_=$row[1]; #idsample
		($tmpchild)=/\>(\w+)\<\/a/; #s.name parsen
		pop(@row);
		pop(@row);
		pop(@row);		
		if (!defined($row[-1])) {$row[-1] = "";}
		$idsnvtmp=$row[-1];
		pop(@row); #delete idsnv
		if (!defined($row[-1])) {$row[-1] = "";}
		$affected = $row[-1];
		pop(@row); #delete affected
		$i=0;
		#print "genesymbol $ngenesymbol{$genesymbol}<br>";
		#print "$tmpidsnv $nidsnv{$tmpidsnv}{$genesymbol}<br>";
		#if ($genesymbol eq "LRRK2") {
		#print "$genesymbol idsnv $idsnvtmp nrow $nrows alleles $variant_allele $nidsnv{$row1[0]}{$row1[2]} trio $trio ref $ref->{'v.idsnv'} $tmpchild eq $child<br>";
		#}
		if 
		(
			(($ngenesymbol{$genesymbol} >= $ref->{"v.idsnv"} ) and ($trio == 0)) 
		or
			( 
				(
					( ($variant_allele != 2) 
					and ($nidsnv{$row1[0]}{$genesymbol} == $nidsnv_affected{$row1[0]}{$genesymbol} ) 
					) 
					or
					($variant_allele >= 2)
					or
					($gene_with_homozygous{$idsample}{$genesymbol}>=1)
				)
				and ($trio == 1) 
				and ($nidsnv_affected{$row1[0]}{$genesymbol} >= $ref->{"v.idsnv"} )
				and ($affected == 1)
			)  
		) {

				# $ref->{v.idsnv} == minimal cases
				# $nidsnv{$row1[0]}{$row1[2]} == idsnvs, genesymbol, i.e. if the combination of snvs is only present in the child
				# bei Trios duefen die compound heterozygoten SNVs nicht noch einmal bei
	               	 	# einem Elternteil vorkommen. Sie wuerden dann auf dem gleichen
				# Haplotyp liegen. Bei homozygoten SNVs muessen sie bei beiden
			 	# Elternteilen vorkommen. Sehr fuzzy, 2,1 ist immer erlaubt.
				# (Erlaubt, falls das Kind 3 SNVs hat, und zwei davon vom Vater und 1 von der Mutter
				# ($nplus==1) if one snv is printed, the next ones must be printed because rowspan is defined in the first snv (can be deleted, because of gene_with_homozygous
				# gene_with_homozygous{$idsample}{$genesymbol}>=1, if a homozygous variant is present in child: display all variants
		print "<tr>";
		
		foreach (@row) { 
				if (!defined($row[$i])) {$row[$i] = "";}
				if ($i == 0) { 
					print "<td align=\"center\">$n</td>";
				}
				if ($i == 1) {
					if (!defined($mother)) {$mother="";}
					if (!defined($father)) {$father="";}
						print qq#
						<td style='white-space:nowrap;'>
						<div class="dropdown">
						$row[$i]&nbsp;&nbsp;
						<a href="comment.pl?idsnv=$idsnvtmp&idsample=$idsample&reason=ar">
						<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
						</a>
						</div>
						</td>
						#;
				}
				elsif ($i == 5) {
					$idsamplesvcf .= "$idsample,";
					$idsnvsvcf    .= "$idsnv,";
					$tmp=&ucsclink2($row[$i]);
					print "<td align=\"center\"> $tmp</td>";
					$n++;
				}
				elsif ($i == 9) {
					($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
					print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
				}
				elsif ($i == 11) {
					($tmp)=&vcf2mutalyzer($dbh,$idsnv);
					print "<td align=\"center\">$tmp</td>";
				}
				elsif (($i==24) or ($i==25)) {
					if ($i==24) {$program = 'polyphen2';}
					if ($i==25) {$program = 'sift';}
					$damaging=&damaging($program,$row[$i]);
					if ($damaging==1) {
						print "<td $warningtdbg>$row[$i]</td>";
					}
					else {
						print "<td> $row[$i]</td>";
					}
				}
				elsif ($i == 31) { # cnv exomedetph
					$tmp=$row[$i];
					if ($row[11] eq "cnv") {
					$tmp=$tmp/100;
					}
					print "<td>$tmp</td>";
				}
				elsif ($i == 33) { # transcripts
					print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
				}
				else {
					print "<td align=\"center\"> $row[$i]</td>";
				}
				if ($i == @row-1) { #hier, weil die letzte column nicht geprinted wird
					print "</tr>\n";
				}
				$i++;
			}
		}
		#print "</tr>\n";
	} # foreach @idsnv
	} # if ngenesymbol
}
print "</tbody></table>";

&callvcf($idsamplesvcf,$idsnvsvcf);


$out->finish;
}
########################################################################
#  getigv without position recessive parents and quality control
########################################################################
sub getigv {
my $dbh      = shift;
my $idsample = shift;
my $parent   = shift;
my $out      = "";

my $query = qq#
SELECT group_concat("<a href='http://localhost:$igvport/load?file=$igvserver",
"%3Fsid=$sess_id\&merge=true\&name=",s.name,
"%26sname=",s.name,"%26file=merged.rmdup.bam","' title='Open sample in IGV'>$parent ",s.name,"</a>")
FROM $sampledb.sample s
WHERE s.idsample = ?
#;


$query = qq#
SELECT group_concat("<a href='http://localhost:$igvport/load?file=$igvserver","%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam",
"\&index=$igvserver","%3Fsid=$sess_id%26sname=",s.name,"%26file=merged.rmdup.bam.bai",
"\&merge=true\&name=",s.name,"' title='Open sample in IGV'>$parent ",s.name,"</a>")
FROM $sampledb.sample s
WHERE s.idsample = ?
#;


#print "<br>query $query $idsample<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsample) || die print "$DBI::errstr";
$idsample = $out->fetchrow_array;
return($idsample);

}

########################################################################
#  singleRecessiveMain called from recessiv
########################################################################
sub singleRecessiveMain {
my $dbh          = shift;
my $idsnv        = shift;
my $idsample     = shift;
my $genesymbol   = shift;
my $dg_iddisease = shift;
my $query        = "";
my $out          = "";
my @prepare      = ();
my @row          = ();
push(@prepare,$idsnv);
push(@prepare,$idsample);
push(@prepare,$genesymbol);

$query = qq#
SELECT 
group_concat(DISTINCT '<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree),
s.sex,
d.symbol,
group_concat(DISTINCT v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele SEPARATOR '|'),
c.rating,
c.patho,
group_concat(DISTINCT $genelink),
group_concat(DISTINCT g.omim separator ''),
group_concat(DISTINCT $mgiID),
group_concat(DISTINCT v.class),
replace(v.func,',',' '),
group_concat(DISTINCT x.alleles),
group_concat(DISTINCT f.fsample),
group_concat(DISTINCT f.samplecontrols),
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(DISTINCT g.nonsynpergene,' (', g.delpergene,')'),
group_concat(DISTINCT dgv.depth),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT x.filter SEPARATOR ', '),
group_concat(DISTINCT x.snvqual),
group_concat(DISTINCT x.gtqual),
group_concat(DISTINCT x.mapqual),
group_concat(DISTINCT x.coverage),
group_concat(DISTINCT x.percentvar),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
s.saffected,
v.idsnv,
group_concat(DISTINCT g.genesymbol),
group_concat(DISTINCT x.alleles),
dg.class
FROM
snv v 
INNER JOIN snvsample                    x ON (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp              dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample             s ON (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample    ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease            d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup             f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup) 
LEFT  JOIN snvgene                      y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                         g ON (g.idgene = y.idgene)
LEFT  JOIN disease2gene                dg ON (dg.iddisease = ? AND g.idgene=dg.idgene)
LEFT  JOIN $sampledb.mouse             mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.pph3               pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift              sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd              cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs                evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores         exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords        h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar             cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment           c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
v.idsnv = ?
AND s.idsample = ?
AND g.genesymbol = ?
#;
#print "$query<br>";
#print "id_dgdisease $dg_iddisease<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($dg_iddisease,@prepare) || die print "$DBI::errstr";
@row = $out->fetchrow_array;
return(@row);
}

########################################################################
# searchResultsPosition searchPosition
########################################################################
sub searchResultsPosition {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $tmp       = "";
my @prepare   = ();
my $position  = "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $class     = "";
my $dgdisease = "";
my $chartdata = "";
my @chartdata = ();
my @pos       = ();
my $allowedprojects = &allowedprojects("s.");

# Aufruf von searchPostionDo.pl mit chrom and start
if ($ref->{'dg.iddisease'} ne "") {
	$dgdisease .= " AND dg.iddisease = ? ";
	push(@prepare,$ref->{'dg.iddisease'});
}
else {
	$dgdisease .= " AND dg.iddisease = ? ";
	push(@prepare,' ');
}
if (($ref->{"position"} ne "") and ($ref->{"name"} ne "")) {
	$position=$ref->{"position"};
	$position=~s/\,//g;
	$position=~s/\s+//g;
	($chrom,$position)=split(/\:/,$position);
	($start,$end)=split(/\-/,$position);
	$where= " v.chrom = ?
		AND v.start >= ?
		AND v.end <= ?
		AND s.name = ? ";
	push(@prepare, $chrom);
	push(@prepare, $start);
	push(@prepare, $end);
	push(@prepare, $ref->{'name'});
}
else {
	print "Values missing.";
	exit;
}
if ($ref->{'snvqual'} ne "") {
	$where .= "AND x.snvqual >= ? ";
	push(@prepare,$ref->{'snvqual'});
}
if ($ref->{'gtqual'} ne "") {
	$where .= "AND x.gtqual >= ? ";
	push(@prepare,$ref->{'gtqual'});
}
if ($ref->{'mapqual'} ne "") {
	$where .= "AND x.mapqual >= ? ";
	push(@prepare,$ref->{'mapqual'});
}
if ($ref->{'filter'} ne "") {
	$where .= "AND x.filter = ? ";
	push(@prepare,$ref->{'filter'});
}

&todaysdate;
&numberofsamples($dbh);

$i=0;
$query = qq#
SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
group_concat(DISTINCT $genelink separator '<br>'),
concat(g.nonsynpergene,' (', g.delpergene,')'),
concat(g.omim),
v.class,v.func,
concat($rssnplink),
concat( '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>'),
s.pedigree,
i.symbol,s.saffected,x.alleles,
(SELECT DISTINCT f.fsampleall FROM snv2diseasegroup f WHERE v.idsnv=f.fidsnv),
x.snvqual,x.gtqual,x.mapqual,x.coverage,x.percentvar,x.filter,v.start,
group_concat(dg.class)
FROM
snv v
INNER JOIN snvsample x on (v.idsnv = x.idsnv) 
INNER JOIN $sampledb.sample s on (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease i on (ds.iddisease = i.iddisease)
LEFT JOIN snvgene y on (v.idsnv = y.idsnv)
LEFT JOIN gene g on (g.idgene = y.idgene)
LEFT JOIN disease2gene dg on (g.idgene = dg.idgene  $dgdisease)
WHERE
$allowedprojects
AND v.class != 'cnv'
AND $where
GROUP BY v.idsnv
ORDER BY v.chrom,v.start
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'idsnv',
	'chr',
	'Gene',
	'NonSyn/ Gene',
	'Omim',
	'Class',
	'Function',
	"$dbsnp",
	'IGV',
	'Pedigree',
	'Disease',
	'Affected',
	'Variant alleles',
	'All',
	'SNV qual',
	'Geno- type qual',
	'Map qual',
	'Depth',
	'PercentVar',
	'Filter'
	);

$i=0;

&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
@chartdata = ();
while (@row = $out->fetchrow_array) {
	$i=0;
	if ($row[-1] ne "") {
			$class=&diseaseGeneColorNew($row[-1]);
	}
	else  {
		$class = "";
	}
	pop(@row);
	print "<tr>";
	push(@pos,$row[-1]);
	push(@chartdata,$row[-3]);
	pop(@row);
	foreach (@row) {
		if ($i == 0) { 
			print "<td $class align=\"center\">$n</td>";
		}
		if ($i == 1) {
			$tmp=&ucsclink2($row[$i]);
			print "<td $class> $tmp</td>";
		}
		elsif ($i == 4) {
			($tmp)=&omim($dbh,$row[$i]);
			print "<td $class>$tmp</td>";
		}
		else {
			print "<td $class> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
#&tablescript("","5");

# figure
$chartdata = "";
$chartdata= "['SNV', 'Variants'] ";

$i=0;
foreach $tmp (@chartdata) {
	$chartdata .= ",\n['$pos[$i]',$tmp]";
	$i++;
}
#print "$chartdata";
print "<br>";

print qq(    
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
	$chartdata
        ]);

        var options = {
          title: 'Fraction of reads carrying the alternative allele',
	  backgroundColor: '#ffffff',
	  vAxis: {title: 'Percent', minValue : 0, maxValue : 100, logScale: false, format:'#.###'},
	  hAxis: {title: 'bp'},
	  lineWidth: 0,
	  pointSize: 4,
	  width    : 1200,
	  height   : 500
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
<div id="chart_div"></div>
);


$out->finish;
}
########################################################################
# searchResultsPosition searchPosition2 to list all idsnv resultsregion
########################################################################
sub get_vep {
my $dbh   = shift;
my $idsnv = shift;
my $chrom = "";
my $start = "";
my $ref   = "";
my $alt   = "";

my $query = "
SELECT chrom,start,refallele,allele
FROM snv
WHERE idsnv = ?
";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsnv) || die print "$DBI::errstr";
($chrom,$start,$ref,$alt) = $out->fetchrow_array;

my $vep_input       = $chrom . " " . $start . " . " .$ref . " " . $alt;
my $vep_input_file  = "/tmp/vep_input_$$.vcf";

open (OUT, ">", "$vep_input_file");
print OUT "$vep_input";
close OUT;

my $cmd = "
perl $vep_cmd \\
-i $vep_input_file \\
-o STDOUT \\
--cache \\
--dir /data/mirror/vep \\
--fasta $vep_fasta \\
--offline \\
--refseq \\
--no_stats \\
--force_overwrite \\
--species homo_sapiens \\
--hgvs \\
--shift_hgvs 1 \\
--symbol \\
--tab \\
--no_intergenic \\
--plugin GeneSplicer,$vep_genesplicer/bin/linux/genesplicer,$vep_genesplicer/human,context=200
";

delete $ENV{'PATH'};
my $result = `$cmd`;
my @result = split(/\n/,$result);
my @line   = ();
my $header = 0;

print "<br><b>$result[0]</b><table class='vep_table'>";
foreach (@result) {
	if (/##/) {next;} # information has two #
	if (/downstream_gene_variant/) {next;} # don't know how to get rid of these bulk of downstream variants
	if (/upstream_gene_variant/) {next;}
	$header = s/^#//; # table header has only one #
	@line = split(/\t/);
	print "<tr>";
	foreach (@line) {
		#print "<td>$_</td>";
		if ($header) {print "<th>$_</th>"} else {print "<td>$_</td>"};
	}
	print "</tr>";
}
print "</table>";

#unlink($vep_input_file);

}
########################################################################
# get_vep_vcf
#######################################################################
sub get_vep_vcf {
my $dbh    = shift;
my $chrom  = shift;
my $start  = shift;
my $ref    = shift;
my $alt    = shift;


my $vep_input       = $chrom . " " . $start . " . " .$ref . " " . $alt;
my $vep_input_file  = "/tmp/vep_input_$$.vcf";

open (OUT, ">", "$vep_input_file") || die;
print OUT "$vep_input";
close OUT;
#perl /usr/local/packages/seq/ensembl-tools-release-85/scripts/variant_effect_predictor/variant_effect_predictor.pl \\

#perl /usr/local/packages/seq/ensembl_vep_91/vep \\
#-i $vep_input_file \\

my $cmd = "
perl $vep_cmd  \\
-i $vep_input_file \\
-o STDOUT \\
--cache \\
--dir /data/mirror/vep \\
--fasta $vep_fasta \\
--offline \\
--refseq \\
--no_stats \\
--force_overwrite \\
--species homo_sapiens \\
--hgvs \\
--shift_hgvs 1 \\
--symbol \\
--tab \\
--no_intergenic \\
--plugin GeneSplicer,$vep_genesplicer/bin/linux/genesplicer,$vep_genesplicer/human,context=200
";

delete $ENV{'PATH'};
my $result = `$cmd` || die;
my @result = split(/\n/,$result);
my @line   = ();
my $header = 0;

print "<br><b>$result[0]</b><table class='vep_table'>";
foreach (@result) {
	if (/##/) {next;} # information has two #
	if (/downstream_gene_variant/) {next;} # don't know how to get rid of these bulk of downstream variants
	if (/upstream_gene_variant/) {next;}
	$header = s/^#//; # table header has only one #
	@line = split(/\t/);
	print "<tr>";
	foreach (@line) {
		#print "<td>$_</td>";
		if ($header) {print "<th>$_</th>"} else {print "<td>$_</td>"};
	}
	print "</tr>";
}
print "</table>";

unlink($vep_input_file);

}
########################################################################
# searchResultsPosition searchPosition2 to list all idsnv resultsregion
########################################################################
sub external_links {
my $dbh          = shift;
my $idsnv        = shift;

my $out = "";

my $query = qq#
SELECT
v.chrom,
v.start,
v.end,
v.class,
v.refallele,
v.allele
FROM snv v
WHERE v.idsnv=?
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsnv) || die print "$DBI::errstr";
my ($chrom,$start,$end,$class,$refallele,$altallele) = $out->fetchrow_array;
$chrom =~ s/chr//;


print "<br>";
print "<a href='https://varsome.com/variant/hg19/$chrom-$start-$refallele-$altallele'>Varsome</a><br>";
print "<a href='https://franklin.genoox.com/clinical-db/variant/snp/$chrom-$start-$refallele-$altallele'>Franklin</a><br>";
#print "<a href='https://varsome.com/security-validation/?next=/variant/hg19/$chrom-$start-$refallele-$altallele'>varsome</a><br>";

}
########################################################################
# searchResultsPosition searchPosition2 to list all idsnv resultsregion
########################################################################
sub searchResultsPosition2 {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $tmp       = "";
my @prepare   = ();

&todaysdate;
&numberofsamples($dbh);

if ($ref->{"idsnv"} ne "") {
	&external_links($dbh,$ref->{"idsnv"});
}

# Aufruf von searchPostionDo.pl mit chrom and start
if (($ref->{"v.chrom"} ne "") and ($ref->{"v.start"} ne "")) {
	$where= " v.chrom = ?
		AND
		v.start = ? ";
	push(@prepare, $ref->{'v.chrom'});
	push(@prepare, $ref->{'v.start'});
}
elsif ($ref->{"idsnv"} ne "") {
	$where =" v.idsnv = ? ";
	push(@prepare, $ref->{'idsnv'});
	
	if ($vep) {
		&get_vep($dbh,$ref->{'idsnv'});
	}
}
else {
	exit;
}

$i=0;
$query = qq#
SELECT
v.idsnv,
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
concat(v.chrom,':',v.start),v.refallele,v.allele,
group_concat(g.genesymbol separator ' '),
c.patho,
group_concat(g.nonsynpergene,' (', g.delpergene,')' separator ', '),
group_concat(DISTINCT g.omim separator ' '),
v.class,v.func,
concat($rssnplink),
concat( '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' ),
s.pedigree,
i.name,s.saffected,x.alleles,x.snvqual,x.gtqual,x.mapqual,x.coverage,x.percentvar,x.filter,
group_concat(DISTINCT $exac_link separator '<br>')
FROM
snv v
LEFT JOIN snvsample                 x ON v.idsnv = x.idsnv 
LEFT JOIN $sampledb.sample          s ON s.idsample = x.idsample
LEFT JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
LEFT JOIN $sampledb.disease         i ON ds.iddisease = i.iddisease
LEFT JOIN snvgene                   y ON v.idsnv = y.idsnv
LEFT JOIN gene                      g ON g.idgene = y.idgene
LEFT JOIN $coredb.evs             evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT JOIN $exomevcfe.comment        c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
$where
GROUP BY
s.name
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
#$out->execute($ref->{'v.chrom'},$ref->{"v.start"}) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'idsnv',
	'Chr',
	'Position<br>(vcf format)',
	'Ref<br>allele',
	'Alt<br>allele',
	'Gene<br>symbol',
	'Pathogenicity',
	'NonSyn/<br>Gene',
	'Omim',
	'Class',
	'Function',
	"$dbsnp",
	'Sample',
	'Pedigree',
	'Disease',
	'Affected',
	'Variant<br>alleles',
	'SNV<br>qual',
	'Genotype<br>qual',
	'Map qual',
	'Depth',
	'%Var',
	'Filter',
	'gnomAD',
	);

$i=0;
&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 1) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 8) {
			($tmp)=&omim($dbh,$row[$i]);
			print "<td>$tmp</td>";
		}
		elsif ($i == 17) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[6] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";



$out->finish;
}


########################################################################
#  searchResultsPositionVcf listPositionVcf to list all idsnv resultsregion
########################################################################
sub searchResultsPositionVcf {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $tmp       = "";
my @prepare   = ();
my $chrom     = "";
my $start     = "";
my $refallele = "";
my $altallele = "";

&todaysdate;
&numberofsamples($dbh);

# Aufruf von searchPostionDo.pl mit chrom and start
#if (($ref->{"v.chrom"} ne "") and ($ref->{"v.start"} ne "")) {
#	$where= " v.chrom = ?
#		AND
#		v.start = ? ";
#	push(@prepare, $ref->{'v.chrom'});
#	push(@prepare, $ref->{'v.start'});
#}
if ($ref->{'idvariant'} ne "") { # called by searchResultsPositionVcf
	$where =" v.idvariant = ? ";
	push(@prepare, $ref->{'idvariant'});
	$query = "
	SELECT chrom,pos,ref,alt
	FROM $wholegenome.variant
	WHERE idvariant = ?
	";
	my $out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($ref->{'idvariant'}) || die print "$DBI::errstr";
	($chrom,$start,$refallele,$altallele) = $out->fetchrow_array;
	
	if ($vep) {
		&get_vep_vcf($dbh,$chrom,$start,$refallele,$altallele);
	}
}
else {
	exit;
}

$i=0;
$query = qq#
SELECT
v.idvariant,
concat(v.chrom,' ',v.pos,' ',v.pos,' ',v.class,' ',v.ref,' ',v.alt),
concat(v.chrom,':',v.pos),v.ref,v.alt,
group_concat(g.genesymbol separator ' '),
group_concat(DISTINCT g.omim separator ' '),
v.class,
v.vep_Consequence,
concat( '<a href="http://localhost:$igvport/load?file=',$igvserver2vcf,'" title="Open sample in IGV"','>',s.name,'</a>' ),
s.pedigree,
i.symbol,
s.saffected,
group_concat(DISTINCT $exac_ae_link separator '<br>'),
group_concat(DISTINCT $exac_aa_link separator '<br>')
FROM
$wholegenome.variant v
LEFT JOIN $wholegenome.sample       x ON v.idvariant = x.idvariant 
LEFT JOIN $sampledb.sample          s ON s.idsample = x.idsample
LEFT JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
LEFT JOIN $sampledb.disease         i ON ds.iddisease = i.iddisease
LEFT JOIN gene                      g ON v.vep_SYMBOL = g.genesymbol
LEFT JOIN $coredb.evs             evs ON (v.chrom=evs.chrom and v.pos=evs.start and v.ref=evs.refallele and v.alt=evs.allele)
WHERE
$where
GROUP BY
s.name
#;
#print "query = $query<br>";
#print "prepare = @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'idsnv',
	'Chr',
	'Position<br>(vcf format)',
	'Ref<br>allele',
	'Alt<br>allele',
	'Gene<br>symbol',
	'Omim',
	'Class',
	'Function',
	'Sample',
	'Pedigree',
	'Disease',
	'Affected',
	'gnomAD ea',
	'gnomAD aa'
	);

$i=0;
&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 1) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 7) {
			($tmp)=&omim($dbh,$row[$i]);
			print "<td>$tmp</td>";
		}
		elsif ($i == 16) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[5] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";



$out->finish;
}


########################################################################
# searchResultsCnv searchCnv
########################################################################
sub searchResultsCnv {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $tmp       = "";
my @tmp       = ();
my @prepare   = ();
my $position  = "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $igvfile   = "";
my $cnvfile   = "";
my $having    = "";
my $allowedprojects = &allowedprojects("s.");

if ($ref->{'datebegin'} ne "") {
	$where = " AND es.date >= ? ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where .= " AND es.date <= ? ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'name'} ne "") {
	$where .= " AND s.name = ? ";
	push(@prepare, $ref->{'name'});
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'percentvar'} ne "") { #number of exons
	$where .= " AND x.percentvar >= ? ";
	push(@prepare,$ref->{'percentvar'});
}
if ($ref->{'percentvar2'} ne "") { #number of exons
	$where .= " AND x.percentvar <= ? ";
	push(@prepare,$ref->{'percentvar2'});
}
if ($ref->{'filter'} ne "") { 
	$where .= " AND x.filter = ? ";
	push(@prepare,$ref->{'filter'});
}
if ($ref->{'exomedepthrsd'} ne "") { 
	$where .= " AND es.exomedepthrsd <= ? ";
	push(@prepare,$ref->{'exomedepthrsd'});
}
if ($ref->{'percentfor1'} ne "") { #dosage
	$where .= " AND (x.percentfor <= ? ";
	push(@prepare,$ref->{'percentfor1'});
	if ($ref->{'percentfor2'} ne "") { #dosage
		$where .= " OR x.percentfor >= ? ";
		push(@prepare,$ref->{'percentfor2'});
	}
	$where .= " ) ";
}
if (($ref->{'percentfor2'} ne "") and ($ref->{'percentfor1'} eq "")) { #number of exons
	$where .= " AND x.percentfor >= ? ";
	push(@prepare,$ref->{'percentfor2'});
}
if ($ref->{'tumor'} eq "yes") { #exclude tumor samples
	$where .= " AND dg.name != ? ";
	push(@prepare,'Tumor');
}

if ($ref->{'nsamples'} ne "") { #number of samples
	$having .= " HAVING allcount <= ? ";
	push(@prepare,$ref->{'nsamples'});
}


&todaysdate;
&numberofsamples($dbh);

$i=0;
$query = qq#
SELECT 
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(s.name separator ', '),
group_concat(s.saffected separator '<br>'),
group_concat(p.pdescription separator '<br>'),
(SELECT
count(xx.idsnv)
FROM snvsample xx 
WHERE v.idsnv = xx.idsnv
AND xx.filter = 'PASS'
) as allcount,
v.length,
x.percentvar,
group_concat(x.percentfor separator '<br>'),
group_concat((ROUND(es.exomedepthrsd,2)) separator '<br>'),
dgv.depth,
(select group_concat(DISTINCT g.omim separator ' ')
FROM  snv vv
LEFT  JOIN snvgene                   y ON vv.idsnv = y.idsnv
LEFT  JOIN gene                      g ON g.idgene = y.idgene
WHERE vv.idsnv = v.idsnv
)
FROM snv v
INNER JOIN snvsample                 x ON v.idsnv=x.idsnv
INNER JOIN $sampledb.sample          s ON x.idsample=s.idsample
INNER JOIN $sampledb.disease2sample ds ON s.idsample=ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease=d.iddisease
INNER JOIN $sampledb.diseasegroup   dg ON d.iddiseasegroup=dg.iddiseasegroup
INNER JOIN $sampledb.project         p ON s.idproject=p.idproject
INNER JOIN $sampledb.exomestat      es ON s.idsample = es.idsample AND ((es.idlibtype = 5) or (es.idlibtype = 1))
LEFT  JOIN $coredb.dgvbp           dgv ON v.chrom=dgv.chrom AND v.start=dgv.start
WHERE
v.class = 'cnv'
AND $allowedprojects
$where
GROUP BY v.idsnv
$having
ORDER BY s.name,v.chrom,v.start
LIMIT 30000;
#;
#print "query = $query<br>";
#print "where @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
#$out->execute($ref->{'v.chrom'},$ref->{"v.start"}) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'SnvID',
	'UCSC',
	'IGV',
	'ExomeDepth',
	'Region',
	'Affected',
	'Project',
	'Count',
	'Size',
	'Exons',
	'Dosage',
	'Noise (Rs)',
	'DGV',
	'Omim'
	);

$i=0;

&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) {
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 1) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 3) {
			@tmp=split(/\, /,$row[$i]);
			print "<td>";
			foreach $tmp (@tmp) {
				$igvfile = &igvfile($tmp,'ExomeDepthSingle.seg',$dbh,'noprint');
				print "$igvfile<br>";
			}
			print "</td>";
			
			($chrom,$start,$end)=split(/\ /,$row[1]);
			print "<td>";
			foreach $tmp (@tmp) {
				$cnvfile = "<a href='searchPosition.pl?position=$chrom:$start-$end&name=$tmp'>$tmp</a>";
				print " $cnvfile<br>";
			}
			print "</td>";
		}
		elsif ($i == 12) {
			($tmp)=&omim($dbh,$row[$i]);
			#$tmp=$row[$i];
			print "<td>$tmp</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";





$out->finish;
}
########################################################################
# searchResultsSv searchSv structural variants resultsstructural
########################################################################
sub searchResultsSv {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";	  
my $out2      = "";	  
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $having    = "";
my $tmp       = "";
my @tmp       = ();
my @samplenames = ();
my @prepare   = ();
my @prepare_mincases   = ();
my $position  = "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $igvfile   = "";
my $cnvfile   = "";
my $mincases  = "";
my $caller    = "";
my $comment   = "";
my $classprint= "";
my $idsv      = "";
my $allowedprojects = &allowedprojects("s.");

if ($ref->{'datebegin'} ne "") {
	$where = " AND es.date >= ? ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where .= " AND es.date <= ? ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'comment'} ne "") {
	$comment = " AND c.rating = 'correct' ";
}
# retrieve all sample names when single samples ara entered
if ($ref->{'name'} ne "") {
	$tmp=$ref->{'name'};
	@tmp=split(/\s+/,$tmp);
	$where    .= " AND  (";
	$mincases .= " AND  (";
	$i=0;
	foreach $tmp (@tmp) {
		$tmp = &getIdsampleByName($dbh,$tmp);
		if ($i > 0) {
			$where    .= " OR ";
			$mincases .= " OR ";
		}
		$where    .= " svs.idsample = ? ";
		$mincases .= " svstmp.idsample = ? ";
		push(@prepare, $tmp);
		push(@prepare_mincases, $tmp);
		$i++;
	}
	$where    .= ") ";
	$mincases .= ") ";
	$mincases  = "(SELECT COUNT(DISTINCT svstmp.idsample) 
		from svsample svstmp 
		WHERE svs.idsv=svstmp.idsv
		$mincases) 
		as mincases, ";
}
# retrieve all sample names when project is entered
elsif ($ref->{'idproject'} ne "") {
	# excluded unaffected
	$query = "
	SELECT name FROM $sampledb.sample s
	INNER JOIN variantstat vs ON s.idsample=vs.idsample
	WHERE idproject = ?
	AND   saffected = 0
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute("$ref->{'idproject'}") || die print "$DBI::errstr";
	while ($tmp = $out->fetchrow_array) {
		if ($ref->{excluded} ne "") {
			$ref->{excluded} .= ' ';
		}
		$ref->{excluded} .= $tmp;
		#print "$tmp<br>";
	}
	
	# names affected
	$query = "
	SELECT name FROM $sampledb.sample s
	INNER JOIN variantstat vs ON s.idsample=vs.idsample
	WHERE idproject = ?
	AND   saffected = 1
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute("$ref->{'idproject'}") || die print "$DBI::errstr";
	while ($tmp = $out->fetchrow_array) {
		push(@tmp,$tmp);
		#print "$tmp<br>";
	}
	@samplenames = @tmp;
	$where    .= " AND  (";
	$mincases .= " AND  (";
	$i=0;
	foreach $tmp (@tmp) {
		$tmp = &getIdsampleByName($dbh,$tmp);
		if ($i > 0) {
			$where    .= " OR ";
			$mincases .= " OR ";
		}
		$where    .= " svs.idsample = ? ";
		$mincases .= " svstmp.idsample = ? ";
		push(@prepare, $tmp);
		push(@prepare_mincases, $tmp);
		$i++;
	}
	$where    .= ") ";
	$mincases .= ") ";
	$mincases  = "(SELECT COUNT(DISTINCT svstmp.idsample) 
		from svsample svstmp 
		WHERE svs.idsv=svstmp.idsv
		$mincases) 
		as mincases, ";
}
else {
	$mincases = "'',";
	$ref->{'mincases'} = "";
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
#if ($ref->{'idproject'} ne "") {
#	$where .= " AND s.idproject = ? ";
#	push(@prepare,$ref->{'idproject'});
#}
if ($ref->{'svtype'} ne "") { 
	$where .= " AND svs.svtype = ? ";
	push(@prepare,$ref->{'svtype'});
}
if ($ref->{'svlenmin'} ne "") { 
	$where .= " AND ABS(svs.svlen) >= ? ";
	push(@prepare,$ref->{'svlenmin'});
}
if ($ref->{'svlenmax'} ne "") { 
	$where .= " AND ABS(svs.svlen) <= ? ";
	push(@prepare,$ref->{'svlenmax'});
}
if ($ref->{'af1KG'} ne "") { 
	$where .= " AND sv.af1KG <= ? ";
	push(@prepare,$ref->{'af1KG'});
}
if ($ref->{'freq'} ne "") { 
	$where .= " AND sv.freq <= ? ";
	push(@prepare,$ref->{'freq'});
}
if ($ref->{'annotation'} ne "") { 
	$where .= " AND FIND_IN_SET(?,sv.overlaps) > 0 ";
	push(@prepare,$ref->{'annotation'});
}
if ($ref->{'gapoverlap'} ne "") { 
	$where .= " AND sv.gapoverlap <= ? ";
	push(@prepare,$ref->{'gapoverlap'});
}
if ($ref->{'giaboverlap'} ne "") { 
	$where .= " AND sv.giaboverlap >= ? ";
	push(@prepare,$ref->{'giaboverlap'});
}
if ($ref->{'lowcomploverlap'} ne "") { 
	$where .= " AND sv.lowcomploverlap <= ? ";
	push(@prepare,$ref->{'lowcomploverlap'});
}
if ($ref->{'dgvoverlap'} ne "") { 
	$where .= " AND sv.dgvoverlap <= ? ";
	push(@prepare,$ref->{'dgvoverlap'});
}
if ($ref->{'gensupdupsoverlap'} ne "") { 
	$where .= " AND sv.gensupdupsoverlap <= ? ";
	push(@prepare,$ref->{'gensupdupsoverlap'});
}
if ($ref->{'omim'} ne "") { 
	$where .= " AND g.omim > 0 ";
	#push(@prepare,$ref->{'omim'});
}
if ($ref->{'bddp'} ne "") { 
	$where .= " AND (svs.bddp >= ? or ISNULL(svs.bddp) ) ";
	push(@prepare,$ref->{'bddp'});
}
if ($ref->{'cnunique'} ne "") { 
	$where .= " AND (svs.cnunique <= ? or ISNULL(svs.cnunique) ) ";
	push(@prepare,$ref->{'cnunique'});
}
if ($ref->{'cndosagedel'} ne "") { 
	$where .= " AND (svs.cndosage <= ? or ISNULL(svs.cndosage) ) ";
	push(@prepare,$ref->{'cndosagedel'});
}
if ($ref->{'cndosagedup'} ne "") { 
	$where .= " AND (svs.cndosage >= ? or ISNULL(svs.cndosage) ) ";
	push(@prepare,$ref->{'cndosagedup'});
}
if ($ref->{'pidp'} ne "") { 
	$where .= " AND (svs.pidp >= ? or ISNULL(svs.pidp) ) ";
	push(@prepare,$ref->{'pidp'});
}
if ($ref->{'caller'} ne "") { 
	($caller,$classprint)=&caller($ref->{'caller'},$dbh);
	#$where .= " AND BIT_COUNT(svs.caller) >= ?";
	#push(@prepare,$ref->{'ncaller'});
}
if ($ref->{'ncaller'} ne "") { 
	$where .= " AND BIT_COUNT(svs.caller) >= ?";
	push(@prepare,$ref->{'ncaller'});
}
if ($ref->{'chrom'} ne "") { 
	$chrom=$ref->{'chrom'};
	$chrom=~s/,//g;
	$chrom=~s/\s+//g;
	($chrom,$start)=split(/\:/,$chrom);
	$where .= " AND svs.chrom = ? ";
	push(@prepare,$chrom);
	($start,$end)=split(/\-/,$start);
	$where .= " AND svs.start >= ? ";
	$where .= " AND svs.end <= ? ";
	push(@prepare,$start);
	push(@prepare,$end);
}


if ($ref->{'ngenes'} ne "") { 
	$having .= " HAVING ngenes>= ? ";
	push(@prepare,$ref->{'ngenes'});
}
if ($ref->{'mincases'}  ne "") { 
	if ($having eq "") {
		$having .= " HAVING ";
	}
	else {
		$having .= " AND ";
	}
	$having .= " mincases >= ? ";
	push(@prepare,$ref->{'mincases'});
}
if ($ref->{'idsv'} ne "") { 
	$where .= " AND sv.idsv = ?  ";
	push(@prepare,$ref->{'idsv'});
}


&todaysdate;
&numberofsamples($dbh);
if ($ref->{'name'} ne "") {
	print "Samples:  $ref->{'name'}<br>";
}
else {
	print "Samples:  @samplenames<br>";
}
print "Excluded: $ref->{excluded}<br>";

#tim deleted 2018-12-08 for Rad sample
#INNER JOIN $sampledb.exomestat      es ON s.idsample = es.idsample

$query = qq#
SELECT 
concat('<a href="listPositionSV.pl?idsv=',sv.idsv,'" title="All carriers of this variant">',sv.idsv,'</a>',' '),
GROUP_CONCAT(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserversv,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
GROUP_CONCAT(DISTINCT s.pedigree separator '<br>'),
GROUP_CONCAT(DISTINCT s.saffected separator '<br>'),
CONCAT(svs.chrom,' ',svs.start,' ',svs.end),
c.rating,
svs.caller,
svs.svtype,
svs.svlen,
COUNT(DISTINCT g.idgene) as ngenes,
GROUP_CONCAT(DISTINCT g.omim separator ' '),
$mincases
sv.freq,
sv.af1KG,
sv.num1KG,
sv.type1KG,
sv.gapoverlap,
sv.dgvoverlap,
sv.gensupdupsoverlap,
sv.lowcomploverlap,
sv.giaboverlap,
sv.overlaps,
svs.cndosage,
svs.cnscore1,
svs.cnscore2,
svs.cnscore3,
svs.cnscore4,
svs.cnunique,
svs.pialleles,
svs.pidp,
svs.pipercentvar,
svs.mtalleles,
svs.mtgq,
svs.bddp,
svs.bdor1,
svs.bdor2,
svs.lppe,
svs.lpsr,
svs.ss,
svs.sr,
svs.idsvsample,
sv.idsv,
svs.idsample
FROM 
sv sv
INNER JOIN svsample                svs ON sv.idsv=svs.idsv
INNER JOIN $sampledb.sample          s ON svs.idsample=s.idsample
INNER JOIN $sampledb.disease2sample ds ON s.idsample=ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease=d.iddisease
INNER JOIN $sampledb.diseasegroup   dg ON d.iddiseasegroup=dg.iddiseasegroup
LEFT  JOIN svgene                    z ON sv.idsv = z.idsv
LEFT  JOIN gene                      g ON z.idgene = g.idgene
LEFT  JOIN $exomevcfe.comment        c ON (svs.chrom = c.chrom and svs.start = c.start and svs.end = c.end)
WHERE
$allowedprojects
$where
$caller
$comment
GROUP BY svs.idsv,svs.idsample,svs.svlen
$having
ORDER BY sv.chrom,sv.start
#;

#print "$query<br>";
#print "@prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare_mincases,@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'IDsv',
	'IGV',
	'Pedigree',
	'Affected',
	'UCSC',
	'Rating',
	'Caller',
	'Type',
	'Length',
	'n Genes',
	'OMIM',
	'Min. cases',
	'In-house SVs',
	'allele frequency 1KG',
	'num1KG',
	'type1KG',
	'Gap',
	'DGV',
	'Duplications',
	'Low complexity',
	'Genome in a bottle',
	'Overlaps',
	'CNVnator dosage',
	'CNVnator score1',
	'CNVnator score2',
	'CNVnator score3',
	'CNVnator score4',
	'CNVnator unique',
	'Pindel alleles',
	'Pindel dp',
	'Pindel percentvar',
	'Manta alleles',
	'Manta mtgq',
	'Breakdancer dp',
	'Breakdancer or1',
	'Breakdancer or2',
	'Lumpy-sv pe',
	'Lumpy-sv sr',
	'whamg ss',
	'whamg sr'
	);

$i=0;

@prepare = (); # for excluded
if ($ref->{'excluded'} ne "") {
	$tmp=$ref->{'excluded'};
	@tmp=split(/\s+/,$tmp);
	$query    = "
		SELECT idsv
		from svsample 
		WHERE idsv = ?
		AND (
		";
	$i=0;
	foreach $tmp (@tmp) {
		$tmp = &getIdsampleByName($dbh,$tmp);
		if ($i > 0) {
			$query    .= " OR ";
		}
		$query    .= " idsample = ? ";
		push(@prepare, $tmp);
		$i++;
	}
	$query    .= ") ";
}
#print "$query<br>@prepare<br>";
$out2 = $dbh->prepare($query) || die print "$DBI::errstr";

&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $cidsample    = "";
my $cidsvsample    = "";
while (@row = $out->fetchrow_array) {
	# check excluded
	$cidsample     = $row[-1];
	pop(@row);
	$idsv=$row[-1];
	pop(@row);
	$cidsvsample=$row[-1];
	pop(@row);
	if ($ref->{'excluded'} ne "") {
		$out2->execute($idsv,@prepare) || die print "$DBI::errstr";
		$tmp=$out2->fetchrow_array;
		#print "$tmp<br>";
		if ($tmp ne "") {next;}
	}
	
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td align=\"center\">$n</td>";
			print "<td> $row[$i]</td>";
		}
		elsif ($i == 4) {
			$tmp=&ucsclinksv($row[$i]);
			print "<td align='center'> $tmp</td>"
		}
		elsif ($i == 10) {
			($tmp)=&omim($dbh,$row[$i]);
			print "<td>$tmp</td>";
		}
		elsif ($i == 1) {
			print qq#
			<td style='white-space:nowrap;'>
			<div class="dropdown">
			$row[$i]&nbsp;&nbsp;
			<a href="comment.pl?idsnv=$cidsvsample&idsample=$cidsample&reason=sv&table=svsample">
			<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
			</a>
			</div>
			</td>
			#;
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

}
########################################################################
# searchResultsSvOld searchSv structural variants
########################################################################
sub searchResultsSvOld {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";	  
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $having    = "";
my $tmp       = "";
my @tmp       = ();
my @prepare   = ();
my @prepare_mincases   = ();
my $position  = "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $igvfile   = "";
my $cnvfile   = "";
my $mincases  = "";
my $caller    = "";
my $classprint= "";
my $allowedprojects = &allowedprojects("s.");

if ($ref->{'datebegin'} ne "") {
	$where = " AND es.date >= ? ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where .= " AND es.date <= ? ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'name'} ne "") {
	$tmp=$ref->{'name'};
	@tmp=split(/\s+/,$tmp);
	$where    .= " AND  (";
	$mincases .= " AND  (";
	$i=0;
	foreach $tmp (@tmp) {
		$tmp = &getIdsampleByName($dbh,$tmp);
		if ($i > 0) {
			$where    .= " OR ";
			$mincases .= " OR ";
		}
		$where    .= " svs.idsample = ? ";
		$mincases .= " svstmp.idsample = ? ";
		push(@prepare, $tmp);
		push(@prepare_mincases, $tmp);
		$i++;
	}
	$where    .= ") ";
	$mincases .= ") ";
	$mincases  = "(SELECT COUNT(svstmp.idsv) 
		from svsample svstmp 
		WHERE svs.idsv=svstmp.idsv
		$mincases) 
		as mincases, ";
}
else {
	$mincases = "'',";
}
if ($ref->{'excluded'} ne "") {
	$tmp=$ref->{'excluded'};
	@tmp=split(/\s+/,$tmp);
	$where    .= " AND svs.idsv NOT IN
		(SELECT DISTINCT tmp2.idsv
		from svsample tmp2 
		INNER JOIN svsample svs ON svs.idsv=tmp2.idsv 
		WHERE (
		";
	$i=0;
	foreach $tmp (@tmp) {
		$tmp = &getIdsampleByName($dbh,$tmp);
		if ($i > 0) {
			$where    .= " OR ";
		}
		$where    .= " svs.idsample = ? ";
		push(@prepare, $tmp);
		$i++;
	}
	$where    .= ") )";
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'svtype'} ne "") { 
	$where .= " AND svs.svtype = ? ";
	push(@prepare,$ref->{'svtype'});
}
if ($ref->{'svlenmin'} ne "") { 
	$where .= " AND ABS(svs.svlen) >= ? ";
	push(@prepare,$ref->{'svlenmin'});
}
if ($ref->{'svlenmax'} ne "") { 
	$where .= " AND ABS(svs.svlen) <= ? ";
	push(@prepare,$ref->{'svlenmax'});
}
if ($ref->{'af1KG'} ne "") { 
	$where .= " AND sv.af1KG <= ? ";
	push(@prepare,$ref->{'af1KG'});
}
if ($ref->{'freq'} ne "") { 
	$where .= " AND sv.freq <= ? ";
	push(@prepare,$ref->{'freq'});
}
if ($ref->{'annotation'} ne "") { 
	$where .= " AND FIND_IN_SET(?,sv.overlaps) > 0 ";
	push(@prepare,$ref->{'annotation'});
}
if ($ref->{'gapoverlap'} ne "") { 
	$where .= " AND sv.gapoverlap <= ? ";
	push(@prepare,$ref->{'gapoverlap'});
}
if ($ref->{'giaboverlap'} ne "") { 
	$where .= " AND sv.giaboverlap >= ? ";
	push(@prepare,$ref->{'giaboverlap'});
}
if ($ref->{'lowcomploverlap'} ne "") { 
	$where .= " AND sv.lowcomploverlap <= ? ";
	push(@prepare,$ref->{'lowcomploverlap'});
}
if ($ref->{'dgvoverlap'} ne "") { 
	$where .= " AND sv.dgvoverlap <= ? ";
	push(@prepare,$ref->{'dgvoverlap'});
}
if ($ref->{'gensupdupsoverlap'} ne "") { 
	$where .= " AND sv.gensupdupsoverlap <= ? ";
	push(@prepare,$ref->{'gensupdupsoverlap'});
}
if ($ref->{'bddp'} ne "") { 
	$where .= " AND (svs.bddp >= ? or ISNULL(svs.bddp) ) ";
	push(@prepare,$ref->{'bddp'});
}
if ($ref->{'pidp'} ne "") { 
	$where .= " AND (svs.pidp >= ? or ISNULL(svs.pidp) ) ";
	push(@prepare,$ref->{'pidp'});
}
if ($ref->{'caller'} ne "") { 
	($caller,$classprint)=&caller($ref->{'caller'},$dbh);
	#$where .= " AND BIT_COUNT(svs.caller) >= ?";
	#push(@prepare,$ref->{'ncaller'});
}
if ($ref->{'ncaller'} ne "") { 
	$where .= " AND BIT_COUNT(svs.caller) >= ?";
	push(@prepare,$ref->{'ncaller'});
}
if ($ref->{'chrom'} ne "") { 
	$chrom=$ref->{'chrom'};
	$chrom=~s/,//g;
	$chrom=~s/\s+//g;
	($chrom,$start)=split(/\:/,$chrom);
	$where .= " AND svs.chrom = ? ";
	push(@prepare,$chrom);
	($start,$end)=split(/\-/,$start);
	$where .= " AND svs.start >= ? ";
	$where .= " AND svs.end <= ? ";
	push(@prepare,$start);
	push(@prepare,$end);
}


if ($ref->{'ngenes'} ne "") { 
	$having .= " HAVING ngenes>= ? ";
	push(@prepare,$ref->{'ngenes'});
}
if ($ref->{'mincases'} ne "") { 
	if ($having eq "") {
		$having .= " HAVING ";
	}
	else {
		$having .= " AND ";
	}
	$having .= " mincases >= ? ";
	push(@prepare,$ref->{'mincases'});
}
if ($ref->{'idsv'} ne "") { 
	$where .= " AND sv.idsv = ?  ";
	push(@prepare,$ref->{'idsv'});
}


&todaysdate;
&numberofsamples($dbh);

$query = qq#
SELECT 
concat('<a href="listPositionSV.pl?idsv=',sv.idsv,'" title="All carriers of this variant">',sv.idsv,'</a>',' '),
GROUP_CONCAT(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserversv,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
GROUP_CONCAT(DISTINCT s.pedigree separator '<br>'),
GROUP_CONCAT(DISTINCT s.saffected separator '<br>'),
CONCAT(svs.chrom,' ',svs.start,' ',svs.end),
svs.caller,
svs.svtype,
svs.svlen,
COUNT(DISTINCT g.idgene) as ngenes,
GROUP_CONCAT(DISTINCT g.omim separator ' '),
$mincases
sv.freq,
sv.af1KG,
sv.num1KG,
sv.type1KG,
sv.dgvoverlap,
sv.gensupdupsoverlap,
sv.lowcomploverlap,
sv.giaboverlap,
sv.overlaps,
svs.cndosage,
svs.cnscore1,
svs.cnscore2,
svs.cnscore3,
svs.cnunique,
svs.pialleles,
svs.pidp,
svs.pipercentvar,
svs.mtalleles,
svs.mtgq,
svs.bddp,
svs.bdor1,
svs.bdor2,
svs.lppe,
svs.lpsr
FROM 
sv sv
INNER JOIN svsample                svs ON sv.idsv=svs.idsv
INNER JOIN $sampledb.sample          s ON svs.idsample=s.idsample
INNER JOIN $sampledb.disease2sample ds ON s.idsample=ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease=d.iddisease
INNER JOIN $sampledb.diseasegroup   dg ON d.iddiseasegroup=dg.iddiseasegroup
INNER JOIN $sampledb.exomestat      es ON s.idsample = es.idsample
LEFT  JOIN svgene                    z ON sv.idsv = z.idsv
LEFT  JOIN gene                      g ON z.idgene = g.idgene
WHERE
$allowedprojects
$where
$caller
GROUP BY svs.idsv,svs.idsample
$having
ORDER BY sv.chrom,sv.start
#;

#print "$query<br>";
#print "@prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare_mincases,@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'IDsv',
	'IGV',
	'Pedigree',
	'Affected',
	'UCSC',
	'Caller',
	'Type',
	'Length',
	'n Genes',
	'OMIM',
	'Min. cases',
	'In-house SVs',
	'allele frequency 1KG',
	'num1KG',
	'type1KG',
	'DGV',
	'Duplications',
	'Low complexity',
	'Genome in a bottle',
	'Overlaps',
	'CNVnator dosage',
	'CNVnator score1',
	'CNVnator score2',
	'CNVnator score3',
	'CNVnator unique',
	'Pindel alleles',
	'Pindel dp',
	'Pindel percentvar',
	'Manta alleles',
	'Manta mtgq',
	'Breakdancer dp',
	'Breakdancer or1',
	'Breakdancer or2',
	'Lumpy-sv pe',
	'Lumpy-sv sr'
	);

$i=0;

&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td align=\"center\">$n</td>";
			print "<td> $row[$i]</td>";
		}
		elsif ($i == 4) {
			$tmp=&ucsclinksv($row[$i]);
			print "<td align='center'> $tmp</td>"
		}
		elsif ($i == 9) {
			($tmp)=&omim($dbh,$row[$i]);
			print "<td>$tmp</td>";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

}
########################################################################
# searchResultsTrans searchTrans  resultstranslocations
########################################################################
sub searchResultsTrans {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $having    = "";
my $tmp       = "";
my @tmp       = ();
my @prepare   = ();
my $position  = "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $igvfile   = "";
my $cnvfile   = "";
my $allowedprojects = &allowedprojects("s.");

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


if ($ref->{'datebegin'} ne "") {
	$where = " AND es.date >= ? ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where .= " AND es.date <= ? ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'name'} ne "") {
	$where .= " AND s.name = ? ";
	push(@prepare, $ref->{'name'});
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'num_discordant'} ne "") { 
	$where .= " AND t.num_discordant >= ? ";
	push(@prepare,$ref->{'num_discordant'});
}
if ($ref->{'sc1'} ne "") { 
	$where .= " AND t.sc1 >= ? ";
	push(@prepare,$ref->{'sc1'});
}
if ($ref->{'sc2'} ne "") { 
	$where .= " AND t.sc2 >= ? ";
	push(@prepare,$ref->{'sc2'});
}
if ($ref->{'countgene1'} ne "") { #number of exons
	$having .= " countgene1 <= ? ";
	push(@prepare,$ref->{'countgene1'});
}
if ($ref->{'countgene2'} ne "") { #number of exons
	if ($having ne "") {
		$having .= " AND ";
	}
	$having .= " countgene2 <= ? ";
	push(@prepare,$ref->{'countgene2'});
}
if ($having ne "") {
	$having = "HAVING " . $having;
}


&todaysdate;
&numberofsamples($dbh);

$query = qq#
SELECT 
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserverTrans1,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserverTrans2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree separator '<br>'),
group_concat(DISTINCT s.saffected separator '<br>'),
(SELECT count(tt.idgene1) FROM translocation tt WHERE t.idgene1=tt.idgene1) as countgene1,
(SELECT count(tt.idgene2) FROM translocation tt WHERE t.idgene2=tt.idgene2) as countgene2,
concat(t.chrom1,' ',t.pos1,' ',t.pos1),
g1.genesymbol,
t.isingene1,
group_concat(DISTINCT g1.omim separator ' '),
concat(t.chrom2,' ',t.pos2,' ',t.pos2),
g2.genesymbol,
t.isingene2,
group_concat(DISTINCT g2.omim separator ' '),
t.varianttype,
t.num_discordant,
t.sc1,
t.sc2
FROM 
translocation t
INNER JOIN $sampledb.sample          s ON t.idsample=s.idsample
LEFT  JOIN gene                     g1 ON t.idgene1=g1.idgene
LEFT  JOIN gene                     g2 ON t.idgene2=g2.idgene
INNER JOIN $sampledb.disease2sample ds ON s.idsample=ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease=d.iddisease
INNER JOIN $sampledb.diseasegroup   dg ON d.iddiseasegroup=dg.iddiseasegroup
INNER JOIN $sampledb.exomestat      es ON s.idsample = es.idsample AND ((es.idlibtype = 5) or (es.idlibtype = 1))
WHERE
$allowedprojects
$where
GROUP BY t.idtranslocation
$having
#;

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'IGV<br>Breakpoint 1',
	'IGV<br>Breakpoint 2',
	'Pedigree',
	'Affected',
	'Count<br>Gene1',
	'Count<br>Gene2',
	'UCSC',
	'Gene 1',
	'Within<br>gene 1',
	'OMIM',
	'UCSC',
	'Gene 2',
	'Within<br>gene 2',
	'OMIM',
	'Variant type',
	'N discordant',
	'SC1',
	'SC2'
	);

$i=0;

&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		#if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) {
			print "<td align=\"center\">$n</td>";
			print "<td> $row[$i]</td>";
		}
		elsif (($i == 6) or ($i == 10)) {
			$tmp=&ucsclinkTrans($row[$i]);
			print "<td> $tmp</td>"
		}
		elsif (($i == 9) or ($i == 13)) {
			($tmp)=&omim($dbh,$row[$i]);
			print "<td>$tmp</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

}
########################################################################
# searchResultsHomozygosity searchHomozygosity
########################################################################
sub searchResultsHomozygosity {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $tmp       = "";
my @prepare   = ();
my $position  = "";
my $chrom     = "";
my $start     = "";
my $end       = "";
my $name       = "";
my $chartdata = "";
my @chartdata = ();
my @pos       = ();
my $allowedprojects = &allowedprojects("s.");
my $alleleratio = $ref->{"alleleratio"};

if ($ref->{'name'} ne "") {
	$where = " AND s.name = ? ";
	push(@prepare, $ref->{'name'});
	$name=$ref->{'name'};
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'count'} ne "") { #number of SNVs
	$where .= " AND h.count >= ? ";
	push(@prepare,$ref->{'count'});
}
if ($ref->{'count2'} ne "") { #number of SNVs
	$where .= " AND h.count <= ? ";
	push(@prepare,$ref->{'count2'});
}


&todaysdate;
&numberofsamples($dbh);

$i=0;
$query = qq#
SELECT 
s.name,
s.saffected,
p.pdescription,
concat(h.chrom,' ',h.start,' ',h.end),
h.count
FROM homozygosity h
INNER JOIN $sampledb.sample          s ON h.idsample=s.idsample
INNER JOIN $sampledb.disease2sample ds ON s.idsample=ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease=d.iddisease
INNER JOIN $sampledb.diseasegroup   dg ON d.iddiseasegroup=dg.iddiseasegroup
INNER JOIN $sampledb.project         p ON s.idproject=p.idproject
WHERE
$allowedprojects
$where
ORDER BY s.name,h.chrom,h.start
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Region',
	'Affected',
	'Project',
	'UCSC',
	'Size (Mb)',
	'n SNVs'
	);

$i=0;

&tableheaderDefault("1000px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) {
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 0) {
			($chrom,$start,$end)=split(/\ /,$row[3]);
			print "<td>";
			$tmp = "<a href='searchPosition.pl?position=$chrom:$start-$end&name=$row[0]'>$row[0]</a>";
			print " $tmp<br>";
			print "</td>";
		}
		elsif ($i == 3) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
			$tmp=($end-$start)/1000000;
			print "<td> $tmp</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


########################################################################
if (($alleleratio) and ($name ne '')) {
my @chromosomes =('chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10','chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19','chr20','chr21','chr22','chrX'),
my $chomosome;

foreach $chomosome (@chromosomes) {
$query = qq#
SELECT
v.start,
x.percentvar
FROM
snv v
INNER JOIN snvsample        x ON v.idsnv    = x.idsnv 
INNER JOIN $sampledb.sample s ON s.idsample = x.idsample
WHERE v.chrom='$chomosome'
AND s.name=?
AND x.snvqual>100
ORDER BY v.start
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($name) || die print "$DBI::errstr";

@pos = ();
@chartdata=();
while (@row = $out->fetchrow_array) {
	push(@pos,$row[0]);
	push(@chartdata,$row[1]);
}

# figure
$chartdata = "";
$chartdata= "['SNV', 'Variants'] ";

$i=0;
foreach $tmp (@chartdata) {
	$chartdata .= ",\n['$pos[$i]',$tmp]";
	$i++;
}
#print "$chartdata";
print "<br>";

print qq(    
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
	$chartdata
        ]);

        var options = {
          title:  '$name $chomosome Fraction of reads carrying the alternative allele',
	  backgroundColor: '#ffffff',
	  vAxis: {title: 'Percent', minValue : 0, maxValue : 100, logScale: false, format:'#.###'},
	  hAxis: {title: 'bp'},
	  lineWidth: 0,
	  pointSize: 4,
	  width:     1200,
	  height:    500
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div$chomosome'));
        chart.draw(data, options);
      }
    </script>
<div id="chart_div$chomosome"></div>
);
}
}

$out->finish;
}
########################################################################
# check searchResultsGenes authorization
########################################################################
sub check_gene_authorization {
my $dbh          = shift;
my $query        = "";
my $out          = "";
my $result       = "";

$query = qq#
SELECT
genesearch
FROM
$exomevcfe.user
WHERE
name = ?
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";
$result = $out->fetchrow_array;

if ($result == 0) {
	print "This feature is not available.";
	exit;
}
$query = qq#
UPDATE
$exomevcfe.user
SET genesearchcount = genesearchcount + 1
WHERE
name = ?
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($user) || die print "$DBI::errstr";

}

########################################################################
# searchResultsGenes searchGeneResults
########################################################################
sub searchResultsGene {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels       = ();
my $out          = "";
my @row          = ();
my $query        = "";
my $avhet        = "";
my $function     = "";
my $functionprint = "";
my $class        = "";
my $classprint   = "";
my $i            = 0;
my $n            = 1;
my $tmp          = "";
my $filter       = "";
my @individuals  = ();
my $individuals  = "";
my $genesymbol   = "";
my $snvqual      = "";
my $mapqual      = "";
my $af           = "";
my $where        = "";
my $where1       = ""; # not for burdentests
my @prepare      = ();
my @prepare1     = (); # not for burdentests
my $confirmed    = "";
my $rating       = "";
my $genotype     = "";
my $inheritance  = "";
my $reason       = "";
my $idsnv        = "";
my %summary      = ();

&check_gene_authorization($dbh);


# Gene symbol exists?
my $wheregenesymbol = " 1= 1 ";
my $genesymboltmp = "";
my @genesymboltmp = ();
#my $genesymbolforsearch = ();
if ($ref->{"g.genesymbol"} ne "") {
	$genesymboltmp = $ref->{"g.genesymbol"};
	$genesymboltmp =~ s/\s+//g;
	(@genesymboltmp) = split (/\,/,$genesymboltmp);
	foreach $genesymboltmp (@genesymboltmp) {
		$query = qq#
		SELECT
		genesymbol
		FROM
		gene
		WHERE
		genesymbol = ?
		#;
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute($genesymboltmp) || die print "$DBI::errstr";
		$genesymbol = $out->fetchrow_array;
		if ($genesymbol eq "") {
			print "Gene symbol $genesymboltmp does not exist.<br>";
			exit;
		}
		else {
			print "Gene symbol $genesymboltmp does exist.<br>";
			if ($where eq "") {
				$where = "(g.genesymbol = ? ";
				push(@prepare,$genesymbol);
			}	
			else {
				$where .= "or g.genesymbol = ? ";
				push(@prepare,$genesymbol);
			}
		}
	}
	$where .= ")";
	#print "where $where<br>";	
}
else {
	print "Gene symbol missing.";
	exit(1);
}
if ($ref->{'s.name'} ne "") {
	$where1 .= " AND s.name = ? ";
	push(@prepare1,$ref->{'s.name'});
}
if ($ref->{'ds.iddisease'} ne "") {
	$where1 .= " AND ds.iddisease = ? ";
	push(@prepare1, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where1 .= " AND s.idcooperation = ? ";
	push(@prepare1, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where1 .= " AND s.idproject = ? ";
	push(@prepare1,$ref->{'idproject'});
}
if ($ref->{'v.freq'} ne "") {
	$where .= " AND v.freq <= ? ";
	push(@prepare,$ref->{'v.freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);

&todaysdate;
&numberofsamples($dbh);
print "Allowed in in-house exomes (n) <= $ref->{'v.freq'}<br>";
print "1000 Genomea AF < $ref->{'af'}<br>";
&printqueryheader($ref,$classprint,$functionprint);

########################## all (heterozygous and homozygous) #####################################################

if ($ref->{mode} ne "homozygous") {
delete($ref->{mode});
			
$i=0;
$query = qq#
SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(s.name separator ' '),
group_concat(s.pedigree separator '<br>'),
group_concat(s.sex separator ' <br>'),
group_concat(d.symbol separator '<br>'),
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
group_concat(c.rating separator '<br>'),
group_concat(c.patho separator '<br>'),
g.genesymbol,
group_concat(DISTINCT g.omim separator ' '),
group_concat(DISTINCT $mgiID separator ' '),
v.class,
replace(v.func,',',' '),
group_concat(x.alleles separator '<br>'),
group_concat(f.fsample separator '<br>'),
v.freq,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
(SELECT group_concat('<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>' separator ' <br>')
FROM hgmd_pro.$hg19_coords h WHERE v.chrom = h.chrom AND v.start = h.pos AND v.refallele=h.ref AND v.allele=h.alt),
(SELECT group_concat( DISTINCT $clinvarlink separator ' <br>')
FROM $coredb.clinvar cv WHERE (v.chrom=cv.chrom and v.start=cv.start AND v.refallele=cv.ref AND v.allele=cv.alt)),
group_concat(DISTINCT $exac_link separator '<br>'),
concat(g.nonsynpergene,' (', g.delpergene,')'),
group_concat(DISTINCT dgv.depth),
(SELECT group_concat(DISTINCT pph.hvar_prediction separator ' <br>')
FROM $coredb.pph3 pph WHERE (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
),
(SELECT group_concat(DISTINCT pph.hvar_prob separator ' <br>')
FROM $coredb.pph3 pph WHERE (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
),
(SELECT group_concat(DISTINCT sift.score )
FROM $coredb.sift sift WHERE (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
),
(SELECT group_concat(DISTINCT cadd.phred )
FROM $coredb.cadd cadd WHERE (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
),
group_concat(x.filter separator '<br>'),
group_concat(x.snvqual separator '<br>'),
group_concat(x.gtqual separator '<br>'),
group_concat(x.mapqual separator '<br>'),
group_concat(x.coverage separator '<br>'),
group_concat(x.percentvar separator '<br>'),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
group_concat(DISTINCT v.idsnv separator ' <br>')
FROM
snv v 
INNER JOIN snvsample                   x ON v.idsnv = x.idsnv 
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample            s ON s.idsample = x.idsample
INNER JOIN $sampledb.disease2sample   ds ON s.idsample=ds.idsample
INNER JOIN $sampledb.disease           d ON ds.iddisease = d.iddisease
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup)
LEFT  JOIN snvgene                     y ON v.idsnv = y.idsnv
LEFT  JOIN gene                        g ON g.idgene = y.idgene
LEFT  JOIN $sampledb.mouse            mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.evs               evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores        exac ON (g.genesymbol=exac.gene)
LEFT  JOIN $exomevcfe.comment          c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
$where
$where1
$function
$class
GROUP BY
v.idsnv
ORDER BY
v.start
LIMIT 5000
#;
#print "query = $query<br>";
#print "where = $where<br>";
#print "where1 = $where1<br>";
#print "prepare = @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,@prepare1) || die print "$DBI::errstr";

# Now print table
(@labels) = &resultlabels();
$labels[18] = "Exomes";

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $damaging     = 0;
my $omimmode     = "";
my $omimdiseases = "";
my $program      = "";
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	$idsnv     = $row[-1];
	pop(@row); #delete checked
	# summary table
	if ($row[12] =~ /missense/)   {$summary{missense}++;}
	if ($row[12] =~ /nonsense/)   {$summary{nonsense}++;}
	if ($row[12] =~ /indel/)      {$summary{indel}++;}
	if ($row[12] =~ /splice/)     {$summary{splice}++;}
	if ($row[12] =~ /frameshift/) {$summary{frameshift}++;}
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 1) {
			$tmp=&igvlink($dbh,$row[$i],$row[5]);
			print "<td align=\"center\"> $tmp</td>";
		}
		elsif ($i == 5) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 9) {
			($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
			print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
		}
		elsif ($i == 11) {
			($tmp)=&vcf2mutalyzer($dbh,$idsnv);
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==24) or ($i==25)) {
			if ($i==24) {$program = 'polyphen2';}
			if ($i==25) {$program = 'sift';}
			$damaging=&damaging($program,$row[$i]);
			if ($damaging==1) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 31) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		elsif ($i == 33) { # transcripts
			print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";
#&tablescript("9,10","");

# print summary table

print "<br><table border=0 cellpadding=2>";
print "<tr><th>Function</th><th>n</th></tr>";
print "<tr><td>missense</td><td align='right'>$summary{missense}</td></tr>";
print "<tr><td>nonsense</td><td align='right'>$summary{nonsense}</td></tr>";
print "<tr><td>indel</td><td align='right'>$summary{indel}</td></tr>";
print "<tr><td>splice</td><td align='right'>$summary{splice}</td></tr>";
print "<tr><td>frameshift</td><td align='right'>$summary{frameshift}</td></tr>";
print "</table>";

} 
##########################  compound heterozygous/homozygous #####################

else {
delete($ref->{mode});
			
$i=0;
$query = qq#
SELECT
group_concat(DISTINCT v.idsnv ORDER BY v.chrom, v.start),
group_concat(DISTINCT s.idsample)
FROM
snv v 
INNER JOIN snvsample                   x ON v.idsnv = x.idsnv 
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample            s ON s.idsample = x.idsample
INNER JOIN $sampledb.disease2sample   ds ON s.idsample=ds.idsample
INNER JOIN $sampledb.disease           d ON ds.iddisease = d.iddisease
LEFT  JOIN snvgene                     y ON v.idsnv = y.idsnv
LEFT  JOIN gene                        g ON g.idgene = y.idgene
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv)
LEFT  JOIN hgmd_pro.$hg19_coords       h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.pph3              pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift             sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd             cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs               evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
WHERE
$where
$where1
$function
$class
GROUP BY s.idsample,g.genesymbol
HAVING ( count(DISTINCT v.chrom,v.start) >= 2
OR max(x.alleles) >= 2 )
ORDER BY
v.start
LIMIT 5000
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,@prepare1) || die print "$DBI::errstr";

# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
my $damaging     = 0;
my $omimmode     = "";
my $omimdiseases = "";
my $program      = "";
my @row1         = ();
my @idsnv        = ();
my $idsnv        = "";
my $idsample     = "";
my $nrows        = 0;

while (@row1 = $out->fetchrow_array) {
	(@idsnv)=split(/\,/,$row1[0]);
	$nrows = @idsnv;
	$idsample=$row1[1];
	foreach $idsnv (@idsnv) {
		$i=0;
		(@row)=&singleRecessiveMain($dbh,$idsnv,$idsample,$ref->{"g.genesymbol"});
		pop(@row);
		pop(@row);
		pop(@row);		
		pop(@row);		
		pop(@row);		
		foreach (@row) {
			if (!defined($row[$i])) {$row[$i] = "";}
			if ($i == 0) {
				print "<td align=\"center\">$n</td>";
				$n++;
			}
			if ($i == 5) {
				$tmp=&ucsclink2($row[$i]);
				print "<td align=\"center\"> $tmp</td>";
			}
			elsif ($i == 9) {
				($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
				print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
			}
			elsif ($i == 11) {
				($tmp)=&vcf2mutalyzer($dbh,$idsnv);
				print "<td align=\"center\">$tmp</td>";
			}
			elsif ($i == 25) { # cnv exomedetph
				$tmp=$row[$i];
				if ($row[8] eq "cnv") {
					$tmp=$tmp/100;
				}
				print "<td>$tmp</td>";
			}
			elsif (($i==24) or ($i==25)) {
				if ($i==24) {$program = 'polyphen2';}
				if ($i==25) {$program = 'sift';}
				$damaging=&damaging($program,$row[$i]);
				if ($damaging==1) {
					print "<td $warningtdbg>$row[$i]</td>";
				}
				else {
					print "<td> $row[$i]</td>";
				}
			}
			elsif ($i == 31) { # cnv exomedetph
				$tmp=$row[$i];
				if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
				}
				print "<td>$tmp</td>";
			}
			elsif ($i == 33) { # transcripts
				print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
			}
			else {
				print "<td align=\"center\"> $row[$i]</td>";
			}
			$i++;
		}
		print "</tr>\n";
	} # foreach @idsnv
	$n++;
}
print "</tbody></table>";
#&tablescript;

}
########################################################################
#burden statistics
#determine number exomes

if ($burdentests == 1) {

print "<br><br>All samples";
$query=qq#
SELECT
dg.name,
d.name,
s.saffected,
count(DISTINCT s.idsample)
FROM $sampledb.sample s
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample
INNER JOIN $sampledb.disease           d ON ds.iddisease     = d.iddisease
INNER JOIN $sampledb.diseasegroup     dg ON d.iddiseasegroup = dg.iddiseasegroup
INNER JOIN variantstat                vs ON s.idsample       = vs.idsample
GROUP BY dg.iddiseasegroup,d.iddisease,s.saffected
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

my $exomes    = 0;
my %exomes    = ();
while (@row = $out->fetchrow_array) {
	$exomes{$row[0]}{$row[1]}{$row[2]}=$row[3];
}

$query=qq#
SELECT
dg.name as diseasegroup,
i.name as disease,
s.saffected as affected,
COUNT(DISTINCT x.idsnv) as nvariants,
COUNT(DISTINCT s.idsample,x.idsnv) as nalleles
FROM
$sampledb.sample                       s
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample
INNER JOIN $sampledb.disease           i ON ds.iddisease     = i.iddisease
INNER JOIN $sampledb.diseasegroup     dg ON i.iddiseasegroup = dg.iddiseasegroup
INNER JOIN snvsample                   x ON s.idsample       = x.idsample
INNER JOIN snv                         v ON v.idsnv          = x.idsnv
INNER JOIN snvgene                     y ON v.idsnv          = y.idsnv
INNER JOIN gene                        g ON g.idgene         = y.idgene
LEFT  JOIN $coredb.evs               evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
WHERE 
$where
$function
$class
GROUP BY dg.iddiseasegroup,i.iddisease,s.saffected
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";
my %variants    = ();
my %samples     = ();
while (@row = $out->fetchrow_array) {
		$variants{$row[0]}{$row[1]}{$row[2]}=$row[3];
		$samples{$row[0]}{$row[1]}{$row[2]}=$row[4];
}
@labels	= (
	'n',
	'Disease group',
	'Disease',
	'Affected',
	'Exomes',
	'n variants',
	'n samples',
	'% variants',
	'% samples',
	);
$n = 1;

&tableheaderDefault_new("table02","1000px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";
my $diseasegroup = "";
my $disease      = "";
my $affected     = "";
foreach $diseasegroup (sort keys %exomes) {
	foreach $disease (sort keys %{$exomes{$diseasegroup}}) {
		foreach $affected (sort keys %{$exomes{$diseasegroup}{$disease}}) {
			print "<tr>";
			print "<td>$n</td>";
			print "<td>$diseasegroup</td>";
			print "<td>$disease</td>";
			print "<td>$affected</td>";
			print "<td>$exomes{$diseasegroup}{$disease}{$affected}</td>";
			print "<td>$variants{$diseasegroup}{$disease}{$affected}</td>";
			print "<td>$samples{$diseasegroup}{$disease}{$affected}</td>";
			$tmp=sprintf("%.3f",$variants{$diseasegroup}{$disease}{$affected}/$exomes{$diseasegroup}{$disease}{$affected});
			if ($tmp == 0) {
				$tmp="";
			}
			print "<td>$tmp</td>";
			$tmp=sprintf("%.3f",$samples{$diseasegroup}{$disease}{$affected}/$exomes{$diseasegroup}{$disease}{$affected});
			if ($tmp == 0) {
				$tmp="";
			}
			print "<td>$tmp</td>";
			print "</tr>";
			$n++;
		}
	}
}
print "</tbody></table></div>";

#determine number exomes
print "<br><br>Without child of trios";
$query=qq#
SELECT
dg.name,
d.name,
s.saffected,
count(DISTINCT s.idsample)
FROM $sampledb.sample s
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample
INNER JOIN $sampledb.disease           d ON ds.iddisease     = d.iddisease
INNER JOIN $sampledb.diseasegroup     dg ON d.iddiseasegroup = dg.iddiseasegroup
INNER JOIN variantstat                vs ON s.idsample       = vs.idsample
WHERE (s.mother = "" OR ISNULL(s.mother))
AND   (s.father = "" OR ISNULL(s.father))
GROUP BY dg.iddiseasegroup,d.iddisease,s.saffected
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

$exomes    = 0;
%exomes    = ();
while (@row = $out->fetchrow_array) {
	$exomes{$row[0]}{$row[1]}{$row[2]}=$row[3];
}

$query=qq#
SELECT
dg.name as diseasegroup,
i.name as disease,
s.saffected as affected,
COUNT(DISTINCT x.idsnv) as nvariants,
COUNT(DISTINCT s.idsample,x.idsnv) as nalleles
FROM
$sampledb.sample                       s
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample
INNER JOIN $sampledb.disease           i ON ds.iddisease     = i.iddisease
INNER JOIN $sampledb.diseasegroup     dg ON i.iddiseasegroup = dg.iddiseasegroup
INNER JOIN snvsample                   x ON s.idsample       = x.idsample
INNER JOIN snv                         v ON v.idsnv          = x.idsnv
INNER JOIN snvgene                     y ON v.idsnv          = y.idsnv
INNER JOIN gene                        g ON g.idgene         = y.idgene
WHERE 
$where
$function
$class
AND (s.mother = "" OR ISNULL(s.mother))
AND (s.father = "" OR ISNULL(s.father))
GROUP BY dg.iddiseasegroup,i.iddisease,s.saffected
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";
%variants    = ();
%samples     = ();
while (@row = $out->fetchrow_array) {
		$variants{$row[0]}{$row[1]}{$row[2]}=$row[3];
		$samples{$row[0]}{$row[1]}{$row[2]}=$row[4];
}
@labels	= (
	'n',
	'Disease group',
	'Disease',
	'Affected',
	'Exomes',
	'n variants',
	'n samples',
	'% variants',
	'% samples',
	);
$n = 1;
&tableheaderDefault_new("table03","1000px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";
$diseasegroup = "";
$disease      = "";
$affected     = "";
foreach $diseasegroup (sort keys %exomes) {
	foreach $disease (sort keys %{$exomes{$diseasegroup}}) {
		foreach $affected (sort keys %{$exomes{$diseasegroup}{$disease}}) {
			print "<tr>";
			print "<td>$n</td>";
			print "<td>$diseasegroup</td>";
			print "<td>$disease</td>";
			print "<td>$affected</td>";
			print "<td>$exomes{$diseasegroup}{$disease}{$affected}</td>";
			print "<td>$variants{$diseasegroup}{$disease}{$affected}</td>";
			print "<td>$samples{$diseasegroup}{$disease}{$affected}</td>";
			$tmp=sprintf("%.3f",$variants{$diseasegroup}{$disease}{$affected}/$exomes{$diseasegroup}{$disease}{$affected});
			if ($tmp == 0) {
				$tmp="";
			}
			print "<td>$tmp</td>";
			$tmp=sprintf("%.3f",$samples{$diseasegroup}{$disease}{$affected}/$exomes{$diseasegroup}{$disease}{$affected});
			if ($tmp == 0) {
				$tmp="";
			}
			print "<td>$tmp</td>";
			print "</tr>";
			$n++;
		}
	}
}
print "</tbody></table></div>";
}
########################################################################
$out->finish;
}
########################################################################
#  singleRecessive
########################################################################
sub singleRecessive {
my $dbh      = shift;
my $idsnv    = shift;
my $idsample = shift;
my $gene     = shift;
my $query    = "";
my $out      = "";
my @prepare  = ();
my @row      = ();
push(@prepare,$idsnv);
push(@prepare,$idsample);
push(@prepare,$gene);


$query = qq#
SELECT
group_concat(DISTINCT '<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>' separator '<br>'),
group_concat(DISTINCT v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele separator '|'),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree separator '<br>'),
group_concat(DISTINCT i.symbol separator '<br>'),
g.genesymbol,
concat(g.nonsynpergene,' (', g.delpergene,')'),
concat($omimlink),
group_concat(DISTINCT v.class separator '<br>'),
group_concat(DISTINCT v.func separator '<br>'),
group_concat(DISTINCT pph.hvar_prediction,'(',pph.hvar_prob,')' separator '<br>'),
group_concat(DISTINCT sift.score  separator '<br>'),
group_concat(DISTINCT cadd.phred  separator '<br>'),
group_concat(DISTINCT f.fsampleall separator '<br>'),
group_concat(DISTINCT x.alleles separator '<br>'),
group_concat(DISTINCT $rssnplink separator '<br>'),
group_concat(DISTINCT avhet separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>' separator '<br>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT af separator '<br>'),
group_concat(DISTINCT $exac_ae_link separator '<br>'),
group_concat(DISTINCT $exac_aa_link separator '<br>'),
group_concat(DISTINCT x.snvqual separator '<br>'),
group_concat(DISTINCT x.gtqual separator '<br>'),
group_concat(DISTINCT x.mapqual separator '<br>'),
group_concat(DISTINCT x.coverage separator '<br>'),
group_concat(DISTINCT x.percentvar separator '<br>'),
group_concat(DISTINCT x.filter separator '<br>'),
group_concat(DISTINCT v.transcript separator '<br>')
FROM
snv v 
INNER JOIN snvsample                    x ON (v.idsnv = x.idsnv) 
INNER JOIN $sampledb.sample             s ON (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample    ds ON (s.idsample=ds.idsample)
INNER JOIN $sampledb.disease            i ON (ds.iddisease = i.iddisease)
LEFT  JOIN snv2diseasegroup             f ON (v.idsnv = f.fidsnv) 
LEFT  JOIN snvgene                      y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                         g ON (g.idgene = y.idgene)
LEFT  JOIN hgmd_pro.$hg19_coords        h ON (v.chrom = h.chrom  and v.start = h.pos    and v.refallele=h.ref         and v.allele=h.alt)
LEFT  JOIN $coredb.pph3               pph ON (v.chrom=pph.chrom  and v.start=pph.start  and v.refallele=pph.ref       and v.allele=pph.alt)
LEFT  JOIN $coredb.sift              sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref      and v.allele=sift.alt)
LEFT  JOIN $coredb.clinvar             cv ON (v.chrom=cv.chrom   and v.start=cv.start   and v.refallele=cv.ref        and v.allele=cv.alt)
LEFT  JOIN $coredb.cadd              cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref      and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs                evs ON (v.chrom=evs.chrom  and v.start=evs.start  and v.refallele=evs.refallele and v.allele=evs.allele)
WHERE
v.idsnv = ?
AND s.idsample = ?
AND g.genesymbol = ?
#;

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";
@row = $out->fetchrow_array;
return(@row);
}
########################################################################
# searchResultsOmim Comment search comment
########################################################################
sub searchResultsOmim {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

if ($ref->{version} eq "new") {
	delete($ref->{version});
	print "New version<br>";
	&searchResultsOmimNew($dbh,$ref);
}
else {
	delete($ref->{version});
	print "Old version<br>";
	&searchResultsOmimOld($dbh,$ref);
}

}
########################################################################
# searchResultsOmim searchOmimResults SOLR
########################################################################
sub searchResultsOmimNew {
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my @row2      = ();
my $query     = "";
my $avhet     = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my $filter    = "";
my @individuals = ();
my $individuals = "";
my $genesymbol  = "";
my @prepare     = ();
my @preparegenes = ();
my $snvqual     = "";
my $mapqual     = "";
my $af          = "";
my $where       = "";
my $wheregenes  = "";
my @omim        = {};
my $omim        = $ref->{"omim"} ;
my $synopsis    = $ref->{"mode"};
my $solrres     = "";
my %solrresh    = ();
my $idomim      = "";
my $allowedprojects = &allowedprojects("s.");
my $idsample    = "";
my $prefix      = "";
my $mode        = "";
my %ar          = ();
my $ar          = $ref->{ar};
if ($ar eq "ar") {
	$ar = 2;
}
else {
	$ar = 0;
}

if (($ref->{'s.name'} eq "") and ($ref->{'ds.iddisease'} eq "") and
($ref->{'s.idcooperation'} eq "") and ($ref->{'idproject'} eq "")) {
	print "No sample ID, disease, cooperation or project.";
	exit(1);
}
if ($omim ne "") {  # omim = omim search phrase
	$prefix = $ref->{'mode'}; #mode = full-text, title, synopsis ....
	$solrres = &querySolr($omim,$prefix);
	
	if(ref($solrres) eq "HASH"){
		# empty or omim ids
    		%solrresh = %$solrres;
	}
	else {
		# suggestion is string
		print "$solrres<br>";
	}
}
else {
	print "No OMIM phrase.";
	exit(1);
}
$i=0;

if ($ref->{'s.name'} ne "") {
	$idsample = &getIdsampleByName($dbh,$ref->{'s.name'});
	$where .= " AND s.idsample = ? ";
	push(@prepare,$idsample);
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'v.freq'} ne "") {
	$where .= " AND v.freq <= ? ";
	push(@prepare,$ref->{'v.freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);


# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);

print "Search phrase: $omim<br>";
&todaysdate;
&numberofsamples($dbh);
print "Allowed in in-house Exomes < $ref->{'v.freq'}<br>";
&printqueryheader($ref,$classprint,$functionprint);
$where .= " AND g.omim = ? ";

$query = qq#
SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT s.name separator ' '),
group_concat(DISTINCT s.pedigree separator ' '),
s.sex,
d.symbol,
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
c.rating,
c.patho,
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(DISTINCT g.omim separator ' '),
group_concat(distinct $mgiID separator ' '),
v.class,
replace(v.func,',',' '),
group_concat(DISTINCT x.alleles separator '<br>'),
f.fsample,
f.samplecontrols,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT x.filter separator '<br>'),
group_concat(DISTINCT x.snvqual separator '<br>'),
group_concat(DISTINCT x.gtqual separator '<br>'),
group_concat(DISTINCT x.mapqual separator '<br>'),
group_concat(DISTINCT x.coverage separator '<br>'),
group_concat(DISTINCT x.percentvar separator '<br>'),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
v.idsnv
FROM
snv v 
INNER JOIN snvsample                   x ON (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample            s ON (s.idsample = x.idsample)
LEFT  JOIN $sampledb.disease2sample   ds ON (s.idsample=ds.idsample)
LEFT  JOIN $sampledb.disease           d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup)
LEFT  JOIN snvgene                     y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                        g ON (g.idgene = y.idgene)
LEFT  JOIN disease2gene               dg on (g.idgene = dg.idgene)
LEFT  JOIN $sampledb.mouse            mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.pph3              pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift             sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd             cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs               evs ON (v.chrom=evs.chrom AND v.start=evs.start AND v.refallele=evs.refallele AND v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores        exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords       h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar            cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment          c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
$allowedprojects
$where
$function
$class
GROUP BY
s.idsample,v.idsnv,g.idgene
ORDER BY
v.chrom,v.start
LIMIT 5000
#;
#print "$query<br>";
#print "query = $where<br>";
#print "query = @prepare $idomim<br>";

# foreach omim gene id returned by solr
foreach $idomim (sort {$solrresh{$b} <=> $solrresh{$a} } keys %solrresh) { #sort according score
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@prepare,$idomim) || die print "$DBI::errstr";
	#print "$idomim<br>";
	while (@row = $out->fetchrow_array) {
		push(@row,$solrresh{$idomim}); #add score
		push(@row2,[@row]);
		# if mode eq ar
		($tmp,$mode)=&omim($dbh,$row[9]); # g.omim=$row[9]
		$mode =~ s/\s+//g;	
		$mode =~ s/<br>//g;	
		#print "$row[9] $row[13] '$mode'<br>"; # omim alleles mode
		if ($mode eq "ar") { # check if autosomal recessive, i.e. if omim number occurs twice !!!! not prepared for multiple samples
			#print "$row[9] $row[13] $mode<br>";
			$ar{$idomim} += $row[13]; #variant allele=row[13]
			#print "asdf $ar{$idomim}<br>";
		}
		else {
			$ar{$idomim} = 2; #variant allele=row[13] # if not ar mode all results are set to '2 alleles' 
		}
	}
} #foreach gene returned by solr

# Now print table
(@labels) = &resultlabels();
$labels[11] = "Score"; # replace column header 'Mode' by 'Score'

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $program      = "";
my $damaging     = "";
my $omimmode     = "";
my $omimdiseases = "";
my $aref         = "";
my $score        = "";
my $idsnv        = "";
for  $aref (@row2) { 
	@row=@{$aref};
	$score    = $row[-1];
	$score=sprintf("%.2f",$score);
	pop(@row);
	$idsnv    = $row[-1];
	pop(@row);
	#push(@row,$score);
	if ($ar{$row[9]} >= $ar) {  # !!!!!!! grouped by v.idsnv and g.idgene to avoid rare cases where query returns rows with more than a single omim gene id
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 1) {
			$tmp=&igvlink($dbh,$row[$i],$row[5]);
			print qq#
			<td style='white-space:nowrap;'>
			<div class="dropdown">
			$tmp&nbsp;&nbsp;
			<a href="comment.pl?idsnv=$idsnv&idsample=$idsample&reason=omim">
			<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
			</a>
			</div>
			</td>
			#;
		}
		elsif ($i == 5) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 9) {
			($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
			print "<td $class align=\"center\">$tmp</td><td align=\"center\">$score</td><td style='min-width:350px'>$omimdiseases</td>\n";
		}
		elsif ($i == 11) {
			($tmp)=&vcf2mutalyzer($dbh,$idsnv);
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==24) or ($i==25)) {
			if ($i==24) {$program = 'polyphen2';}
			if ($i==25) {$program = 'sift';}
			$damaging=&damaging($program,$row[$i]);
			if ($damaging==1) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 31) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		elsif ($i == 33) { # cnv exomedetph
			print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
	} #if ar
}
print "</tbody></table></div>";


print "<br>";
$query = qq#
SELECT DISTINCT 
g.omim,
g.genesymbol,
o.omimdisease,
o.disease
FROM gene g
INNER JOIN $sampledb.omim o on (g.omim = o.omimgene)
WHERE g.omim = ?
#;

@row2 = ();
foreach $idomim (sort {$solrresh{$a} <=> $solrresh{$b} } keys %solrresh) {
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($idomim) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@row2,[@row]);
	}
}
print "OMIM genes checked: ";
@labels	= (
	'n',
	'OMIM gene',
	'Gene- symbol',
	'Omim disease',
	'Disease',
	);
$n = 1;
print "<table border='0'";
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

for  $aref (@row2) { 
	@row=@{$aref};
	print "<tr>";
	$i = 0;
	foreach (@row) {
		if ($i == 0) {
			($tmp)=&omim($dbh,$row[0]);
			print "<td>$n</td>";
			print "<td>$tmp</td>";
		}
		else {
			print "<td>$row[$i]</td>";
		}
		$i++;
	}
$n++;
print "</tr>";
}
print "<table><br>";

#$out->finish;
}
########################################################################
# searchResultsOmim searchOmimResults
########################################################################
sub searchResultsOmimOld {
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $avhet     = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my $filter    = "";
my @individuals = ();
my $individuals = "";
my $genesymbol  = "";
my @prepare     = ();
my @preparegenes = ();
my $snvqual     = "";
my $mapqual     = "";
my $af          = "";
my $where       = "";
my $wheregenes  = "";
my @omim        = {};
my $omim        = $ref->{"omim"} ;
my $synopsis    = $ref->{"mode"};
my $searchfield = "";
my $allowedprojects = &allowedprojects("s.");

if (($ref->{'s.name'} eq "") and ($ref->{'ds.iddisease'} eq "") and
($ref->{'s.idcooperation'} eq "") and ($ref->{'idproject'} eq "")) {
	print "No sample ID, disease, cooperation or project.";
	exit(1);
}
if ($omim ne "") {
	print "Search phrase: $omim<br>";
	if ($synopsis == 1) {
		print "Search in synopsis<br>";
		$searchfield = "omim_cs";
	}
	else {
		print "Search in full text<br>";
		$searchfield = "omim_fulltext";
	}
	@omim = split(/AND/,$omim);
	foreach $tmp (@omim) {
		$tmp=&trim($tmp);
		if ($i>=1) {
			$wheregenes .= " AND ";
		}
		$where .= " AND ";
		$where .= "  replace(oo.$searchfield,'\n',' ') like ? ";
		$wheregenes .= "  replace(oo.$searchfield,'\n',' ') like ? ";
		push(@prepare,"%$tmp%");
		push(@preparegenes,"%$tmp%");
		$i++;
	}
}
else {
	print "No OMIM phrase.";
	exit(1);
}
$i=0;

if ($ref->{'s.name'} ne "") {
	$where .= " AND s.name = ? ";
	push(@prepare,$ref->{'s.name'});
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'v.freq'} ne "") {
	$where .= " AND v.freq <= ? ";
	push(@prepare,$ref->{'v.freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);


# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);

&todaysdate;
&numberofsamples($dbh);
print "Allowed in in-house Exomes < $ref->{'v.freq'}<br>";
print "1000 Genomea AF < $ref->{'af'}<br>";
&printqueryheader($ref,$classprint,$functionprint);

			
$i=0;
$query = qq#
SELECT 
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT s.name separator ' '),
group_concat(DISTINCT s.pedigree separator '<br>'),
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
group_concat(DISTINCT $genelink separator '<br>'),
concat(g.nonsynpergene,' (', g.delpergene,')'),
concat(g.omim),
v.class,
v.func,
(SELECT group_concat(DISTINCT  pph.hvar_prediction,'(',pph.hvar_prob,')' separator '<br>')
FROM $coredb.pph3 pph WHERE (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
),
(SELECT group_concat(DISTINCT  sift.score )
FROM $coredb.sift sift WHERE (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
),
group_concat(DISTINCT cadd.phred separator ' '),
(SELECT DISTINCT f.fsampleall FROM snv2diseasegroup f WHERE v.idsnv=f.fidsnv),
group_concat(DISTINCT x.alleles separator '<br>'),
concat($rssnplink),avhet,
(SELECT group_concat('<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>' separator '<br>')
FROM hgmd_pro.$hg19_coords h WHERE v.chrom = h.chrom AND v.start = h.pos AND v.refallele=h.ref AND v.allele=h.alt),
group_concat(DISTINCT $clinvarlink separator '<br>'),
af,
group_concat(DISTINCT $exac_ae_link separator '<br>'),
group_concat(DISTINCT $exac_aa_link separator '<br>'),
group_concat(DISTINCT x.snvqual separator '<br>'),
group_concat(DISTINCT x.gtqual separator '<br>'),
group_concat(DISTINCT x.mapqual separator '<br>'),
group_concat(DISTINCT x.coverage separator '<br>'),
group_concat(DISTINCT x.percentvar separator '<br>'),
group_concat(DISTINCT x.filter separator '<br>'),
v.transcript,
v.idsnv
FROM
snv v 
INNER JOIN snvsample                 x ON (v.idsnv = x.idsnv) 
INNER JOIN $sampledb.sample          s ON (s.idsample = x.idsample)
LEFT  JOIN $sampledb.disease2sample ds ON (s.idsample=ds.idsample)
LEFT  JOIN $sampledb.disease         i ON (ds.iddisease = i.iddisease)
LEFT  JOIN snvgene                   y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                      g ON (g.idgene = y.idgene)
LEFT  JOIN $sampledb.omim            o ON (g.omim = o.omimgene)
LEFT  JOIN $sampledb.omimfulltext   oo ON (o.omimdisease = oo.omim_id)
LEFT  JOIN $coredb.cadd           cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.clinvar          cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $coredb.evs             evs ON (v.chrom=evs.chrom AND v.start=evs.start AND v.refallele=evs.refallele AND v.allele=evs.allele)
WHERE
$allowedprojects
$where
$function
$class
GROUP BY
v.idsnv
ORDER BY
v.chrom,v.start
LIMIT 5000
#;
#print "$query<br>";
#print "query = $where<br>";
#print "query = @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'idsnv',
	'DNA ID',
	'Pedigree',
	'Chr',
	'Gene',
	'Non syn/ Gene',
	'Omim',
	'Mode',
	'Class',
	'Function',
	'pph2',
	'Sift',
	'CADD',
	'Count',
	'Variant alleles',
	"$dbsnp",
	'av Het',
	'HGMD',
	'ClinVar',
	'1000 genomes AF',
	'gnomAD ea',
	'gnomAD aa',
	'SNV Qual',
	'Geno- type Qual',
	'Map Qual',
	'Depth',
	'%Var',
	'Filter',
	'UCSC Transcripts'
	);

$i=0;

&tableheaderDefault();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $damaging = 0;
my $program  = "";
my $mode     = "";
while (@row = $out->fetchrow_array) {
	my $idsnv    = $row[-1];
	pop(@row);
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 3) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		# jedesmal aendern
		elsif ($i == 6) {
			($tmp,$mode)=&omim($dbh,$row[$i]);
			print "<td>$tmp</td>";
			print "<td>$mode</td>";
		}
		elsif ($i == 1) {
			$tmp=&igvlink($dbh,$row[$i],$row[3]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 7) {
			($tmp)=&vcf2mutalyzer($dbh,$idsnv);
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==9) or ($i==10)) {
			if ($i==9) {$program = 'polyphen2';}
			if ($i==10) {$program = 'sift';}
			$tmp=$row[$i];
			if ($i==9) {
				$tmp=~s/benign//g;
				$tmp=~s/probably damaging//g;
				$tmp=~s/possibly damaging//g;
				$tmp=~s/\)//g;
				$tmp=~s/\(//g;
				$tmp=~s/<br>/ /g;
			}
			$damaging=&damaging($program,$tmp);
			if ($damaging==1) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 24) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[7] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

print "<br>";
$query = qq#
SELECT DISTINCT 
g.omim,
g.genesymbol,
o.omimdisease,
o.disease
FROM gene g
INNER JOIN $sampledb.omim            o on (g.omim = o.omimgene)
INNER JOIN $sampledb.omimfulltext   oo on (o.omimdisease = oo.omim_id)
WHERE $wheregenes
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@preparegenes) || die print "$DBI::errstr";
print "OMIM genes checked: ";
@labels	= (
	'n',
	'OMIM gene',
	'Gene- symbol',
	'Omim disease',
	'Disease',
	);
$n = 1;
print "<table border='0'";
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i = 0;
	foreach (@row) {
		if ($i == 0) {
			($tmp)=&omim($dbh,$row[0]);
			print "<td>$n</td>";
			print "<td>$tmp</td>";
		}
		else {
			print "<td>$row[$i]</td>";
		}
		$i++;
	}
	$n++;
	print "</tr>";
}
print "<table><br>";

$out->finish;
}
########################################################################
# importHPO 
########################################################################
sub importHPO {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});

my $samplename = $ref->{samplename};
#$samplename    =~ s/\s+//g;
$samplename = HTML::Entities::encode($samplename);

my $hpo        = $ref->{phenotype};
#my @tmp = unpack("C*",$hpo);
#print "<pre>@tmp<br></pre>";
my (@hpo)      = split(/\r\n/,$hpo);
my $symptom    = "";
my $query      = "";
my $allowedprojects = &allowedprojects();

# samplename empty
if ($samplename eq "") {
	print "Sample ID empty.<br>";
	exit(1);
}

# check samplename and rights
$query = "
SELECT idsample FROM $sampledb.sample 
WHERE name = ? 
AND $allowedprojects
";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($samplename) || die print "$DBI::errstr";
my $idsample = $out->fetchrow_array;
if ($idsample eq "") {
	print "Wrong SampleID or no rights to access this sample.";
	exit(1);
}

print "Imported:<br>$samplename<br>";

# set old entries to active = 0
$query = "UPDATE $exomevcfe.hpo SET active=0 WHERE idsample = ?";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsample) || die print "$DBI::errstr";

# new insert
foreach $hpo (@hpo) {
	($hpo,$symptom) = split(/\s+/,$hpo,2);
	$hpo =~ s/\s+//g;
	$symptom =~ s/\^s+//;
	$symptom =~ s/\s+$//;
	$query = "
	INSERT INTO $exomevcfe.hpo (idsample, samplename, hpo, symptoms, lastuser) VALUES (?, ?, ?, ?, ?)
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($idsample,$samplename,$hpo,$symptom,$user) || die print "$DBI::errstr";
	print "$hpo, $symptom<br>";
}

}
########################################################################
# showHPO by showHPO.pl
########################################################################
sub showHPO {
my $self         = shift;
my $dbh          = shift;
my $idsample     = shift;

my $i         = 0;
my $n         = 1;
my @labels    = ();
my $out       = "";
my @row       = ();
my @row2      = ();
my $query     = "";
my $allowedprojects = &allowedprojects("s.");

$query = "
SELECT he.samplename,he.hpo,h.name,he.symptoms,he.active,he.lastuser,he.dateentered 
FROM $sampledb.sample s
INNER JOIN $exomevcfe.hpo he ON s.idsample=he.idsample
INNER JOIN $sampledb.hpo   h ON he.hpo=h.id
WHERE he.idsample = ?
AND $allowedprojects
ORDER BY he.active,he.dateentered,he.hpo
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsample) || die print "$DBI::errstr";

@labels	= (
	'n',
	'ID',
	'HPO',
	'Name',
	'Symptoms',
	'Active',
	'User',
	'Date'
	);

&tableheaderDefault("1000px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i = 0;
	foreach (@row) {
		if ($i == 0) {
			print "<td>$n</td>";
			print "<td>$row[$i]</td>";
		}
		else {
			print "<td>$row[$i]</td>";
		}
		$i++;
	}
	$n++;
	print "</tr>";
}
print "</tbody></table></div>";

}
########################################################################
# searchResultsHPO searchHPOResults
########################################################################
sub searchResultsHPO {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

use LWP::Simple;

my @labels    = ();
my $out       = "";
my @row       = ();
my @row2      = ();
my $query     = "";
my $avhet     = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $i         = 0;
my $n         = 1;
my $tmp         = "";
my @tmp         = ();
my %tmp         = ();
my $filter      = "";
my $url         = "";
my $phenomizer  = "";
my @individual  = ();
my $individual  = "";
my $genesymbol  = "";
my $score       = "";
my $hits        = "";
my $maxic       = "";
my %genesymbol  = ();
my %hits        = ();
my %maxic       = ();
my @genesymbol  = ();
my @prepare     = ();
my @hpoprepare  = ();
my @preparegenes = ();
my $snvqual     = "";
my $mapqual     = "";
my $af          = "";
my $where       = "";
my $hpowhere    = "";
my $wheregenes  = "";
my @omim        = {};
my $hpo         = $ref->{"hpo"} ;
my @hpo         = ();
my $allowedprojects = &allowedprojects("s.");
my $idsample    = "";
my $prefix      = "";
my $mode        = "";
my %ar          = ();
my $ar          = $ref->{ar};
if ($ar eq "ar") {
	$ar = 2;
}
else {
	$ar = 0;
}


my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


if (($ref->{'s.name'} eq "") and ($ref->{'ds.iddisease'} eq "") and
($ref->{'s.idcooperation'} eq "") and ($ref->{'idproject'} eq "")) {
	print "No sample ID, disease, cooperation or project.";
	exit(1);
}

if ($hpo ne "") {
	chomp($hpo);
	$hpo   =~ s/\,/ /g;
	$hpo   =~ s/\s+/\,/g;
	@hpo = split(/,/,$hpo);
	foreach $hpo (@hpo) {
		if ($hpowhere ne "") {
			$hpowhere .= " OR ";
		}
		$hpowhere .= " ha.id = ? ";
		push(@hpoprepare,$hpo);
	}
	$query = "
	SELECT hg.gene,max(h.ic)
	FROM $sampledb.hpoancestors ha
	INNER JOIN $sampledb.hpo h ON ha.ancestor=h.id
	INNER JOIN $sampledb.hpogene hg ON h.id=hg.id
	WHERE $hpowhere
	GROUP BY hg.gene,ha.id
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@hpoprepare) || die print "$DBI::errstr";
	while (($genesymbol,$maxic) = $out->fetchrow_array) {
		# hash of arrays, one array with maxic for each gene
		push(@{$tmp{$genesymbol}},$maxic);
		$hits{$genesymbol}++;
		if ($maxic > $maxic{$genesymbol} ) {
			$maxic{$genesymbol} = $maxic;
		}
	}
	foreach $genesymbol (keys %tmp) {
		push(@genesymbol,$genesymbol);
		$i   = 0;
		$tmp = 0;
		@tmp = @{ $tmp{$genesymbol} };
		foreach $maxic (@tmp) {
			$i++;
			$tmp +=  $maxic;
		}
		$genesymbol{$genesymbol} = ($tmp/$i);
	}
}
elsif ($hpo eq "asdfasdf") {
	chomp($hpo);
	$hpo   =~ s/\,/ /g;
	$hpo   =~ s/\s+/\,/g;
	@hpo = split(/,/,$hpo);
	foreach $hpo (@hpo) {
		if ($hpowhere ne "") {
			$hpowhere .= " OR ";
		}
		$hpowhere .= " hg.id = ? ";
		push(@hpoprepare,$hpo);
	}
	$query = "
	SELECT hg.gene,sum(h.ic)/count(h.ic),count(h.id),max(h.ic) 
	FROM $sampledb.hpogene hg
	LEFT JOIN $sampledb.hpo h ON hg.id=h.id
	WHERE $hpowhere
	GROUP BY hg.gene
	ORDER BY hg.gene,sum(h.ic)/count(h.ic) desc
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@hpoprepare) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@genesymbol,$row[0]);
		$genesymbol{$row[0]}=$row[1];
		$hits{$row[0]}      =$row[2];
		$maxic{$row[0]}     =$row[3];
		#print "$row[0] $row[1]<br>";
	}
}
elsif ($hpo eq "asdfasdf") {
	chomp($hpo);
	$hpo   =~ s/\,/ /g;
	$hpo   =~ s/\s+/\,/g;
	@hpo = split(/,/,$hpo);
	foreach $hpo (@hpo) {
		if ($hpowhere ne "") {
			$hpowhere .= " OR ";
		}
		$hpowhere .= "id = ? ";
		push(@hpoprepare,$hpo);
	}
	$query = "SELECT gene,count(gene) 
	FROM $sampledb.hpogene 
	WHERE $hpowhere
	GROUP BY gene
	ORDER BY count(gene) desc
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@hpoprepare) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@genesymbol,$row[0]);
		$genesymbol{$row[0]}=$row[1];
		#print "$row[0] $row[1]<br>";
	}
}
else {
	print "No HPO terms.";
	exit(1);
}

$i=0;

if ($ref->{'s.name'} ne "") {
	$idsample = &getIdsampleByName($dbh,$ref->{'s.name'});
	$where .= " AND s.idsample = ? ";
	push(@prepare,$idsample);
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'v.freq'} ne "") {
	$where .= " AND v.freq <= ? ";
	push(@prepare,$ref->{'v.freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);

print "Maximal 100 variants<br>";
print "Search phrase: $hpo<br>";
&todaysdate;
&numberofsamples($dbh);
print "Allowed in in-house Exomes < $ref->{'v.freq'}<br>";
&printqueryheader($ref,$classprint,$functionprint);
$where .= " AND g.approved = ? ";

$query = qq#
SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT s.name separator ' '),
group_concat(DISTINCT s.pedigree separator ' '),
s.sex,
d.symbol,
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
c.rating,
c.patho,
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(DISTINCT g.omim separator ' '),
group_concat(distinct $mgiID separator ' '),
v.class,
replace(v.func,',',' '),
group_concat(DISTINCT x.alleles separator '<br>'),
f.fsample,
f.samplecontrols,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT x.filter separator '<br>'),
group_concat(DISTINCT x.snvqual separator '<br>'),
group_concat(DISTINCT x.gtqual separator '<br>'),
group_concat(DISTINCT x.mapqual separator '<br>'),
group_concat(DISTINCT x.coverage separator '<br>'),
group_concat(DISTINCT x.percentvar separator '<br>'),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
v.idsnv
FROM
snv v 
INNER JOIN snvsample                   x ON (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample            s ON (s.idsample = x.idsample)
LEFT  JOIN $sampledb.disease2sample   ds ON (s.idsample=ds.idsample)
LEFT  JOIN $sampledb.disease           d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup)
LEFT  JOIN snvgene                     y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                        g ON (g.idgene = y.idgene)
LEFT  JOIN disease2gene               dg on (g.idgene = dg.idgene)
LEFT  JOIN $sampledb.mouse            mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.pph3              pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift             sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd             cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs               evs ON (v.chrom=evs.chrom AND v.start=evs.start AND v.refallele=evs.refallele AND v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores        exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords       h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar            cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment          c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
$allowedprojects
$where
$function
$class
GROUP BY
s.idsample,v.idsnv,g.idgene
ORDER BY
v.chrom,v.start
LIMIT 5000
#;
#print "$query<br>";
#print "query = $where<br>";
#print "query = @prepare $idomim<br>";

# foreach gene returned by hpo search
my $ngenes=1;
my $maxgenes=100;
if ($demo == 1) {
	$maxgenes=50;
}
my $checkedgenes=0;
foreach $genesymbol (sort {$genesymbol{$b}<=>$genesymbol{$a}} sort keys %genesymbol) {
	#print "asdf '$genesymbol' $genesymbol{$genesymbol}<br>";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@prepare,$genesymbol) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@row2,[@row,$genesymbol{$genesymbol},$hits{$genesymbol},$maxic{$genesymbol}]);

		# if mode eq ar
		($tmp,$mode)=&omim($dbh,$row[9]); # g.omim=$row[9]
		$mode =~ s/\s+//g;	
		$mode =~ s/<br>//g;	
		#print "$row[9] $row[13] '$mode'<br>";
		if ($mode eq "ar") {
			#print "$row[9] $row[13] $mode<br>";
			# for compound heterozyous
			$ar{$row[9]} += $row[13]; #variant allele=row[13]
			#print "asdf $ar{$idomim}<br>";
		}
		else {
			# if ad gene are set to 2, the will be shown in any case because ($ar{$row[9]} >= $ar)
			$ar{$row[9]} = 2; #variant allele=row[13]
		}
		$ngenes++;
	}
	if ($ngenes > $maxgenes) {
		last;
	}
	$checkedgenes++;
} 

# Now print table
(@labels) = &resultlabels();
$labels[11] = "Avg_IC<br>Max_IC<br>Hits"; # replace column header 'Mode' by 'Score'

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $program      = "";
my $damaging     = 0;
my $omimmode     = "";
my $omimdiseases = "";
my $hposcores    = "";
my $aref         = "";
$score           = "";
my $idsnv        = "";
for  $aref (@row2) { 
	@row=@{$aref};
	$maxic    = $row[-1];
	$maxic    = sprintf("%.2f",$maxic);
	pop(@row);
	$hits     = $row[-1];
	pop(@row);
	$score    = $row[-1];
	$score    = sprintf("%.2f",$score);
	pop(@row);
	$idsnv    = $row[-1];
	pop(@row);
	#push(@row,$score,$hits,$maxic);
	$hposcores = "$score<br>$maxic<br>$hits";
	if ($ar{$row[9]} >= $ar) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 1) {
			$tmp=&igvlink($dbh,$row[$i],$row[5]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 5) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		# jedesmal aendern
		elsif ($i == 9) {
			($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
			print "<td $class align=\"center\">$tmp</td><td align=\"center\">$hposcores</td><td style='min-width:350px'>$omimdiseases</td>\n";
		}
		elsif ($i == 11) {
			($tmp)=&vcf2mutalyzer($dbh,$idsnv);
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==24) or ($i==25)) {
			if ($i==24) {$program = 'polyphen2';}
			if ($i==25) {$program = 'sift';}
			$damaging=&damaging($program,$row[$i]);
			if ($damaging==1) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 31) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		elsif ($i == 33) { # cnv exomedetph
			print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
	} #if ar
}
print "</tbody></table></div>";


print "Genes checked: ";
@labels	= (
	'n',
	'Gene symbol',
	'Score',
	'Hits',
	'Max IC'
	);
$n = 1;
print "<table border='0'";
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$ngenes=1;
foreach $genesymbol (sort {$genesymbol{$b}<=>$genesymbol{$a}} keys %genesymbol) {
	print "<tr>";
	print "<td>$n</td>";
	print "<td>$genesymbol</td>";
	print "<td>$genesymbol{$genesymbol}</td>";
	print "<td>$hits{$genesymbol}</td>";
	print "<td>$maxic{$genesymbol}</td>";
	$n++;
	print "</tr>";
	if ($ngenes > $checkedgenes) {
		last;
	}
	$ngenes++;
}
print "<table><br>";

#$out->finish;
}
########################################################################
# searchResultsHPO searchHPOResults
########################################################################
sub searchResultsHPOPhenomizer {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

use LWP::Simple;

my @labels    = ();
my $out       = "";
my @row       = ();
my @row2      = ();
my $query     = "";
my $avhet     = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @tmp       = ();
my $filter    = "";
my $url         = "";
my $phenomizer  = "";
my @individual  = ();
my $individual  = "";
my $genesymbol  = "";
my $score       = "";
my %genesymbol  = ();
my @genesymbol  = ();
my @prepare     = ();
my @preparegenes = ();
my $snvqual     = "";
my $mapqual     = "";
my $af          = "";
my $where       = "";
my $wheregenes  = "";
my @omim        = {};
my $hpo         = $ref->{"hpo"} ;
my $allowedprojects = &allowedprojects("s.");
my $idsample    = "";
my $prefix      = "";
my $mode        = "";
my %ar          = ();
my $ar          = $ref->{ar};
if ($ar eq "ar") {
	$ar = 2;
}
else {
	$ar = 0;
}

if (($ref->{'s.name'} eq "") and ($ref->{'ds.iddisease'} eq "") and
($ref->{'s.idcooperation'} eq "") and ($ref->{'idproject'} eq "")) {
	print "No sample ID, disease, cooperation or project.";
	exit(1);
}
if ($hpo ne "") {
	$hpo   =~ s/\,/ /g;
	$hpo   =~ s/\s+/\,/g;
	$url = "http://compbio.charite.de/phenomizer/phenomizer/PhenomizerServiceURI?username=ddf77c97&password=56c88e9d&mobilequery=true&terms=$hpo";
	$phenomizer = get $url;
	for $tmp (split /^/, $phenomizer) {
		#print "$tmp<br>";
		@tmp        = split(/\t/,$tmp);
		$score      = $tmp[0];
		$score      =~ s/\s+//g;
		$genesymbol = $tmp[4];
		$genesymbol =~ s/\s+//g;
		@genesymbol = split(/\,/,$genesymbol);
		foreach $genesymbol (@genesymbol) {
			#print "genesymbol $genesymbol<br>";
			if (!exists($genesymbol{$genesymbol})) {
				$genesymbol{$genesymbol}=$score;
			}
		}
	}
}
else {
	print "No HPO terms.";
	exit(1);
}
$i=0;
if ($ref->{'s.name'} ne "") {
	$idsample = &getIdsampleByName($dbh,$ref->{'s.name'});
	$where .= " AND s.idsample = ? ";
	push(@prepare,$idsample);
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare, $ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare, $ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'v.freq'} ne "") {
	$where .= " AND v.freq <= ? ";
	push(@prepare,$ref->{'v.freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);


# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);

print "Search phrase: $hpo<br>";
&todaysdate;
&numberofsamples($dbh);
print "Allowed in in-house Exomes < $ref->{'v.freq'}<br>";
print "1000 Genomea AF < $ref->{'af'}<br>";
&printqueryheader($ref,$classprint,$functionprint);
$where .= " AND g.genesymbol = ? ";

$query = qq#
SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT s.name separator ' '),
group_concat(DISTINCT s.pedigree separator '<br>'),
concat(v.chrom,' ',v.start,' ',v.end,' ',v.class,' ',v.refallele,' ',v.allele),
group_concat(DISTINCT $genelink separator '<br>'),
concat(g.nonsynpergene,' (', g.delpergene,')'),
concat(g.omim),
v.class,
v.func,
(SELECT group_concat(DISTINCT  pph.hvar_prediction,'(',pph.hvar_prob,')' separator '<br>')
FROM $coredb.pph3 pph WHERE (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
),
(SELECT group_concat(DISTINCT  sift.score )
FROM $coredb.sift sift WHERE (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
),
group_concat(DISTINCT cadd.phred separator ' '),
(SELECT DISTINCT f.fsampleall FROM snv2diseasegroup f WHERE v.idsnv=f.fidsnv),
group_concat(DISTINCT x.alleles separator '<br>'),
concat($rssnplink),avhet,
(SELECT group_concat('<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>' separator '<br>')
FROM hgmd_pro.$hg19_coords h WHERE v.chrom = h.chrom AND v.start = h.pos AND v.refallele=h.ref AND v.allele=h.alt),
group_concat(DISTINCT $clinvarlink separator '<br>'),
af,
group_concat(DISTINCT $exac_ae_link separator '<br>'),
group_concat(DISTINCT $exac_aa_link separator '<br>'),
group_concat(DISTINCT x.snvqual separator '<br>'),
group_concat(DISTINCT x.gtqual separator '<br>'),
group_concat(DISTINCT x.mapqual separator '<br>'),
group_concat(DISTINCT x.coverage separator '<br>'),
group_concat(DISTINCT x.percentvar separator '<br>'),
group_concat(DISTINCT x.filter separator '<br>'),
v.transcript,
v.idsnv
FROM
snv v 
INNER JOIN snvsample                 x ON (v.idsnv = x.idsnv) 
INNER JOIN $sampledb.sample          s ON (s.idsample = x.idsample)
LEFT  JOIN $sampledb.disease2sample ds ON (s.idsample=ds.idsample)
LEFT  JOIN $sampledb.disease         i ON (ds.iddisease = i.iddisease)
LEFT  JOIN snvgene                   y ON (v.idsnv = y.idsnv)
LEFT  JOIN gene                      g ON (g.idgene = y.idgene)
LEFT  JOIN $coredb.cadd           cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.clinvar          cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $coredb.evs             evs ON (v.chrom=evs.chrom AND v.start=evs.start AND v.refallele=evs.refallele AND v.allele=evs.allele)
WHERE
$allowedprojects
$where
$function
$class
GROUP BY
v.idsnv
ORDER BY
v.chrom,v.start
LIMIT 5000
#;
#print "$query<br>";
#print "query = $where<br>";
#print "query = @prepare $idomim<br>";
# foreach gene returned by solr
foreach $genesymbol (sort {$genesymbol{$a}<=>$genesymbol{$b}} keys %genesymbol) {
	#print "asdf '$genesymbol' $genesymbol{$genesymbol}<br>";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@prepare,$genesymbol) || die print "$DBI::errstr";
	while (@row = $out->fetchrow_array) {
		push(@row2,[@row,$genesymbol{$genesymbol}]);

		# if mode eq ar
		($tmp,$mode)=&omim($dbh,$row[6]); # g.omim=$row[6]
		$mode =~ s/\s+//g;	
		#print "$row[6] $row[13] '$mode'<br>";
		if ($mode eq "ar") {
			#print "$row[6] $row[13] $mode<br>";
			# for compound heterozyous
			$ar{$row[6]} += $row[13]; #variant allele=row[13]
			#print "asdf $ar{$idomim}<br>";
		}
		else {
			# if ad gene are set to 2, the will be shown in anny case because ($ar{$row[6]} >= $ar)
			$ar{$row[6]} = 2; #variant allele=row[13]
		}
	}
} #foreach gene returned by exomizer

@labels	= (
	'n',
	'idsnv',
	'DNA ID',
	'Pedigree',
	'Chr',
	'Gene',
	'Non syn/ Gene',
	'Omim',
	'Mode',
	'Class',
	'Function',
	'pph2',
	'Sift',
	'CADD',
	'Count',
	'Variant alleles',
	"$dbsnp",
	'av Het',
	'HGMD',
	'ClinVar',
	'1000 genomes AF',
	'gnomAD ea',
	'gnomAD aa',
	'SNV Qual',
	'Geno- type Qual',
	'Map Qual',
	'Depth',
	'%Var',
	'Filter',
	'UCSC Transcripts',
	'Score'
	);


&tableheaderDefault();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $damaging = 0;
my $program  = "";
my $aref     = "";
$score    = "";
my $idsnv    = "";
for  $aref (@row2) { 
	@row=@{$aref};
	$score    = $row[-1];
	pop(@row);
	$idsnv    = $row[-1];
	pop(@row);
	push(@row,$score);
	if ($ar{$row[6]} >= $ar) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 3) {
			$tmp=&ucsclink2($row[$i]);
			print "<td> $tmp</td>";
		}
		# jedesmal aendern
		elsif ($i == 6) {
			($tmp,$mode)=&omim($dbh,$row[$i]);
			print "<td>$tmp</td>";
			print "<td>$mode</td>";
		}
		elsif ($i == 1) {
			$tmp=&igvlink($dbh,$row[$i],$row[3]);
			print "<td> $tmp</td>";
		}
		elsif ($i == 7) {
			($tmp)=&vcf2mutalyzer($dbh,$idsnv);
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==9) or ($i==10)) {
			if ($i==9) {$program = 'polyphen2';}
			if ($i==10) {$program = 'sift';}
			$tmp=$row[$i];
			if ($i==9) {
				$tmp=~s/benign//g;
				$tmp=~s/probably damaging//g;
				$tmp=~s/possibly damaging//g;
				$tmp=~s/\)//g;
				$tmp=~s/\(//g;
				$tmp=~s/<br>/ /g;
			}
			$damaging=&damaging($program,$tmp);
			if ($damaging==1) {
				print "<td $warningbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 24) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[7] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
	} #if ar
}
print "</tbody></table></div>";


print "Genes checked: ";
@labels	= (
	'n',
	'Gene symbol',
	'Score'
	);
$n = 1;
print "<table border='0'";
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

foreach $genesymbol (sort {$genesymbol{$a}<=>$genesymbol{$b}} keys %genesymbol) {
	print "<tr>";
	print "<td>$n</td>";
	print "<td>$genesymbol</td>";
	print "<td>$genesymbol{$genesymbol}</td>";
	$n++;
	print "</tr>";
}
print "<table><br>";

#$out->finish;
}
########################################################################
# searchResultsDiseaseGene searchDiseaseGene
########################################################################
sub searchResultsDiseaseGene {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $rssnp     = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $genesymbol = "";
my $allowedprojects = &allowedprojects("");
my @prepare   = ();
my $forcount  = "";
my @forcount  = ();
my $ncount    = "";
my $avhet     = "";
my $where     = "";

delete($ref->{burdentest});

$forcount = "1 = 1 ";

if ($ref->{'datebegin'} ne "") {
	$where = " AND es.date >= ? ";
	$forcount .= " AND es.date >= ? ";
	push(@prepare, $ref->{'datebegin'});
	push(@forcount, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where .= " AND es.date <= ? ";
	$forcount .= " AND es.date <= ? ";
	push(@prepare, $ref->{'dateend'});
	push(@forcount, $ref->{'dateend'});
}
if ($ref->{'s.name'} ne "") {
	$where = "AND s.name = ? ";
	$forcount .= "AND s.name = ? ";
	push(@prepare,$ref->{'s.name'});
	push(@forcount,$ref->{'s.name'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= "AND s.idcooperation = ? ";
	$forcount .= "AND s.idcooperation = ? ";
	push(@prepare,$ref->{'s.idcooperation'});
	push(@forcount,$ref->{'s.idcooperation'});
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= "AND ds.iddisease = ? ";
	$forcount .= "AND ds.iddisease = ? ";
	push(@prepare,$ref->{'ds.iddisease'});
	push(@forcount,$ref->{'ds.iddisease'});
}
if ($ref->{'idproject'} ne "") {
	$where .= "AND s.idproject = ? ";
	$forcount .= "AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
	push(@forcount,$ref->{'idproject'});
}
if ($ref->{'nall'} ne "") {
	$where .= "AND (f.fsampleall <= ? OR ISNULL(f.fsampleall))";
	push(@prepare,$ref->{'nall'});
}
if ($ref->{'score'} ne "") {
	$where .= "AND dg.class = ? ";
	push(@prepare,$ref->{'score'});
}
if ($giabradio == 1) {
if ($ref->{'giab'} ne "") {
	$where .= " AND v.giab = ? ";
	push(@prepare,$ref->{'giab'});
}
}
if ($ref->{'affecteds'} eq "onlyunaffecteds") {
	$forcount .= " AND s.saffected = 0 ";
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);


# number of individuals
			
$i=0;
$query = qq#
SELECT
count(DISTINCT es.idsample)
FROM
$sampledb.sample s 
INNER JOIN $sampledb.disease2sample ds ON s.idsample   = ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease
INNER JOIN $sampledb.exomestat      es ON s.idsample   = es.idsample
WHERE
$forcount
AND ((es.idlibtype = 5) or (es.idlibtype = 1))
AND $allowedprojects
#;
#print "query = $query<br>";
#print "values = $ref->{'ds.iddisease'} @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@forcount) || die print "$DBI::errstr";
$ncount = $out->fetchrow_array;


# search variations

&todaysdate;
&numberofsamples($dbh);

print "<br>Individuals tested $ncount<br>";
print "Allowed in in-house exomes $ref->{'nall'}<br>";
&printqueryheader($ref,$classprint,$functionprint);

$query = qq#
SELECT 
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree," "),
s.sex,
d.symbol,
concat($ucsclink),
c.rating,
c.patho,
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(DISTINCT g.omim separator ' '),
group_concat(distinct $mgiID separator ' '),
v.class,
replace(v.func,',',' '),
x.alleles,
f.fsample,
f.samplecontrols,
group_concat(DISTINCT $exac_gene_link separator '<br>'),
group_concat(DISTINCT exac.mis_z separator '<br>'),
group_concat(DISTINCT '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
x.filter,
x.snvqual,
x.gtqual,
x.mapqual,
x.coverage,
group_concat(distinct x.percentvar),
replace(v.transcript,':','<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>'),
group_concat(DISTINCT dg.class),
v.idsnv,
x.idsample
FROM
snv v 
INNER JOIN snvsample                   x on (v.idsnv = x.idsnv) 
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
INNER JOIN $sampledb.sample            s on (s.idsample = x.idsample)
INNER JOIN $sampledb.disease2sample   ds ON (s.idsample = ds.idsample)
INNER JOIN $sampledb.disease           d on (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup)
LEFT  JOIN snvgene                     y on (v.idsnv = y.idsnv)
LEFT  JOIN gene                        g on (g.idgene = y.idgene)
LEFT  JOIN disease2gene               dg on (g.idgene = dg.idgene)
LEFT  JOIN $sampledb.mouse            mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $sampledb.exomestat        es ON s.idsample = es.idsample AND ((es.idlibtype = 5) or (es.idlibtype = 1))
LEFT  JOIN $coredb.pph3              pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift             sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd             cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs               evs ON (v.chrom=evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores        exac ON (g.genesymbol=exac.gene)
LEFT  JOIN hgmd_pro.$hg19_coords       h ON (v.chrom = h.chrom AND v.start = h.pos  AND v.refallele=h.ref AND v.allele=h.alt)
LEFT  JOIN $coredb.clinvar            cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
LEFT  JOIN $exomevcfe.comment          c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
WHERE
dg.iddisease = ?
$function
$class
$where
AND $allowedprojects
GROUP BY
v.idsnv,s.idsample
ORDER BY
v.chrom,v.start
#;
#print "query = $query<br>";
#print "values = $ref->{'ds.iddisease'} @prepare<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($ref->{'dg.iddisease'},@prepare) || die print "$DBI::errstr";

# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";
$class = "";

$n=1;
my $program      = "";
my $damaging     = "";
my $omimmode     = "";
my $omimdiseases = "";
my $idsnv        = "";
my $idsample     = "";
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	# bekannte Gene in disease2gene color red
	$idsample     = $row[-1];
	pop(@row);
	$idsnv=($row[-1]);
	pop(@row);
	if ($row[-1] ne '') {
		$class=&diseaseGeneColorNew($row[-1]);
	}
	else {
		$class = '';
	}
	pop(@row);
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 1) {
			print qq#
			<td style='white-space:nowrap;'>
			<div class="dropdown">
			$row[$i]&nbsp;&nbsp;
			<a href="comment.pl?idsnv=$idsnv&idsample=$idsample&reason=other">
			<img style='width:12pt;height:12pt;' src="/EVAdb/evadb_images/browser-window.png" title="Variant annotation" />
			</a>
			</div>
			</td>
			#;
		}
		elsif ($i == 9) {
			($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
			print "<td $class align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
		}
		elsif ($i == 11) {
			($tmp)=&vcf2mutalyzer($dbh,$idsnv);
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==24) or ($i==25)) {
			if ($i==24) {$program = 'polyphen2';}
			if ($i==25) {$program = 'sift';}
			$damaging=&damaging($program,$row[$i]);
			if ($damaging==1) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 31) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		elsif ($i == 33) { # transcripts
			print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>\n";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

$n--;
print "<br>Variants found $n<br>";
print "Individuals tested $ncount<br>";
if ($ncount != 0) {
$ncount=$n/$ncount;
$ncount=sprintf("%.2f",$ncount);
print "Variants / Individual $ncount<br>";
}
print "<br><br>";
&listDiseaseGenes($dbh,$ref->{'dg.iddisease'});

$out->finish;
}
########################################################################
# searchResultsMito 
########################################################################
sub searchResultsMito {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my @row2      = ();
my $query     = "";
my $rssnp     = "";
my $function  = "";
my $functionprint  = "";
my $class     = "";
my $classprint= "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my $genesymbol = "";
my $allowedprojects = &allowedprojects("");
my @prepare   = ();
my $avhet     = "";
my $name      = "";
my $start     = "";
my @idsamples = ();
my $idsample  = "";


if ($ref->{'datebegin'} ne "") {
	$name .= " AND es.date >= ? ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$name .= " AND es.date <= ? ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'s.name'} ne "") {
	$name .= "AND s.name = ? ";
	push(@prepare,$ref->{'s.name'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$name .= "AND s.idcooperation = ? ";
	push(@prepare,$ref->{'s.idcooperation'});
}
if ($ref->{'idproject'} ne "") {
	$name .= "AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
	
# select all idsamples for loop
$query = "
SELECT DISTINCT s.idsample
FROM $sampledb.sample  s 
INNER JOIN $sampledb.disease2sample     ds ON s.idsample = ds.idsample
INNER JOIN $sampledb.disease             d on ds.iddisease = d.iddisease
INNER JOIN $sampledb.exomestat          es ON s.idsample = es.idsample
WHERE $allowedprojects
$name
";	

#print "query = $query<br>";
#print "values =  @prepare<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare) || die print "$DBI::errstr";

while (@row = $out->fetchrow_array) {
	push(@idsamples,@row);
}
#print "@idsamples<br>";
$name    = "";
@prepare = ();	
	
if ($ref->{'nall'} ne "") {
	$name .= "AND v.freq <= ? ";
	push(@prepare,$ref->{'nall'});
}
if ($ref->{'ncases'} ne "") {
	$name .= "AND v.freq >= ? ";
	push(@prepare,$ref->{'ncases'});
}
if ($ref->{'snvqual'} ne "") {
	$name .= "AND x.snvqual >= ? ";
	push(@prepare,$ref->{'snvqual'});
}
if ($ref->{'gtqual'} ne "") {
	$name .= "AND x.gtqual >= ? ";
	push(@prepare,$ref->{'gtqual'});
}
if ($ref->{'mapqual'} ne "") {
	$name .= "AND x.mapqual >= ? ";
	push(@prepare,$ref->{'mapqual'});
}
if ($ref->{'coverage'} ne "") {
	$name .= "AND x.coverage >= ? ";
	push(@prepare,$ref->{'coverage'});
}
if ($ref->{'cfrm'} ne "") {
	$name .= "AND mm.disease_status = ? ";
	push(@prepare,$ref->{'cfrm'});
}

my $explain = "";
if ($ref->{"printquery"} eq "yes") {
	$explain = " explain extended ";
}
# function
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);


# search variations

&todaysdate;
&numberofsamples($dbh);


print "Allowed in in-house exomes $ref->{'nall'}<br>";
&printqueryheader($ref,$classprint,$functionprint);

$query = qq#
$explain SELECT
concat('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>',' '),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
group_concat(DISTINCT s.pedigree," "),
concat($ucsclinkmito),
v.refallele,
v.allele,
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
md.name,
group_concat(DISTINCT g.omim separator ' '),
v.class,
v.func,
mm.disease,
mm.disease_status,
mm.af,
group_concat(DISTINCT $clinvarlink separator '<br>'),
v.freq,
x.alleles,
x.snvqual,x.gtqual,x.mapqual,x.coverage,
group_concat(distinct x.percentvar),v.transcript,
v.start,
v.idsnv
FROM
snv v 
INNER JOIN snvsample                     x ON (v.idsnv = x.idsnv) 
INNER JOIN $sampledb.sample              s ON (s.idsample = x.idsample)
INNER JOIN snvgene                       y ON (v.idsnv = y.idsnv)
INNER JOIN gene                          g ON (g.idgene = y.idgene)
INNER JOIN $sampledb.exomestat          es ON s.idsample = es.idsample
LEFT  JOIN $coredb.mitomap              mm ON (v.chrom=mm.chrom and v.start=mm.start and v.refallele=mm.refallele and v.allele=mm.allele)
LEFT  JOIN $coredb.mitogb               mg ON (v.chrom=mg.chrom and v.start=mg.start and v.refallele=mg.refallele and v.allele=mg.allele)
LEFT  JOIN $coredb.mitodomains          md ON (v.chrom=md.chrom and v.start=md.start)
LEFT  JOIN $coredb.clinvar              cv ON (v.chrom=cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
WHERE
v.chrom="chrM"
$function
$class
$name
AND x.idsample=?
AND $allowedprojects
GROUP BY
x.idsnv,x.idsample
ORDER BY
v.chrom,v.start
#;

foreach $idsample (@idsamples) {
#print "query = $query<br>";
#print "values =  @prepare<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,$idsample) || die print "$DBI::errstr";

if ($ref->{"printquery"} eq "yes") {
	print "query = $query<br>";
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	print q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		print "<tr>";
		foreach (@row) {print "<td>$_</td>";} 
		print "</tr>";
	}
	print "</table>";
	exit;
}

while (@row = $out->fetchrow_array) {
	push(@row2,[@row]);
}

}
@labels	= (
	'n',
	'idsnv',
	'DNA id',
	'Pedigree',
	'Chr',
	'Ref',
	'Alt',
	'Gene symbol',
	'Non syn/ Gene',
	'Domain',
	'Omim',
	'Mode',
	'Class',
	'Function',
	'Disease',
	'Disease Status',
	'Mitomap Freq',
	'ClinVar',
	'Count',
	'Alleles',
	'SNV qual',
	'Geno- type qual',
	'Map qual',
	'Depth',
	'%Var',
	'UCSC Transcripts'
	);

&tableheaderDefault();
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";
$class = "";

$n=1;
my $program  = "";
my $damaging = "";
my $mode     = "";
my $idsnv    = "";
my $aref     = "";
for $aref (@row2) {
	@row=@{$aref};
	print "<tr>";
	$i=0;
	$idsnv=($row[-1]);
	pop(@row);
	$start=$row[-1];
	pop(@row);
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print "<td class='$class' > $row[$i]</td>";
		}
		elsif ($i == 10) {
			$tmp="<a href=http://mitomap.org//cgi-bin/search_allele?starting=$start>$row[$i]</a>";
			print "<td align=\"center\">$tmp</td>";
		}
		elsif ($i == 9) {
			($tmp,$mode)=&omim($dbh,$row[$i]);
			print "<td $class>$tmp</td>";
			print "<td>$mode</td>";
		}
		else {
			print "<td class='$class' > $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
} # foreach @row2
print "</tbody></table></div>";
#&tablescript("","7,12");

$out->finish;
}

########################################################################
# Disease gene color
########################################################################
sub diseaseGeneColorNew {
my $score = shift;
my $class = "";
	if ($score == 1) {
		$class="class='diseaseGene1'"; # confirmed ad
	}
	elsif ($score == 5) {
		$class="class='diseaseGene2'"; # confirmed recessive
	}
	elsif ($score == 9) {
		$class="class='diseaseGene3'"; # confirmed X-linked_dominant
	}
	elsif ($score == 2) {
		$class="class='diseaseGene4'"; # confirmed X-linked_recessive
	}
	elsif ($score == 6) {
		$class="class='diseaseGene5'"; # probable ad
	}
	elsif ($score == 10) {
		$class="class='diseaseGene6'"; # probable recessive
	}
	elsif ($score == 3) {
		$class="class='diseaseGene7'"; # probable X-linked_dominant
	}
	elsif ($score == 7) {
		$class="class='diseaseGene8'"; # probable X-linked_recessive
	}
	elsif ($score == 11) {
		$class="class='diseaseGene9'"; # possible ad
	}
	elsif ($score == 4) {
		$class="class='diseaseGene10'"; # possible recessive
	}
	elsif ($score == 8) {
		$class="class='diseaseGene11'"; # possible X-linked_dominant
	}
	elsif ($score == 12) {
		$class="class='diseaseGene12'"; # possible X-linked_recessive
	}
	elsif ($score == 13) {
		$class="class='diseaseGene13'"; # other i.e candidate
	}

return($class);
}
########################################################################
# burden listDiseaseGenes
########################################################################
sub listDiseaseGenes {
my $dbh       = shift;
my $disease   = shift;
my $query     = "";
my @labels    = ();
my $out       = "";
my @row       = ();
my $n         = 1;
my $i         = 1;

$query=qq#
SELECT
g.genesymbol,
dg.class 
FROM
disease2gene dg
INNER JOIN gene g ON dg.idgene=g.idgene
WHERE 
dg.iddisease = ?
ORDER BY g.genesymbol
#;

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($disease) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Gene',
	'Class'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	# bekannte Gene in disease2gene color red
	$i = 0;
	foreach (@row) {
		if ($i == 0) {
			print "<td>$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table>";

}
########################################################################
# burden searchDiseaseGene, called by burdenIntern
########################################################################
#determine number of variants
sub burdenQueries {
my $mode     = shift;
my $explain  = shift;
my $where    = shift;
my $function = shift;
my $class    = shift;

my $query    = "";

if ($mode eq "dominant") {
$query=qq#
$explain SELECT
dgr.name as diseasegroup,
d.name as disease,
COUNT(DISTINCT x.idsample,x.idsnv) as nvariants,
s.saffected as affected,
g.genesymbol
FROM
snv v 
INNER JOIN snvgene                     y ON v.idsnv          = y.idsnv
INNER JOIN gene                        g ON g.idgene         = y.idgene
LEFT  JOIN disease2gene               dg ON g.idgene         = dg.idgene
INNER JOIN snvsample                   x ON v.idsnv          = x.idsnv
INNER JOIN snv2diseasegroup            f ON v.idsnv          = f.fidsnv
INNER JOIN $sampledb.sample            s ON s.idsample       = x.idsample
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample
INNER JOIN $sampledb.disease           d ON ds.iddisease     = d.iddisease
INNER JOIN $sampledb.diseasegroup    dgr ON d.iddiseasegroup = dgr.iddiseasegroup
WHERE 
$where
$function
$class
AND FIND_IN_SET('PASS',x.filter)
GROUP BY g.idgene,dgr.iddiseasegroup,d.iddisease,s.saffected
#;
}
if ($mode eq "recessive") {
$query=qq#
$explain SELECT 
dgr.name as diseasegroup, 
d.name as disease, 
COUNT(DISTINCT x.idsample,x.idsnv)-COUNT(DISTINCT x.idsample) as nsamples,
s.saffected as affected, 
g.genesymbol
FROM  snv v 
INNER JOIN snvgene                     y ON v.idsnv          = y.idsnv 
INNER JOIN gene                        g ON g.idgene         = y.idgene 
LEFT  JOIN disease2gene               dg ON g.idgene         = dg.idgene 
INNER JOIN snvsample                   x ON v.idsnv          = x.idsnv 
INNER JOIN snv2diseasegroup            f ON v.idsnv          = f.fidsnv 
INNER JOIN $sampledb.sample            s ON s.idsample       = x.idsample 
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample 
INNER JOIN $sampledb.disease           d ON ds.iddisease     = d.iddisease 
INNER JOIN $sampledb.diseasegroup    dgr ON d.iddiseasegroup = dgr.iddiseasegroup 
WHERE
$where
$function
$class
AND FIND_IN_SET('PASS',x.filter)
GROUP BY g.idgene,dgr.iddiseasegroup,d.iddisease,s.saffected
HAVING nsamples > 0
UNION
SELECT 
dgr.name as diseasegroup, 
d.name as disease, 
COUNT(DISTINCT x.idsample) as nsamples,
s.saffected as affected, 
g.genesymbol
FROM  snv v 
INNER JOIN snvgene                     y ON v.idsnv          = y.idsnv 
INNER JOIN gene                        g ON g.idgene         = y.idgene 
LEFT  JOIN disease2gene               dg ON g.idgene         = dg.idgene 
INNER JOIN snvsample                   x ON v.idsnv          = x.idsnv 
INNER JOIN snv2diseasegroup            f ON v.idsnv          = f.fidsnv 
INNER JOIN $sampledb.sample            s ON s.idsample       = x.idsample 
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample 
INNER JOIN $sampledb.disease           d ON ds.iddisease     = d.iddisease 
INNER JOIN $sampledb.diseasegroup    dgr ON d.iddiseasegroup = dgr.iddiseasegroup 
WHERE
$where
$function
$class
AND FIND_IN_SET('PASS',x.filter)
AND x.alleles >= 2
GROUP BY g.idgene,dgr.iddiseasegroup,d.iddisease,s.saffected
#;
}

return $query;
}
#######################################################################
# burden searchDiseaseGene
########################################################################
sub burdenIntern {
my $dbh           = shift;
my $ref           = shift;

use Text::NSP::Measures::2D::Fisher::twotailed;

my $function      = "";
my $class         = "";
my $functionprint = "";
my $classprint    = "";
($function,$functionprint)=&function($ref->{'function'},$dbh);
($class,$classprint)=&class($ref->{'class'},$dbh);
my @labels        = ();
my $out           = "";
my @row           = ();
my $query         = "";
my @prepare       = ();
my $where         = "";
my $n             = "";
my $i             = "";
my %disease       = ();
my $buf           = "";

if ($ref->{'dg.iddisease'} ne "") {
	$where = "dg.iddisease = ? ";
	push(@prepare,$ref->{'dg.iddisease'});
}
else {
	$where = " 1 = 1 ";
}


# determine disease name
my $iddisease = $ref->{'ds.iddisease'};
$query = 
"SELECT name 
FROM $sampledb.disease
WHERE iddisease = ?
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($iddisease) || die print "$DBI::errstr";
my $disease = $out->fetchrow_array;
# determine disease group
$query = 
"SELECT dg.name 
FROM $sampledb.disease d
INNER JOIN $sampledb.diseasegroup dg ON d.iddiseasegroup = dg.iddiseasegroup
WHERE d.iddisease = ?
";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($iddisease) || die print "$DBI::errstr";
my $diseasegroup = $out->fetchrow_array;
$buf .= "Disease: $disease, $diseasegroup<br><br>";

	
if ($ref->{'datebegin'} ne "") {
	$where = " AND es.date >= ? ";
	push(@prepare, $ref->{'datebegin'});
}
if ($ref->{'dateend'} ne "") {
	$where .= " AND es.date <= ? ";
	push(@prepare, $ref->{'dateend'});
}
if ($ref->{'score'} ne "") {
	$where .= "AND dg.class = ? ";
	push(@prepare,$ref->{'score'});
}
if ($ref->{'nall'} ne "") {
	$where .= "AND f.fsampleall <= ? ";
	push(@prepare,$ref->{'nall'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);

#determine number of cases and controls per disease group
$query=qq#
SELECT
dg.name,
d.name,
count(DISTINCT s.idsample),
s.saffected
FROM $sampledb.sample s
INNER JOIN $sampledb.disease2sample   ds ON s.idsample       = ds.idsample
INNER JOIN $sampledb.disease           d ON ds.iddisease     = d.iddisease
INNER JOIN $sampledb.diseasegroup     dg ON d.iddiseasegroup = dg.iddiseasegroup
WHERE s.idsample IN
(SELECT
DISTINCT x.idsample
FROM
snvsample x)
GROUP BY dg.iddiseasegroup,d.iddisease,s.saffected
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
my $ncases    = 0;
my $ncontrols = 0;
$buf .= "Controls:<br>";
$buf .= "Disease,Diseasegroup,n_samples,affected:<br>";
while (@row = $out->fetchrow_array) {
	if ($row[2] >= 80) {
		$disease{$row[0]}{$row[1]}{$row[3]}=$row[2];
		if (($row[0] eq $diseasegroup) and ($row[1] eq $disease) and ($row[3] == 1)) {
			$ncases     = $row[2];
		}
		elsif ($row[0] ne $diseasegroup) {
			$ncontrols += $row[2];
			$buf .= "$row[0], $row[1], $row[2], $row[3]<br>";
		}
	}

}
my $printquery = "n";
my $explain = "";
if ($printquery eq "y") {
	$explain = "explain extended ";
}

#determine number of variants
if ($ref->{burdentest} eq "1") {
	$query = &burdenQueries("dominant", $explain,$where,$function,$class);
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@prepare) || die print "$DBI::errstr";
}
if ($ref->{burdentest} eq "2") {
	$query = &burdenQueries("recessive",$explain,$where,$function,$class);
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute(@prepare,@prepare) || die print "$DBI::errstr";
}

#$buf .= "query = $query<br>";
#$buf .= "where = $where<br>";
#$buf .= "prepare = @prepare<br>";

if ($printquery eq "y") {
	$buf .= q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		$buf .= "<tr>";
		foreach (@row) {$buf .= "<td>$_</td>";} 
		$buf .= "</tr>";
	}
	$buf .= "</table>";
	$query="show warnings";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute();
	$buf .= q(<table border="1" cellspacing="0" cellpadding="2"> );
	while (@row = $out->fetchrow_array) {
		$buf .= "<tr>";
		foreach (@row) {$buf .= "<td>$_</td>";} 
		$buf .= "</tr>";
	}
	$buf .= "</table>";
	return $buf;
}

# store variants for cases and controls in hash
$n=1;
my %variants   = ();
my $pcases     = 0;
my $pcontrols  = 0;
my $fisher     = 0;
#0 diseasegroup
#1 disease
#2 nvariants
#3 affected
#4 genesymbol
while (@row = $out->fetchrow_array) {
	if ($disease{$row[0]}{$row[1]}{$row[3]} >= 80) {
		#$buf .= "@row<br>";
		if (($row[0] eq $diseasegroup) and ($row[1] eq $disease) and ($row[3] == 1)) {
			$variants{$row[4]}{cases}    = $row[2];
		}
		elsif ($row[0] ne $diseasegroup) {
			$variants{$row[4]}{controls} = $variants{$row[4]}{controls} + $row[2];
		}
	}
}

@labels	= (
	'n',
	'Gene',
	'n Cases',
	'n Controls',
	'Variant Cases',
	'Variant Controls',
	'Percent Cases',
	'Percent Controls',
	'Fisher exact p-value'
	);

$buf .= &tableheaderDefault("1000px","","","","noprint");
$buf .= "<thead><tr>";
foreach (@labels) {
	$buf .= "<th align=\"center\">$_</th>";
}
$buf .= "</tr></thead><tbody>\n";
foreach my $gene (sort keys %variants) {
	$buf .= "<tr align=\"center\">";
	if ($ncases > 0) {
		$pcases = $variants{$gene}{cases}    / $ncases * 100;
		$pcases = sprintf("%.2f",$pcases);
	}
	else {
		$pcases     = "";
	}
	if ($ncontrols > 0) {
		$pcontrols  = $variants{$gene}{controls} / $ncontrols * 100;
		$pcontrols  = sprintf("%.2f",$pcontrols);
	}
	else {
		$pcontrols     = "";
	}
	#$fisher = calculateStatistic(n11=>$pcases, n12=>$pcontrols, n21=>$variants{$gene}{cases}, n22=>$variants{$gene}{controls});
	my $n1p = $ncases+$ncontrols;
	my $np1 = $ncases+$variants{$gene}{cases};
	my $npp = $ncases+$ncontrols+$variants{$gene}{cases}+$variants{$gene}{controls};
	#$fisher = calculateStatistic(n11=>$pcases, n1p=>$pcontrols, np1=>$variants{$gene}{cases}, npp=>$variants{$gene}{controls});
	$fisher = calculateStatistic(n11=>$ncases, n1p=>$n1p, np1=>$np1, npp=>$npp);
	$fisher = sprintf("%.7f",$fisher);
	$buf .= "<td></td><td>$gene</td><td>$ncases</td><td>$ncontrols</td><td>$variants{$gene}{cases}</td><td>$variants{$gene}{controls}</td><td>$pcases</td><td>$pcontrols</td><td>$fisher</td>";
	$buf .= "</tr>\n";
}
$buf .= "</tbody></table></div>";

return $buf;
}
########################################################################
# burden searchDiseaseGene
########################################################################
# fork wrapper
sub burden {
my $self          = shift;
my $dbh           = shift;
my $ref           = shift;
my $cgi           = shift; 
my $buf           = "";


#http://www.stonehenge.com/merlyn/LinuxMag/col39.html

# parent process
#my $session = $cgi->param('session');
#if (defined($session)) {
if (my $session = $cgi->param('session')) {
	my $refresh       = "";
	my $cache = get_cache_handle();
	my $data = $cache->get($session);
	print $cgi->header;
      	#print $cgi->start_html(-title => "Exome",
        #($data->[0] ? () :
        #(-head => ["<meta http-equiv=refresh content=5>"])));
	unless (($data->[0])) {
		$refresh = "<meta http-equiv=refresh content=5>";
	}
	&printHeader("","","fork",$refresh);
	unless ($data and ref $data eq "ARRAY") { # something is wrong
		print "error<br>";
		exit 0;
	}
	print ($data->[1]);
	print $cgi->p($cgi->i("... Continuing. Please wait. ..."))  unless $data->[0];    
	#print "<br>end2 $session<br>";
	print $cgi->end_html;
}
elsif (defined($ref->{'function'})) {
	my $session = get_session_id();
	my $cache = get_cache_handle();
	$cache->set($session, [0, ""]); # no data yet
	if (my $pid = fork) {       # parent does
		$cgi->delete_all(); 
		$cgi->param('session', $session);
		#print $cgi->header; # bloss nicht diese Zeile
		print $cgi->redirect($cgi->self_url());
	} 
	elsif (defined $pid) {    # child does
		my $child_dbh = $dbh->clone(); # otherwise mysql connection will close in child
		$dbh->{InactiveDestroy} = 1;
		undef $dbh;
		close STDOUT; 
		close STDERR;
		#sleep(310);
		# perform long job
		$buf = &burdenIntern($child_dbh,$ref);

		$cache->set($session, [1, $buf]);	       
		exit 0;
	}
	else {
		die "Cannot fork: $!";
	}	      
}
#exit (0);
}
########################################################################

sub get_cache_handle {
	require Cache::FileCache;
	Cache::FileCache->new
		({
		namespace => 'exome',
		username => 'nobody',
		default_expires_in => '240 minutes',
		auto_purge_interval => '4 hours',
		});
}
	
sub get_session_id {
	require Digest::MD5;
	Digest::MD5::md5_hex(Digest::MD5::md5_hex(time().{}.rand().$$));
}

########################################################################
# adminList listAdmin
########################################################################
sub adminList {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $allowedprojects = &allowedprojects("s.");

if ($role ne "admin") {print "Not admin";exit(1);}
			
$i=0;
$query = qq#
SELECT
iduser, 
name, 
yubikey, 
igvport, 
cooperations, 
projects,
role,
edit,
genesearch,
comment,
succeeded_all,
failed_all,
failed_last,
lastlogin,
genesearchcount
FROM
$logindb.user
ORDER BY
name
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'id',
	'Login',
	'Yubikey',
	'IGV port',
	'Cooperations',
	'Projects',
	'Role',
	'Edit',
	'Gene search',
	'Comment',
	'All logins',
	'Failed logins',
	'Last failed logins',
	'Last login',
	'Gene search count'
	);

$i=0;

&tableheaderDefault("1000px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print "<td><a href=\"admin.pl?mode=edit&amp;id=$row[$i]\">$row[$i]</a></td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

$out->finish;
}

########################################################################
# listCooperation
########################################################################
sub listCooperation {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $allowedprojects = &allowedprojects("s.");

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

			
$i=0;
$query = qq#
SELECT
distinct c.idcooperation, 
c.name, 
c.prename, 
c.institution, 
c.email, 
c.phone
FROM
$sampledb.cooperation c
INNER JOIN $sampledb.sample s ON s.idcooperation=c.idcooperation
WHERE $allowedprojects
ORDER BY
name
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";

@labels	= (
	'n',
	'id',
	'Name',
	'Preame',
	'Institution',
	'Email',
	'Phone'
	);

$i=0;

&tableheaderDefault("1500px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
		}
		print "<td> $row[$i]</td>";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


$out->finish;
}

########################################################################
# searchConclusions resultsConclusions
########################################################################
sub searchConclusion {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $where     = "";
my $field     = "";
my $idsample  = "";
my $idsnv     = "";
my @values2   = ();
my $libtype   = "";
my $count     = "''";
my $nonsyn    = "''";
my $order     = $ref->{order};
delete($ref->{order});
$order=~s/\'//g;
if (
($order ne 's.pedigree,s.name') and
($order ne 's.name') and
($order ne 'substr(cl.indate,1,10),s.pedigree,s.name')
)
{die;}

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


my $allowedprojects = &allowedprojects("s.");

$where = "WHERE s.nottoseq = 0 ";
#$where .= " AND ( co.rating = 'correct' OR ISNULL(co.rating) OR co.confirmed='yes' OR ISNULL(co.confirmed) ) ";

if ($ref->{rating} eq 'correct') {
	$where .= " AND co.rating = 'correct' ";
}
delete($ref->{rating});
if ($ref->{patho} eq 'notunknown') {
	$where .= " AND co.patho != 'unknown' ";
}
delete($ref->{patho});

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$i=0;
foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " es.date >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " es.date <= ? ";
			push(@values2,$values[$i]);
		}
		else {
			$where .= $field . " = ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}

# 
			
$i=0;
$query = qq#
SELECT
s.name,
s.pedigree,
s.foreignid,
s.sex,
s.saffected,
d.name,
c.name,
cl.solved,
GROUP_CONCAT(DISTINCT co.genesymbol SEPARATOR " "),
GROUP_CONCAT(DISTINCT co.omimphenotype SEPARATOR " "),
GROUP_CONCAT(DISTINCT co.pmid SEPARATOR " "),
cl.conclusion,
cl.comment,
s.entered,
es.date,
datediff(es.date,s.entered),
cl.indate,
datediff(cl.indate,s.entered),
cl.changedate,
GROUP_CONCAT(DISTINCT '<a href="listPosition.pl?idsnv=', v.idsnv,'" title="All carriers of this variant">',g.genesymbol,'</a>',
 ', ',v.class, ', ', co.genotype, ', ', co.inheritance, ', ', co.patho, if(co.clinvardate>"0000-00-00", concat(", ",co.clinvardate),"") SEPARATOR " <br>"),
GROUP_CONCAT(DISTINCT h.hpo SEPARATOR " <br>"),
GROUP_CONCAT(DISTINCT h.symptoms SEPARATOR " <br>"),
s.idsample
FROM
$sampledb.sample s 
INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
INNER JOIN $sampledb.disease         d ON ds.iddisease = d.iddisease    
INNER JOIN $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
LEFT  JOIN $sampledb.exomestat      es ON s.idsample = es.idsample AND ((es.idlibtype = 5) or (es.idlibtype = 1))
LEFT  JOIN $exomevcfe.conclusion    cl ON s.idsample = cl.idsample
LEFT  JOIN $exomevcfe.comment       co ON s.idsample = co.idsample
LEFT  JOIN snv                       v ON (v.chrom=co.chrom and v.start=co.start and v.refallele=co.refallele and v.allele=co.altallele and v.end=co.end)
LEFT  JOIN snvgene                   y ON v.idsnv = y.idsnv
LEFT  JOIN gene                      g ON g.idgene = y.idgene
LEFT  JOIN $exomevcfe.hpo            h ON s.idsample = h.idsample
$where
AND $allowedprojects
AND (h.active=1 OR ISNULL(h.active))
GROUP BY s.idsample
ORDER BY
$order
#;
#print "query = $query<br>";
#print "@values2<br>";
#print "query = $where<br>";
#s.pedigree,s.name
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'ID Links',
	'Pedigree',
	'Foreign ID',
	'Sex',
	'Affected',
	'Diagnosis',
	'Cooperation',
	'Solved',
	'Gene symbol',
	'OMIM',
	'PMID',
	'Results',
	'Comment',
	'Sample date',
	'Analysis date',
	'Days',
	'Conclusion date',
	'Days',
	'Conclusion last change',
	'Gene, Genotype, Inheritance, Pathogenicity, ClinVarSubmission',
	'HPO',
	'Symptoms'
	);


&tableheaderDefault("1750px");

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$i           = 0;
$n           = 1;
$tmp         = "";
my $sname    = "";
my $pedigree = "";
while (@row = $out->fetchrow_array) {
	$idsample = $row[-1];
	$sname    = $row[0];
	$pedigree = $row[1];
	pop(@row);
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 0) { 
			print qq#
			<td style='white-space:nowrap;'>
			<div class="dropdown">
			$row[$i]&nbsp;&nbsp;
			<img style='width:14pt;height:14pt;' src="/EVAdb/evadb_images/down-squared.png" title="Links to analysis functions" onclick="myFunction($n)" class="dropbtn" />
			<div id="myDropdown$n" class="dropdown-content">
			        <a href='search.pl?pedigree=$pedigree'>Autosomal dominant</a>
				<a href='searchGeneInd.pl?pedigree=$sname'>Autosomal recessive</a>
				<a href='searchTrio.pl?pedigree=$sname'>De novo trio</a>
				<a href='searchTumor.pl?pedigree=$sname'>Tumor/Control</a>
				<a href='searchDiseaseGene.pl?sname=$sname'>Disease panels</a>
				<a href='searchHGMD.pl?sname=$sname'>ClinVar/HGMD</a>
				<a href='searchOmim.pl?sname=$sname'>OMIM</a>
				<a href='searchHPO.pl?sname=$sname'>HPO</a>
				<a href='searchDiagnostics.pl?sname=$sname'>Coverage lists</a>
				<a href='searchHomo.pl?sname=$sname'>Homozygosity</a>
				<a href='searchCnv.pl?sname=$sname'>CNV</a>
				#;
				if ($contextM eq "contextMg") { # is genome
					print qq#
					<a href='searchSv.pl?sname=$sname'>Structural variants</a>
					#;
				}
				print qq#
				<a href='searchSample.pl?pedigree=$pedigree'>Sample information</a>
				<a href='conclusion.pl?idsample=$idsample'>Sample conclusions</a>
				<a href='report.pl?sname=$sname'>Report</a>
				#;
				if ($role eq "admin" || $role eq "manager" ){
                                        print qq#
                                        <a href='wrapper.pl?sname=$sname&file=merged.rmdup.bam'>Download BAM</a>
                                        #;
                                }
                                print qq#
			</div>
			</div>
			</td>
			#;
		}
		elsif ($i == 7) {
			if ($row[7] eq "") {$row[7] = 0;}
			if ($row[$i] == 0) {
				$tmp = "not processed";
			}
			if ($row[$i] == 1) {
				$tmp = "solved";
			}
			if ($row[$i] == 2) {
				$tmp = "not solved";
			}
			if ($row[$i] == 3) {
				$tmp = "new candidate";
			}
			if ($row[$i] == 4) {
				$tmp = "follow-up pending";
			}
			print "<td><span style='white-space:nowrap'>$tmp</span></td>";
		}
		elsif (($i == 14) || ($i == 16) || ($i == 18)) { # es.date cl.indate cl.changedate
			$row[$i] = substr($row[$i],0,10);
			print "<td> $row[$i]</td>";
		}
		elsif ($i == 19) { # gene ....
			print "<td><span style='white-space:nowrap'>$row[$i]</span></td>";
		}
		elsif ($i == 21) { # Symptomes ....
			print "<td style='min-width:300px'>$row[$i]</td>";
		}
		else {
			print "<td> $row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


$out->finish;
}
########################################################################
# searchStatistics exomestatistics resultsexomestat resultsqualitycontrol
########################################################################
sub searchStat {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});

if ($ref->{mode} eq "figure") {
	delete($ref->{mode});
	&searchStatFigure($dbh,$ref);
}
if ($ref->{mode} eq "table") {
	delete($ref->{mode});
	&searchStatTable($dbh,$ref);
}

}

########################################################################
# searchStatistics exomestatistics resultsexomestat
########################################################################
sub searchStatFigure {
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $where     = "";
my $field     = "";
my $idsample  = "";
my @values2   = ();
my $libtype   = "";
#my $dir       = "''";
#my $file      = "";
my $name      = "";
my $order     = $ref->{order};
delete($ref->{order});
$order=~s/\'//g;
if (
($order ne 's.pedigree,s.name') and
($order ne 's.name') and
($order ne 'e.seq') and
($order ne 's.sex,e.sry DESC') and
($order ne 'max(l.ldate),s.pedigree,s.name') and
($order ne 'substr(e.date,1,10),s.pedigree,s.name')
)
{die;}

my $allowedprojects = &allowedprojects("s.");


my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$where = "WHERE s.nottoseq = 0 ";


$i=0;
foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " e.date >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " e.date <= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "datebeginlast") {
			$where .= " e.datelast >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateendlast") {
			$where .= " e.datelast <= ? ";
			push(@values2,$values[$i]);
		}
		else {
			$where .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}

# 
if ($ref->{libtype} ne "") {
	$where .= " AND (l.libtype = ? OR ISNULL(e.idlibtype))";
	push(@values2,$ref->{libtype});
}
			
$query = qq#
SELECT
s.name,
s.idsample,
s.sbam
FROM
$sampledb.sample s 
LEFT JOIN  $sampledb.disease2sample ds ON s.idsample = ds.idsample
LEFT JOIN  $solexa.sample2library   sl ON s.idsample = sl.idsample
LEFT JOIN  $solexa.library           l ON sl.lid = l.lid
INNER JOIN $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
LEFT JOIN  $solexa.libtype          lt on l.libtype = lt.ltid 
LEFT JOIN  $solexa.libpair          lp on l.libpair = lp.lpid 
LEFT JOIN  $sampledb.exomestat       e ON (s.idsample = e.idsample AND e.idlibtype=l.libtype AND e.idlibpair=l.libpair)
LEFT JOIN  variantstat              vs ON s.idsample = vs.idsample   
LEFT JOIN  $exomevcfe.conclusion    cl ON s.idsample=cl.idsample
LEFT JOIN  $solexa.assay             a ON e.idassay=a.idassay
$where
AND $allowedprojects
AND l.lfailed = 0
GROUP BY
s.idsample,l.libtype,l.libpair
ORDER BY
$order
#;
#print "query = $query<br>";
#print "@values2<br>";
#s.pedigree,s.name
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";


$n=1;
my $height = 400;
my $width  = 400;
print "<table border=1>";
while (@row = $out->fetchrow_array) {
	$name = $row[0];
	my $gcout          = "/gc.metric.hist.png";
	my $basedis        = "/basedistribution.png";
	my $mtdnaout       = "/chrM.depth.png";
	my $insertout      = "/insert.hist-0.png";
	my $covout         = "/coverageprofile_onofftarget.png";
	my $qualitybycycle = "/meanqualitybycycle.chart.png";
	
	$n++;
	print "<tr>
	<td>
	<font face=\"Tahoma\" size=2>
	<b>$row[0]</b><br>
	</font>
	</td>
	<td><img src=\"readPng.pl?file=$gcout&name=$name\" height=\"$height\" width=\"$width\" alt=\"GC Bias Plot missing.\"></td>
	<td><img src=\"readPng.pl?file=$basedis&name=$name\" height=\"$height\" width=\"$width\" alt=\"Base distribution by cycle missing.\"></td>
	<td><img src=\"readPng.pl?file=$insertout&name=$name\" height=\"$height\" width=\"$width\" alt=\"Library insert size missing.\"></td>
	<td><img src=\"readPng.pl?file=$covout&name=$name\" height=\"$height\" width=\"$width\" alt=\"Coverage figure not for exomes.\"></td>
	<td><img src=\"readPng.pl?file=$qualitybycycle&name=$name\" height=\"$height\" width=\"$width\" alt=\"Quality by cycle missing.\"></td>
	<td><img src=\"readPng.pl?file=$mtdnaout&name=$name\" height=\"$height\" width=\"$width\" alt=\"Coverage of mitochondrial DNA missing.\"></td>
	</tr>
	";

 	#<td><object data=\"readPng.pl?file=$insertout\" type=\"application/pdf\"><a href=\"readPng.pl?file=$insertout\">PDF laden</a></object></td>
	#<td><a href=\"readPng.pl?file=$insertout\">PDF laden</a></td>

}

print "</table>";

$out->finish;
}
########################################################################
# searchStatistics exomestatistics resultsexomestat
########################################################################
sub searchStatTable {
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $where     = "";
my $field     = "";
my $idsample  = "";
my $sname     = "";
my @values2   = ();
my $libtype   = "";
my $nonsyn    = "''";
my $order     = $ref->{order};
delete($ref->{order});
$order=~s/\'//g;
if (
($order ne 's.pedigree,s.name') and
($order ne 's.name') and
($order ne 'e.seq') and
($order ne 's.sex,e.sry DESC') and
($order ne 'max(l.ldate),s.pedigree,s.name') and
($order ne 'substr(e.date,1,10),s.pedigree,s.name')
)
{die;}

my $allowedprojects = &allowedprojects("s.");


my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$where = "WHERE s.nottoseq = 0 ";

# libtype muss auch in der Where-Klausel der Subquery angegeben werden
# placeholder on first position
if ($ref->{libtype} ne "") {
	$libtype = " AND sol.libtype = ? ";
	push(@values2,$ref->{libtype});
}

$i=0;
foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " e.date >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " e.date <= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "datebeginlast") {
			$where .= " e.datelast >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateendlast") {
			$where .= " e.datelast <= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "idproject" ) {
			$where .= " s.idproject = ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "s.name" ) {
			my @names=split(" ", $values[$i]);
			my $namesquery="(";
			foreach my $samplename (@names){
				if ($namesquery ne "(" ) {
					$namesquery .= " OR ";
				}
				$namesquery .= " s.name = ? ";
				push(@values2, $samplename);
			}
			$namesquery.=")";
			
			$where .= $namesquery. " " if $namesquery ne "()";
		}
		else {
			$where .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}

# 
if ($ref->{libtype} ne "") {
	$where .= " AND (l.libtype = ? OR ISNULL(e.idlibtype))";
	push(@values2,$ref->{libtype});
}

my $libname = "l.lname";

if ( isEdit() == 1 ){
	$libname = "concat('<a href=\"../solexa/library.pl?id=',l.lid,'&amp;mode=edit\">',l.lname,'</a>')";
}else{
	$libname = "l.lname";
}

#replace(replace(replace(replace (cl.solved,1,"solved"),2,"not_solved"),3,"candidate"),4,"pending")
			
$i=0;
$query = qq#
SELECT
s.name,
concat_ws(' ',cl.solved, group_concat(DISTINCT co.genesymbol SEPARATOR ' ')),
h.idsample,
s.pedigree,s.sex,s.foreignid,s.externalseqid,e.sry,p.pdescription,c.name,group_concat( DISTINCT D.name ), s.saffected,
group_concat( DISTINCT $libname ),lt.ltlibtype,lp.lplibpair,a.name,
e.mix,
e.duplicates*100,e.opticalduplicates*100,e.reads,e.mapped,e.percentm,e.properlyp,e.seq,
round(e.seq/e.mapped*1000000000),
e.onbait,e.avgcov,e.avgcovstd,(e.avgcovstd/e.avgcov),e.uncovered,e.cov1x,e.cov4x,e.cov8x,e.cov20x,e.tstv,
vs.snv,
vs.indel,
vs.pindel,
vs.exomedepth,
group_concat(DISTINCT l.linsertsize,' (', l.linsertsizesd,') '),
ROUND(e.exomedepthrsd,2),
(SELECT group_concat(' (', COALESCE(sor.rdaterun,'') ,') ',
sor.rname,' ',soa.alane,' ', COALESCE(sot.ttag,'') separator '<br>')
FROM $sampledb.sample ss
INNER JOIN $solexa.sample2library sosl ON ss.idsample = sosl.idsample
INNER JOIN $solexa.library sol         ON sosl.lid = sol.lid
INNER JOIN $solexa.library2pool sopl   ON sol.lid = sopl.lid
INNER JOIN $solexa.pool sop            ON sopl.idpool = sop.idpool
INNER JOIN $solexa.lane soa            ON sop.idpool = soa.idpool
INNER JOIN $solexa.run sor             ON sor.rid = soa.rid
LEFT  JOIN $solexa.tag sot             ON sol.idtag = sot.idtag
WHERE  s.idsample = ss.idsample  
AND sol.libtype=l.libtype 
AND sol.libpair=l.libpair
$libtype
AND soa.aread1failed = 'F'
AND soa.aread2failed = 'F'
AND sol.lfailed = 0  
), mismatchrate, avgqual, avgquallast5, libcomplexity, q30fraction, avgdiffdepth,
s.idsample, dw.iduser is not null download
FROM
$sampledb.sample s 
LEFT  JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
LEFT  JOIN $sampledb.disease         D ON ds.iddisease = D.iddisease
LEFT  JOIN $solexa.sample2library   sl ON s.idsample = sl.idsample
LEFT  JOIN $solexa.library           l ON sl.lid = l.lid
INNER JOIN $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
INNER JOIN $sampledb.project         p ON s.idproject = p.idproject
LEFT  JOIN $solexa.libtype          lt on l.libtype = lt.ltid 
LEFT  JOIN $solexa.libpair          lp on l.libpair = lp.lpid 
LEFT  JOIN $sampledb.exomestat       e ON (s.idsample = e.idsample AND e.idlibtype=l.libtype AND e.idlibpair=l.libpair)
LEFT  JOIN variantstat              vs ON s.idsample = vs.idsample   
LEFT  JOIN $exomevcfe.conclusion    cl ON s.idsample = cl.idsample
LEFT  JOIN $solexa.assay             a ON e.idassay = a.idassay
LEFT  JOIN $exomevcfe.hpo            h ON s.idsample = h.idsample
LEFT  JOIN $exomevcfe.comment       co ON s.idsample = co.idsample
LEFT  JOIN $exomevcfe.download      dw ON ( s.idsample = dw.idsample OR s.idproject = dw.idproject and NOW()>=dw.startdate and NOW()<=dw.enddate and dw.iduser=(select iduser FROM $exomevcfe.user where name='$user' ))
$where
AND $allowedprojects
AND l.lfailed = 0
GROUP BY
s.idsample,l.libtype,l.libpair
ORDER BY
$order
#;
#print "query = $query<br>";
#print "@values2<br>";
#s.pedigree,s.name
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'ID Links',
	'<div class="tooltip">Con-<br>clusion<span class="tooltiptext">0 nothing_done<br>1 solved<br>2 not_solved<br>3 candidate<br>4 pending</span></div>',
	'HPO',
	'Pedigree',
	'Sex',
	'Foreign ID',
	'External<br>SeqID',
	'SRY',
	'Project',
	'Cooperation',
	'Disease',
	'Affected',
	'Libraries',
	'libtype',
	'libpair',
	'type',
	'Contam.',
	'Duplicates',
	'Optical duplicates',
	'Reads',
	'Mapped',
	'Mapped<br>percent',
	'Properly<br>paired',
	'Seq (Gb)',
	'Read<br>length',
	'on bait',
	'Avg cov (exome)',
	'Avg cov STDev',
	'STDev / Avg cov',
	'Uncovered',
	'Cov 1x',
	'Cov 4x',
	'Cov 8x',
	'Cov 20x',
	'Ts/Tv',
	'SNV',
	'Indel',
	'Pindel',
	'Exomedepth',
	'Insert (sd)',
	'CNV noise (Rs)',
	'Run dates',
	'mismatchrate', 
	'avgqual', 
	'avgquallast5', 
	'libcomplexity', 
	'q30fraction', 
	'avgdiffdepth'
	);


&tableheaderDefault();

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$i=0;
$n=1;
my $pedigree = "";
# http://swisnl.github.io/jQuery-contextMenu/demo.html
# https://api.jquery.com/contextmenu/

while (@row = $out->fetchrow_array) {

	my $canDownload = ( $row[-1] || $role eq "admin" || $role eq "manager" );
	pop(@row);

	$idsample = $row[-1];
	$sname    = $row[0];
	$pedigree = $row[3];
	pop(@row);
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 0) { 
			$tmp = &getigv($dbh,$idsample,"");
			print qq#
			<td style='white-space:nowrap;'>
			<div class="dropdown">
			$tmp&nbsp;&nbsp; 
			<img style='width:14pt;height:14pt;' src="/EVAdb/evadb_images/down-squared.png" title="Links to analysis functions" onclick="myFunction($n)" class="dropbtn" />
			<div id="myDropdown$n" class="dropdown-content">
			        <a href='search.pl?pedigree=$pedigree'>Autosomal dominant</a>
				<a href='searchGeneInd.pl?pedigree=$sname'>Autosomal recessive</a>
				<a href='searchTrio.pl?pedigree=$sname'>De novo trio</a>
				<a href='searchTumor.pl?pedigree=$sname'>Tumor/Control</a>
				<a href='searchDiseaseGene.pl?sname=$sname'>Disease panels</a>
				<a href='searchHGMD.pl?sname=$sname'>ClinVar/HGMD</a>
				<a href='searchOmim.pl?sname=$sname'>OMIM</a>
				<a href='searchHPO.pl?sname=$sname'>HPO</a>
				<a href='searchDiagnostics.pl?sname=$sname'>Coverage lists</a>
				<a href='searchHomo.pl?sname=$sname'>Homozygosity</a>
				<a href='searchCnv.pl?sname=$sname'>CNV</a>
				#;
				if ($contextM eq "contextMg") { # is genome
					print qq#
					<a href='searchSv.pl?sname=$sname'>Structural variants</a>
					#;
				}
				print qq#
				<a href='searchSample.pl?pedigree=$pedigree&autosearch=1'>Sample information</a>
				<a href='conclusion.pl?idsample=$idsample'>Sample conclusions</a>
				<a href='report.pl?sname=$sname'>Report</a>
				#;
				if ( $canDownload ){
                                        print qq#
					 <a href='wrapper.pl?sname=$sname&file=$vcfRawFileName'>Download Raw VCF</a>
                                        <a href='wrapper.pl?sname=$sname&file=$bamFileName'>Download BAM</a>
                                        #;
                                }
                                print qq#
			</div>
			</div>
			</td>
			#;

		}
		elsif ($i == 2) { # HPO
			if ($row[$i] ne "") {
				print "<td><a href='showHPO.pl?idsample=$row[$i]'>HPO</a></td>";
			}
			else {
				print "<td><a href='importHPO.pl?sname=$sname'>New</a></td>";
			}
		}
		elsif ($i == 3 ){
			print qq#
				<td><a href='searchStat.pl?pedigree=$pedigree&autosearch=1'>$pedigree</a></td>
			#;
		}
		elsif ($i == 7){ # SRY
			if ( ($row[$i] ne '') and ($row[$i] < 100 ) and ($row[$i-3] eq "male") and ($row[10] eq 'exomic')) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			elsif ( ($row[$i] ne '') and ($row[$i] > 25 ) and ($row[$i-3] eq "female") and ($row[10] eq 'exomic')) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			elsif ( ($row[$i] ne '') and ($row[$i] < 12 ) and ($row[$i-3] eq "male") and ($row[10] eq 'genomic')) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			elsif ( ($row[$i] ne '') and ($row[$i] > 3 ) and ($row[$i-3] eq "female") and ($row[10] eq 'genomic')) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td>$row[$i]</td>";
			}
		}
		elsif ($i == 16) { # Contamination
			if ( ($row[$i] ne '') and ($row[$i] >= 0.03) ) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 23) { # Seq (GB)
			if ( ($row[$i] ne '') and ($row[$i] < 8) ) {
				print "<td class='textred'>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 41) { 
			print "<td class='width230'>$row[$i]</td>";
		}
		elsif ($i == 48) {
			#Service field
			print "";print "<td>$row[46]</td>";
		}
		else {
			print "<td>$row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


$out->finish;
}
########################################################################
# searchRnaStatistics rnastatistics resultsrnastat
########################################################################
sub searchRnaStat {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $where     = "";
my $field     = "";
my $idsample  = "";
my @values2   = ();
my $order     = $ref->{order};
delete($ref->{order});
$order=~s/\'//g;
if (
($order ne 's.pedigree,s.name') and
($order ne 's.name') and
($order ne 'r.seq') and
($order ne 'substr(r.date,1,10),s.pedigree,s.name')
)
{die;}


my $allowedprojects = &allowedprojects("s.");

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$where = "WHERE s.nottoseq = 0 ";

$i=0;
foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " r.date >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " r.date <= ? ";
			push(@values2,$values[$i]);
		}
		else {
			$where .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
			
$i=0;
$query = qq#
SELECT
s.name,
s.pedigree,
s.sex,
s.foreignid,
c.name,
o.orname,
ti.name,
a.name,
r.mapper,
r.readLength,
r.mapped,
r.mappedPairs,
r.splitReads,
r.exonicRate,
r.intronicRate,
r.intragenicRate,
r.intergenicRate,
r.rRNARate,
s.idsample
FROM
$sampledb.sample s 
LEFT  JOIN $sampledb.disease2sample ds ON s.idsample      = ds.idsample
INNER JOIN $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
INNER JOIN $sampledb.rnaseqcstat     r ON s.idsample      = r.idsample
INNER JOIN $sampledb.organism        o ON s.idorganism    = o.idorganism
LEFT  JOIN $sampledb.tissue         ti ON s.idtissue      = ti.idtissue
INNER JOIN $sampledb.exomestat       e ON s.idsample=e.idsample
LEFT JOIN  $solexa.assay             a ON e.idassay=a.idassay
$where
AND $allowedprojects
GROUP BY
s.idsample
ORDER BY
$order
#;
#print "query = $query<br>";
#print "@values2<br>";
#s.pedigree,s.name
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'ID<br>IGV',
	'Pedigree<br>FPKM',
	'Sex',
	'Foreign ID',
	'Cooperation',
	'Organism',
	'Tissue',
	'Assay',
	'Mapper',
	'Read<br>length',
	'Mapped<br>reads',
	'Mapped<br>pairs',
	'Split<br>reads',
	'Exonic',
	'Intronic',
	'Intra-<br>genic',
	'Inter-<br>genic',
	'rRNA'
	);


&tableheaderDefault();
$i=0;

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;

while (@row = $out->fetchrow_array) {
	$idsample = $row[-1];
	pop(@row);
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
			$tmp=&igvlinkRNA($dbh,$row[$i]);
			print "<td align=\"center\"> $tmp</td>";
		}
		elsif ($i==1) {
			$tmp = $row[$i];
			if ($row[5] eq "human") {
			$tmp = "<a href='searchRpkm.pl?name=$row[0]'>$tmp</a>";
			}
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==8) or ($i==9) or ($i==10)) {
			$tmp = $row[$i];
			$tmp =~ s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g;
			print "<td align=\"center\">$tmp</td>";
		}
		elsif (($i==11) or ($i==12) or ($i==13) or ($i==14) or ($i==15)) {
			$tmp=sprintf("%.3f",$row[$i]);
			print "<td align=\"center\">$tmp</td>";
		}
		else {
			print "<td align=\"center\">$row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


$out->finish;
}
########################################################################
# searchRpkm rnastatistics resultsrpkm
########################################################################
sub searchRpkm {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $where     = "";
my $field     = "";
my @values2   = ();

if (($ref->{'s.name'} eq "") and ($ref->{'g.genesymbol'} eq "")) {
	print "RNA ID or gene symbol empty.";
	exit;
}

my $allowedprojects = &allowedprojects("s.");

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$where = "WHERE s.nottoseq = 0 ";

$i=0;
foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " r.date >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " r.date <= ? ";
			push(@values2,$values[$i]);
		}
		else {
			$where .= $field . " like ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
			
$i=0;
$query = qq#
SELECT
s.name,
ti.name,
g.genesymbol,
rpkm.readcount,
rpkm.fpkm
FROM
$sampledb.sample s 
LEFT  JOIN $sampledb.disease2sample ds ON s.idsample  = ds.idsample
INNER JOIN $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
INNER JOIN $rnadb.genebased       rpkm ON s.idsample  = rpkm.idsample
INNER JOIN $sampledb.rnaseqcstat     r ON s.idsample  = r.idsample
INNER JOIN $rnagenedb.gene           g ON rpkm.idgene = g.idgene
LEFT  JOIN $sampledb.tissue         ti ON s.idtissue  = ti.idtissue
$where
AND $allowedprojects
ORDER BY
g.genesymbol,s.name
#;
#print "query = $query<br>";
#GROUP BY
#rpkm.idsample,rpkm.idgene
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'ID',
	'Tissue',
	'Gene<br>symbol',
	'Count',
	'FPKM'
	);


&tableheaderDefault("1000px");
$i=0;

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";


while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
			print "<td align=\"center\"> $row[$i]</td>";
		}
		elsif ($i==4) {
			$tmp=sprintf("%.3f",$row[$i]);
			print "<td align=\"center\">$tmp</td>";
		}
		else {
			print "<td align=\"center\">$row[$i]</td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

$out->finish;
}
########################################################################
# search Transcript Statistics Coverage resultsCoverage
########################################################################
sub searchTranscriptstat {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $j         = 0;
my $t         = 0;
my $n         = 1;
my $chrom     = "";
my @individuals = ();
my $individuals = "";
my $tmp       = "";
my @tmp       = ();
my @tmp2      = ();
my $where     = "";
my $field     = "";
my $chartdata = "";
my @chartdata = ();
my @ids       = ();
my @avgdepth  = ();
my @seq       = ();
my $normalization = 0;
my @values2   = ();
my $allowedprojects = &allowedprojects("s.");
my @prepare      = ();

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});



my $order     = $ref->{order};
delete($ref->{order});
$order=~s/\'//g;
if (($order eq "s.pedigree,s.name") or
	($order eq "s.name") or
	($order eq "g.geneSymbol")) {
}
else {
	die;
}

if (($ref->{'g.genesymbol'} eq "") and ($ref->{'t.name'} eq "")) {
	print "Gene symbol or RefSeq empty";
	exit;
}

$ref->{"s.name"}=trim($ref->{"s.name"});
@individuals= split(/\s+/,$ref->{"s.name"});
if ($ref->{"s.name"} ne "") {
foreach $tmp (@individuals) {
	if ($i == 0) {
		$individuals    .= "(";
	}
	if ($i != 0) {
		$individuals    .= "OR ";
	}
	$individuals    .= "s.name = ? ";
	push(@prepare,$tmp);
	$i++;
}
$individuals    .= ") ";
}
delete($ref->{"s.name"});

if ($ref->{"normalization"} eq "gene") {
	$normalization="gene";
}
if ($ref->{"normalization"} eq "exome") {
	$normalization="exome";
}
delete($ref->{"normalization"});

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$i=0;
foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		$where .= $field . " = ? ";
		push(@values2,$values[$i]);
	}
	$i++;
}
if ($where ne "") {
	$where = "WHERE  $where";
}
if (($where ne "") and ($individuals ne "")) {
	$where = $where . " AND " . $individuals;
}
if (($where eq "") and ($individuals ne "")) {
	$where = " WHERE " . $individuals;
}


#print "$where @values2<br>";
			
$i=0;
$query = qq#
SELECT
s.name,
s.pedigree,
s.foreignid,
g.genesymbol,
t.name,
lt.ltlibtype,
lp.lplibpair,
a.name,
e.seq,
ts.avgdepthtotal,
ts.qdepthtotal,
ts.avgmapqualtotal,
t.chrom,
t.exonStarts,
t.exonEnds,
ts.avgdepth,
ts.qdepth,
ts.avgmapqual
FROM
$sampledb.gene g
INNER JOIN $sampledb.transcript      t ON g.idgene=t.idgene
INNER JOIN $sampledb.transcriptstat ts ON t.idtranscript=ts.idtranscript
INNER JOIN $sampledb.sample          s ON ts.idsample=s.idsample
INNER JOIN $sampledb.exomestat       e ON (ts.idsample=e.idsample
					and ts.idlibtype=e.idlibtype
					and ts.idlibpair=e.idlibpair)
INNER JOIN $solexa.libtype          lt ON ts.idlibtype=lt.ltid
INNER JOIN $solexa.libpair          lp ON ts.idlibpair=lp.lpid
INNER JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
LEFT  JOIN $solexa.assay             a ON ts.idassay = a.idassay
$where
AND $allowedprojects
ORDER BY
$order
LIMIT 400
#;
#print "query = $query<br>";
#s.pedigree,s.name
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2,@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'ID',
	'Pedigree',
	'Foreign ID',
	'Gene Symbol',
	'Transcript',
	'Libtype',
	'Libpair',
	'Type',
	'Seq (Gb)',
	'Avg depth',
	'Depth > 20',
	'Avg MapQual',
	'Position, Avg depth, Depth > 20, Avg MapQual'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
$i=0;
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
	$i++;
}
print "</tr>";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 12) { 
			print q(<td class="coverage"><table  border="1" cellspacing="0" cellpadding="1"> );
		}
		if (($i == 12) or ($i == 13) or ($i == 14)) {  # chrom pos
			if ($i == 12)  {  # chrom pos
				print "<tr>";
					$chrom=$row[$i];
					@tmp=split(/\,/,$row[$i+1]);
					@tmp2=split(/\,/,$row[$i+2]);
					$t=0;
					foreach (@tmp) {
						$tmp = $chrom . ":" . $tmp[$t] . "-" . $tmp2[$t];
						$tmp = &ucsclink($tmp,$t+1);
						print "<td width=\"25px\"  align=\"center\">$tmp</td>";
						$t++;
					}
				print "</tr>\n";
			}
		}
		elsif (($i == 15) or ($i == 16) or ($i == 17)) {  # values per exon
			@tmp=split(/\,/,$row[$i]);
			print "<tr>";
			if ($i==15) {
				push(@ids,$row[0]); #for figure
				push(@seq,$row[8]); #for normalization per exome
				push(@avgdepth,$row[9]); #for normalization per gene
				push(@chartdata,[@tmp]);
			}
			foreach $tmp (@tmp) {
				$tmp=sprintf("%.0f",$tmp);
				if (($i==15) and ($tmp < 20)) {
					print "<td $warningtdbg align=\"center\">$tmp</td>";
				}
				elsif (($i==16) and ($tmp < 100)) {
					print "<td $warningtdbg align=\"center\">$tmp</td>";
				}
				elsif (($i==17) and ($tmp < 50)) {
					print "<td $warningtdbg align=\"center\">$tmp</td>";
				}
				else {
					print "<td $green width=\"25px\" align=\"center\">$tmp</td>";
				}
			}
			print "</tr>\n";
		}
		else {
			if ($i==8) {
				$row[$i]=sprintf("%.1f",$row[$i]);
			}
			elsif (($i==9) or ($i==10) or ($i==11)) {
				$row[$i]=sprintf("%.0f",$row[$i]);
			}
			print "<td align='center'> $row[$i]</td>";
		}
		if ($i == 17) { 
			print "</table></td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";
print "<br><br>";

# Header
$chartdata= "['exon' ";
for $i (0 .. $#chartdata) {
	$t=$i+1;
	$chartdata=$chartdata . " ,'$ids[$i]'";
}
$chartdata=$chartdata . " ]";
$i=0;
for $j (0 .. $#{ $chartdata[$i]}) {
	$t=$j+1;
	$chartdata=$chartdata . " ,\n[ '$t' ";
	for $i (0 .. $#chartdata) {
		if ($chartdata[$i][$j] < 1) {$chartdata[$i][$j] = 1} #for logscale
		if ($normalization eq "gene") {
			if ($avgdepth[$i] == 0) {
				$avgdepth[$i] =10; #to avoid division by 0
			}
			$chartdata[$i][$j] = $chartdata[$i][$j] / $avgdepth[$i];
			$chartdata[$i][$j] = sprintf("%.1f",$chartdata[$i][$j]) ;
		}
		elsif ($normalization eq "exome") {
			$chartdata[$i][$j] = $chartdata[$i][$j] / $seq[$i];
			$chartdata[$i][$j] = sprintf("%.1f",$chartdata[$i][$j]) ;
		}
		#$chartdata[$i][$j] = log($chartdata[$i][$j])/log(2);
		$chartdata=$chartdata . ", $chartdata[$i][$j]";
	}
	$chartdata=$chartdata . " ] ";
}
#print "$chartdata";

#$chartdata= qq(
#['Year', 'Sales', 'Expenses'],
#          ['2004',  1000,      400],
#          ['2005',  1170,      460],
#          ['2006',  660,       1120],
#          ['2007',  1030,      540]
#);

print qq(    
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
	$chartdata
        ]);

        var options = {
          title: 'Coverage',
	  backgroundColor: '#ffffff',
	  vAxis: {title: 'Coverage (log scale)', logScale: true, format:'#.###'},
	  hAxis: {title: 'Exons'},
	  pointSize: 4,
	  width:     1200,
	  height:    500
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
<div id="chart_div"></div>
);



$out->finish;
}

########################################################################
# search Diagnostics coveragelists coverage lists
########################################################################
sub searchResultsDiagnostics {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $t         = 0;
my $n         = 1;
my $chrom     = "";
my $tmp       = "";
my @tmp       = ();
my @tmp2      = ();
my $where     = "";
my $field     = "";
my @values2   = ();
my $allowedprojects = &allowedprojects("s.");
my @prepare      = ();

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


if ($ref->{'s.name'} eq "") {
	print "DNA id missing";
	exit;
}

$ref->{"s.name"}=trim($ref->{"s.name"});


my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};

$i=0;
foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		$where .= $field . " = ? ";
		push(@values2,$values[$i]);
	}
	$i++;
}
if ($where ne "") {
	$where = "WHERE  $where";
}

$i=0;
$query = qq#
SELECT
DISTINCT s.name,
s.pedigree,
s.foreignid,
lt.ltlibtype,
lp.lplibpair,
a.name,
e.seq,
avgcov,
cov20x
FROM
$sampledb.gene g
INNER JOIN $sampledb.transcript      t ON g.idgene=t.idgene
INNER JOIN $sampledb.transcriptstat ts ON t.idtranscript=ts.idtranscript
INNER JOIN $sampledb.sample          s ON ts.idsample=s.idsample
INNER JOIN $sampledb.exomestat       e ON (ts.idsample=e.idsample
					and ts.idlibtype=e.idlibtype
					and ts.idlibpair=e.idlibpair)
INNER JOIN $solexa.libtype          lt ON ts.idlibtype=lt.ltid
INNER JOIN $solexa.libpair          lp ON ts.idlibpair=lp.lpid
INNER JOIN $sampledb.disease2gene   dg ON g.idgene = dg.idgene
INNER JOIN $sampledb.disease         d ON dg.iddisease = d.iddisease
LEFT  JOIN $solexa.assay             a ON ts.idassay = a.idassay
$where
AND $allowedprojects
ORDER BY g.genesymbol,t.name
#;

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2,@prepare) || die print "$DBI::errstr";
&todaysdate;
print "<br>";
print q(<table class="outer" border= "0" cellspacing="0" cellpadding="2"> );
while (@row = $out->fetchrow_array) {
	print "<tr><td class=n>DNA Id:     </td><td class=n>$row[0]</td></tr>";
	print "<tr><td class=n>Pedigree:   </td><td class=n>$row[1]</td></tr>";
	print "<tr><td class=n>Foreign ID: </td><td class=n>$row[2]</td></tr>";
	print "<tr><td class=n>Libtype:    </td><td class=n>$row[3]</td></tr>";
	print "<tr><td class=n>Libpair:    </td><td class=n>$row[4]</td></tr>";
	print "<tr><td class=n>Assay:      </td><td class=n>$row[5]</td></tr>";
	print "<tr><td class=n>Seqence:    </td><td class=n>$row[6]</td></tr>";
	print "<tr><td class=n>Average <br>coverage:    </td><td class=n>$row[7]</td></tr>";
	print "<tr><td class=n>At least <br>20x coverage:    </td><td class=n>$row[8]</td></tr>";
}
print q(</table><br>);
			
$i=0;
$query = qq#
SELECT
g.genesymbol,
t.name,
ts.avgdepthtotal,
ts.qdepthtotal,
ts.avgmapqualtotal,
t.chrom,
t.exonStarts,
t.exonEnds,
ts.avgdepth,
ts.qdepth,
ts.avgmapqual
FROM
$sampledb.gene g
INNER JOIN $sampledb.transcript t      ON g.idgene=t.idgene
INNER JOIN $sampledb.transcriptstat ts ON t.idtranscript=ts.idtranscript
INNER JOIN $sampledb.sample s          ON ts.idsample=s.idsample
INNER JOIN $sampledb.exomestat e       ON (ts.idsample=e.idsample
					and ts.idlibtype=e.idlibtype
					and ts.idlibpair=e.idlibpair)
INNER JOIN $solexa.libtype lt           ON ts.idlibtype=lt.ltid
INNER JOIN $solexa.libpair lp           ON ts.idlibpair=lp.lpid
INNER JOIN $sampledb.disease2gene dg             ON g.idgene = dg.idgene
INNER JOIN $sampledb.disease d         ON dg.iddisease = d.iddisease
$where
AND $allowedprojects
ORDER BY g.genesymbol,t.name
#;
#print "query = $query<br>";
#print "values2 = @values2<br>";
#s.pedigree,s.name
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2,@prepare) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Gene Symbol',
	'Transcript',
	'Avg depth',
	'Depth > 20',
	'Avg MapQual',
	'Position, Avg depth, Depth > 20, Avg MapQual'
	);

print q(<table border="1" cellspacing="0" cellpadding="2"> );
$i=0;

print "<tr>";
$i=0;
foreach (@labels) {
	if ($i == 6) {
		print "<th align=\"left\">$_</th>";
	}
	else {
		print "<th align=\"center\">$_</th>";
	}
	$i++;
}
print "</tr>";

$n=1;
my $exons       = 0;
my $exonsnotok  = 0;
my %exonsnotok  = ();
my $exoncounter = 0;
my $avgcovnonok = 0;
my $avg20xnonok = 0;
my $avgmapnonok = 0;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 5) { 
			print q(<td class="coverage"><table  border="1" cellspacing="0" cellpadding="1"> );
		}
		if (($i == 5) or ($i == 6) or ($i == 7)) {  # chrom pos
			if ($i == 5)  {  # chrom pos
				print "<tr>";
					$chrom=$row[$i];
					@tmp=split(/\,/,$row[$i+1]);
					@tmp2=split(/\,/,$row[$i+2]);
					$t=0;
					foreach (@tmp) {
						$tmp = $chrom . ":" . $tmp[$t] . "-" . $tmp2[$t];
						$tmp = &ucsclink($tmp,$t+1);
						print "<td width=\"25px\" align=\"center\">$tmp</td>";
						$t++;
						$exons++;
					}
				print "</tr>\n";
			}
		}
		elsif (($i == 8) or ($i == 9) or ($i == 10)) {  # values per exon
			@tmp=split(/\,/,$row[$i]);
			print "<tr>";
			$exoncounter = 0;
			foreach $tmp (@tmp) {
				$tmp=sprintf("%.0f",$tmp);
				if (($i==8) and ($tmp < 20)) { # average read depth per exon
					print "<td class=\"warning\" align=\"center\">$tmp</td>";
					$avgcovnonok++;
					$exonsnotok{"$row[1]$exoncounter"}++;
				}
				elsif (($i==9) and ($tmp < 100)) { #percent exon covered >= 20 x
					print "<td class=\"warning\" align=\"center\">$tmp</td>";
					$avg20xnonok++;
					$exonsnotok{"$row[1]$exoncounter"}++;
				}
				elsif (($i==10) and ($tmp < 50)) { # average mapping qual
					print "<td class=\"warning\" align=\"center\">$tmp</td>";
					$avgmapnonok++;
					$exonsnotok{"$row[1]$exoncounter"}++;
				}
				else {
					print "<td width=\"25px\"  class=\"dna\" align=\"center\">$tmp</td>";
				}
				$exoncounter++;
			}
			print "</tr>\n";
		}
		else {
			if (($i==2) or ($i==3) or ($i==4)) {
				$row[$i]=sprintf("%.0f",$row[$i]);
			}
			print "<td align='center'> $row[$i]</td>";
		}
		if ($i == 10) { 
			print "</table></td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>";
print "<br><br>";
$exonsnotok = keys %exonsnotok;
if ($exons>0) {
	$tmp = sprintf("%.1f",100*$exonsnotok/$exons);
}
print "n exons (all) $exons<br>";
print "n exons (not passed) $exonsnotok ($tmp %)<br>";
print "n exons (average read depth < 20) $avgcovnonok<br>";
print "n exons (base pairs covered at least 20 times < 100%) $avg20xnonok<br>";
print "n exons (average mapping quality < 50) $avgmapnonok<br>";


$out->finish;
}

########################################################################
# searchHomozygous
########################################################################
sub searchHom {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $tmp       = "";
my @individuals = ();
my $individuals = "";
my $where     = "";
my $field     = "";
my @values2   = ();
my @idsamples = ();
my $idsample  = "";
my %row       = ();

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};


foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		$where .= $field . " = ? ";
		push(@values2,$values[$i]);
	}
	$i++;
}

# select idsample for loop
$query = qq#
SELECT s.idsample 
FROM $sampledb.sample s
LEFT JOIN $sampledb.disease2sample ds ON s.idsample=ds.idsample
where $where
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";
while ($idsample = $out->fetchrow_array) {
	push(@idsamples,$idsample);
}
#print "idsamples @idsamples<br>";

@labels	= (
	'n',
	'id',
	'Pedigree',
	'Sex',
	'SRY',
	'Kit',
	'homx',
	'allx',
	'homx/allx'
	);

print qq(\n<table class="outer" border="5" cellspacing="6" cellpadding="14">\n ); #outer table
print "<tr><td class=\"outer\">";

$i=0;
print qq(<table border="1" cellspacing="0" cellpadding="2">\n );

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>\n";
}
print "</tr>";
			
$n=1;
%row = ();
foreach $idsample (@idsamples) {
$query = qq#
SELECT
s.name,s.pedigree,s.sex,e.sry,e.type,
(sum(x.alleles)-count(x.alleles)) as homx,
count(x.idsnvsample) as allx,
((sum(x.alleles)-count(x.alleles))/(count(x.alleles))) as hom2all
FROM snv v 
INNER JOIN snvsample              x ON v.idsnv = x.idsnv 
INNER JOIN $sampledb.sample       s ON s.idsample = x.idsample
INNER JOIN $sampledb.exomestat    e ON (s.idsample = e.idsample) 
WHERE x.alleles > 0
AND v.chrom = 'chrX'
AND v.start > 2700000
AND v.func != 'unknown'
AND snvqual >= 40
AND mapqual >= 55
AND s.idsample = ?
GROUP BY s.idsample
#;
#print "query = $query<br>";


$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsample) || die print "$DBI::errstr";
# alles in hash of arrays
while (@row = $out->fetchrow_array) {
	# addieren von n falls gleicher Wert
	$row{$row[-1]*1e9+$n}=[ @row ];
}
$n++;
} # end foreach

$n=1;
foreach $tmp (sort keys %row) {
	@row = @{ $row{$tmp} };
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>\n";
		}
		if (($row[7] < 0.85) and ($row[2] eq "male")) {
			print "<td class=\"warning\" align=\"center\"> $row[$i]</td>\n";
		}
		elsif (($row[7] > 0.50) and ($row[2] eq "female")) {
			print "<td class=\"warning\" align=\"center\"> $row[$i]</td>\n";
		}
		else {
			print "<td align=\"center\"> $row[$i]</td>\n";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>\n";

print "</td><td class=\"outer\">\n"; #outer table

my $subquerystop = "
(SELECT count(xx.idsnv) 
FROM snv vv 
INNER JOIN snvsample    xx on vv.idsnv = xx.idsnv 
INNER JOIN $sampledb.sample       ss on ss.idsample = xx.idsample
WHERE (FIND_IN_SET('nonsense',vv.func))
AND s.idsample=ss.idsample)
";
my $subquerysplice = "
(SELECT count(xx.idsnv) 
FROM snv vv 
INNER JOIN snvsample    xx on vv.idsnv = xx.idsnv 
INNER JOIN $sampledb.sample       ss on ss.idsample = xx.idsample
WHERE (FIND_IN_SET('splice',vv.func))
AND s.idsample=ss.idsample)
";
my $subqueryindel = "
(SELECT count(xx.idsnv) 
FROM snv vv 
INNER JOIN snvsample    xx on vv.idsnv = xx.idsnv 
INNER JOIN $sampledb.sample       ss on ss.idsample = xx.idsample
WHERE (FIND_IN_SET('indel',vv.func))
AND s.idsample=ss.idsample)
";
my $subqueryframeshift = "
(SELECT count(xx.idsnv) 
FROM snv vv 
INNER JOIN snvsample    xx on vv.idsnv = xx.idsnv 
INNER JOIN $sampledb.sample       ss on ss.idsample = xx.idsample
WHERE (FIND_IN_SET('frameshift',vv.func))
AND s.idsample=ss.idsample)
";
my $subqueryclassindel = "
(SELECT count(xx.idsnv) 
FROM snv vv 
INNER JOIN snvsample    xx on vv.idsnv = xx.idsnv 
INNER JOIN $sampledb.sample       ss on ss.idsample = xx.idsample
WHERE class='indel'
AND s.idsample=ss.idsample )
";


@labels	= (
	'n',
	'id',
	'Pedigree',
	'Sex',
	'Kit',
	'hom',
	'all',
	'hom/all',
	'avg coverage',
	'avg SNVqual',
	'stop',
	'splice',
	'indel',
	'frameshift',
	'classindel'
	);

print qq(<table border="1" cellspacing="0" cellpadding="2"> \n);
$i=0;

print "<tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>\n";
}
print "</tr>";

$n=1;
%row = ();
foreach $idsample (@idsamples) {
$query = qq#
SELECT
s.name,s.pedigree,s.sex,e.type,
(sum(x.alleles)-count(x.alleles)) as hom,
count(x.idsnvsample) as allsnv,
((sum(x.alleles)-count(x.alleles))/(count(x.alleles))) as hom2all,
round(avg(coverage)) as cov,
round(avg(snvqual))  as qual,
$subquerystop,
$subquerysplice,
$subqueryindel,
$subqueryframeshift,
$subqueryclassindel
FROM snv v 
INNER JOIN snvsample    x ON v.idsnv = x.idsnv 
INNER JOIN $sampledb.sample       s ON s.idsample = x.idsample
INNER JOIN $sampledb.exomestat    e ON s.idsample = e.idsample 
WHERE x.alleles > 0
AND v.func != 'unknown'
AND snvqual >= 40
AND mapqual >= 55
AND s.idsample = ?
GROUP BY s.idsample
#;
#print "query = $query<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($idsample) || die print "$DBI::errstr";

# alles in hash of arrays
while (@row = $out->fetchrow_array) {
	$row{$row[6]*1e9+$n}=[ @row ];
}
$n++
} #end foreach

$n=1;
foreach $tmp (sort keys %row) {
	@row = @{ $row{$tmp} };
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>\n";
		}
		print "<td align=\"center\"> $row[$i]</td>\n";
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</table>\n";
print "</td></tr>"; #outer table
print "</table>\n";


$out->finish;
}


########################################################################
# searchHGMD resultHGMD resultsHGMD resultsClinvar
########################################################################
sub searchHGMD {
my $self            = shift;
my $dbh             = shift;
my $ref             = shift;

my @labels          = ();
my $out             = "";
my @row             = ();
my $query           = "";
my $i               = 0;
my $n               = 1;
my $tmp             = "";
my $where           = "";
my $where_path      = "";
my $where_path_hgmd = "";
my @prepare         = ();
my $homozygous      = "";
my $allowedprojects = &allowedprojects("s.");
my $function        = "";
my $functionprint   = "";
my $class           = "";
my $classprint      = "";
my $clinvar         = "";


my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});



#############################################################

if ($ref->{agmd} ne "") {
	#$where .= "AND dg.iddisease=448 ";
	$where .= "AND dgd.name='AGMD' ";
}

if ($ref->{mode} eq "homozygous") {
	$homozygous=" HAVING ( count(DISTINCT v.chrom,v.start) >= 2)
	OR max(x.alleles) >= 2 ";
}

if ($ref->{'s.name'} ne "") {
	$where .= " AND s.name = ? ";
	push(@prepare,$ref->{'s.name'});
}
if ($ref->{'pedigree'} ne "") {
	$where .= " AND s.pedigree = ? ";
	push(@prepare,$ref->{'pedigree'});
}
if ($ref->{'idproject'} ne "") {
	$where .= " AND s.idproject = ? ";
	push(@prepare,$ref->{'idproject'});
}
if ($ref->{'ds.iddisease'} ne "") {
	$where .= " AND ds.iddisease = ? ";
	push(@prepare,$ref->{'ds.iddisease'});
}
if ($ref->{'s.idcooperation'} ne "") {
	$where .= " AND s.idcooperation = ? ";
	push(@prepare,$ref->{'s.idcooperation'});
}
if ($ref->{'freq'} ne "") {
	$where .= " AND freq <= ? ";
	push(@prepare,$ref->{'freq'});
}

($where,@prepare) = &defaultwhere($ref,$where,@prepare);


my $selection = $ref->{selection}; # inheritance mode
if (($selection eq "ad") or ($selection eq "ar") or ($selection eq "x")) {
	$where .= " AND FIND_IN_SET(?,omim.inheritance) ";
	push(@prepare,$selection);
}

$clinvar = $ref->{clinvar};
if ($clinvar == 1) {
	if ($where ne "") {
		$where_path .= " AND ";
		$where_path_hgmd .= " AND ";
	}
	$where_path .= " (cv.path like '%pathogenic%')  ";
	$where_path_hgmd .= " ISNULL(cv.path)  ";
}
if ($clinvar == 2) {
	if ($where ne "") {
		$where .= " AND ";
	}
	$where .= " (cv.path like '%uncertain%') ";
}

# class, function
($class,$classprint)=&class($ref->{'class'},$dbh);
($function,$functionprint)=&function($ref->{'function'},$dbh);

&todaysdate;
&numberofsamples($dbh);
&printqueryheader($ref,$classprint,$functionprint);

###################################
# important
# count(DISTINCT v.chrom,v.start)
# because it is possible 
# that two rs numbers are present
# at the same position with the same allele
# or
# at the same position with different alleles
# in snv
#
####################################
			
$i=0;

$query = qq#
SELECT 
group_concat(DISTINCT '<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>' separator '<br>'),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
s.pedigree,
s.sex,
d.symbol,
group_concat(DISTINCT $ucsclink separator '<br>'),
group_concat(DISTINCT c.rating separator '<br>'),
group_concat(DISTINCT c.patho separator '<br>'),
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(DISTINCT g.omim, ' '),
group_concat(distinct $mgiID separator " "),
group_concat(DISTINCT v.class separator '<br>'),
group_concat(DISTINCT v.func separator '<br>'),
group_concat(DISTINCT x.alleles separator '<br>'),
group_concat(DISTINCT f.fsample separator '<br>'),
group_concat(DISTINCT f.samplecontrols separator '<br>'),
group_concat(DISTINCT $exac_gene_link separator ' '),
group_concat(DISTINCT exac.mis_z separator ' '),
group_concat(DISTINCT  '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>' separator '<br>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT x.filter separator '<br>'),
group_concat(DISTINCT x.snvqual separator '<br>'),
group_concat(DISTINCT x.gtqual separator '<br>'),
group_concat(DISTINCT x.mapqual separator '<br>'),
group_concat(DISTINCT x.coverage separator '<br>'),
group_concat(DISTINCT x.percentvar separator '<br>'),
group_concat(DISTINCT replace(v.transcript,':','<br>') separator '<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>')
FROM  hgmd_pro.$hg19_coords h
INNER JOIN snv                         v ON (v.chrom      = h.chrom AND v.start = h.pos AND v.refallele=h.ref AND v.allele=h.alt)
INNER JOIN snvgene                     y ON (v.idsnv      = y.idsnv)
INNER JOIN gene                        g ON (y.idgene     = g.idgene)
INNER JOIN snvsample                   x ON (v.idsnv      = x.idsnv)
INNER JOIN $sampledb.sample            s ON (x.idsample   = s.idsample)
INNER JOIN $sampledb.disease2sample   ds ON (s.idsample   = ds.idsample)
INNER JOIN $sampledb.disease           d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup)
LEFT  JOIN disease2gene               dg ON (g.idgene=dg.idgene)
LEFT  JOIN $sampledb.disease         dgd ON (dg.iddisease=dgd.iddisease)
LEFT  JOIN $sampledb.mouse            mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
LEFT  JOIN $coredb.pph3              pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift             sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd             cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs               evs ON (v.chrom      = evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores        exac ON (g.genesymbol=exac.gene)
LEFT  JOIN $sampledb.omim           omim ON (g.omim       = omim.omimgene)
LEFT  JOIN $exomevcfe.comment          c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
LEFT  JOIN $coredb.clinvar            cv ON (v.chrom      = cv.chrom and v.start=cv.start and v.refallele=cv.ref and v.allele=cv.alt)
WHERE 
$allowedprojects
$where
$where_path_hgmd
$function
$class
GROUP BY s.idsample,g.genesymbol
$homozygous
UNION
SELECT 
group_concat(DISTINCT '<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>' separator '<br>'),
group_concat(DISTINCT '<a href="http://localhost:$igvport/load?file=',$igvserver2,'" title="Open sample in IGV"','>',s.name,'</a>' SEPARATOR '<br>'),
s.pedigree,
s.sex,
d.symbol,
group_concat(DISTINCT $ucsclink separator '<br>'),
group_concat(DISTINCT c.rating separator '<br>'),
group_concat(DISTINCT c.patho separator '<br>'),
group_concat(DISTINCT $genelink separator '<br>'),
group_concat(DISTINCT g.omim, ' '),
group_concat(distinct $mgiID separator " "),
group_concat(DISTINCT v.class separator '<br>'),
group_concat(DISTINCT v.func separator '<br>'),
group_concat(DISTINCT x.alleles separator '<br>'),
group_concat(DISTINCT f.fsample separator '<br>'),
group_concat(DISTINCT f.samplecontrols separator '<br>'),
group_concat(DISTINCT $exac_gene_link separator ' '),
group_concat(DISTINCT exac.mis_z separator ' '),
group_concat(DISTINCT  '<a href="http://$hgmdserver/hgmd/pro/mut.php?accession=',h.id,'">',h.id,'</a>' separator '<br>'),
group_concat(DISTINCT $clinvarlink separator '<br>'),
group_concat(DISTINCT $exac_link separator '<br>'),
group_concat(distinct g.nonsynpergene,' (', g.delpergene,')'),
group_concat(distinct dgv.depth),
group_concat(DISTINCT pph.hvar_prediction separator ' '),
group_concat(DISTINCT pph.hvar_prob separator ' '),
group_concat(DISTINCT sift.score separator ' '),
group_concat(DISTINCT cadd.phred separator ' '),
group_concat(DISTINCT x.filter separator '<br>'),
group_concat(DISTINCT x.snvqual separator '<br>'),
group_concat(DISTINCT x.gtqual separator '<br>'),
group_concat(DISTINCT x.mapqual separator '<br>'),
group_concat(DISTINCT x.coverage separator '<br>'),
group_concat(DISTINCT x.percentvar separator '<br>'),
group_concat(DISTINCT replace(v.transcript,':','<br>') separator '<br>'),
group_concat(DISTINCT $primer SEPARATOR '<br>')
FROM $coredb.clinvar            cv 
INNER JOIN snv                         v ON (v.chrom      = cv.chrom AND v.start = cv.start AND v.refallele=cv.ref AND v.allele=cv.alt)
INNER JOIN snvgene                     y ON (v.idsnv      = y.idsnv)
INNER JOIN gene                        g ON (y.idgene    = g.idgene)
INNER JOIN snvsample                   x ON (v.idsnv      = x.idsnv)
INNER JOIN $sampledb.sample            s ON (x.idsample   = s.idsample)
INNER JOIN $sampledb.disease2sample   ds ON (s.idsample   = ds.idsample)
INNER JOIN $sampledb.disease           d ON (ds.iddisease = d.iddisease)
LEFT  JOIN snv2diseasegroup            f ON (v.idsnv = f.fidsnv AND d.iddiseasegroup=f.fiddiseasegroup)
LEFT  JOIN disease2gene               dg ON (g.idgene=dg.idgene)
LEFT  JOIN $sampledb.disease         dgd ON (dg.iddisease=dgd.iddisease)
LEFT  JOIN $sampledb.mouse            mo ON (g.genesymbol = mo.humanSymbol)
LEFT  JOIN $coredb.dgvbp             dgv ON (v.chrom = dgv.chrom AND v.start=dgv.start)
LEFT  JOIN $coredb.pph3              pph ON (v.chrom=pph.chrom and v.start=pph.start and v.refallele=pph.ref and v.allele=pph.alt)
LEFT  JOIN $coredb.sift             sift ON (v.chrom=sift.chrom and v.start=sift.start and v.refallele=sift.ref and v.allele=sift.alt)
LEFT  JOIN $coredb.cadd             cadd ON (v.chrom=cadd.chrom and v.start=cadd.start and v.refallele=cadd.ref and v.allele=cadd.alt)
LEFT  JOIN $coredb.evs               evs ON (v.chrom      = evs.chrom and v.start=evs.start and v.refallele=evs.refallele and v.allele=evs.allele)
LEFT  JOIN $coredb.evsscores        exac ON (g.genesymbol=exac.gene)
LEFT  JOIN $sampledb.omim           omim ON (g.omim       = omim.omimgene)
LEFT  JOIN $exomevcfe.comment          c ON (v.chrom=c.chrom and v.start=c.start and v.refallele=c.refallele and v.allele=c.altallele and s.idsample=c.idsample)
LEFT  JOIN hgmd_pro.$hg19_coords       h ON (v.chrom      = h.chrom and v.start=h.pos and v.refallele=h.ref and v.allele=h.alt)
WHERE 
$allowedprojects
$where
$where_path
$function
$class
GROUP BY s.idsample,g.genesymbol
$homozygous
ORDER BY 9
#;
#print "query = $query<br>";
#print "prepare = @prepare<br>";
#print "where $where<br>";
#print "function $function<br>";
#print "class $class<br>";


$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,@prepare) || die print "$DBI::errstr";

# Now print table
(@labels) = &resultlabels();

$i=0;

&tableheaderResults();

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $program      = "";
my $damaging     = "";
my $omimmode     = "";
my $omimdiseases = "";
my $idsnv        = "";
# no mutalyzer for group by gene
# sub omim prepared for more than one omim entry split by space
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if (!defined($row[$i])) {$row[$i] = "";}
		if ($i == 0) { 
			print "<td align=\"center\">$n</td>";
		}
		if ($i == 9) {
			($tmp,$omimmode,$omimdiseases)=&omim($dbh,$row[$i]);
			print "<td align=\"center\">$tmp</td><td>$omimmode</td><td style='min-width:350px'>$omimdiseases</td>\n";
		}
		elsif (($i==24) or ($i==25)) {
			if ($i==24) {$program = 'polyphen2';}
			if ($i==25) {$program = 'sift';}
			$damaging=&damaging($program,$row[$i]);
			if ($damaging==1) {
				print "<td $warningtdbg>$row[$i]</td>";
			}
			else {
				print "<td> $row[$i]</td>";
			}
		}
		elsif ($i == 31) { # cnv exomedetph
			$tmp=$row[$i];
			if ($row[11] eq "cnv") {
				$tmp=$tmp/100;
			}
			print "<td>$tmp</td>";
		}
		elsif ($i == 33) { # cnv exomedetph
			print "<td align=\"center\" style='white-space:nowrap;'>$row[$i]</td>\n";
		}
		else {
			print "<td align=\"center\">$row[$i]</td>\n";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>\n";

$out->finish;
}
########################################################################
# searchSample resultsSamples
########################################################################
sub searchSample {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $field     = "";
my @values2   = ();
my $idsample  = "";
my $sname     = "";
my $pedigree  = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


if (exists($ref->{'idproject'})) {
	$ref->{'s.idproject'}=$ref->{'idproject'};
	delete($ref->{'idproject'});
}

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
my $allowedprojects = &allowedprojects("s.");


foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " s.entered >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " s.entered <= ? ";
			push(@values2,$values[$i]);
		}
		else {
			$where .= $field . " = ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
if ($where ne "") {
	$where .= " AND ";
}
#$where .= " libtype = 5 ";
$where .= $allowedprojects;
if ($where ne "") {
	$where = "WHERE  $where";
}

			
$i=0;
$query = qq#
SELECT
s.name,
concat_ws(' ',cl.solved, group_concat(DISTINCT co.genesymbol SEPARATOR '')),
h.idsample,
s.foreignid,
s.externalseqid,
s.pedigree,
s.sex,
s.saffected,
t.name,
concat(i.name,' (',i.symbol,')'),
p.pdescription,
group_concat(DISTINCT l.lstatus),
group_concat(DISTINCT s.nottoseq),
c.name,
s.scomment,
s.entered,
s.idsample
FROM
$sampledb.sample s 
LEFT  JOIN $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
LEFT  JOIN $sampledb.disease2sample ds ON s.idsample = ds.idsample
LEFT  JOIN $sampledb.disease         i ON ds.iddisease = i.iddisease
LEFT  JOIN $sampledb.tissue          t ON s.idtissue = t.idtissue
LEFT  JOIN $solexa.sample2library   sl ON s.idsample = sl.idsample
LEFT  JOIN $solexa.library           l ON sl.lid = l.lid
INNER JOIN $sampledb.project         p ON s.idproject=p.idproject
LEFT  JOIN $exomevcfe.conclusion    cl ON s.idsample=cl.idsample
LEFT  JOIN $exomevcfe.comment       co ON s.idsample=co.idsample
LEFT  JOIN $exomevcfe.hpo            h ON s.idsample=h.idsample
$where
GROUP BY s.name
ORDER BY
i.name,s.pedigree,s.name
#;
#print "query = $query<br>";
#print "values2 = @values2<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'ID Links',
	'<div class="tooltip">Con-<br>clusion<span class="tooltiptext">0 nothing_done<br>1 solved<br>2 not_solved<br>3 candidate<br>4 pending</span></div>',
	'HPO',
	'Foreign ID',
	'External<br>SeqID',
	'Pedigree',
	'Sex',
	'Affected',
	'Tissue',
	'Disease',
	'Project',
	'Status',
	'Not to<br>sequence',
	'Cooperation',
	'Comment',
	'Entered',
	'Internal ID'
	);

&tableheaderDefault("1500px");
$i=0;

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	$idsample = $row[16];
	$pedigree = $row[5];
	$sname    = $row[0];
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print qq#
			<td style='white-space:nowrap;'>
			<div class="dropdown">
			$row[$i]&nbsp;&nbsp;
			<img style='width:14pt;height:14pt;' src="/EVAdb/evadb_images/down-squared.png" title="Links to analysis functions" onclick="myFunction($n)" class="dropbtn" />
			<div id="myDropdown$n" class="dropdown-content">
			        <a href='search.pl?pedigree=$pedigree'>Autosomal dominant</a>
				<a href='searchGeneInd.pl?pedigree=$sname'>Autosomal recessive</a>
				<a href='searchTrio.pl?pedigree=$sname'>De novo trio</a>
				<a href='searchTumor.pl?pedigree=$sname'>Tumor/Control</a>
				<a href='searchDiseaseGene.pl?sname=$sname'>Disease panels</a>
				<a href='searchHGMD.pl?sname=$sname'>ClinVar/HGMD</a>
				<a href='searchOmim.pl?sname=$sname'>OMIM</a>
				<a href='searchHPO.pl?sname=$sname'>HPO</a>
				<a href='searchDiagnostics.pl?sname=$sname'>Coverage lists</a>
				<a href='searchHomo.pl?sname=$sname'>Homozygosity</a>
				<a href='searchCnv.pl?sname=$sname'>CNV</a>
				#;
				if ($contextM eq "contextMg") { # is genome
					print qq#
					<a href='searchSv.pl?sname=$sname'>Structural variants</a>
					#;
				}
				print qq#
				<a href='searchSample.pl?pedigree=$pedigree'>Sample information</a>
				<a href='conclusion.pl?idsample=$idsample'>Sample conclusions</a>
				<a href='report.pl?sname=$sname'>Report</a>
				#;
				if ($role eq "admin" || $role eq "manager" ){
                                        print qq#
                                        <a href='wrapper.pl?sname=$sname&file=merged.rmdup.bam'>Download BAM</a>
                                        #;
                                }
                                print qq#
			</div>
			</div>
			</td>
			#;
		}
		elsif ($i == 2) { # HPO
			if ($row[$i] ne "") {
				print "<td><a href='showHPO.pl?idsample=$row[$i]'>HPO</a></td>";
			}
			else {
				print "<td><a href='importHPO.pl?sname=$sname'>New</a></td>";
			}
		}
		elsif ($i == 5 ){
			print qq#
				<td><a href='searchSample.pl?pedigree=$pedigree'>$pedigree</a></td>
			#;
		}
		else {
			print "<td> $row[$i] </td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


$out->finish;
}
########################################################################
# searchDiffEx resultsDiffEx
########################################################################
sub searchDiffEx {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $field     = "";
my @values2   = ();
my $idsample  = "";
my $pedigree  = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});

print $cgi->csrf_field, "\n";
$csrf_token = generate_csrf_token($user, $csrfsalt);
print qq(
<input name="wwwcsrf" type= "hidden" value="$csrf_token">
);


print "<input type=\"submit\" name=\"diffEx\" value=\"Differential Expession\" >";
print "<br><br>";
print "<input type=\"radio\"  name=\"fcshrinkage\" value=\"yes\" checked> Fold-change shrinkage (default)<br>";
print "<input type=\"radio\"  name=\"fcshrinkage\" value=\"no\"> No fold-change shrinkage";
print "<br><br>";

if (exists($ref->{'idproject'})) {
	$ref->{'s.idproject'}=$ref->{'idproject'};
	delete($ref->{'idproject'});
}

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
my $allowedprojects = &allowedprojects("s.");


foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " s.entered >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " s.entered <= ? ";
			push(@values2,$values[$i]);
		}
		else {
			$where .= $field . " = ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
if ($where ne "") {
	$where .= " AND ";
}
#$where .= " libtype = 5 ";
$where .= $allowedprojects;
if ($where ne "") {
	$where = "WHERE  $where";
}

			
$i=0;
$query = qq#
SELECT
s.name,
s.foreignid,s.pedigree,s.sex,s.saffected,o.orname,t.name,a.name,
concat(i.name,' (',i.symbol,')'),p.pdescription,group_concat(l.lstatus),
group_concat(s.nottoseq),c.name,s.scomment,s.entered,
s.idsample
FROM
$sampledb.sample s 
LEFT  JOIN  $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
LEFT  JOIN  $sampledb.disease2sample ds ON s.idsample      = ds.idsample
LEFT  JOIN  $sampledb.disease         i ON ds.iddisease    = i.iddisease
LEFT  JOIN  $sampledb.tissue          t ON s.idtissue      = t.idtissue
LEFT  JOIN  $solexa.sample2library   sl ON s.idsample      = sl.idsample
LEFT  JOIN  $solexa.library           l ON sl.lid          = l.lid
INNER JOIN $sampledb.project          p ON s.idproject     = p.idproject
LEFT  JOIN $exomevcfe.conclusion     cl ON s.idsample      = cl.idsample
INNER JOIN $sampledb.rnaseqcstat     rs ON s.idsample      = rs.idsample
INNER JOIN $sampledb.exomestat        e ON s.idsample      = e.idsample
LEFT  JOIN $solexa.assay              a ON e.idassay       = a.idassay
INNER JOIN $sampledb.organism         o ON s.idorganism    = o.idorganism
$where
GROUP BY s.name
ORDER BY
i.name,s.pedigree,s.name
#;
#print "query = $query<br>";
#print "values2 = @values2<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Cases',
	'Controls',
	'ID Links',
	'Foreign Id',
	'Pedigree',
	'Sex',
	'Affected',
	'Organism',
	'Tissue',
	'Assay',
	'Disease',
	'Project',
	'Status',
	'No to<br>sequence',
	'Cooperation',
	'Comment',
	'Entered',
	'Internal ID'
	);

&tableheaderDefault("1500px");
$i=0;

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $tmpcases    = "";
my $tmpcontrols = "";
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	$idsample = $row[13];
	$pedigree = $row[3];
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			$tmpcases    = join("###",$row[$i]);
			$tmpcontrols = join("###",$row[$i]);
			print "<td align=\"center\"><input type=\"checkbox\" name=\"cases\" value=\"$tmpcases\"></td>";
			print "<td align=\"center\"><input type=\"checkbox\" name=\"controls\" value=\"$tmpcontrols\"></td>";
			print "<td align=\"center\">$row[$i]</td>";
		}
		else {
			print "<td> $row[$i] </td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


$out->finish;
}
########################################################################
# searchDiffEx resultsDiffPeak
########################################################################
sub searchDiffPeak {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $out       = "";
my @row       = ();
my $query     = "";
my $i         = 0;
my $n         = 1;
my $where     = "";
my $field     = "";
my @values2   = ();
my $idsample  = "";
my $pedigree  = "";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});

print $cgi->csrf_field, "\n";
$csrf_token = generate_csrf_token($user, $csrfsalt);
print qq(
<input name="wwwcsrf" type= "hidden" value="$csrf_token">
);

print "<input type=\"submit\" name=\"diffPeak\" value=\"Differential Peak Calling\" >";
print "<br><br>";
print "<input type=\"radio\"  name=\"peaktype\" value=\"yes\" checked> Narrow peak<br>";
print "<input type=\"radio\"  name=\"peaktype\" value=\"no\"> Broad peak";
print "<br><br>";

if (exists($ref->{'idproject'})) {
	$ref->{'s.idproject'}=$ref->{'idproject'};
	delete($ref->{'idproject'});
}

my @fields    = sort keys %$ref;
my @values    = @{$ref}{@fields};
my $allowedprojects = &allowedprojects("s.");


foreach $field (@fields) {
	unless ($values[$i] eq "") {
		if ($where ne "") {
			$where .= " AND ";
		}
		if ($field eq "datebegin") {
			$where .= " s.entered >= ? ";
			push(@values2,$values[$i]);
		}
		elsif ($field eq "dateend") {
			$where .= " s.entered <= ? ";
			push(@values2,$values[$i]);
		}
		else {
			$where .= $field . " = ? ";
			push(@values2,$values[$i]);
		}
	}
	$i++;
}
if ($where ne "") {
	$where .= " AND ";
}
#$where .= " libtype = 5 ";
$where .= $allowedprojects;
if ($where ne "") {
	$where = "WHERE  $where";
}

			
$i=0;
$query = qq#
SELECT
s.name,
s.foreignid,s.pedigree,s.sex,s.saffected,o.orname,t.name,a.name,
concat(i.name,' (',i.symbol,')'),p.pdescription,group_concat(l.lstatus),
group_concat(s.nottoseq),c.name,s.scomment,s.entered,
s.idsample
FROM
$sampledb.sample s 
LEFT  JOIN  $sampledb.cooperation     c ON s.idcooperation = c.idcooperation
LEFT  JOIN  $sampledb.disease2sample ds ON s.idsample      = ds.idsample
LEFT  JOIN  $sampledb.disease         i ON ds.iddisease    = i.iddisease
LEFT  JOIN  $sampledb.tissue          t ON s.idtissue      = t.idtissue
LEFT  JOIN  $solexa.sample2library   sl ON s.idsample      = sl.idsample
LEFT  JOIN  $solexa.library           l ON sl.lid          = l.lid
INNER JOIN  $sampledb.project         p ON s.idproject     = p.idproject
LEFT  JOIN  $exomevcfe.conclusion    cl ON s.idsample      = cl.idsample
INNER JOIN  $sampledb.chipseqstats   cs ON s.idsample      = cs.idsample
INNER JOIN  $sampledb.exomestat       e ON s.idsample      = e.idsample
LEFT  JOIN  $solexa.assay             a ON e.idassay       = a.idassay
INNER JOIN  $sampledb.organism        o ON s.idorganism    = o.idorganism
$where
GROUP BY s.name
ORDER BY
i.name,s.pedigree,s.name
#;
#print "query = $query<br>";
#print "values2 = @values2<br>";

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@values2) || die print "$DBI::errstr";

@labels	= (
	'n',
	'Cases',
	'Controls',
	'ID Links',
	'Foreign Id',
	'Pedigree',
	'Sex',
	'Affected',
	'Organism',
	'Tissue',
	'Assay',
	'Disease',
	'Project',
	'Status',
	'No to<br>sequence',
	'Cooperation',
	'Comment',
	'Entered',
	'Internal ID'
	);

&tableheaderDefault("1500px");
$i=0;

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;
my $tmpcases    = "";
my $tmpcontrols = "";
while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	$idsample = $row[13];
	$pedigree = $row[3];
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			$tmpcases    = join("###",$row[$i]);
			$tmpcontrols = join("###",$row[$i]);
			print "<td align=\"center\"><input type=\"checkbox\" name=\"cases\" value=\"$tmpcases\"></td>";
			print "<td align=\"center\"><input type=\"checkbox\" name=\"controls\" value=\"$tmpcontrols\"></td>";
			print "<td align=\"center\">$row[$i]</td>";
		}
		else {
			print "<td> $row[$i] </td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";


$out->finish;
}
########################################################################
# getRole
########################################################################
sub getRole {
	return $role;
}
########################################################################
# isEdit
########################################################################
sub isEdit {
	return $dbedit;
}
########################################################################
#  canDownload
########################################################################
sub canDownload {
my $self         = shift;
my $sname        = shift;
my $dbh          = shift;
my $canDownload  = 0;
my $out;


my $query = qq#
SELECT dw.iduser is not null download
FROM $sampledb.sample s
LEFT JOIN $exomevcfe.download  dw ON ( s.idsample = dw.idsample OR s.idproject = dw.idproject and NOW()>=dw.startdate and NOW()<=dw.enddate and dw.iduser=(select iduser FROM $exomevcfe.user where name='$user' ))
WHERE s.name = ?
#;


#print "<br>query $query $idsample<br>";
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($sname) || die print "$DBI::errstr";
$canDownload = $out->fetchrow_array;

$canDownload = 1 if ( getRole() eq "admin" || getRole() eq "manager" );

return($canDownload);

}
########################################################################
# allowedSampleName
########################################################################
sub allowedSampleName {
	my $dbh             = shift;
	my $samplename      = shift;
	my $allowedprojects = &allowedprojects("");
	my $out             = "";
	my $tmp             = "";
	my $query ="
	SELECT name
	FROM $sampledb.sample
	WHERE name = ?
	AND $allowedprojects
	";
	$out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute($samplename) || die print "$DBI::errstr";
	$tmp = $out->fetchrow_array;
	if ($tmp eq "") {
		print "$samplename not allowed<br>";
	}
}
########################################################################
# searchDiffExDoDo resultsDiffExDoDo
########################################################################
sub searchDiffExDoDo {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;
my $casesref     = shift;
my $controlsref  = shift;
my (@cases)      = @$casesref;
my (@controls)   = @$controlsref;
my $tmpcases     = "";
my $tmpcontrols  = "";
my $n            = 0;
my $i            = 0;
my @row          = ();
my $ppid         = getppid;
my $mytime       = time;
my $outfile      = "/srv/tmp/diffex$ppid$mytime";
#my $outfile      = "/tmp/diffex";


my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});


print "Reads mapping to annotated genes are quantified with HTseq-count 
(PMID <a href=https://www.ncbi.nlm.nih.gov/pubmed/25260700>25260700</a>).
The Relative Log Expression (RLE) normalization implemented in the R Bioconductor package DESeq2 
(PMID <a href=https://www.ncbi.nlm.nih.gov/pubmed/25516281>25516281</a>) is used to normalize gene counts.
<br><br>";

my $fcshrinkage=$ref->{fcshrinkage};

my @cmd = ("/usr/bin/perl");
push (@cmd, "$performDEAnalysis");
print "Cases: ";
foreach(@cases) {
	&allowedSampleName($dbh,$_);
	print "$_ ";
	$tmpcases    .= " -ca $_ ";
	push (@cmd, "-ca");
	push (@cmd, "$_");
}
print "<br>";
print "Controls: ";
foreach(@controls) {
	&allowedSampleName($dbh,$_);
	print "$_ ";
	$tmpcontrols .= " -co $_ ";
	push (@cmd, "-co");
	push (@cmd, "$_");
}
push (@cmd, "-e");
push (@cmd, "diffEx");
push (@cmd, "-o");
push (@cmd, "$outfile");
if ($fcshrinkage eq "no") {
	push (@cmd, "-nofcs");
}
my $cmd = join " ", @cmd;
$ENV{'PATH'} = "/usr/local/bin:/usr/bin";
my $error = system ($cmd);
#my $error = system (@cmd);
#system ("$performDEAnalysis $tmpcases $tmpcontrols -e diffEx -o $outfile");

$outfile .= "/DESeq2";
print "<br>";
my $height = 400;
my $width  = 400;
print "<table>";
print "
	<tr>
	<td><img src=\"readPng2.pl?file=$outfile/EstimatedDispersion.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/PCA.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/heatmap.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	</tr>
	<tr>
	<td width=\"$width\" valign=\"top\"><b>Estimated Dispersion.</b> The plot shows the gene-wise estimated dispersion (black), 
	the fitted dispersion values (red), and the final estimates used in testing (blue).</td>
	<td width=\"$width\" valign=\"top\"><b>PCA.</b> The principal component analysis plot displays the overall effect of 
		experimental covariates and batch effects. 
		Plotted is the first (x-axis) versus the second (y-axis) principal component.</td>
	<td width=\"$width\" valign=\"top\"><b>Sample-to-Sample Distance Heatmap.</b> The heatmap displays the Euclidean distances between 
		the samples which are calculated using the RLE normalized gene expression counts.</td>
	</tr>
	<tr>
	<td><img src=\"readPng2.pl?file=$outfile/MAPlot.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/top1000_rowMeans_HeatMap.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/top100_de_HeatMap.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	</tr>
	<tr>
	<td width=\"$width\" valign=\"top\"><b>MA-plot</b> The plot shows the log2 fold changes over the mean of normalized counts. Each dot 
		represents a single gene. log2 fold changes are calculated as the average gene expression ratio of the case- versus the control group.</td>
	<td width=\"$width\" valign=\"top\"><b>Hierarchical clustering</b> of the 100 most expressed genes visualized as heat map.</td>
	<td width=\"$width\" valign=\"top\"><b>Hierarchical clustering</b> of the top 100 up- and downregulated genes visualized as heat map.</td>
	</tr>
	<tr>
	<td><img src=\"readPng2.pl?file=$outfile/volcanoPlot.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/pValueHistogram.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/pAdjHistogram.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	</tr>
	<tr>
	<td width=\"$width\" valign=\"top\"><b>Volcano plot.</b> The plot displays the log 2 fold expression change (x-axis) versus the 
		p-value (y-axis). Each dot represents a single gene. The red dots highlight genes above a p-value
		of 0.01 and above a two-fold expression change.</td>
	<td width=\"$width\" valign=\"top\"><b>p-value histogram</b> showing the distribution of the p-values.</td>
	<td width=\"$width\" valign=\"top\"><b>Adjusted p-value histogram.</b> The histogram shows the distribution of the Benjamini-Hochberg 
		corrected p-values (false discovery rate 0.1).</td>
	</tr>
";
print "</table>";
print "<br><br>";

my @labels	= (
	'n',
	'Gene',
	'baseMean',
	'log2FoldChange',
	'lfcSE',
	'pvalue',
	'padj',
	'regulation'
);

&tableheaderDefault("1000px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

open(IN, "<", "$outfile/diffEx.csv");
while (<IN>) {
	$n++;
	if ($n<=1) {next;}
	s/\"//g;
	@row=split(/\,/);
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i==0) {
			print "<td>$n</td>";
		}
		print "<td>$_</td>";
		$i++;
	}
	print "</tr>";
}

print "</tbody></table></div>";

close IN;
	
}

########################################################################
# searchDiffExDoDo resultsDiffPeakDoDo
########################################################################
sub searchDiffPeakDoDo {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;
my $casesref     = shift;
my $controlsref  = shift;
my (@cases)      = @$casesref;
my (@controls)   = @$controlsref;
my $tmpcases     = "";
my $tmpcontrols  = "";
my $n            = 0;
my $i            = 0;
my @row          = ();
my $ppid         = getppid;
my $mytime       = time;
my $outfile      = "/srv/tmp/diffex$ppid$mytime";
#my $outfile      = "/srv/tmp/diffex";

my $cgi          = new CGI::Plus;
$cgi->csrf(1);
if (! $cgi->csrf_check)
    { die 'security error' }
delete($ref->{csrf});
my $csrf_token = $ref->{wwwcsrf};
my $status = check_csrf_token($user, $csrfsalt, $csrf_token,\%options);
die "Wrong CSRF token" unless ($status == CSRF_OK);
delete($ref->{wwwcsrf});

print "Calculating differentially bound sites which can take up to 15 minutes. Please wait ... 
<br><br>";

print "Peaks are called with MACS2 (PMID: <a href=https://www.ncbi.nlm.nih.gov/pubmed/18798982>18798982</a>). To compute differentially bound 
sites from multiple ChIP-seq experiments the R Bioconductor package DiffBind 
(Bioconductor: <a href=https://bioconductor.org/packages/release/bioc/html/DiffBind.html>DiffBind</a>) is used<br>and reported peaks are annotated
with the R Bioconductor package ChIPseeker (Bioconductor: <a href=http://bioconductor.org/packages/release/bioc/html/ChIPseeker.html>ChIPseeker</a>) and 
ChIPpeakAnno (Bioconductor: <a href=http://bioconductor.org/packages/release/bioc/html/ChIPpeakAnno.html>ChIPpeakAnno</a>).
<br><br>";

my $peaktype=$ref->{peaktype};

my @cmd = "/usr/bin/perl";
push (@cmd, "$performDiffPeakCalling");
print "Cases: ";
foreach(@cases) {
	&allowedSampleName($dbh,$_);
	print "$_ ";
	$tmpcases    .= " -ca $_ ";
	push (@cmd, "-ca");
	push (@cmd, "$_");
}
print "<br>";
print "Controls: ";
foreach(@controls) {
	&allowedSampleName($dbh,$_);
	print "$_ ";
	$tmpcontrols .= " -co $_ ";
	push (@cmd, "-co");
	push (@cmd, "$_");
}
push (@cmd, "-e");
push (@cmd, "diffPeak");
push (@cmd, "-o");
push (@cmd, "$outfile");
push (@cmd, "-s");
push (@cmd, "human");
if ($peaktype eq "no") {
	push (@cmd, "-b");
}
$ENV{'PATH'} = "/usr/local/bin:/usr/bin";
system (@cmd);
#system ("$performDEAnalysis $tmpcases $tmpcontrols -e diffEx -o $outfile");

print "<br>";
my $height = 400;
my $width  = 400;
print "<table>";
print "
	<tr>
	<td><img src=\"readPng2.pl?file=$outfile/Heatmap_ob.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/PCA_ob.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/Peak_annotation_bar.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	</tr>
	<tr>
	<td width=\"$width\" valign=\"top\"><b>Sample-to-Sample Distance Heatmap.</b> The heatmap displays the distances between the samples which are calculated based on called peaks.</td>
	<td width=\"$width\" valign=\"top\"><b>PCA.</b> The principal component analysis plot displays the overall effect of experimental covariates and batch effects. Plotted is the first (x-axis) versus the second (y-axis) principal component.</td>
	<td width=\"$width\" valign=\"top\"><b>Genomic Annotation Barplot.</b> This plot shows the distribution of peaks over different types of genomic features.</td>
	</tr>
	<tr>
	<td><img src=\"readPng2.pl?file=$outfile/Peak_annotation_pie.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/Peak_distance2TSS.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/Peak_overview.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	</tr>
	<tr>
	<td width=\"$width\" valign=\"top\"><b>Genomic Annotation Piechart.</b> This plot shows the distribution of peaks over different types of genomic features.</td>
	<td width=\"$width\" valign=\"top\"><b>Distribution of binding loci relative to TSS.</b> The distance from the peak to the TSS of the nearest gene is calculated and the percentage of binding sites upstream and downstream from the TSS of the nearest genes are plotted.</td>
	<td width=\"$width\" valign=\"top\"><b>ChIP peaks coverage plot</b> shows the coverage of peak regions over chromosomes</td>
	</tr>
	<tr>
	<td><img src=\"readPng2.pl?file=$outfile/Peak_upsetplot_pie.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/Peak_upsetplot.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	<td><img src=\"readPng2.pl?file=$outfile/Peak_featureBarplot.png\" height=\"$height\" width=\"$width\" alt=\"Plot missing.\"></td>
	</tr>
	<tr>
	<td width=\"$width\" valign=\"top\"><b>Genomic Annotation Overlaps.</b> This plot shows the distribution of peaks over different types of genomic features (including information if features overlap).</td>
	<td width=\"$width\" valign=\"top\"><b>Genomic Annotation Overlaps.</b> This plot shows the distribution of peaks over different types of genomic features (including information if features overlap).</td>
	<td width=\"$width\" valign=\"top\"><b>Feature barplot.</b> The barplot summarizes the distribution of peaks over different type of genomic features.</td>
	</tr>
";
print "</table>";
print "<br><br>";

my @labels	= (
	'n',
	'seqnames',
	'start',
	'end','width',
	'strand','Conc',
	'Conc_case',
	'Conc_control',
	'Fold',
	'p.value',
	'FDR',
	'feature',
	'peak',
	'feature.ranges.start',
	'feature.ranges.end',
	'feature.ranges.width',
	'feature.strand',
	'distance',
	'insideFeature',
	'distanceToStart',
	'gene_name','genename',
	'refseq',
	'symbol',
	'entrez_id'
);

&tableheaderDefault("1000px");
print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>\n";

open(IN, "<", "$outfile/anno.csv");
while (<IN>) {
	$n++;
	if ($n<=1) {next;}
	s/\"//g;
	@row=split(/\,/);
	print "<tr>";
	$i=0;
	foreach (@row) {
		#if ($i==0) {
		#	print "<td>$n</td>";
		#}
		print "<td>$_</td>";
		$i++;
	}
	print "</tr>";
}

print "</tbody></table></div>";

close IN;
	
}
########################################################################
# searchIbs resultsIbs
########################################################################
sub searchResultsIbs {
my $self         = shift;
my $dbh          = shift;
my $ref          = shift;

my @labels    = ();
my $n         = 0;
my $i         = 0;
my $out       = "";
my @row       = ();
my $query     = "";
my $ibs       = "";
my $where     = "";
my $qualtype  = ""; # snvqual or gtqual
my @prepare   = ();
my $sample1   = ($ref->{'sample1'});
my $sample2   = ($ref->{'sample2'});
my $idsample1 = getIdsampleByName($dbh,$sample1);
my $idsample2 = getIdsampleByName($dbh,$sample2);
my $allowedprojects = &allowedprojects("s.");
my $maxfreq   = 0;
my $nsnvs     = 0;
my $nsamples  = 0;
my $alleles   = "";

if ( ($idsample1 ne "") and ($idsample2 ne "") ){
	push(@prepare,$idsample1,$idsample2);
}
else {
	print "Sample IDs missing.<br>";
	exit;
}

# nsamples maxfreq
$query = qq#
SELECT count(DISTINCT idsample) FROM snvsample
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$nsamples = $out->fetchrow_array;
$maxfreq = int($nsamples/5); # 20%

if ($ref->{'alleles'} ne "") {
	$alleles = "AND x2.alleles >= ? ";
	push(@prepare,$ref->{'alleles'});
	$where .= "AND x.alleles >= ? ";
	push(@prepare,$ref->{'alleles'});
}
if ($ref->{'freq'} ne "") {
	$where .= "AND v.freq > ? ";
	push(@prepare,$ref->{'freq'});
}
if ($ref->{'freqmax'} ne "") {
	$where .= "AND v.freq < ? ";
	push(@prepare,$ref->{'freqmax'});
}
else {
	$where .= "AND v.freq < ? ";
	push(@prepare,$maxfreq);
	$where .= "AND v.af < ? ";
	push(@prepare,0.2);
}
if ($ref->{'snvqual'} ne "") {
	$where .= "AND x.snvqual >= ? ";
	push(@prepare,$ref->{'snvqual'});
}
if ($ref->{'gtqual'} ne "") {
	$where .= "AND x.gtqual >= ? ";
	push(@prepare,$ref->{'gtqual'});
}
if ($ref->{'mapqual'} ne "") {
	$where .= "AND x.mapqual >= ? ";
	push(@prepare,$ref->{'mapqual'});
}
if ($ref->{'coverage'} ne "") {
	$where .= "AND x.coverage >= ? ";
	push(@prepare,$ref->{'coverage'});
}
if ($ref->{'filter'} ne "") {
	$where .= "AND x.filter = ? ";
	push(@prepare,$ref->{'filter'});
}
if ($ref->{'percentvar'} ne "") {
	$where .= "AND x.percentvar >= ? ";
	push(@prepare,$ref->{'percentvar'});
}


$query = qq#
SELECT COUNT(co1), COUNT(co2) FROM
(
SELECT (x.idsnv) as co1, 
(SELECT COUNT(x2.idsnv) FROM snvsample x2 use index(idsnvidsample)
WHERE (x2.idsample=? or x2.idsample= ?)
AND x.idsnv = x2.idsnv
$alleles
GROUP BY x2.idsnv 
HAVING count(x2.idsample)=2
) as co2
FROM snvsample x 
INNER JOIN snv              v ON x.idsnv=v.idsnv 
INNER JOIN $sampledb.sample s ON x.idsample=s.idsample 
WHERE $allowedprojects
AND v.class = "snp"
$where
AND x.idsample=?
LIMIT 60000
) tmp
#;

$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,$idsample1) || die print "$DBI::errstr";
($nsnvs,$ibs) = $out->fetchrow_array;

$ibs = sprintf( "%.2f", $ibs/$nsnvs);

print "$sample1 and $sample2 share $ibs of alternative alleles of SNVs.<br>";
print "<br>Parent/child pairs and sibs share approximately 50% of SNVs.<br>";
print "Unrelated pairs share approximately 17% of SNVs.<br><br>";
print "$nsnvs SNVs matching following criteria were used for the comparison.<br>";
print "Frequency > $ref->{'freq'}<br>";
print "Frequency < $maxfreq<br>";
print "Filter  = $ref->{'filter'}<br>";
print "depth   >= $ref->{'coverage'}<br>";
print "snvqual >= $ref->{'snvqual'}<br>";
print "gtqual  >= $ref->{'gtqual'}<br>";
print "mapqual >= $ref->{'mapqual'}<br>";
print "percentvar >= $ref->{'percentvar'}<br>";
print "<br><br>$query<br>Params<br>".join(" - ", @prepare)." - $idsample1<br>" if ($role eq "admin");
$query = qq#
SELECT 
CONCAT('<a href="listPosition.pl?idsnv=',v.idsnv,'" title="All carriers of this variant">',v.idsnv,'</a>'),
v.chrom,v.start,v.freq,x.snvqual,x.gtqual, x.mapqual, x.coverage, x.percentvar,
(SELECT COUNT(x2.idsnv) FROM snvsample x2 use index(idsnvidsample)
WHERE (x2.idsample=? or x2.idsample= ?)
AND x.idsnv = x2.idsnv
$alleles
GROUP BY x2.idsnv 
HAVING count(x2.idsample)=2
) as co2
FROM snvsample x 
INNER JOIN snv              v ON x.idsnv=v.idsnv 
INNER JOIN $sampledb.sample s ON x.idsample=s.idsample 
WHERE $allowedprojects
AND v.class = "snp"
$where
AND x.idsample=?
ORDER BY v.chrom,v.start
LIMIT 60000
#;
$out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute(@prepare,$idsample1) || die print "$DBI::errstr";

@labels	= (
	'n',
	'SNV ID',
	'Chromosome',
	'Position',
	'Frequency',
	'SNV qual',
	'GT qual',
	'Map qual',
	'Depth',
	'Percentvar',
	'Count'
	);

&tableheaderDefault("1000px");
$i=0;

print "<thead><tr>";
foreach (@labels) {
	print "<th align=\"center\">$_</th>";
}
print "</tr></thead><tbody>";

$n=1;

while (@row = $out->fetchrow_array) {
	print "<tr>";
	$i=0;
	foreach (@row) {
		if ($i == 0) { #edit project
			print "<td align=\"center\">$n</td>";
			print "<td align=\"center\"> $row[$i] </td>";
		}
		else {
			print "<td align=\"center\"> $row[$i] </td>";
		}
		$i++;
	}
	print "</tr>\n";
	$n++;
}
print "</tbody></table></div>";

$out->finish;
}


########################################################################
# tableheaderResults
########################################################################
sub tableheaderResults {
my $width   = shift;
my $numeric = shift;
my $string  = shift;
my $html    = shift;
my $mode    = shift;  # for burden test
my $buf     = "";

if (!defined($width)) {$width = "style='width:1900px;'";}
$buf = "<br><br>";
if ($width eq "650px") {
	$width = "style='width:650px'";
}
elsif ($width eq "1000px") {
	$width = "style='width:1000px'";
}
elsif ($width eq "1500px") {
	$width = "style='width:1500px'";
}
elsif ($width eq "1750px") {
	$width = "style='width:1750px'";
}
elsif ($width eq "2000px") {
	$width = "style='width:2000px'";
}

$buf .= qq(
<div id="container" $width>
<div>
Toggle columns: 
  <a class="toggle-vis" data_column="3,4,5">Personal Inf.</a>
- <a class="toggle-vis" data_column="7,8">Comments</a>
- <a class="toggle-vis" data_column="11,12">Omim</a>
- <a class="toggle-vis" data_column="13">Mouse</a>
- <a class="toggle-vis" data_column="24">NonSyn/Gene</a>
- <a class="toggle-vis" data_column="25">DGV</a>
- <a class="toggle-vis" data_column="26,27,28,29">Predictions</a>
- <a class="toggle-vis" data_column="30,31,32,33,34,35">Quality</a>
- <a class="toggle-vis" data_column="37">Primer</a>
</div>
<br>

<table id="results" numeric="$numeric" string="$string" html="$html" cellspacing="0" class="display compact" style="width:100%"> 
);


if ($mode eq "") {
	print $buf;
}
else {
	return $buf;
}

}

########################################################################
# tableheaderDefault
########################################################################
sub tableheaderDefault {
my $width   = shift;
my $numeric = shift;
my $string  = shift;
my $html    = shift;
my $mode    = shift;  # for burden test
my $buf     = "";

if (!defined($width)) {$width = "";}
$buf = "<br><br>";
if ($width eq "650px") {
	$width = "style='width:650px'";
}
elsif ($width eq "1000px") {
	$width = "style='width:1000px'";
}
elsif ($width eq "1500px") {
	$width = "style='width:1500px'";
}
elsif ($width eq "1750px") {
	$width = "style='width:1750px'";
}
elsif ($width eq "2000px") {
	$width = "style='width:2000px'";
}

$buf .= qq(
<div id="container" $width>
<table id="default" numeric="$numeric" string="$string" html="$html" cellspacing="0" class="display compact" width="100%"> 
);

if ($mode eq "") {
	print $buf;
}
else {
	return $buf;
}

}

########################################################################
# tableheaderDefault_new
########################################################################
sub tableheaderDefault_new {
my $tableid = shift;
my $width   = shift;
my $numeric = shift;
my $string  = shift;
my $html    = shift;
my $mode    = shift;  # for burden test
my $buf     = "";
if ($tableid eq "") {
	$tableid = "table01";
}

if (!defined($width)) {$width = "";}
$buf = "<br><br>";
if ($width eq "650px") {
	$width = "style='width:650px;'";
}
elsif ($width eq "1000px") {
	$width = "style='width:1000px'";
}
elsif ($width eq "1500px") {
	$width = "style='width:1500px'";
}
elsif ($width eq "1750px") {
	$width = "style='width:1750px'";
}
elsif ($width eq "2000px") {
	$width = "style='width:2000px'";
}


$buf .= qq(
<div id="container1" $width>
<table id="$tableid" numeric="$numeric" string="$string" html="$html" cellspacing="0" class="compact display" width="100%">
);

if ($mode eq "") {
	print $buf;
}
else {
	return $buf;
}

}

########################################################################
# callVCF
########################################################################

sub callvcf {
my $idsamplesvcf = shift;
my $idsnvsvcf    = shift;

print "<br><form action=\"printVCF.pl\" method=\"post\">" ;
print "<input type=\"hidden\"  name=\"idsamplesvcf\" value=\"$idsamplesvcf\">";
print "<input type=\"hidden\"  name=\"idsnvsvcf\" value=\"$idsnvsvcf\">";
print "<input type=\"submit\" value=\"VCF file\">";
print "</form>" ;
}

########################################################################
# printVCF
########################################################################

sub printVCF {
my $self         = shift;
my $dbh          = shift;
my $idsamples    = shift;
my $idsnvs       = shift;

my %hash;
tie %hash, "Tie::IxHash";

# remove duplicates
my @idsamples = split(/\,/,$idsamples);
%hash   = map { $_, 1 } @idsamples;
@idsamples = keys %hash;


my @idsnvs = split(/\,/,$idsnvs);
%hash   = map { $_, 1 } @idsnvs;
@idsnvs = keys %hash;

my $result = &getVCF($dbh,$sampledb,\@idsnvs,\@idsamples);
print "<pre><textarea cols='150' readonly rows='50'>";
print "$result";
print "</textarea></pre>";

}


############################################################
#getVCF: get a VCF file from a list of idsnvs and idsamples
############################################################
sub getVCF {
	my $dbh      = shift;
	my $sampledb = shift;
	my $tmp      = shift;
	my @idsnvs   = @$tmp;
	$tmp         = shift;
	my @idsamples= @$tmp;
	
	
	my $ret = qq{##fileformat=VCFv4.1
##INFO=<ID=DP,Number=1,Type=Integer,Description="Raw read depth">
##INFO=<ID=AF,Number=1,Type=Float,Description="Allele frequency of this variant in the Munich Exome DB">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="# high-quality bases">
##FORMAT=<ID=MQ,Number=1,Type=Integer,Description="Root-mean-square mapping quality of covering reads">
##FORMAT=<ID=SQ,Number=1,Type=Integer,Description="Variant quality (samtools)">
##FORMAT=<ID=PF,Number=1,Type=Integer,Description="Percent of reads on the forward strand">
##FORMAT=<ID=PV,Number=1,Type=Integer,Description="Percent of reads showing the variant">
##FILTER=<ID=VARQ,Description="Filtered out by vcfutils.pl varFilter, because of to low MQ (< 25)">
##FILTER=<ID=VARd,Description="Filtered out by vcfutils.pl varFilter, because of to low read depth (< 3)">
##FILTER=<ID=VARD,Description="Filtered out by vcfutils.pl varFilter, because of to high read depth (> 9999)">
##FILTER=<ID=VARa,Description="Filtered out by vcfutils.pl varFilter, because of to low read depth of variant bases (< 2)">
##FILTER=<ID=VARG,Description="Filtered out by vcfutils.pl varFilter, because of ??? (probably something with surrounding variants)">
##FILTER=<ID=VARg,Description="Filtered out by vcfutils.pl varFilter, because of ??? (probably something with surrounding variants)">
##FILTER=<ID=VARP,Description="Filtered out by vcfutils.pl varFilter, because of bias probability (see PV4)">
##FILTER=<ID=VARM,Description="Filtered out by vcfutils.pl varFilter, because of ???">
##FILTER=<ID=VARS,Description="Filtered out by vcfutils.pl varFilter, because of Hardy-Weinberg equilibrium">
##FILTER=<ID=Q20,Description="Filtered out by filterSNPqual.pl because median quality < 20">
##FILTER=<ID=Q15,Description="Filtered out by filterSNPqual.pl because median quality < 15">
##FILTER=<ID=Q10,Description="Filtered out by filterSNPqual.pl because median quality < 10">
##FILTER=<ID=Q5,Description="Filtered out by filterSNPqual.pl because median quality < 5">
##FILTER=<ID=Q3,Description="Filtered out by filterSNPqual.pl because median quality < 3">
##SamplesInMunichExomeDB=};


	#get number of samples in database
	my $query = "SELECT count(DISTINCT idsample) FROM snvsample;";
	my $out = $dbh->prepare($query) || die print "$DBI::errstr";
	$out->execute() || die print "$DBI::errstr";
	my ($sampleCount) =  $out->fetchrow_array;
	$ret .= "$sampleCount\n#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT";
	
	#get names of samples
	foreach my $currSample(@idsamples) {
		$query = "SELECT name FROM $sampledb.sample WHERE idsample=?;";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		$out->execute(($currSample)) || die print "$DBI::errstr";
		my ($currName) =  $out->fetchrow_array;
		$ret .= "\t$currName";
	}
	
	
	#get entries for each SNV
	foreach my $currSNV (@idsnvs){
		
		#get entries
		#$query = "SELECT chrom,start,if(rs='','.',rs),refallele,allele,(SELECT SUM(alleles) FROM snvsample WHERE idsnv = ?) FROM snv WHERE idsnv=?";
		$query = "SELECT chrom,start,if(rs='','.',rs),refallele,allele,freq FROM snv WHERE idsnv=?";
		$out = $dbh->prepare($query) || die print "$DBI::errstr";
		#$out->execute(($currSNV,$currSNV)) || die print "$DBI::errstr";
		$out->execute(($currSNV)) || die print "$DBI::errstr";
		my @columns =  $out->fetchrow_array;
		$ret .= "\n".join("\t",@columns[0..4]);
		my $info = "AF=".sprintf("%.3f",($columns[5]/($sampleCount*2)));
		
		
		my $format = "GT:GQ:DP:MQ:SQ:PF:PV";
		my $dp   = 0;
		my $qual = 0;
		my $foundSamples = 0;
		my %filter;
		#get info from snvsample
		foreach my $currSample(@idsamples) {
			$query = "SELECT alleles,percentvar,percentfor,snvqual,mapqual,coverage,filter,gtqual FROM snvsample WHERE idsnv = ? AND idsample = ?";
			$out = $dbh->prepare($query) || die print "$DBI::errstr";
			$out->execute(($currSNV,$currSample)) || die print "$DBI::errstr";
			if(my ($alleles,$percentvar,$percentfor,$snvqual,$mapqual,$coverage,$filter,$gtqual) =  $out->fetchrow_array){
				$foundSamples++;
				
				if($alleles == 0){
					$format .= "\t0/0";
				}elsif($alleles == 1){
					$format .= "\t0/1";
				}else{
					$format .= "\t1/1";
				}
				
				$format .= ":$gtqual:$coverage:$mapqual:$snvqual:$percentfor:$percentvar";
				
				my @columns = split(",",$filter);
				foreach(@columns){
					$filter{$_} = 1;		#set filters
				}
				
				$dp   += $coverage;
				$qual += $snvqual;
				
				
			}else{
				$format .= "\t.";
			}
			
			
		}
		
		#mean of qual
		if($foundSamples>0){
			$qual = sprintf("%d",($qual/$foundSamples));
		}
		$ret .= "\t$qual";
		
		#remove PASS if more than one filter and PASS was set
		if( (keys %filter)>1 && $filter{"PASS"}){
			delete $filter{"PASS"};
		}
		$ret .= "\t".join(";",keys %filter);
		
	
		$info .= ";DP=$dp";
		$ret .= "\t$info\t$format";
	}

	
	return $ret;
}
########################################################################
# drawMask
########################################################################

sub drawMask {
my $self   = shift;
my $AoH    = shift;
my $mode   = shift;
if (!defined($mode)) {$mode="";}
my $href   = "";
my ($dbh)    = &loadSessionId();

my $cgi    = new CGI::Plus;
$cgi->csrf(1);
print $cgi->csrf_field, "\n";

my $csrf_token = generate_csrf_token($user, $csrfsalt);
print qq(
<input name="wwwcsrf" type= "hidden" value="$csrf_token">
);

print qq(
<table border="1" cellspacing="0" cellpadding="3">
);

foreach $href (@{$AoH}) {
	if ($href->{type} eq 'readonly' ) {
		&readonly($href->{label},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'readonly2') {
		&text($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},'readonly');
	}
	elsif ($href->{type} eq 'hidden') {
		&hidden($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},'readonly');
	}
	elsif ($href->{type} eq 'text') {
		&text($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},"",$href->{autofocus});
	}
	elsif ($href->{type} eq 'password') {
		&text($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},"password",$href->{autofocus});
	}
	elsif ($href->{type} eq 'textFocus') {
		&textFocus($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'jsdate') {
		&jsdate($href->{label},$href->{name},$href->{value},$href->{size},$href->{maxlength},$href->{bgcolor},"");
	}
	elsif ($href->{type} eq 'radio') {	
		&radio($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'radioWell') {	
		&radioWell($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'radioBarcode') {	
		&radioBarcode($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'radioCheck') {	
		&radio($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'checkbox') {	
		&checkbox($href->{label},$href->{type},$href->{labels},$href->{value},$href->{name},$href->{values},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'select') {	
		&select1($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'selectdb') {	
		&selectdb($href->{label},$href->{name},$href->{value},$href->{bgcolor},$dbh);
	}
	elsif ($href->{type} eq 'selectApplicant') {	
		&selectApplicant($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'selectWgleader') {	
		&selectWgleader($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'selectFenumber') {	
		&selectFenumber($href->{label},$href->{name},$href->{value},$href->{bgcolor});
	}
	elsif ($href->{type} eq 'textArea') {	
		&textArea($href->{label},$href->{name},$href->{value},$href->{cols},$href->{rows},$href->{maxlength},$href->{bgcolor});
	}
}
if ($mode eq "nosubmit") {
	#&submit;
}
elsif ($mode eq "barcode") {
	&submitBarcode;
}
else {
	&submit('formbg');
}

print qq(
</table>
);

}

########################################################################
# deleteSpace: delete beginning and trailing space
########################################################################

sub deleteSpace {
my $self      = shift;
my $ref       = shift;
my $fieldName = "";
my $value     = "";

while (($fieldName,$value) = each (%$ref)) {
	$value    =~ s/^\s+// ;
	$value    =~ s/\s+$// ;
	$ref->{$fieldName}=$value;
}
}

########################################################################
# OKprompt
########################################################################

sub OKprompt {
my $self        = shift;

print qq(
<script type="text/javascript">
<!--
Check = confirm("Soll der Eintrag gespeichert werden?");
if(Check == false) {
	history.back();
}
//-->
</script>
);

}

########################################################################
# text
########################################################################

sub text {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $size       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;
	my $readonly   = shift;
	my $autofocus  = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	);
	if ($readonly eq 'readonly') {
		print qq(<td class="$bgcolor"><input class="readonly" name="$name" value="$value" size="$size" maxlength="$maxlength" readonly></td>);
	}
	elsif ($readonly eq 'password') {
		print qq(<td class="$bgcolor"><input type="password" name="$name" value="$value" size="$size" maxlength="$maxlength"></td>);
	}
	else {
		print qq(<td class="$bgcolor"><input type="text" name="$name" value="$value" size="$size" maxlength="$maxlength" $autofocus></td>);
	}
	print qq(
	</tr>
	);

}
########################################################################
# jsdate
########################################################################

sub jsdate {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $size       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;
	my $readonly   = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	);
	if ($readonly eq 'readonly') {
		print qq(<td class="$bgcolor"><input class="readonly" name="$name" value="$value" size="$size" maxlength="$maxlength" readonly>);
	}
	else {
		print qq(<td class="$bgcolor"><input name="$name" value="$value" size="$size" maxlength="$maxlength">);
	}
	print qq(
	<script language="JavaScript">
	new tcal ({
		// form name
		'formname': 'myform',
		// input name
		'controlname': '$name'
	});
	</script>
	</td>
	</tr>
	
	);

}

########################################################################
# hidden
########################################################################

sub hidden {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $size       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;
	my $readonly   = shift;

	print qq(<input type="hidden" name="$name" value="$value">);

}
########################################################################
# readonly
########################################################################

sub readonly {
	my $label      = shift;
	my $value      = shift;
	my $bgcolor    = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label&nbsp;</td>);
	print qq(<td class="$bgcolor">$value&nbsp;</td>);
	print qq(
	</tr>
	);
}

########################################################################
# radio
########################################################################

sub radio {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	if ($type eq "radioCheck") {
		print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	}
	else {
		print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	}
	
	$i=0;
	print qq(<td class="$bgcolor">\n);
	foreach (@labels) {
		if (!defined($values[$i])) {$values[$i] = "";}
		print qq(<input type="radio" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		if ($type eq "radioCheck") {
			print qq( onchange="Check()">$labels[$i]<br>\n);
		}
		else {
			print qq( >$labels[$i]<br>\n);
		}
		$i++;
	}
	print qq(</td></tr>);
	
}

########################################################################
# radioBarcode For Barcode2. Makes buttons for position
########################################################################

sub radioBarcode {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	
	$i=0;
	print qq(<td class="$bgcolor">\n);
	foreach (@labels) {
		print qq(<input type="radio" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		print qq(>$labels[$i]&nbsp;&nbsp;&nbsp;);
		$i++;
	}
	print qq(</td></tr>);
	
}

########################################################################
# radioWell. For Barcodes, checkboxes for the 24 wells
########################################################################

sub radioWell {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	print qq(<tr><td class="$bgcolor" valign="top">$label</td>);
	
	$i=0;
	print qq(<td class="$bgcolor">\n);
	print qq(<table border='1'>\n);
	print qq(<tr><td class="$bgcolor" valign="top">);
	foreach (@labels) {
		print qq(<input type="radio" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		print qq(>$labels[$i]<br>\n);
		$i++;
		if (($i == 8) or ($i == 16)) {
			print qq(</td><td class="$bgcolor" valign="top">);
		}
	}
	print qq(</td></tr>);
	print qq(</table>\n);
	print qq(</td></tr>);
	
}
########################################################################
# radioold
########################################################################

sub radioold {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;

	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);

	print qq(<tr><td class="$bgcolor">);
	foreach (@labels) {
		print qq($_ <br>);
		$i++;
	}
	print qq(</td>);
	
	$i=0;
	print qq(<td class="$bgcolor">);
	foreach (@labels) {
		print qq(<input type="$type" name="$name" value="$values[$i]");
		if ( $value eq $values[$i] ) {print " checked " ;}
		print qq(><br>);
		$i++;
	}
	print qq(</td></tr>);
	
}
########################################################################
# button
########################################################################
sub functionButton {
print qq#

<br><br>
<button type='button' class='button100' id='nonsynonymous'>Nonsynonymous</button><br>
<button type='button' class='button100' id='lof'>LoF</button><br>
<button type='button' class='button100' id='synonymous'>Synonymous</button><br>
<button type='button' class='button100' id='none'>None</button><br>
<button type='button' class='button100' id='all'>All</button><br>

#;
}
########################################################################
# checkbox
########################################################################

sub checkbox {
	my $label    = shift;
	my $type     = shift;
	my $labels   = shift;
	my $value    = shift;
	my $name     = shift;
	my $values   = shift;
	my $bgcolor  = shift;
	
	my $i        = 0;
	my @labels   = split(/\,\s+/,$labels);
	my @values   = split(/\,\s+/,$values);
	my @value    = split(/\,\s+/,$value);

	print qq(<tr><td class="$bgcolor" valign="top">$label);
	if ($label eq "Function") {
		&functionButton();
	}
	print qq(</td>);
	
	$i=0;
	print qq(<td class="$bgcolor">\n);
	print qq(<table border='1'>\n);
	print qq(<tr><td class="$bgcolor" valign="top">);
	foreach (@labels) {
		if (!defined($value[$i])) {$value[$i] = "";}
		print qq(<input type="checkbox" name="$name" value="$values[$i]");
		if ( $value[$i] eq $values[$i] ) {print " checked " ;}
		print qq(>$labels[$i]<br>\n);
		$i++;
		#if (($i == 8) or ($i == 16)) {
		#	print qq(</td><td class="$bgcolor" valign="top">);
		#}
	}
	print qq(</td></tr>);
	print qq(</table>\n);
	print qq(</td></tr>);

}

########################################################################
# select1
########################################################################

sub select1 {
	my $label    = shift;
	my $name     = shift;
	my $value    = shift;
	my $bgcolor  = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	<td  class="$bgcolor">
	);
#	select("$name","$value");
	print qq(
	</td>
	</tr>
	);
}

########################################################################
# selectdb
########################################################################

sub selectdb {
	my $label    = shift;
	my $name     = shift;
	my $value    = shift;
	my $bgcolor  = shift;
	my $dbh      = shift;
	my $sql      = "";
	my $sth      = "";
	my @row      = ();
	my $htmltext = "";
	my $menuflag = "";
	my $allowedprojects = "";
	if ( ($name eq "s.excluded_disease") or ($name eq "ds.iddisease") ) { # for search
		$allowedprojects = &allowedprojects("s.");
		$sql = "SELECT distinct d.iddisease,d.name,d.name
			FROM $sampledb.disease d
			INNER JOIN $sampledb.disease2sample ds ON d.iddisease=ds.iddisease
			INNER JOIN $sampledb.sample s ON ds.idsample=s.idsample
			WHERE $allowedprojects
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ( ($name eq "dg.iddisease") ) { # for search
		$sql = "SELECT distinct d.iddisease,d.name,d.name
			FROM $sampledb.disease d
			INNER JOIN disease2gene dg ON d.iddisease=dg.iddisease
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "lstatus") {
		$sql = "SELECT lstatus,lstatus,lstatus
			FROM $solexa.library
			WHERE lstatus != ''
			GROUP BY
			lstatus
			ORDER BY lstatus";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "s.idcooperation") { # for search
		$allowedprojects = &allowedprojects("");
		$sql = "SELECT distinct co.idcooperation,co.name,concat(co.name,', ',co.prename)
			FROM $sampledb.cooperation co
			INNER JOIN $sampledb.sample s ON s.idcooperation=co.idcooperation
			WHERE $allowedprojects
			ORDER BY name";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name =~ "lid") {
		#$sql = "SELECT lid,lmenuflag,CONCAT('Project: ',pname,' - ',pdescription,' * Library: ',lname,' - ',ldescription)
		$sql = "SELECT lid,lmenuflag,CONCAT(pname,' - ',pdescription,' *  ',lname,' - ',ldescription)
			FROM $sampledb.project p,library l 
			WHERE p.pid=l.pid
			ORDER BY pname,lname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "rid") {
		$sql = "SELECT rid,rmenuflag,CONCAT(rname,' - ',t.name,' - ',rcomment)
			FROM run r, runtype t
			WHERE r.rdescription = t.runtypeid
			ORDER BY rdate,rdaterun
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if (($name eq "cid") or ($name eq "sid")) {
		$sql = "SELECT cid,cmenuflag,CONCAT(cname,' - ',cdescription) 
			FROM kit 
			ORDER BY cname";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if (($name eq "uidreceived") or ($name eq "uidused") or ($name eq "uid") or ($name eq "l.uid")) {
		$sql = "SELECT uid,umenuflag,CONCAT(uname,', ',uprename) 
			FROM user 
			ORDER BY uname,uprename";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "machine")  {
		$sql = "SELECT DISTINCT machine,machine,machine 
			FROM rread 
			ORDER BY machine";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "readNumber")  {
		$sql = "SELECT DISTINCT readNumber,readNumber,readNumber 
			FROM rread 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "alane")  {
		$sql = "SELECT DISTINCT alane,alane,alane 
			FROM lane 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "rdescription")  {
		$sql = "SELECT DISTINCT runtypeid,name, name
			FROM runtype 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if (($name eq "libtype") or ($name eq "idlibtype") 
		or ($name eq "ts.idlibtype")) {
		$sql = "SELECT DISTINCT ltid,ltlibtype, ltlibtype
			FROM $solexa.libtype 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "libpair")  {
		$sql = "SELECT DISTINCT lpid,lplibpair, lplibpair
			FROM libpair 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if (($name eq "idorganism") or ($name eq "s.idorganism")) {
		$sql = "SELECT DISTINCT idorganism,orname, orname
			FROM $sampledb.organism 
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "s.idtissue") {
		$sql = "SELECT DISTINCT idtissue,name, name
			FROM $sampledb.tissue 
			ORDER BY name
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if ($name eq "ts.idassay")  {
		$sql = "SELECT DISTINCT idassay,name, name
			FROM $solexa.assay
			ORDER BY name
			";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}
	if (($name eq "idproject") or ($name eq "s.idproject")){ # for search
		$allowedprojects = &allowedprojects("");
		$sql = "SELECT idproject,pmenuflag,CONCAT(pname,' - ',pdescription)
			FROM $sampledb.project
			WHERE $allowedprojects
			ORDER BY pname DESC";
			#print "$allowedprojects\n";
		$sth = $dbh->prepare($sql) || die print "$DBI::errstr";
		$sth->execute || die print "$DBI::errstr";
	}

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	<td  class="$bgcolor">
	);
	print"<select name=\"$name\">";	
	print "<option value =''> ";
	while (@row = $sth->fetchrow_array) {
		if ($row[0] eq $value) {
			print"<option selected value ='$row[0]'> $row[2]";
		}
		elsif ($row[1] ne 'F') { # das ist fuer die Flag-Felder
			print"<option value ='$row[0]'> $row[2]";
		}
	}
	print"</select>";	

	print qq(
	</td>
	</tr>
	);

}
########################################################################
# textArea
########################################################################

sub textArea {
	my $label      = shift;
	my $name       = shift;
	my $value      = shift;
	my $cols       = shift;
	my $rows       = shift;
	my $maxlength  = shift;
	my $bgcolor    = shift;

	print qq(
	<tr>
	<td class="$bgcolor">$label</td>
	<td  class="$bgcolor"><textarea name="$name" cols="$cols" rows="$rows" maxlength="$maxlength">$value</textarea></td>
	</tr>
	);

}

########################################################################
# submit
########################################################################

sub submit {
	my $bgcolor  = shift;

	print qq(
	<tr>
	<td class="$bgcolor">&nbsp;</td>
	<td class="$bgcolor">
	<input type="submit" value="Submit">
	<input type="reset"  value="Reset">
	</td>
	</tr>
	);

}



########################################################################
# printHeader
########################################################################

sub printHeader {
my $self        = shift;
my $background  = shift;
my $sessionid   = shift;
my $refresh     = shift;
#my $cgi         = new CGI;
my $cgi         = new CGI::Plus;
my $cookie      = "";
my $csrf_field  = "";
$cgi->csrf(1);
$cgi->set_content_type('text/html; charset=utf-8');
$cgi->{'cookies'}->{'outgoing'}->{'csrf'}->{'secure'} = 1;
$cgi->{'cookies'}->{'outgoing'}->{'csrf'}->{'httponly'} = 1;
$cgi->{'cookies'}->{'outgoing'}->{'csrf'}->{'samesite'} = 'Strict';
$cgi->{'cookies'}->{'outgoing'}->{'csrf'}->{'max-age'} = '+1d';
#Debug::ShowStuff
#use Debug::ShowStuff ':all';
#use Debug::ShowStuff::ShowVar;

if (!defined($background)) {$background = "";}
if (!defined($sessionid))  {$sessionid  = "";}

unless (($sessionid eq "sessionid_created") or ($sessionid eq "fork")) {
	#print $cgi->header(-type=>'text/html',-charset=>'utf-8');
	print $cgi->header_plus;
	$csrf_field = $cgi->csrf_field;
	#showhash $cgi;
	#showhash $cgi->{'cookies'}->{'outgoing'};
	#showhash $cgi->{'cookies'}->{'outgoing'}->{'csrf'};
	#showhash $cgi->{'cookies'}->{'outgoing'}->{'csrf'}->{'values'};

}
if ($sessionid eq "fork") {
	print qq(
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    	"http://www.w3.org/TR/html4/loose.dtd">
	$refresh
	<html>
	<head>
	<title>EVAdb</title>
	);
}
else {
	print qq(
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    	"http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>
	<title>EVAdb</title>
	) ;
}
if ($sessionid eq "sessionid_created") { # redirect to Quality control
	print qq(
	<meta http-equiv="refresh" content="4; url='searchStat.pl'" />
	);
}

# Tell Perl not to buffer our output
$| = 1;

print qq(
	
<link rel="stylesheet" type="text/css" href="/DataTables-1.10.22/datatables.min.css">
<script type="text/javascript" src="/DataTables-1.10.22/datatables.min.js"></script>

<link rel="stylesheet" href="/DataTables-1.10.22/jquery.contextMenu.min.css">
<script src="/DataTables-1.10.22/jquery.contextMenu.min.js"></script>
<script src="/DataTables-1.10.22/jquery.ui.position.js"></script>

<link rel="stylesheet" href="/EVAdb/cal/calendar.css">
<script language="JavaScript" src="/EVAdb/cal/calendar_db.js"></script>

<meta name="viewport" content="width=device-width, height=device-height,  initial-scale=1, minimum-scale=1">
<link rel="stylesheet" type="text/css" href="/EVAdb/evadb/EVAdbtest.css">
<script type="text/javascript" src="/EVAdb/evadb/EVAdbtest.js"></script>
</head>
) ;

if ($background eq "white") {
	print qq(<body bgcolor=\"#ffffff\">\n);
	print qq(<div id="wrapper">);
	print qq(<div id="content">);
}
else {
	print qq(<body bgcolor=\"#CCCCCC\">\n);
	print qq(<div id="wrapper">);
	print qq(<div id="content">);
}

# check that referer is equal to host
my $referer = $ENV{HTTP_REFERER};
my $host = $ENV{HTTP_HOST};
my $request_uri = $ENV{REQUEST_URI};
my $http_user_agent = $ENV{HTTP_USER_AGENT};
my $url = "";
if ((index($referer, $host) < 0) or ($host eq ""))  {
	$url = "https://$host$request_uri";
	#print "referer $referer <br>";
	#print "host $host <br>";
	#print "request_uri $request_uri <br>";
	#print "http_user_agent $http_user_agent <br>";
	#print "url $url<br>";
	print "<script>window.location.replace('$url')</script>";
	exit;
}

#my $key;
#foreach $key (sort keys(%ENV)) {
#  print "$key = $ENV{$key}<br>";
#}

return($csrf_field); 
}
########################################################################
# htmlencode
########################################################################

sub htmlencode {
	my $self    = shift;
	my $string  = shift;
	HTML::Entities::encode($string);
	return($string);
}
########################################################################
# htmlencodearray
########################################################################

sub htmlencodearray {
	my $self    = shift;
	my (@array) = @_;
	my $tmp     = "";
	my @res     = ();
	foreach $tmp (@array) {
		HTML::Entities::encode($tmp);
		push(@res,$tmp);
	}
	return(@res);
}
########################################################################
# htmlencodehash
########################################################################

sub htmlencodehash {
	my $self     = shift;
	my $ref      = shift;
	my $key      = "";
	my $tt       = chr(0);
	my $tmp      = "";
	my @tmp      = ();
	my $checkbox = "";
	my $i        = 0;
	for $key (keys %$ref) {
		if ($ref->{$key} =~ /$tt/) {   # for checkbox_group
			$i        = 0;
			$checkbox = "";
			$tmp = $ref->{$key};
			@tmp = split(/$tt/,$tmp);
			foreach $tmp (@tmp) {
				HTML::Entities::encode($tmp);
				if ($i >= 1) {
					$checkbox = $checkbox . $tt;
				}
				$checkbox = $checkbox . $tmp;
				$i++;
			}
			$ref->{$key} = $checkbox;
		}
		else {
			HTML::Entities::encode($ref->{$key});
		}
	}
	return($ref);
}
########################################################################
# showMenu
########################################################################
sub showMenu {


print qq|
  <div id="mySidenav" class="sidenav">
  <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>
  <div class="subnav">Sample searches</div>
  <a href="searchStat.pl">Samples with quality</a>
  <a href="searchSample.pl">Samples</a>
  <div class="subnav">Variant searches</div>
  <a href="search.pl">Autosomal dominant</a>
  <a href="searchGeneInd.pl">Autosmal recessive</a>
  <a href="searchTrio.pl">De novo trio</a>
  <a href="searchDiseaseGene.pl">Disease panels</a>
  <a href="searchGene.pl">Genes</a>
  <a href="searchHGMD.pl">ClinVar/HGMD</a>
  <a href="searchOmim.pl">OMIM</a>
  <a href="searchHPO.pl">HPO</a>
  <a href="searchTumor.pl">Tumor/Controls</a>
  <a href="searchSameVariant.pl">Same Variant</a>
  <a href="searchPosition.pl">Region</a>
  <div class="subnav">CNV</div>
  <a href="searchCnv.pl">CNV</a>
  <div class="subnav">Coverage</div>
  <a href="searchTranscriptstat.pl">Coverage of genes</a>
  <a href="searchDiagnostics.pl">Coverage of panels</a>
  <div class="subnav">Other</div>
  <a href="searchHomo.pl">Homozygosity</a>
  <a href="searchIbs.pl">IBS</a>
  <a href="importHPO.pl">Import HPO</a>
  <a href="searchVcfTrio.pl">GATK denovo</a>
  <a href="searchVcf.pl">GATK Mutect2</a>
|;
if ($sv_menu) {
print qq|
  <div class="subnav">Structural variants</div>
  <a href="searchSv.pl">Structural variants</a>
|;
}
if ($translocation_menu) {
print qq|
  <div class="subnav">Translocations</div>
  <a href="searchTrans.pl">Translocations</a>
|;
}
print qq|
  <div class="subnav">Annotations/Report</div>
  <a href="searchComment.pl">Variant annotations</a>
  <a href="searchConclusion.pl">Case conclusions</a>
  <a href="report.pl">Report</a>
|;
if ($mtdna_menu) {
print qq|
  <div class="subnav">Mito</div>
  <a href="searchMito.pl">Mito</a>
|;
}
if ($rna_menu) {
print qq|
  <div class="subnav">RNA</div>
  <a href="searchRnaStat.pl">RNA</a>
  <a href="searchRpkm.pl">FPKM</a>
  <a href="searchDiffEx.pl">Differential expression</a>
  <a href="searchDiffPeak.pl">Differential peak callling</a>
|;
}
print qq|
  <div class="subnav">Help</div>
  <a href="help.pl">Help</a>
  <div class="subnav">Logout</div>
  <a href="login.pl">Logout $user</a>
|;
if ($role eq "admin") {
print qq|
  <div class="subnav">Admin</div>
  <a href="adminList.pl">List accounts</a>
  <a href="admin.pl">New account</a>
|;
}
print qq|
</div>

<!-- Use any element to open the sidenav -->
<span style="padding:20px;font-size:24px;cursor:pointer" onclick="openNav()">&#9776; Menu</span>

<!-- Add all page content inside this div if you want the side nav to push page content to the right (not used if you only want the sidenav to sit on top of the page -->
<div id="main">

|;

}
########################################################################
# login_message
########################################################################

sub login_message {
my $self        = shift;

my $item          = "";
my $value         = "";
my %logins        = ();
my $login_message = "";

open(IN, "$text");
while (<IN>) {
	chomp;
	($item,$value)=split(/\:/);
	$logins{$item}=$value;
}
close IN;
my $dbh = DBI->connect("DBI:mysql:$maindb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";

my $query = "SELECT module FROM $exomevcfe.textmodules WHERE name='login_message'";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
$login_message = $out->fetchrow_array;

return($dbh,$login_message);
}
########################################################################
# printFooter
########################################################################

sub printFooter {
my $self        = shift;
my $dbh         = shift;

my $item  = "";
my $value = "";
my %logins = ();
# select footer from exomevcfe.textmodules
#select password from file
if ($dbh eq "asdf") {
	open(IN, "$text");
	while (<IN>) {
		chomp;
		($item,$value)=split(/\:/);
		$logins{$item}=$value;
	}
	close IN;
	$dbh = DBI->connect("DBI:mysql:$maindb", "$logins{dblogin}", "$logins{dbpasswd}") || die print "$DBI::errstr";
}

my $query = "SELECT module FROM $exomevcfe.textmodules WHERE name='footer'";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute() || die print "$DBI::errstr";
my $footer = $out->fetchrow_array;


print qq(
<br><br>
</div>
</div>
<div id="footer">
<br>
<div class="footertext ">
$footer
<br><br>
</div> 
</div> 
</div> 
</body>
</html>
);

}
########################################################################



1;
__END__
