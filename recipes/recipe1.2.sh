#!/bin/sh

to_val=`expr 30 - 10 + 1`
for i in `yes ""|cat -n|head -30|tail -$to_val`; do
    echo $i
done

awk 'BEGIN{print ""}'

for i in `seq 10 30`; do
    echo $i
done

awk 'BEGIN{print ""}'

for i in `yes ""|cat -n|head -30|awk 'NR>=10&&NR%5==0'{print}`; do
    echo $i
done
