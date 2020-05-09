#!/usr/bin/perl 

use strict;

my ($dummy,$chrom,$start,$end,$i,$n,$oldchrom);
my %dgv = ();

system("wget -c http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/dgvMerged.txt.gz");
system("gunzip dgvMerged.txt.gz");

open (IN, "<", "dgvMerged.txt");
open (OUT, ">", "dgvbp.txt");

$n=0;
print "Takes about 10 hours, requires about 20G memory\n";
print "Start with chromosome chr1\n";
while (<IN>) {
	chomp;
	($dummy,$chrom,$start,$end)=split(/\t/);
	if ($n % 1000 == 0) {
		print "n=$n $chrom $start\n";
	}
	if (($chrom ne $oldchrom) and ($chrom ne 'chr1')) {
		print "$oldchrom save\n";
		&save();
		print "$chrom new hash\n";
		%dgv=();
	}
	for ($i=$start+1;$i<=$end;$i++) {
		$dgv{$chrom}{$i}++;
	}
	$oldchrom=$chrom;
	$n++;
}
&save(); # last chromosome
close IN;
close OUT;

system("mysql hg19 < dgvbp.txt");


sub save {
my $chrom = "";
my $pos   = "";
foreach $chrom (sort keys %dgv) {
	for $pos (sort { $a <=> $b } keys %{$dgv{$chrom}}) {
		print OUT "$chrom\t$pos\t$dgv{$chrom}{$pos}\n";
	}
}
}
