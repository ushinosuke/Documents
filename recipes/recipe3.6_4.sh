#!/bin/sh

if [ -z "`echo "$1"|grep '^[01]\+$'`" ]; then
    echo "Invalid number!"
    exit 1
fi
