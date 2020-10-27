#!/usr/bin/perl 

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
BEGIN {require './Snvedit.pm';}
use DBI;

########################################################################
# global variables
########################################################################

my $cgiquery        = new CGI;
my $ref             = $cgiquery->Vars;
my $snvedit          = new Snvedit;
my $personref       = "";
my @fields          =();
my @values          =();

my $sql             = "";
my $sth             = "";
my $id=$ref->{idsample};
my $forward  = qq#<meta http-equiv="refresh" content="0;  URL=sample.pl?id=$id&mode=edit">#;

########################################################################
# main
########################################################################

$snvedit->printHeader('','','','',$forward);
my ($dbh) = $snvedit->loadSessionId();


# encoded name

# delete beginning and trailing space
$snvedit->deleteSpace($ref);

if ($ref->{mode} eq "edit") {
	delete($ref->{"mode"});
	$snvedit->editDisease2sample($ref,$dbh,'disease2sample');
}
else {
	delete($ref->{"mode"});
	$snvedit->insertIntoDisease2sample($ref,$dbh,'disease2sample');
}

# select and display new entry
#$snvedit->showMenu("");
#$snvedit->showAllSample2library($dbh,$ref->{idsample2library});

#my $run = "";
#my $id=$ref->{rid};
#$run = $snvedit->initRunEdit();
#$snvedit->showMenu("");
#print "<span class=\"big\">Edit Run</span><br><br>" ;
#$snvedit->showRun2stock($dbh,$id);
#print qq(<form action="runInsert.pl" method="post" name=\"myform\">);
#$snvedit->getShowRun($dbh,$id,$run,'noprint');
#$snvedit->drawMask($run);
#print $cgiquery->hidden(-name=>'mode',-default=>'edit');
#print "</form>";

#end

$snvedit->printFooter($dbh);


