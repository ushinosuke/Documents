#!/bin/sh

number=0

ps ax -o "pid ucomm" | while read line; do
    pid=`echo "$line" | awk "{print \\$1}"`
    [ -n "`echo "$pid" | grep "[^0-9]"`" ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print \\$2}"`

    printf "#%-3d : pid=%d is %s\n" $number $pid "$command"
done

echo "The number of processes is ${number}."
