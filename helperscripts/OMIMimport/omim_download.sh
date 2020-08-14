#!/bin/bash

# requires morbidmap.txt from OMIM in datadir
# requires genemap2.txt from OMIM in datadir

datadir=$PWD
scriptdir=$PWD
user=<database_user>
password=<database_password>

##############################################################################
# generates exomhg19.omim. Maps OMIM diseases to OMIM genes.
# requires morbidmap.txt and genemap2.txt (for inheritance)
##############################################################################

$scriptdir/parse_omim.pl $datadir $scriptdir
mysql       -u $user -p$password    exomehg19 < $scriptdir/omim.sql
mysqlimport -u $user -p$password -L exomehg19   $scriptdir/omim.txt

##############################################################################
# update gene tables with OMIM gene numbers
# requires genemap2.txt 
##############################################################################

$scriptdir/omim2gene.pl $datadir $scriptdir $user $password exomehg19plus
