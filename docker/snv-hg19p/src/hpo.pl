#!/usr/bin/perl

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);
BEGIN {require './Snv.pm';}
use DBI;
use JSON;

my $snv        = new Snv;
my $cgiquery   = new CGI;
my $term       = $cgiquery->param('term');
my $term_orig  = $term;
$term = "%". $term . "%";
my @tmp        = ();
my @res        = ();
my $jres       = "";
my $sampledb = $Snv::sampledb;

#$snv->printHeader("","cgisessid");
print "Content-type: text/html\n\n";
my ($dbh) = $snv->loadSessionId();

my $query = "SELECT 
DISTINCT h.id,h.name
FROM
$sampledb.hpo h
LEFT JOIN $sampledb.hposynonym s ON h.id=s.id
WHERE h.name like ?
OR s.synonym like ?
OR h.id = ?
";
my $out = $dbh->prepare($query) || die print "$DBI::errstr";
$out->execute($term,$term,$term_orig) || die print "$DBI::errstr";
while (@tmp = $out->fetchrow_array) {
	#push(@res,@tmp);
	if ($jres ne '') {
		$jres .= ',';
	}
	$jres .= encode_json(\@tmp);
	
}

$jres = '[' . $jres . ']';
#$jres = '[["a000123","seizures"],["a00asdf0123","seizasdfures"]]';
print "$jres";
