FROM centos:centos7
MAINTAINER Mikel Asla mikel.asla@keensoft.es, Enzo Rivello enzo.rivello@alfresco.com
RUN yum update -y
RUN yum install -y \
    apr \
    apr-devel \
    curl \
    cpp \
    gcc \
    ghostscript \
    gpg \
    ImageMagick \
    lsof \
    make \
    tar \
    unzip \
    sed \
    wget 
RUN yum clean all

ENV ALF_VERSION=201702 \
	ALF_BUILD=201702-build-00016 \
	CATALINA_HOME=/usr/local/tomcat \
	ALF_HOME=/usr/local/alfresco \
	TOMCAT_KEY_ID=D63011C7 \
	TOMCAT_MAJOR=7 \
	TOMCAT_VERSION=7.0.69 \
	JDK_BUILD=8u121-b13 \
	JDK_VERSION=8u121 \
	JDK_DIR=jdk1.8.0_121 \
	AOS_VERSION=1.1.5 \
        LANG="en_US.utf8"

ENV TOMCAT_TGZ_URL=https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
	JDK_RPM=jdk-$JDK_VERSION-linux-x64.rpm \
	JAVA_HOME=/usr/java/$JDK_DIR \
	ALF_ZIP=alfresco-community-distribution-$ALF_VERSION.zip \
	AOS_ZIP=alfresco-aos-module-$AOS_VERSION.zip \
	AOS_AMP=alfresco-aos-module-$AOS_VERSION.amp 

ENV JDK_URL=http://download.oracle.com/otn-pub/java/jdk/$JDK_BUILD/e9e7ea248e2c4826b92b3f075a80e441/$JDK_RPM \
	JRE_HOME=$JAVA_HOME/jre \
	ALF_DOWNLOAD_URL=https://download.alfresco.com/release/community/$ALF_BUILD/$ALF_ZIP \
	AOS_DOWNLOAD_URL=https://download.alfresco.com/release/community/$ALF_BUILD/$AOS_ZIP \
	DIST=/tmp/alfresco/alfresco-community-distribution-$ALF_VERSION

ENV PATH $CATALINA_HOME/bin:$ALF_HOME/bin:$PATH

RUN set -x \
	&& mkdir -p $CATALINA_HOME $ALF_HOME

# get apache-tomcat
RUN set -x \
	&& gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key "$TOMCAT_KEY_ID" \
	&& set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --verify tomcat.tar.gz.asc \
	&& tar -xvf tomcat.tar.gz --strip-components=1 -C $CATALINA_HOME \
	&& rm tomcat.tar.gz*

# get oracle jdk1.8.0.121
RUN set -x \
	&& wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" $JDK_URL \
	&& rpm -Uvh $JDK_RPM \
	&& rm -f $JDK_RPM

# compile APR
RUN set -x \
	&& tar zxf $CATALINA_HOME/bin/tomcat-native.tar.gz -C /tmp \
	&& cd /tmp/tomcat-native-1.1.33-src/jni/native/ \
	&& ./configure --with-apr=/usr/bin/apr-1-config --with-java-home=$JAVA_HOME --libdir=/usr/lib/jni --with-ssl=no \
	&& make && make install \
	&& cd && rm -rf /tmp/tomcat-native* \
	&& yum remove -y gcc make cpp \
	&& yum clean all

# get alfresco ZIP
RUN set -x \
	&& mkdir /tmp/alfresco \
	&& wget --no-check-certificate $ALF_DOWNLOAD_URL \
	&& unzip $ALF_ZIP -d /tmp/alfresco \
	&& rm -f $ALF_ZIP

WORKDIR $ALF_HOME

# Alfresco basic instalation 
RUN set -x \
	&& ln -s /usr/local/tomcat /usr/local/alfresco/tomcat \
	&& mkdir -p $CATALINA_HOME/conf/Catalina/localhost \
	&& mv $DIST/web-server/conf/Catalina/localhost/alfresco.xml tomcat/conf/Catalina/localhost/ \
	&& mv $DIST/web-server/conf/Catalina/localhost/share.xml tomcat/conf/Catalina/localhost/ \
	&& mv $DIST/web-server/lib/* tomcat/lib/ \
	&& mv $DIST/web-server/shared tomcat/ \
	&& mv $DIST/web-server/webapps/alfresco.war tomcat/webapps/ \
	&& mv $DIST/web-server/webapps/share.war tomcat/webapps/ \
	&& mv $DIST/web-server/webapps/ROOT.war tomcat/webapps/ \
	&& mv $DIST/web-server/webapps/solr4.war tomcat/webapps/ \
	&& mv $DIST/solr4/context.xml tomcat/conf/Catalina/localhost/solr4.xml \
	&& mv $DIST/solr4 . \
	&& mv $DIST/alf_data . \
	&& mv $DIST/amps . \
	&& mv $DIST/amps_share . \
	&& mv $DIST/bin . \
	&& mv $DIST/licenses . \
	&& mv $DIST/modules . \
	&& mv $DIST/README.txt . \
	&& rm -rf /tmp/alfresco

# Configure Tomcat
COPY assets/tomcat/catalina.properties $CATALINA_HOME/conf/catalina.properties
COPY assets/tomcat/setenv.sh $CATALINA_HOME/bin/setenv.sh
COPY assets/tomcat/server.xml $CATALINA_HOME/conf/server.xml

# Configure Alfresco
COPY assets/alfresco/alfresco-global.properties $ALF_HOME/tomcat/shared/classes/alfresco-global.properties

# Configure Solr4
RUN set -x \
	&& sed -i 's,@@ALFRESCO_SOLR4_DIR@@,'"$ALF_HOME"'/solr4,g' tomcat/conf/Catalina/localhost/solr4.xml \
	&& sed -i 's,@@ALFRESCO_SOLR4_MODEL_DIR@@,'"$ALF_HOME"'/solr4/model,g' tomcat/conf/Catalina/localhost/solr4.xml \
	&& sed -i 's,@@ALFRESCO_SOLR4_CONTENT_DIR@@,'"$ALF_HOME"'/solr4/content,g' tomcat/conf/Catalina/localhost/solr4.xml \
	&& sed -i 's,@@ALFRESCO_SOLR4_DATA_DIR@@,'"$ALF_HOME"'/solr4,g' solr4/workspace-SpacesStore/conf/solrcore.properties \
	&& sed -i 's,@@ALFRESCO_SOLR4_DATA_DIR@@,'"$ALF_HOME"'/solr4,g' solr4/archive-SpacesStore/conf/solrcore.properties \
	&& sed -i 's,alfresco.secureComms=https,alfresco.secureComms=none,g' solr4/workspace-SpacesStore/conf/solrcore.properties \
	&& sed -i 's,alfresco.secureComms=https,alfresco.secureComms=none,g' solr4/archive-SpacesStore/conf/solrcore.properties

# Install Alfresco Office Services
RUN set -x \
	&& mkdir /tmp/aos \
	&& wget --no-check-certificate $AOS_DOWNLOAD_URL \
	&& unzip $AOS_ZIP -d /tmp/aos \
	&& mv /tmp/aos/extension/* tomcat/shared/classes/alfresco/extension \
	&& mv /tmp/aos/$AOS_AMP amps \
	&& mv /tmp/aos/aos-module-license.txt licenses \
	&& mv /tmp/aos/_vti_bin.war tomcat/webapps \
	&& rm -rf /tmp/aos $AOS_ZIP

# Install addons 
COPY assets/amps $ALF_HOME/amps
COPY assets/amps_share $ALF_HOME/amps_share
RUN set -x \
	&& bash $ALF_HOME/bin/apply_amps.sh -force

# Install api-explorer WAR file
RUN set -x \
	&& wget https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/api-explorer/5.2.0/api-explorer-5.2.0.war -O tomcat/webapps/api-explorer.war

# Add user alfresco
RUN set -x \
	&& useradd -ms /bin/bash alfresco \
	&& chown -RL alfresco:alfresco $ALF_HOME
USER alfresco

EXPOSE 8080
VOLUME $ALF_HOME/alf_data
CMD ["catalina.sh", "run"]
