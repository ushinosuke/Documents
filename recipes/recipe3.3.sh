#!/bin/sh

rnd1=`awk 'BEGIN{srand();print int(rand()*6)+1}'`
rnd2=`cat /dev/urandom|od -DA n|head -1|tr -dc 0-9|cut -c -5|awk '$0=int($0*6/10^5)+1'`
rnd3=`jot -r 1 1 6`

for i in `seq 1 3`; do
    eval echo \$rnd$i
done
