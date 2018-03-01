#!/bin/bash

PID=`ps ax | grep java | grep labkey | grep -v grep | grep -v activemq | sed 's/^ *//' | cut -d ' ' -f 1`

kill -9 $PID