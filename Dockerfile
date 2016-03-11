FROM centos:centos7
MAINTAINER Mikel Asla mikel.asla@keensoft.es, Enzo Rivello enzo.rivello@alfresco.com
RUN yum update -y
RUN yum install -y \
    wget \
    curl \
    gpg \
    tar \
    unzip \
    sed \
    ImageMagick \
    ghostscript \
    libreoffice-headless \
    libreoffice


ENV ALF_VERSION=201512-EA \
	ALF_BUILD=201512-EA-build-00003 \
	CATALINA_HOME=/usr/local/tomcat \
	ALF_HOME=/usr/local/alfresco \
	TOMCAT_KEY_ID=D63011C7 \
	TOMCAT_MAJOR=7 \
	TOMCAT_VERSION=7.0.67 \
	JRE_BUILD=8u45-b14 \
	JRE_VERSION=8u45 \
	JRE_DIR=jdk1.8.0_45

ENV TOMCAT_TGZ_URL=https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz \
	SOLR4_HOME=$ALF_HOME/solr4 \
	JRE_TGZ=server-jre-$JRE_VERSION-linux-x64.tar.gz \
	JAVA_HOME=/usr/local/java/$JRE_DIR \
	ALF_ZIP=alfresco-community-distribution-$ALF_VERSION.zip

ENV JRE_URL=http://download.oracle.com/otn-pub/java/jdk/$JRE_BUILD/$JRE_TGZ \
	JRE_HOME=$JAVA_HOME/jre \
	ALF_DOWNLOAD_URL=http://dl.alfresco.com/release/community/$ALF_BUILD/$ALF_ZIP

ENV PATH $CATALINA_HOME/bin:$ALF_HOME/bin:$PATH

RUN mkdir -p $CATALINA_HOME \
	&& mkdir -p $ALF_HOME

# get apache-tomcat
RUN gpg --keyserver pgp.mit.edu --recv-key "$TOMCAT_KEY_ID" \
	&& set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --verify tomcat.tar.gz.asc \
	&& tar -xvf tomcat.tar.gz --strip-components=1 -C $CATALINA_HOME \
	&& rm tomcat.tar.gz*


# get sun server-jre
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" $JRE_URL \
	&& mkdir -p /usr/local/java \
	&& tar xzvf $JRE_TGZ -C /usr/local/java \
	&& rm -f $JRE_TGZ

# get alfresco ZIP
RUN mkdir /tmp/alfresco \
	&& wget $ALF_DOWNLOAD_URL \
	&& unzip $ALF_ZIP -d /tmp/alfresco \
	&& rm -f $ALF_ZIP

WORKDIR $ALF_HOME

# Alfresco configuration
RUN ln -s /usr/local/tomcat /usr/local/alfresco/tomcat \
	&& mkdir -p $CATALINA_HOME/conf/Catalina/localhost \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/web-server/shared tomcat/ \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/web-server/lib/postgresql-9.4-1201-jdbc41.jar tomcat/lib/ \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/web-server/webapps/* tomcat/webapps/ \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/solr4/context.xml tomcat/conf/Catalina/localhost/solr4.xml \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/alf_data . \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/solr4 . \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/amps . \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/bin . \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/licenses . \
	&& mv /tmp/alfresco/alfresco-community-distribution-$ALF_VERSION/README.txt . \
	&& rm -rf /tmp/alfresco

RUN mkdir ./amps_share \
  && chmod +x bin/apply_amps.sh 
 
RUN sh ./bin/apply_amps.sh 

COPY assets/server.xml $CATALINA_HOME/conf/server.xml
COPY assets/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml
COPY assets/catalina.properties $CATALINA_HOME/conf/catalina.properties
COPY assets/setenv.sh $CATALINA_HOME/bin/setenv.sh
COPY assets/alfresco-global.properties $ALF_HOME/tomcat/shared/classes/alfresco-global.properties

RUN sed -i 's,@@ALFRESCO_SOLR4_DIR@@,'"$ALF_HOME"'/solr4,g' tomcat/conf/Catalina/localhost/solr4.xml
RUN sed -i 's,@@ALFRESCO_SOLR4_MODEL_DIR@@,'"$ALF_HOME"'/solr4/model,g' tomcat/conf/Catalina/localhost/solr4.xml
RUN sed -i 's,@@ALFRESCO_SOLR4_CONTENT_DIR@@,'"$ALF_HOME"'/solr4/content,g' tomcat/conf/Catalina/localhost/solr4.xml
RUN sed -i 's,@@ALFRESCO_SOLR4_DATA_DIR@@,'"$ALF_HOME"'/solr4,g' solr4/workspace-SpacesStore/conf/solrcore.properties 
RUN sed -i 's,@@ALFRESCO_SOLR4_DATA_DIR@@,'"$ALF_HOME"'/solr4,g' solr4/archive-SpacesStore/conf/solrcore.properties 

EXPOSE 8080 8443 8009
VOLUME $ALF_HOME/alf_data
CMD ["catalina.sh", "run"]
