#!/bin/sh

bin=1000001
dec=`echo "ibase=2;$bin"|bc`
echo $dec

dec=65
bin=`echo "obase=2;$dec"|bc`
echo $bin
