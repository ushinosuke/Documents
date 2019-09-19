#!/bin/sh

mycat="Debunesu"

echo "$mycat"|tr 'a-z' 'A-Z'
echo "$mycat"|tr 'A-Z' 'a-z'

echo "$mycat"|awk '$0=toupper($0)'
echo "$mycat"|awk '$0=tolower($0)'
