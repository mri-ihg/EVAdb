#!/usr/bin/perl 

##################################################################################
# Tim M Strom Juni 2010
# import omim into gene table
##################################################################################

use strict;
use DBI;

my @line       = ();
my $symbol     = "";
my $approved_symbol     = "";
my $omim       = "";
my $disorder   = "";
my $n          = 0;

my $datadir   = $ARGV[0];
my $scriptdir = $ARGV[1];
my $user      = $ARGV[2];
my $password  = $ARGV[3];
my $database  = $ARGV[4];


my $dbh = DBI->connect("DBI:mysql:database=$database", $user, $password) 
	|| die print "$DBI::errstr\n";

&correction($dbh);

open (INFILE, "<", "$datadir/genemap2.txt");
open (LOG, ">", "$scriptdir/$database.log");

while (<INFILE>) {
	chomp;
	if (/^#/) {next;}
	@line             = split(/\t/);
	$omim             = $line[5];
	$symbol           = $line[6];
	$approved_symbol  = $line[8];
	$disorder         = $line[12];
	if ($disorder =~ /\(3\)/) {
		#print "$approved_symbol, $symbol, $omim, $disorder\n";
		if ($approved_symbol eq "") {
			#There are only a few entries without approved gene symbol
			#print "Gene $omim Symbol $symbol $disorder\n";
			next;
		}
		#&testSymbol($dbh, $approved_symbol, $symbol, $omim);
		&into_db($dbh, $approved_symbol, $omim);
	}	
}
close (INFILE);
print LOG "Entries updated: $n\n";
close (LOG);
##################################################################################
# testSymbol
##################################################################################
sub testSymbol {
	my $dbh             = shift;
	my $approved_symbol = shift;
	my $symbol          = shift;
	my $omim            = shift;
	my $sth             = "";
	my $sql             = "";

$sql= "
SELECT genesymbol,omim,approved,hgncId
FROM gene
WHERE approved = '$approved_symbol'
";
	$sth = $dbh->prepare($sql) || print "Can't prepare statement: $DBI::errstr\n";
	$sth->execute();
	my @res = $sth->fetchrow_array;
	my $arraysize = @res;
	if ($arraysize == 0) {
		#approved symbols not found in gene table
		print "approved_symbol $approved_symbol, symbol $symbol, omim $omim\n";
	}
}
##################################################################################
# into_db
##################################################################################
sub into_db {
	my $dbh    = shift;
	my $symbol = shift;
	my $omim   = shift;
	my $sth    = "";
	my $sql    = "";
	my $test   = "";
	my $add    = 0;

	$symbol =~ s/\s//g;
	$omim   =~ s/\s//g;
	#print "$symbol $omim\n";
$sql= "
UPDATE IGNORE
gene
SET
omim = '$omim'
WHERE
approved = '$symbol'
";
	$sth  = $dbh->prepare($sql) || print "Can't prepare statement: $DBI::errstr\n";
	$test = $sth->execute();
	if ($test == 1) {
		$add =1;
	}
	if ($add) {
		$n++;
		print LOG "Updated: $symbol $omim\n";
	}
	else {
		print LOG "Not updated: $symbol $omim\n";
	}
}
##################################################################################
# correction
##################################################################################
sub correction {
	my $dbh    = shift;
	my $sth    = "";
	my $sql    = "";
	
	my $symbol = "";
	my @res    = ();
	
# geneTableSymbol => approvedSymbolNotFound
my %symbols_not_found = (
not           => 'NOTCH2NLC',
AK128525      => 'IGKC',
ZAK           => 'MAP3K20',
KMT2E         => 'KMT2E',
not           => 'PRSS2',
KMT2C         => 'KMT2C',
not           => 'GULOP',
SGK196        => 'POMK',
not           => 'MIR2861',
not           => 'NUTM2B-AS1',
KMT2A         => 'KMT2A',
not           => 'C1QTNF5',
KMT2D         => 'KMT2D',
MIR548F5      => 'MAB21L1',
not           => 'ATXN8',
not           => 'IGHG2',
not	      => 'IGHM',
RPS17L        => 'RPS17',
not           => 'PERCC1',
not           => 'SNORD118',
not           => 'KCNJ18',
KMT2B         => 'KMT2B',
'SEPT5-GP1BB' => 'GP1BB');

$sql= "
UPDATE gene
SET approved = (SELECT symbol FROM hg19.hgnc WHERE symbol = ?), 
hgncId = (SELECT hgnc_id FROM hg19.hgnc WHERE symbol = ?),
omim = (SELECT omim_id FROM hg19.hgnc WHERE symbol = ?)
WHERE genesymbol=?;
";

foreach $symbol (keys %symbols_not_found) {
	$approved_symbol = $symbols_not_found{$symbol};
	$sth = $dbh->prepare($sql) || print "Can't prepare statement: $DBI::errstr\n";
	$sth->execute($approved_symbol,$approved_symbol,$approved_symbol,$symbol);
	#print "$symbol, $approved_symbol, @res\n";
}

}

# update gene set omim=0;

