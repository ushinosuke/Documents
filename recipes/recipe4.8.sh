#!/bin/sh

RAND=`mktemp /tmp/temp.XXXXXX`
if [ $? -eq 0 ]; then
    rm $RAND ; RAND=${RAND#/tmp/temp.}
fi
echo $RAND
