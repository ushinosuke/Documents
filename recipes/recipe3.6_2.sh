#!/bin/sh

if [ -z "`echo "$1"|grep '^0x[0-9a-fA-F]\+$'`" ]; then
    echo "Invalid number!"
    exit 1
fi
