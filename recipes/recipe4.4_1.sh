#!/bin/sh

ascii_code="$1"
bsla_oct=`printf "\134%03o" $ascii_code`
char=`printf "${bsla_oct}_"`
char=${char%_}

echo "$char"
