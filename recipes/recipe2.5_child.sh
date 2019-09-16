#!/bin/sh

echo "start $0"

echo "    global1@child : $global1"
echo "    global2@child : $global2"

global1="tamanegi"
global2="mitsuba"

if [ -f "$temp_file" ]; then
    for variable in global1 global2; do
        eval echo "$variable=\'\$$variable\'" >> $temp_file
    done
fi

echo "end $0"
