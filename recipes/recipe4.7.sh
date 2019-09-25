#!/bin/sh

filepath="/food/Nihon/yoshoku/hayashirice.txt"

filename=${filepath##*/}
dirpath=${filepath%/*}

echo Found "$filename" at "$dirpath" with shell functions.

filename=`basename "$filepath"`
dirpath=`dirname "$filepath"`

echo Found "$filename" at "$dirpath" with commands.
