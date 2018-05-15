FROM debian:sid as builder

LABEL maintainer "mikel.asla@keensoft.es"
LABEL version "201707-GA"
LABEL description "alfresco-standalone 201707-GA builder stage"

# Dependencies
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		curl \
	    cpp \
	    dirmngr \
	    gcc \
	    gpg \
	    gpg-agent \
	    openjdk-8-jdk \
	    libapr1 \
	    libapr1-dev \
	    lsof \
	    make \
	    tar \
	    unzip \
	    sed \
	    wget 

# Environment variables
ENV ALF_VERSION=201707 \
	ALF_BUILD=201707-build-00028 \
	CATALINA_HOME=/usr/local/tomcat \
	ALF_HOME=/usr/local/alfresco \
	JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \	
	AOS_VERSION=1.1.6

ENV ALF_ZIP=alfresco-community-distribution-$ALF_VERSION.zip \
	AOS_ZIP=alfresco-aos-module-$AOS_VERSION.zip \
	AOS_AMP=alfresco-aos-module-$AOS_VERSION.amp 

ENV ALF_DOWNLOAD_URL=https://download.alfresco.com/release/community/$ALF_BUILD/$ALF_ZIP \
	AOS_DOWNLOAD_URL=https://download.alfresco.com/release/community/$ALF_BUILD/$AOS_ZIP \
	DIST=/tmp/alfresco/alfresco-community-distribution-$ALF_VERSION

ENV PATH $CATALINA_HOME/bin:$ALF_HOME/bin:$PATH

# Create root folders
RUN set -x \
	&& mkdir -p $ALF_HOME $CATALINA_HOME

# get alfresco ZIP
RUN set -x \
	&& mkdir /tmp/alfresco \
	&& wget --no-check-certificate $ALF_DOWNLOAD_URL \
	&& unzip $ALF_ZIP -d /tmp/alfresco

# Alfresco basic instalation 
RUN set -x \
	&& ln -s $CATALINA_HOME $ALF_HOME/tomcat \
	&& mkdir -p $CATALINA_HOME/conf/Catalina/localhost $CATALINA_HOME/lib/ $CATALINA_HOME/webapps \
	&& mv $DIST/web-server/conf/Catalina/localhost/alfresco.xml $CATALINA_HOME/conf/Catalina/localhost/ \
	&& mv $DIST/web-server/conf/Catalina/localhost/share.xml $CATALINA_HOME/conf/Catalina/localhost/ \
	&& mv $DIST/web-server/lib/* $CATALINA_HOME/lib/ \
	&& mv $DIST/web-server/shared $CATALINA_HOME/ \
	&& mv $DIST/web-server/webapps/alfresco.war $CATALINA_HOME/webapps/ \
	&& mv $DIST/web-server/webapps/share.war $CATALINA_HOME/webapps/ \
	&& mv $DIST/web-server/webapps/ROOT.war $CATALINA_HOME/webapps/ \
	&& mkdir $CATALINA_HOME/webapps/alfresco $CATALINA_HOME/webapps/share $CATALINA_HOME/webapps/ROOT \
	&& unzip $CATALINA_HOME/webapps/alfresco.war -d $CATALINA_HOME/webapps/alfresco \
	&& unzip $CATALINA_HOME/webapps/share.war -d $CATALINA_HOME/webapps/share \
	&& unzip $CATALINA_HOME/webapps/ROOT.war -d $CATALINA_HOME/webapps/ROOT \
	&& rm -rf $CATALINA_HOME/webapps/*.war \
	&& mv $DIST/alf_data $ALF_HOME \
	&& mv $DIST/amps $ALF_HOME \
	&& mv $DIST/bin $ALF_HOME \
	&& mv $DIST/modules $ALF_HOME

# alfresco-pdf-renderer 
RUN set -x \
	&& mkdir /usr/local/alfresco/alfresco-pdf-renderer \
	&& wget https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-pdf-renderer/1.0/alfresco-pdf-renderer-1.0-linux.tgz \
	&& tar xzvf alfresco-pdf-renderer-1.0-linux.tgz -C /usr/local/alfresco/alfresco-pdf-renderer 

# Configure Alfresco
COPY assets/alfresco/alfresco-global.properties $CATALINA_HOME/shared/classes/alfresco-global.properties

# Install Alfresco Office Services
RUN set -x \
	&& mkdir /tmp/aos \
	&& wget --no-check-certificate $AOS_DOWNLOAD_URL \
	&& unzip $AOS_ZIP -d /tmp/aos \
	&& mv /tmp/aos/extension/* $CATALINA_HOME/shared/classes/alfresco/extension \
	&& mv /tmp/aos/$AOS_AMP $ALF_HOME/amps \
	&& mkdir $CATALINA_HOME/webapps/_vti_bin \
	&& unzip /tmp/aos/_vti_bin.war -d $CATALINA_HOME/webapps/_vti_bin

# Install addons 
COPY assets/amps $ALF_HOME/amps
COPY assets/amps_share $ALF_HOME/amps_share
RUN set -x \
	&& java -jar $ALF_HOME/bin/alfresco-mmt.jar install $ALF_HOME/amps $CATALINA_HOME/webapps/alfresco -directory -nobackup \
	&& java -jar $ALF_HOME/bin/alfresco-mmt.jar install $ALF_HOME/amps_share $CATALINA_HOME/webapps/share -directory -nobackup

# Install api-explorer WAR file
RUN set -x \
	&& wget https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/api-explorer/5.2.0/api-explorer-5.2.0.war -O $CATALINA_HOME/webapps/api-explorer.war \
	&& mkdir $CATALINA_HOME/webapps/api-explorer \
	&& unzip $CATALINA_HOME/webapps/api-explorer.war -d $CATALINA_HOME/webapps/api-explorer \
	&& rm -rf $CATALINA_HOME/webapps/api-explorer.war

FROM tomcat:7-jre8

LABEL maintainer "mikel.asla@keensoft.es"
LABEL version "201707-GA"
LABEL description "alfresco-standalone 201707-GA application stage"

ENV CATALINA_HOME=/usr/local/tomcat \
	ALF_HOME=/usr/local/alfresco

# Dependencies
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \	 
	    ghostscript \
	    imagemagick \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p $ALF_HOME $ALF_HOME/alf_data \
	&& ln -s $CATALINA_HOME $ALF_HOME/tomcat

COPY --from=builder /usr/local/alfresco/bin /usr/local/alfresco/bin
COPY --from=builder /usr/local/alfresco/alfresco-pdf-renderer /usr/local/alfresco/alfresco-pdf-renderer
COPY --from=builder /usr/local/tomcat/lib/postgresql-9.4.1212.jar /usr/local/tomcat/lib/postgresql-9.4.1212.jar
COPY --from=builder /usr/local/tomcat/conf/Catalina /usr/local/tomcat/conf/Catalina
COPY --from=builder /usr/local/tomcat/shared /usr/local/tomcat/shared
COPY --from=builder /usr/local/tomcat/webapps /usr/local/tomcat/webapps

RUN set -x \	
	&& sed -i 's;shared.loader=;shared.loader=${catalina.base}/shared/classes,${catalina.base}/shared/lib/*.jar;g' $CATALINA_HOME/conf/catalina.properties \
	&& useradd -ms /bin/bash alfresco \
	&& chown -RL alfresco:alfresco $ALF_HOME
USER alfresco
WORKDIR $ALF_HOME
EXPOSE 8080
VOLUME $ALF_HOME/alf_data
CMD ["catalina.sh", "run"]


	
	