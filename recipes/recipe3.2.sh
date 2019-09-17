#!/bin/sh

value=1.3
rounded_value=`awk "BEGIN{print int($value+0.5)}"`
echo "The answer is \"$rounded_value\"."
