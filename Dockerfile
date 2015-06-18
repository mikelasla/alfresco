FROM centos:centos7
MAINTAINER Mikel Asla mikel.asla@entelgy.com
RUN yum update -y
RUN yum install -y \
    wget \
    curl \
    gpg \
    tar \
    unzip \
    sed \
    fontconfig \
    libSM \ 
    libICE \
    libXrender \
    libXext \
    cups-libs \
    ImageMagick \
    ghostscript

ENV ALF_VERSION 5.0.d
ENV ALF_BUILD 5.0.d-build-00002

ENV CATALINA_HOME /usr/local/tomcat
RUN mkdir -p "$CATALINA_HOME"
ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.62
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

#RUN gpg --keyserver pgp.mit.edu --recv-key DE885DD3
RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	#&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	#&& gpg --verify tomcat.tar.gz.asc \
	&& tar -xvf tomcat.tar.gz --strip-components=1 -C $CATALINA_HOME \
	#&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

ENV ALF_HOME /usr/local/alfresco
ENV SOLR4_HOME $ALF_HOME/solr4
RUN mkdir -p $ALF_HOME
WORKDIR $ALF_HOME

ENV JRE_TGZ server-jre-7u80-linux-x64.tar.gz
ENV JRE_URL http://download.oracle.com/otn-pub/java/jdk/7u80-b15/server-jre-7u80-linux-x64.tar.gz
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" $JRE_URL \
	&& mkdir -p /usr/local/java \
	&& tar xzvf $JRE_TGZ -C /usr/local/java \
	&& rm -f $JRE_TGZ

ENV JAVA_HOME /usr/local/java/jdk1.7.0_80
ENV JRE_HOME $JAVA_HOME/jre

ENV ALF_ZIP alfresco-community-$ALF_VERSION.zip
ENV ALF_DOWNLOAD_URL http://dl.alfresco.com/release/community/$ALF_BUILD/$ALF_ZIP

# get alfresco ZIP
RUN mkdir /tmp/alfresco \
	&& wget $ALF_DOWNLOAD_URL \
	&& unzip $ALF_ZIP -d /tmp/alfresco \
	&& rm -f $ALF_ZIP

# Alfresco configuration
RUN ln -s /usr/local/tomcat /usr/local/alfresco/tomcat \
	&& mkdir -p $CATALINA_HOME/conf/Catalina/localhost \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/web-server/shared tomcat/ \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/web-server/endorsed tomcat/ \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/web-server/lib/postgresql-9.3-1102-jdbc41.jar tomcat/lib/ \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/web-server/webapps/* tomcat/webapps/ \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/solr4/context.xml tomcat/conf/Catalina/localhost/solr4.xml \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/alf_data . \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/solr4 . \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/amps . \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/bin . \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/licenses . \
	&& mv /tmp/alfresco/alfresco-community-$ALF_VERSION/README.txt . \
	&& rm -rf /tmp/alfresco


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

ENV PATH $CATALINA_HOME/bin:$ALF_HOME/bin:$PATH

EXPOSE 8080 8443 8009
CMD ["catalina.sh", "run"]
