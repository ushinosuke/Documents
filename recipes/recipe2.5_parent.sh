#!/bin/sh

global1="sato"
global2="shio"

export global1
export global2

temp_file=`mktemp "/tmp/ONABE_GUTSUGUTSU.XXXXXX"`
export temp_file

./recipe2.5_child.sh

for variable in `cat $temp_file`; do
    eval $variable
done
rm -f $temp_file

echo "  global1@parent : $global1"
echo "  global2@parent : $global2"
