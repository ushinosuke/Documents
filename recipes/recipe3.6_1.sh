#!/bin/sh

if [ -z "`echo "$1"|grep '^[0-9]\+$'`" ]; then
    echo "Invalid number!"
    exit 1
fi
