#!/bin/sh

i=10
while [ $i -le 30 ]; do
    echo $i
    i=`expr $i + 5`
    #i=$(expr $i + 5)
    #i=$((i + 5))
done
