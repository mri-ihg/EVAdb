#!/usr/bin/perl -w

############################################################
#
# getfile.cgi
#
# Author: Riccardo Berutti
# Date:   15.07.2015
#
# Provides required file after checking
# authorisation in resumable mode
# parsing HTTP_RANGE requests
#
############################################################

use CGI;
#use CGI::Session;

#Config
	my $file_root = ''; # Absolute path prefix to file like /data/isilon/seq/analysis/exomehg19/

# Init
	$cgi=new CGI();
	my %headers = map { $_ => $cgi->http($_) } $cgi->http();
	my $filename=$cgi->param("file");

	if ( $filename eq "" )
	{
		print $cgi->header( -status => "403" );
		exit;
	}
	
# Session recover
	##my $session_id=$cgi->param("sid");
	##my $session = new CGI::Session(undef, $session_id....)

# File stats:
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime) = stat($filename);
	my $weak="";

# Generate ETag field 
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

# Check if authorised
	my $file_to_check = $filename; 
	$file_to_check =~ s/.bai$//g;

	my $auth=0;

	# Replace here auth check:                               #################################
	if ( $file_to_check eq "/data/isilon/seq/analysis/exomehg19/MRBE/MRB330/exomicout/paired-endout/merged.rmdup.bam" ) ####Authorisation check here!####
	{                                                        #################################
		$auth=1;
	}
	
	# If unauthorised, reply 403 Forbidden
	if ( $auth == 0 )
	{
		print $cgi->header(-status => "403");
		return;
	}

# Check if file exists, if not reply 404 Not found
	if ( ! -e $file_root.$filename )
	{
		print $cgi->header(-status => "404");
		return;
	}

# Open File for Output
open FOUT, "$filename" or die "$filename: $!";

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
}

# Complete header information
	$cgihead{'-ETag'}=$etag; #@$if_range; #$etag;
	$cgihead{'-Accept-Ranges'}='bytes';
	$cgihead{'-Last-Modified'}='Wed, 15 Jul 2015 21:07:05 GMT';
	$cgihead{'-Content-Length'}=$size;
	$cgihead{'-type'}="octet/stream";

# Send HTTP Header
	print $cgi->header(%cgihead);

# Send file
	my $buf_size = 4096;
	my $buf;
	my $total=0;
	binmode(STDOUT);

	# If size < buf_size no problem, send all

	# Send buffered output
	while ( read(FOUT, $buf, $buf_size) ) 
	{
		print $buf; 
		$total=$total+$buf_size; 

		# Last chunk, adjust to send only the required bytes
		if( $total+$buf_size > $size )
		{
			$buf_size=$size-$total;
		}
	}


# Close file
	close FOUT;


