#!/bin/sh

echo "1."
cat recipe1.0.sh 2> /dev/null

echo "2."
cat recipe1.0.sh 2>&1 | awk 'sub(/No/,"NO")'

echo "3."
cat recipe1.0.sh >/dev/null 2>&1 | awk 'sub(/No/,"NO")'
