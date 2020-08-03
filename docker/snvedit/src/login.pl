#!/usr/bin/perl

########################################################################
# Tim M Strom   February 2007
########################################################################

use strict;
use CGI;
use CGI::Session;
BEGIN {require './Snvedit.pm';}
use DBI;

my $snv         = new Snvedit;

$snv->printHeader();
$snv->showMenu("login");
$snv->deleteSessionId();
print "<font size = 6>Login</font><br><br>" ;

print qq(
<form action="loginDo.pl" method="post">

<table border="1" cellspacing="0" cellpadding="3">

	<tr>
	<td class="formbg">Name</td>
	<td class="formbg"><input name="name" value="" size="30" maxlength="100" autofocus></td>
	</tr>
	
	<tr>
	<td class="formbg">Password</td>
	<td class="formbg"><input name="password" type= "password" value="" size="30" maxlength="100"></td>
	</tr>

	<tr>
	<td class="formbg">&nbsp;</td>
	<td class="formbg">
	<input type="submit" value="Submit">
	<input type="reset"  value="Reset">
	</td>
	</tr>

</table>
</form>
);

$snv->printFooter();
