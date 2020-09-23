# ####################################################################
#
# Pipeline/Dockerfile 
#
# ####################################################################
# 
# Build docker container to execute the whole IHG pipeline
# contains slave and master SGE and client and server MYSQL
# How to achieve it is still a mistery! :)
#
# Last edited		2020.02.27
# Created 		2020.02.21
#

# ####################################################################


# Inherits base container from opensuse/leap
FROM opensuse/leap


# Main working directory (when logging in into the container)
WORKDIR /sequencing


# Define frequently used variables/paths

	# Custom software directories
	ARG	PACKAGES=/usr/local/packages
	ARG	PIPELINE=/pipeline
	ARG	SEQPACKAGES=/usr/local/packages

	# System directories
	ARG	BIN=/usr/bin
	ARG	INC=/usr/include
	ARG	LIB=/usr/lib
	ARG	LOCALBIN=/usr/local/bin

# Create directory structure
	RUN mkdir -p /data
	RUN mkdir -p $PIPELINE
	RUN mkdir -p $PACKAGES
	RUN mkdir -p $SEQPACKAGES
  RUN mkdir -p /library

# Install required packages
RUN zypper install -y 		\
	bzip2			\
	cmake			\
	curl			\
	curl-devel		\
	docker			\
	fontconfig-devel	\
	freetype-devel		\
	gcc			\
	gcc-c++			\
	gd-devel		\
	gdlib			\
	git			\
	gnu_parallel		\
	gzip			\
	ImageMagick		\
	ImageMagick-devel	\
	libbz2-devel		\
	libopenblas_pthreads-devel \
	libX11-devel		\
	libXext-devel		\
	libXft-devel		\
	libXpm-devel		\
	mariadb-client 		\
	ncurses-devel		\
	perl-CPAN* 		\
	perl-DateTime* 		\
	perl-DBI   		\
	perl-DBD-mysql		\
	perl-List-MoreUtils	\
	perl-Log-Log4perl 	\
	perl-Log-Dispatch*	\
	perl-MailTools		\
	perl-MIME-Lite		\
	perl-Test-Memory-Cycle	\
	perl-Tie-IxHash		\
	perl-XML-DOM-XPath	\
	perl-XML-LibXML		\
	perl-XML-Simple 	\
	python			\
	python-devel		\
	python-pip		\
	R-base 			\
	tar			\
	unzip			\
	wget			\
	xz-devel		\
	zlib-devel


	# Install samtools
	# v.0.1.19
		RUN \
			curl 'https://netcologne.dl.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2' > $SEQPACKAGES/samtools-0.1.19.tar.bz2;	\
			tar -xvf $SEQPACKAGES/samtools-0.1.19.tar.bz2 -C $SEQPACKAGES/ ; 										\
			sed -i 's/lcurses/lncurses/g' $SEQPACKAGES/samtools-0.1.19/Makefile;										\
			sed -i 's/\-g\ \-Wall\ \-O2/\-g\ \-Wall\ \-O2\ \-fPIC/g' $SEQPACKAGES/samtools-0.1.19/Makefile;							\
			make -C $SEQPACKAGES/samtools-0.1.19;														\
			cp  $SEQPACKAGES/samtools-0.1.19/*h $INC/;													\
			cp  $SEQPACKAGES/samtools-0.1.19/*o $LIB/;													\
			cp  $SEQPACKAGES/samtools-0.1.19/libbam.a $LIB/; 												\
			cp  $SEQPACKAGES/samtools-0.1.19/samtools $BIN/;												\
			ln  -s $SEQPACKAGES/samtools-0.1.19 $SEQPACKAGES/samtools;											\
			rm  $SEQPACKAGES/samtools-0.1.19.tar.bz2;


	# Install Tabix Perl
	# v.0.2.5
		RUN \
			curl 'https://liquidtelecom.dl.sourceforge.net/project/samtools/tabix/tabix-0.2.5.tar.bz2' > $SEQPACKAGES/tabix-0.2.5.tar.bz2;			\
			tar -xvf $SEQPACKAGES/tabix-0.2.5.tar.bz2 -C $SEQPACKAGES;											\
			make -C $SEQPACKAGES/tabix-0.2.5;														\
			bash -c 'cd $SEQPACKAGES/tabix-0.2.5/perl; perl $SEQPACKAGES/tabix-0.2.5/perl/Makefile.PL';							\
			make -C  $SEQPACKAGES/tabix-0.2.5/perl/;													\
			make -C  $SEQPACKAGES/tabix-0.2.5/perl/ install;												\
			cp  $SEQPACKAGES/tabix-0.2.5/tabix $BIN/;													\
			rm  $SEQPACKAGES/tabix-0.2.5.tar.bz2;


	# Install VCFTools
	# v.0.1.13
	# 		/usr/local/packages/seq/VCFtools
		RUN \
			curl -L 'https://github.com/vcftools/vcftools/archive/v0.1.13.tar.gz' > $SEQPACKAGES/vcftools-0.1.13.tar.gz;					\
			tar -xvf $SEQPACKAGES/vcftools-0.1.13.tar.gz -C $SEQPACKAGES/;											\
			cd $SEQPACKAGES/vcftools-0.1.13;														\
			make;																		\
			ln -s  $SEQPACKAGES/vcftools-0.1.13  $SEQPACKAGES/vcftools;											\
			ln -s  $SEQPACKAGES/vcftools-0.1.13  $SEQPACKAGES/VCFtools;											\
			rm  $SEQPACKAGES/vcftools-0.1.13.tar.gz;


# Custom packages: Final config
	
	RUN  mkdir /usr/local/packages/seq
	RUN  for TOOL in /usr/local/packages/*; do ln -s $TOOL $( echo $TOOL | sed 's/packages/packages\/seq/') ; done
	



# CPAN
# Software specific dependencies have been installed already

	# Prerequisites:
	RUN zypper install -y perl-DBD-mysql

	RUN 	cp $SEQPACKAGES/samtools-0.1.19/libbam.a	/usr/lib/libbam.a; \
		cp $SEQPACKAGES/samtools-0.1.19/bam.h		/usr/include/bam.h;
	RUN cpan install 		\
		diagnostics		#
	RUN cpan install	Bio::DB::Fasta		#
	ENV LD_LIBRARY_PATH=$SEQPACKAGES/samtools-0.1.19
	ENV SAMTOOLS=$SEQPACKAGES/samtools-0.1.19 
	RUN cpan install	Bio::DB::Sam		#
	RUN cpan install	File::chmod::Recursive

	
	RUN cpan -fi \
		File::chmod File::chmod::Recursive \
		ExtUtils::MakeMaker Test::Requires Module::Implementation Params::Validate \
		GD Test::Deep Test::Most Test Bio::DB::Sam Log::Dispatch Log::Log4perl \
		File::Path File::ReadBackwards File::HomeDir Module::Build List::MoreUtils \
		DateTime::Locale DateTime::TimeZone DateTime Pod::Usage Statistics::Descriptive \
		GD::Graph::histogram Statistics::R MIME::Lite Math::Random Math::Round GD::Graph::bars GD::* \
		GD::Graph GD::Graph::bars GD::Graph::histogram Archive::Zip Set::IntervalTree \
		Bio::Root::Version Bio::DB::GFF Bio::ASN1::EntrezGene inc::latest Data::Stag \
		IO::String ExtUtils::Command::MM Test::Harness Data::Swap Inline::C Set::IntSpan::Fast::XS \
		Statistics::Basic Statistics::Distribution Statistics::KernelExtension Statistics::RankCorrelation \
		forks forks::shared Template

# FIX:
	RUN zypper install -y java;
	# Install snpEFF
	# v.3.4e
		RUN \
			curl -L 'https://master.dl.sourceforge.net/project/snpeff/snpEff_v3_4_core.zip' > $SEQPACKAGES/SnpEff.zip;	\
			unzip $SEQPACKAGES/SnpEff.zip -d $SEQPACKAGES;									\
			ln -s $SEQPACKAGES/snpEff $SEQPACKAGES/seq/snpEff;								\
			rm $SEQPACKAGES/SnpEff.zip;
	#Other fix
		RUN mkdir -p /opt/jre1.8.0/bin; ln -s /usr/bin/java /opt/jre1.8.0/bin/java;
		RUN ln -s $SEQPACKAGES/tabix-0.2.5 $SEQPACKAGES/tabix; ln -s $SEQPACKAGES/seq/tabix-0.2.5 $SEQPACKAGES/seq/tabix;

# Add Pipeline and prepare configuration:

	RUN mkdir -p /build/pipeline \
		&& mkdir -p /build/pipeline_docker \
		&& git clone https://github.com/mri-ihg/ngs_pipeline /build/pipeline \
		&& git clone https://github.com/mri-ihg/Docker /build/pipeline_docker \
		&& cp /build/pipeline/Pipeline/* /pipeline \
		&& cp /build/pipeline_docker/configuration_test/conf.initAnalysis.template.xml /pipeline/conf.initAnalysis.xml


	# ADD build/pipeline /pipeline
  # ADD build/pipeline/Pipeline /pipeline
	# RUN rm /pipeline/*xml
	# RUN ln -s /configuration/conf.initAnalysis.xml 	/pipeline/conf.initAnalysis.xml
	# RUN ln -s /configuration/current.config.xml	/pipeline/current.config.xml


# Install SSH

	RUN zypper install -y openssh
	RUN sshd-gen-keys-start

# Define machine role and start runs accordingly

	# Install mariadb server
	#RUN zypper install -y *mariadb*
  RUN zypper install -y mysql
	# RUN cpan install DBD::mysql

# Cleanup tmp files
	RUN \
		rm -rf /build;


# Unit tests

# VIM to correct and test scripts
RUN zypper install -y vim

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && mkdir /anno_db

VOLUME [ "/data", "/library", "/anno_db" ]

ENTRYPOINT [ "/entrypoint.sh" ]
