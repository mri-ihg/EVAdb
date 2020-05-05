Create the following directory tree

/srv/www/cgi-bin/mysql/|---solexa
		       |
		       |---snvedit                       |
		       |
		       |---test

Copy all files in 'LIMS'       to the 'solexa' folder.
Copy all files in 'management' to the 'snvedit' folder.
Copy all files in 'user'       to the 'test' folder.

cp LIMS/* /srv/www/cgi-bin/mysql/solexa/.
cp management/* /srv/www/cgi-bin/mysql/snvedit/.
cp user/* /srv/www/cgi-bin/mysql/test/.

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




