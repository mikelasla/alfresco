JAVA_OPTS="$JAVA_OPTS -Dalfresco.home=/usr/local/alfresco" 
JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote"
#JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"
JAVA_OPTS="$JAVA_OPTS -XX:ReservedCodeCacheSize=128m"
JAVA_OPTS="$JAVA_OPTS -Xms512M -Xmx1024M" # java-memory-settings
export JAVA_OPTS
			    
