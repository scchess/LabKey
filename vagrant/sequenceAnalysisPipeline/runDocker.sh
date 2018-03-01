#!/bin/sh

HOST_IP=192.168.56.1
LOCAL_FILE_ROOT=/c/home/
EXPT_DIR=/c/expts/
LK_CODE_DIR=/c/labkey_data/remote/labkey
LOCAL_BUILD_DIR=/c/discvr16.2/build/deploy/

docker run --rm --add-host activemq:$HOST_IP -v $EXPT_DIR:/expts -v $LOCAL_FILE_ROOT:/data -v $LK_CODE_DIR:/labkeyCode -v $LOCAL_BUILD_DIR:/hostBuild -w /labkeyCode -it bbimber/discvr-seq:16.2 bash
