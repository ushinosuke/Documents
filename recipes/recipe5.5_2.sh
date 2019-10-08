#!/bin/sh

IFS_BACKUP=$IFS
IFS=`printf '\012_'` ; IFS=${IFS%_}

number=0

for line in `ps ax -o "pid ucomm"`
do
    pid=`echo "$line" | awk "{print \\$1}"`
    [ -n "`echo "$pid" | grep "[^0-9]"`" ] && continue
    number=`expr $number + 1`
    command=`echo "$line" | awk "{print \\$2}"`

    printf "#%-3d : pid=%d is %s\n" $number $pid "$command"
done

IFS=$IFS_BACKUP
unset IFS_BACKUP

echo "The number of processes is ${number}."
