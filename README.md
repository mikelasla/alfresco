# Alfresco Community Edition 201707-GA docker image

This image runs Alfresco Community [201707-GA](https://community.alfresco.com/docs/DOC-7034-alfresco-community-edition-201704-ga-release) version. 

## Stack

2. Apache Tomcat 7.0.86
3. OpenJDK 1.8.0_171
4. PostgreSQL 9.4
5. Alfresco Platform 5.2.g (201707GA)
6. Alfresco Share 5.2.f (201707GA)
7. Solr 6 (alfresco-search-services-1.1.0)
8. AOS Module 1.1.6
9. Aikau 1.0.101.3 (SCM tag)
10. LibreOffice 5.2 
11. ImageMagick 6.9.1-10

## Images

This project produces Alfresco Community 201707GA repository image. It also provides a docker-compose.yml file to wire everything up.

```bash
 docker-compose ps
              Name                            Command              State           Ports         
-------------------------------------------------------------------------------------------------
alfrescostandalone_alfresco_1      catalina.sh run                 Up      0.0.0.0:8080->8080/tcp
alfrescostandalone_libreoffice_1   /opt/libreoffice/startoo.sh     Up      8100/tcp              
alfrescostandalone_postgres_1      docker-entrypoint.sh postgres   Up      5432/tcp              
alfrescostandalone_solr6_1         ./run.sh run                    Up      8983/tcp 
```

## Use

### Manual startup

You can skip the use of Docker Compose and start Alfresco with just `docker run` commands (not recomended)

~~~~~
$ docker run -d --network alfnet --name postgres -e POSTGRES_DB=alfresco -e POSTGRES_USER=alfresco -e POSTGRES_PASSWORD=alfresco postgres:9.4
$ docker run -d --network alfnet --name solr6 keensoft/alfresco-solr6:201707GA
$ docker run -d --network alfnet --name libreoffice keensoft/libreoffice:latest
$ docker run -it --network alfnet --name alfresco -p 8080:8080 mikelasla/alfresco-standalone
~~~~~

### Docker Compose

~~~~~
$ git clone https://github.com/mikelasla/alfresco
$ docker-compose up
~~~~~

## Addons included

1. [Alfresco JavaScript Console 0.6](https://github.com/share-extras/js-console)
2. [Support Tools 0.0.1.0-SNAPSHOT](https://github.com/OrderOfTheBee/ootbee-support-tools)
3. [Version by name 1.2.0](https://github.com/keensoft/alfresco-version-by-name)
4. [Share Site Creators 0.0.3](https://github.com/jpotts/share-site-creators)
5. [Uploader Plus 1.5.1](https://github.com/softwareloop/uploader-plus)

## [Alfresco 5.2 REST API explorer](https://github.com/Alfresco/rest-api-explorer)

The image also has the api-exlorer webapp, check this page for reference on new Alfresco 5.2 REST API

[Alfresco 5.2 REST API Reference community DOC](https://community.alfresco.com/docs/DOC-6532-alfresco-52-rest-apis)

## Access

(admin/admin)

~~~~~
http://localhost:8080/share
http://localhost:8080/alfresco
http://localhost:8080/api-explorer
~~~~~
