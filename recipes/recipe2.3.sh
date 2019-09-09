#!/bin/sh

var="que sera, sera"
#unset var

defined="YES"
if [ "${var-UNDEF}" = "UNDEF" ]; then
    if [ -z "$var" ]; then
        defined="NO"
    fi
fi

echo $defined
