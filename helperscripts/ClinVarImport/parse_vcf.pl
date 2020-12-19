#!/usr/local/bin/perl

use strict;

my @line         = ();
my $chrom        = "";
my $pos          = "";
my $ref          = "";
my $alt          = "";
my $posmod       = "";
my $refmod       = "";
my $altmod       = "";
my $info         = "";
my @info         = ();
my %info         = ();
my $tmp          = "";
my $item         = "";
my $value        = "";
my $modified     = 0;
my $clnacc       = "";
my $clnsig       = "";
my $clnsigconf   = "";
my $clnsigout    = "";
my $scriptdir    = "ClinVarForCron";


open(IN ,"$scriptdir/clinvar.vcf");
open(OUT,">$scriptdir/clinvar.txt");
while (<IN>) {
	chomp;
	if (/^#/) {next;}
	%info    = ();
	@line    = split(/\t/);
	$chrom   = $line[0];
	if ($chrom eq 'MT') {next;}
	$chrom   = 'chr' . $chrom;
	$pos     = $line[1];
	$ref     = $line[3];
	$alt     = $line[4];
	$info    = $line[7];
	@info    = split(/\;/,$info);
	foreach $tmp (@info) {
		($item,$value) = split(/\=/,$tmp);
		$info{$item}   = $value;
	}
	$clnacc      = $info{ALLELEID};
	$clnsig      = $info{CLNSIG};
	$clnsigconf  = $info{CLNSIGCONF};

	#if ($info{CLNSIG} eq "") {print "$chrom,$pos,ERROR\n";}
	($posmod, $refmod, $altmod)=getMinimalRepresentation($pos, $ref, $alt);
	if ($clnsigconf ne "") {
		$clnsigout = $clnsigconf;
		$clnsigout =~ s/\,/ /g;
	}
	else {
		$clnsig =~ s/\_of\_pathogenicity//g;
		#$clnsig =~ s/\_/ /g;
		$clnsigout = $clnsig;
	}
	print OUT "$chrom\t$posmod\t$refmod\t$altmod\t$clnacc\t$clnsigout\n";
}
print "modified $modified\n";

#Function
sub getMinimalRepresentation
{
	my ($start, $ref, $alt) = (shift,shift,shift);

	if ( length($ref)==1 && length($alt)==1 ) {
		#do nothing
	}
	else {
		# strip off identical suffixes
		while (substr($alt,length($alt)-1) eq substr($ref,length($ref)-1) && min(length($alt),length($ref)) > 1 ) {
			$alt = substr($alt,0,length($alt)-1);
			$ref = substr($ref,0,length($ref)-1);
			#print "1\n";
		}
		# strip off identical prefixes and increment position
		while (substr($alt,0) eq substr($ref,0)  && min(length($alt),length($ref)) > 1) {
			$alt = substr($alt, 1);
			$ref = substr($ref, 1);
			$pos = $pos + 1;
			#print "2\n";
		}
		$modified++;

	}
	return ($start, $ref, $alt);
}
sub min {
	my ($x,$y) = (shift,shift);
	my $min = ($x, $y)[$x > $y];
}

