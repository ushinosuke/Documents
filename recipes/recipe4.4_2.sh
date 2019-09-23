#!/bin/bash

char="$1"
ascii_code=`echo -n "$char"|od -t uC|awk '$0=$2'`
[ -z "$ascii_code" ] && ascii_code=0

echo "$ascii_code"
