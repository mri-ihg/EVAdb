#!/usr/bin/perl

use strict;


my $datadir   = $ARGV[0];
my $scriptdir = $ARGV[1];


#############################################################################
# select all entries with (3) from morbidmap.txt (molecular phenotype of the disorder known)
#############################################################################

my @line       = ();
my @tmp        = ();


my $morbidmap = "$datadir/morbidmap.txt";
my $morbidmap_parsed = "$scriptdir/morbidmap_parsed.txt";
open (IN,  "<",  "$morbidmap");
open (OUT, ">", "$morbidmap_parsed");

#mostly there is a space between omim number and (3)
#sometimes not
while (<IN>) {
	chomp;
	if (/^#/) {next;}
	@line     = split(/\t/);
	if ($line[0] =~ /\(3\)/) {
		$_=$line[0];
		s/ \(3\)//;
		s/\(3\)//;
		s/\,$//;
		$line[0]=$_;
		@tmp=split(/\s/,$line[0]);
		if ($tmp[-1] =~ /^\d\d\d\d\d\d$/) {
			$_=$line[0];
			s/\, $tmp[-1]//;
			$line[0]=$_;
			print OUT "$tmp[-1]\t$line[0]\t$line[2]\n";
		}
		else { # for entries without disease omim number
			print OUT "NULL\t$line[0]\t$line[2]\n";
		}
	}
}

close IN;
close OUT;

##############################################################################################
# retrieve inheritance mode from genemap2.txt and add to morbidmap_parsed.txt
##############################################################################################
my $disease       = "";
my @disease       = ();
my $omimdisease   = "";
my $comment       = "";
my %comment       = ();
my $inheritance   = "";
my %inheritance   = ();
my $tmp           = "";


open(IN, "<", "$datadir/genemap2.txt");
while (<IN>) {
	chomp;
	if (/^#/) {next;}
	@line             = split(/\t/);
	$disease          = $line[12];
	if ($disease =~ /\(3\)/) {
		#print "$disease\n";
		@disease = split(/\;/,$disease);
		foreach $disease(@disease) {
			#print "$disease\n";
			($disease, $comment) = split(/\([3|4]\)/,$disease);
			$comment =~ s/\,//;
			$comment =~ s/^\s+|\s+$//g;
			#print "$comment\n";
			$disease =~ s/^\s+|\s+$//g;
			$disease =~ s/(\d\d\d\d\d\d)$//;
			$omimdisease = $1;
			#$disease =~ s/^\s+|\s+$//g;
			#$disease =~ s/\,$//g;
			#$disease =~ s/\{|\}//g;
			#print "$disease\n";
			#print "$omimdisease\n";
			if ($comment =~ /Autosomal dominant/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "ad";
			}
			if ($comment =~ /Autosomal recessive/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "ar";
			}
			if ($comment =~ /X-linked/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "x";
			}
			if ($comment =~ /Somatic mutation/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "somatic";
			}
			if ($comment =~ /Somatic mosaicism/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "mosaicism";
			}
			if ($comment =~ /Isolated cases/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "sporadic";
			}
			if ($comment =~ /sporadic/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "sporadic";
			}
			if ($comment =~ /Multifactorial/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "polygenic";
			}
			if ($comment =~ /polygenic/i) {
				if ($inheritance ne "") {
					$inheritance .= ",";
				}
				$inheritance .= "polygenic";
			}
			#unless ($omimdisease =~ /\d\d\d\d\d\d/) {
			#	print "Not found $disease $omimdisease\n$_\n\n";
			#}
			unless ($omimdisease =~ /\d\d\d\d\d\d/) {
				$inheritance{$omimdisease}  = $inheritance;
				$comment{$omimdisease}      = $comment;
				$inheritance                = "";
				$comment                    = "";
			}
		}
	}	
}

close IN;

my @line = ();

open(IN,  "<", "$scriptdir/morbidmap_parsed.txt");
open(OUT, ">", "$scriptdir/omim.txt");

while (<IN>) {
	chomp;
	@line=split(/\t/);
	print OUT "$_\t$inheritance{$line[0]}\t$comment{$line[0]}\n";
}

close IN;
close OUT;

