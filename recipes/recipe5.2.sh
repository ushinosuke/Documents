#!/bin/sh

d=`echo {a..e}|awk "{num=NF+1-2;print \\$num}"`
echo $d

d=$(echo {a..e}|awk "{num=NF+1-2;print \$num}")
echo $d

d=`echo {a..e}|awk "\\$0=\\$(NF+1-2)"`
echo $d

d=$(echo {a..e}|awk "\$0=\$(NF+1-2)")
echo $d
