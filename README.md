# alfresco

Alfresco Standalone Community Dockerfile


# Alfresco Community Dockerfile

* [`5.0.d` master/Dockerfile](https://github.com/mikelasla/alfresco/blob/master/Dockerfile "Dockerfile") 

This Dockerfile is an attempt to get Alfresco Community running as a docker container but it needs further improvements...
I'm doing this just for learning docker and yes, i'm loving it!

You can clone de project

`git clone https://github.com/mikelasla/alfresco`

And then build the image from within the project dir

`docker build -t <TAG> .`

## Actual Image status

Alfresco Community (5.0.d)

* From centos:centos7
* Apache Tomcat 7.0.59
* Sun Server JRE 8.0_45
* Database : (hostname 'postgres', database 'alfresco', user 'alfresco', password 'alfresco')
* LibreOffice (missing)
* Alfresco Share and Apache Solr4 running in the same Java process

## How to use it  

* (1). Run postgres in background

`docker run --name postgres -e POSTGRES_DB=alfresco -e POSTGRES_USER=alfresco -e POSTGRES_PASSWORD=alfresco -d postgres`

* (2) Run Alfresco linked to postgres and expose http port to host

`docker run --name alfresco-standalone --link postgres:postgres -p 8080:8080 -d mikelasla/alfresco-standalone`

* (3) Have fun

[http://localhost:8080/share](http://localhost:8080/share)
