#!/usr/bin/perl 

use strict;
#use lib "/srv/www/cgi-bin/mysql/test";
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use lib dirname(abs_path($0));
use Snv;

my $snv      = new Snv;
my $cgi      = new CGI;
my $file     = $cgi->param('file');
my $name     = $cgi->param('name');


print "Content-Type: image/png\n\n";

my ($dbh) = $snv->loadSessionId();
$file       = $snv->htmlencode($file);
$name       = $snv->htmlencode($name);
$snv->readPng($dbh,$file,$name);


