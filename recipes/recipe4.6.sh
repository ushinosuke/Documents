#!/bin/sh

string="---debunesu-gorin-uchan---"
trimming_chr="-"

while [ "_$string" != "_${string#[$trimming_chr]}" ]; do
    string=${string#[$trimming_chr]}
done

while [ "_$string" != "_${string%[$trimming_chr]}" ]; do
    string=${string%[$trimming_chr]}
done

echo "$string"
