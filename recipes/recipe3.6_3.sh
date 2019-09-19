#!/bin/sh

if [ -z "`echo "$1"|grep '^0[1-7]*$'`" ]; then
    echo "Invalie number!"
    exit 1
fi
