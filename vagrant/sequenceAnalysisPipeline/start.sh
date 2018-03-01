#!/bin/bash

#set -x

# Adapt the following lines to your configuration
JAVA_HOME=/usr/lib/jvm/java-8-oracle
LABKEY_HOME=/labkeyCode
LABKEY_LOG=$LABKEY_HOME/output.log
PATH=$JAVA_HOME/bin:$PATH

#Added to support labkey
PATH=$PATH:/labkey/bin
export PATH

#JAVA_OPTS="-Xmx384m -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
JAVA_OPTS="-Xmx4g"
CLASSPATH=$JAVA_HOME/lib/tools.jar:$LABKEY_HOME/labkeyBootstrap.jar

if [ ! -e /pipeline ];then
	mkdir /pipeline
fi

/bin/echo "Copying modules.."
rsync -t -r /hostBuild/modules/*.module $LABKEY_HOME/modules
rsync -t -r /hostBuild/labkeywebapp/ $LABKEY_HOME/labkeywebapp

/bin/echo "Starting LabKey Remote Pipeline Service.."
cd $LABKEY_HOME
$JAVA_HOME/bin/java -cp $CLASSPATH $JAVA_OPTS -Dlabkey.externalModulesDir=$LABKEY_HOME/externalModules \
org.labkey.bootstrap.RemoteServerBootstrap -configdir=$LABKEY_HOME/configs -webappdir=$LABKEY_HOME/labkeywebapp >$LABKEY_LOG 2>&1 &

tail -f $LABKEY_LOG 