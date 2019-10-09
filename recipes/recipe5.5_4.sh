#!/bin/sh

number=0

for line in `ps ax -o "pid ucomm"   | \
             sed -e 's/\(.*\)/\1_/' | \
             tr ' \t' '\006\025'`
do
    line=`echo $line | tr '\006\025' ' \t'`
    line=${line%_}
    pid=`echo "$line" | awk "{print \\$1}"`
    [ -n "`echo $pid | grep "[^0-9]"`"  ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print \\$2}"`

    printf "#%-3d : pid=%d is %s\n" $number $pid "$command"
done

echo "The number of processes is ${number}."
