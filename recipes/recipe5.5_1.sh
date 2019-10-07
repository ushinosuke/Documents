#!/bin/sh

number=0

temp_file=`mktemp /tmp/proclist.XXXXXX`

ps ax -o "pid ucomm" > $temp_file

exec 3<&0 < $temp_file

while read line; do
    pid=`echo "$line" | awk "{print \\$1}"`
    [ -n "`echo "$pid" | grep "[^0-9]"`" ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print \\$2}"`
    printf "#%-3d : pid=%d is %s\n" $number $pid "$command"
done

exec 0<&3 3<&-
[ -f "$temp_file" ] && rm -f $temp_file

echo "The number of processes is ${number}."
