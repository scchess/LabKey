#!/bin/sh

SCRIPT_DIR=`dirname $0`
SCRIPT_NAME=`basename $0`

LABKEY_ROOT=$SCRIPT_DIR/../..
LABKEY_BUILD=$LABKEY_ROOT/build
if [ ! -d "$LABKEY_BUILD" ]; then
    echo "Run 'ant' from $LABKEY_ROOT/server then run this script"
    exit 1
fi

CP=.
CP=$CP:"$LABKEY_ROOT/external/lib/server/*"
CP=$CP:"$LABKEY_ROOT/external/lib/build/*"
# for sfl4j used by ehcache
CP=$CP:$LABKEY_ROOT/server/modules/search/lib/tika-app-0.9.jar
#CP=$CP:$LABKEY_ROOT/external/lib/server/xercesImpl.jar
#CP=$CP:$LABKEY_ROOT/external/lib/server/commons-lang-2.6.jar
#CP=$CP:$LABKEY_ROOT/external/lib/server/xbean.jar
#CP=$CP:$LABKEY_ROOT/external/lib/server/jfreechart-1.0.0.jar
CP=$CP:$LABKEY_BUILD/staging/labkeyWebapp/WEB-INF/lib/api.jar
CP=$CP:$LABKEY_BUILD/staging/labkeyWebapp/WEB-INF/lib/internal.jar
CP=$CP:$LABKEY_BUILD/staging/labkeyWebapp/WEB-INF/lib/schemas.jar
CP=$CP:$LABKEY_BUILD/flow-engine/lib/flow-engine.jar

java -Xmx512m -Xms512m -cp $CP org.labkey.flow.Main "$@"
