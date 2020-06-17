Create the following directory tree

/srv/www/cgi-bin/mysql/|---solexa
		       |
		       |---snvedit                       |
		       |
		       |---snv-hg19p

Copy all files in 'cgi-bin'   to the 'mysql' folder.

cp -r cgi-bin/* /srv/www/cgi-bin/mysql/.

The paths of the directories are defined at top of the 
Snv.pm file and can be modified.
################################################################
#stylesheet and javascript
Copy the javascript and css folders into /srv/www/htdocs.

cp -r css_js/cal /srv/www/htdocs/.
cp -r css_js/DataTables /srv/www/htdocs/.
cp -r css_js/gif /srv/www/htdocs/.
cp -r css_js/medialize-jQuery-contextMenu-09dffab /srv/www/htdocs/.

################################################################
#database user and password

# create the database user
# Use strong passwords.

mysql  -u root -p mysql
create user 'exomereadonly' IDENTIFIED BY 'exomereadonly';
update mysql.user set Host='localhost' where User='exomereadonly';
drop user exomereadonly;
insert into mysql.user (Host,User,Password) VALUES ('localhost','exomereadonly','exomereadonly');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','exomehg19','exomereadonly','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','exomehg19plus','exomereadonly','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','solexa','exomereadonly','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','hgmd_pro','exomereadonly','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','hg19','exomereadonly','Y');
insert into mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv) VALUES ('localhost','exomevcfe','exomereadonly','Y','Y','Y');

create user exome IDENTIFIED BY 'exome';
update mysql.user set Host='localhost' where User='exome';
insert into mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv) VALUES ('localhost','exomehg19','exome','Y','Y','Y');
insert into mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv) VALUES ('localhost','exomevcfe','exome','Y','Y','Y');
insert into mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv) VALUES ('localhost','solexa','exome','Y','Y','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','exomehg19plus','exome','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','hgmd_pro','exome','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','hg19','exome','Y');

create user solexa IDENTIFIED BY 'solexa';
update mysql.user set Host='localhost' where User='solexa';
insert into mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv) VALUES ('localhost','solexa','solexa','Y','Y','Y');
insert into mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv) VALUES ('localhost','exomevcfe','solexa','Y','Y','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','exomehg19','solexa','Y');
insert into mysql.db (Host,Db,User,Select_priv) VALUES ('localhost','hg19','solexa','Y');

flush privileges;


# Create three password files in /usr/tools
# The password files should only be readable for the apache user.
# That is usually wwwrun.
# The files must contain the 3 following lines.
# 'csrfsalt' should contain 6 random characters (lower and upper characters and numbers)
# File for application 'user'/usr/tools/textreadonly.txt
dblogin:exomereadonly
dbpasswd:mysqlpassword
csrfsalt:XXXXX

# file for application 'managment' /usr/tools/text.txt
dblogin:exome
dbpasswd:exome
csrfsalt:XXXXX

# file for application 'solexa' /usr/tools/solexa.txt
dblogin:solexa
dbpasswd:solexa
csrfsalt:XXXXX


# create an admin user
mysql  -u root -p exomevcfe
insert into exomevcfe.user (name,password,role,edit,genesearch,yubikey) VALUES ('admin','$2a$08$pmAbhhM2wYD/G9oxziYV3.J9MHwOTG2edQP.RXX.YF2HAhWJ0L1Jm','admin',1,1,0);
quit
login ist admin
password is Admintest1
Yubikey is disabled.
Change the password!!
Activate the Yubikey!!

# Two-factor authentication with one-time-password
The application provides two-factor authentication with one-time-password
with the classical YubiKey.
If you don't want to use this feature, the field 'user' in exomevcfe.user
must contain a '0'.
If you want to use this feature, the field must contain the identifier of
a classical YubiKey.
Before you can use this module, you need to register for an API key at Yubico. 
This is as simple as logging onto <https://upgrade.yubico.com/getapikey/> and 
entering your Yubikey's OTP and your email address. 
Once you have the API and ID, you need to provide those details to the module to work.
Create a file: /usr/tools/textreadonly2.txt (only readable for wwwrun)
and enter the following information:

id:<myid>
api:<myapi>


################################################################
#Perl modules
Install the required Perl modules.

cpan CGI
cpan CGI::Plus
cpan CGI::Session
cpan DBI
cpan Crypt::Eksblowfish::Bcrypt
cpan File::Basename
cpan Auth::Yubikey_WebClient
cpan Tie::IxHash
cpan Apache::Solr
cpan HTML::Entities
cpan WWW::CSRF
cpan Crypt::Random
cpan LWP::Simple
cpan Text::NSP::Measures::2D::Fisher::twotailed
cpan XML::Simple
cpan Statistics::R
cpan Cache::FileCache
cpan Digest::MD5
cpan Date::Calc
cpan Data::Dumper
cpan Text::ParseWords
cpan Cwd

################################################################
# Apache

Set up an Apache server with ssl enabled.
Enable the following modules
    enable session
    session_cookie
    rewrite
    RewriteEngine
    ssl

Generate a dummy certificate only for a test server.
Call the script /usr/bin/gensslcert. 

Add the following lines to vhost-ssl.conf
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Xss-Protection "1; mode=block"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header set Content-Security-Policy "default-src https: 'unsafe-eval' 'unsafe-inline'"




