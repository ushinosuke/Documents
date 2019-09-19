#!/bin/sh

string="KabayakiUnagiSanshou"
left_word=`echo "$string"|cut -c -8`
middle_word=`echo "$string"|cut -c 9-13`
right_word=$(echo "$string"|cut -c $(expr ${#string} - 7 + 1)-)

echo "$left_word"
echo "$middle_word"
echo "$right_word"
