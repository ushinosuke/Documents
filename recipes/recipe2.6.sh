#!/bin/sh

lsDay=0
eval lsDay_$lsDay=\"Sunday\"   ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=\"Monday\"   ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=\"Tuesday\"  ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=\"Wednesday\"; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=\"Thursday\" ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=\"Friday\"   ; lsDay=`expr $lsDay + 1`
eval lsDay_$lsDay=\"Saturday\" ; lsDay=`expr $lsDay + 1`

i=0
while [ $i -lt $lsDay ]; do
    eval echo \$lsDay_$i
    i=`expr $i + 1`
done
