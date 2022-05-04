#!/usr/bin/perl

############################################################
#
# wrapper.pl
#
# Author: Riccardo Berutti
# Date:   15.07.2015
#
# Provides required file after checking
# authorisation in resumable mode
# parsing HTTP_RANGE requests
#
############################################################

use strict;
BEGIN {require './Snv.pm';}
use IO::Select;

my $cgi   = new CGI();
my $snv   = new Snv;

# Init
	my %headers  = map { $_ => $cgi->http($_) } $cgi->http();
	my $filename = $cgi->param("file");
#	$filename    = $snv->htmlencode($filename);

	if ( $filename eq "" )
	{
		print $cgi->header( -status => "403" );
		exit;
	}
	
# Session recover
	my $sess_id = $cgi->param("sid");
#	$sess_id    = $snv->htmlencode($sess_id);
	my ($dbh)   = $snv->loadSessionId($sess_id);

# Log in STDERR
	my $debug = 0;
	if ($debug) {
		my $ref   = $cgi->Vars;
#		$ref = $snv->htmlencodehash($ref);
		my %param = %$ref;
		foreach my $tmp (sort keys %headers) {
			print STDERR "$tmp $headers{$tmp}\n";
		}
		foreach my $tmp (sort keys %param) {
			print STDERR "$tmp $param{$tmp}\n";
		}
		print STDERR "filename $filename\n";
		print STDERR "sess_id $sess_id\n";
	}	
	
# check authorization and retrieve path
	if ($debug) {
		print STDERR "before authorization\n";
	}	
	my $sname = $cgi->param("sname");
#	$sname    = $snv->htmlencode($sname);
	my $dir   = $snv->checkigv($sname,$dbh);
	if ($dir eq "NOT_ALLOWED") {
		print $cgi->header(-status => "403");
		exit;
	}
	else {
		$filename = $dir . '/' . $filename;
	}

# Mime-type:
	my $mime_type = ( $filename =~ /\.html$/ ? "text/html" : "octet/stream" );
	#my $mime_type="octet/stream";



# Check if file exists, if not reply 404 Not found
	if ($debug) {
		print STDERR "before file exists\n";
	}	
	if ( ! -e $filename )
	{
		print $cgi->header(-status => "404");
		print "File $filename is missing.";
		exit;
	}

# File stats:
	if ($debug) {
		print STDERR "before file stats\n";
	}	
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime) = stat($filename);
	my $weak="";

# Generate ETag field 
	if ($debug) {
		print STDERR "before ETag\n";
	}	
	my $etag;
	if ( $mode != 0 )
	{
		$etag=sprintf('%s"%x-%x-%x"', $weak, $ino, $size, $mtime);
	}
	else
	{
		$etag=sprintf('%s"%x"', $weak, $mtime);
	}

# Get Range Request:
	my $range=""; 
	my $if_range="";

	$range =    $headers{'HTTP_RANGE'};
	$if_range = $headers{'HTTP_IF_RANGE'};



# Open File for Output
open FOUT, "$filename" or die "$filename: $!";
#open (FOUT, "<:raw", "$filename") or die "$filename: $!";
#binmode(FOUT);

# HTTP Output header
	my %cgihead;

# Calculate file chunks to send
	my $start;
	my $end;

	# Parse range field:
	# Formats:
	#	bytes=start-end
	#	bytes=start-
	if ( $range =~ /bytes=(\d+)-(\d*)/ )
	{
		# Start / End 
		$start = $1;
		$end = $2; #= $size -1;
		# If end not provided it means download all the rest
		if ($end eq "" )
		{
			$end=$size-1;
		}

		# Add to header range info
		$cgihead{"-status"}=206; 
		$cgihead{"-Content-Range"}="bytes $start-$end/$size";	# Must provide total filesize

		# Calculating data transfer size
		$size=( $end - $start +1);
		seek FOUT, $start, 0;
	}else{
		if ( 
			( $cgi->param("file") eq "merged.rmdup.bam" || $cgi->param("file") =~ /.*vcf/ ) 
			&&
			( $snv->getRole() ne "admin" && $snv->getRole() ne "manager" && ! $snv->canDownload($sname, $dbh) )
		)
		{
			print $cgi->header( -status => "403" );
			print "Not authorized\n";
                	exit;
		}
	}

# Complete header information
	$cgihead{'-ETag'}=$etag; #@$if_range; #$etag;
	$cgihead{'-Accept-Ranges'}='bytes';
	$cgihead{'-Last-Modified'}='Wed, 15 Jul 2015 21:07:05 GMT';
	$cgihead{'-Content-Length'}=$size;
	$cgihead{'-type'}="$mime_type";
	$cgihead{'-attachment'}=$cgi->param("file");

# Send HTTP Header
	print $cgi->header(%cgihead);

# Send file
	$|++;
	my $buf_size = 4096;
	#my $buf_size = 8192;
	#my $buf_size = 1024;
	my $buf;
	my $total=0;
	if ($debug) {
		print STDERR "before set stdout\n";
	}
	binmode(STDOUT);

	# If size < buf_size no problem, send all

	if ($debug) {
		print STDERR "before transfer\n";
	}
	# Send buffered output
	while ( read(FOUT, $buf, $buf_size) ) 
	{
		print $buf;

		$total=$total+$buf_size; 

		if ( $total > 512*1024*1024*1024 )
		{
			exit;
		}

		# Last chunk, adjust to send only the required bytes
		if( $total+$buf_size > $size )
		{
			$buf_size=$size-$total;
		}
	}
	if ($debug) {
		print STDERR "after transfer: sent $total bytes\n";
	}

# Close file
	close FOUT;


