# Alfresco Community Edition 201701-GA docker image

This images runs a standalone Alfresco Community [201701-GA](https://community.alfresco.com/docs/DOC-6587-alfresco-community-edition-201701-ga-release-notes) version

## Stack

1. Centos 7
2. Apache Tomcat 7.0.69
3. Oracle JDK 1.8.0.121
4. Apache HTTPD 2.4
5. PostgreSQL 9.4.4
6. Alfresco Platform 5.2.e
7. Alfresco Share 5.2.d
8. Solr 4.10.3
9. AOS Module 1.1.5
10. Aikau 1.0.101.3 (SCM tag)
11. LibreOffice 5.1.4.2 (Based on image from [XCGD](https://hub.docker.com/r/xcgd/libreoffice/))
12. ImageMagick 6.9.1-10


## Use

### Manual startup

~~~~~
$ docker run -d --name postgres -e POSTGRES_DB=alfresco -e POSTGRES_USER=alfresco -e POSTGRES_PASSWORD=alfresco postgres:9.4
$ docker run -d --name libreoffice xcgd/libreoffice
$ docker run -it --name alfresco -p 8080:8080 --link postgres:postgres --link libreoffice:libreoffice mikelasla/alfresco-standalone
~~~~~

### docker-compose

~~~~~
$ git clone https://github.com/mikelasla/alfresco
$ docker-compose up -d --build
$ docker-compose logs -f alfresco
~~~~~


## Addons included

1. [Alfresco JavaScript Console 0.6](https://github.com/share-extras/js-console)
2. [Support Tools 0.0.1.0-SNAPSHOT](https://github.com/OrderOfTheBee/ootbee-support-tools)
3. [Version by name 1.2.0](https://github.com/keensoft/alfresco-version-by-name)
4. [Share Site Creators 0.0.3](https://github.com/jpotts/share-site-creators)
5. [Uploader Plus 1.5.1](https://github.com/softwareloop/uploader-plus)

## [Alfresco 5.2 REST API explorer](https://github.com/Alfresco/rest-api-explorer)

Check this page for reference on new Alfresco 5.2 REST API

[Alfresco 5.2 REST API Reference community DOC](https://community.alfresco.com/docs/DOC-6532-alfresco-52-rest-apis)

Thanks to [Gavin Cornwell](https://github.com/gavincornwell) for a great job documenting this new Alfresco functionality


## Access

(admin/admin)

~~~~~
http://localhost:8080/share
http://localhost:8080/alfresco
http://localhost:8080/solr4
http://localhost:8080/api-explorer
~~~~~