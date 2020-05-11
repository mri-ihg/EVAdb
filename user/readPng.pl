#!/usr/bin/perl 

use strict;
BEGIN {require './Snv.pm';}

my $snv      = new Snv;
my $cgi      = new CGI;
my $file     = $cgi->param('file');
my $name     = $cgi->param('name');


print "Content-Type: image/png\n\n";

my ($dbh) = $snv->loadSessionId();
#$file       = $snv->htmlencode($file);
#$name       = $snv->htmlencode($name);
$snv->readPng($dbh,$file,$name);


