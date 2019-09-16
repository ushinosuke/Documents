#!/bin/sh

hnCalorie=" "
eval hnCalorie_zarusoba=\"300\"; hnCalorie="${hnCarolie}zarusoba "
eval hnCalorie_doria=\"700\"   ; hnCalorie="${hnCalorie}doria "
eval hnCalorie_unadon=\"650\"  ; hnCalorie="${hnCalorie}unadon "

for key in $hnCalorie; do
    eval echo "$key : \$hnCalorie_$key"
done
