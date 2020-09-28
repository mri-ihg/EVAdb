FROM debian:latest

##
# Settings to match to your environment
ENV DB_HOST mysql
ENV DB_USER root
ENV DB_PASSWD secr3t
ENV DB_USER_NONPRIV test
ENV DB_PASSWD_NONPRIV test
ENV YUBIKEY_ID test
ENV YUBIKEY_APIKEY secr3t
ENV INITIAL_USER admin
ENV INITIAL_USER_PASSWD Admintest1

# Static paths
ENV DB_CREDS_PATH /etc/evadb/db.secret
ENV YUBIKEY_CREDS_PATH /etc/evadb/yubikey.secret
ENV PERLLIB "/user:/src/annotation"

ENV DBNSFP_VERSION "v3.5a"
ENV GNOMAD_RELEASE "2.1.1"

# Static switches 0=false 1=true
ENV INIT_DB 1
ENV INIT_USER 1
ENV IMPORT_DBNSFP 1
ENV IMPORT_CADD 1
ENV IMPORT_GNOMAD 1
ENV IMPORT_LOF_METRICS 1
ENV IMPORT_DGV 1
ENV IMPORT_CLINVAR 1
ENV IMPORT_UCSC 1
ENV IMPORT_CDSDB 1

##
# Install Binaries and create directories
#
# Relink perl executable since evadb expects it in /usr/local/bin.
RUN apt update \
  && apt install -y git perl libcgi-pm-perl wget libcgi-session-perl libapache-session-perl r-base r-base-dev gcc cpp zip make libdbd-mysql-perl libbio-samtools-perl samtools tabix curl default-mysql-client python3 python3-pip python3-mysqldb \
  && ln -s /usr/bin/perl /usr/local/bin/perl \
  && pip3 install intervaltree sqlalchemy \
  && mkdir /library \
  && mkdir /database \
  && mkdir -p /src/annotation

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

RUN git clone https://github.com/mri-ihg/ngs_pipeline.git /ngs_pipeline \
  && cp -rv /ngs_pipeline/Pipeline/* /src/annotation/ \
  && rm -rf /ngs_pipeline

COPY ./entrypoint.sh /entrypoint.sh
COPY ./src/ /src

RUN chmod 755 /entrypoint.sh \
  && chmod -R +x /src

VOLUME [ "/library", "/database" ]

ENTRYPOINT [ "/entrypoint.sh" ]
