FROM httpd:latest

##
# Settings to match to your environment
ENV DB_HOST mysql
ENV DB_USER root
ENV DB_PASSWD secr3t
ENV YUBIKEY_ID test
ENV YUBIKEY_APIKEY secr3t

# Static paths
ENV DB_CREDS_PATH /etc/evadb/db.secret
ENV YUBIKEY_CREDS_PATH /etc/evadb/yubikey.secret
ENV PERLLIB "/user:/usr/local/apache2/cgi-bin"

##
# Install Binaries and create directories
#
# Relink perl executable since evadb expects it in /usr/local/bin.
RUN apt update \
  && apt install -y git perl libcgi-pm-perl libcgi-session-perl libapache-session-perl r-base r-base-dev gcc cpp zip make libdbd-mysql-perl libbio-samtools-perl samtools tabix curl \
  && ln -s /usr/bin/perl /usr/local/bin/perl \
  && mkdir /ssl \

RUN yes | cpan -T CGI CGI::Plus CGI::Session DBI Crypt::Eksblowfish::Bcrypt File::Basename Auth::Yubikey_WebClient Tie::IxHash Apache::Solr HTML::Entities WWW::CSRF Crypt::Random LWP::Simple Text::NSP::Measures::2D::Fisher::twotailed XML::Simple Statistics::R Cache::FileCache Digest::MD5 Date::Calc Data::Dumper Text::ParseWords Cwd
RUN yes | cpan -T DBD::mysql
RUN yes | cpan -T install diagnostics Bio::DB::Fasta File::chmod::recursive Bio::DB::Sam Log::Log4perl

# Install tabix perl module
RUN git clone https://github.com/samtools/tabix tabix \
  && cd tabix \
  && make \
  && cd perl \
  && perl Makefile.PL \
  && make \
  && make install \
  && cd ../.. \
  && rm -rf tabix

COPY ./htdocs/ /usr/local/apache2/htdocs/
COPY ./src/ /usr/local/apache2/cgi-bin
COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod -R 755 /usr/local/apache2/ \
  && chmod 755 /entrypoint.sh

EXPOSE 80
EXPOSE 443

VOLUME [ "/ssl" ]

ENTRYPOINT [ "/entrypoint.sh" ]
