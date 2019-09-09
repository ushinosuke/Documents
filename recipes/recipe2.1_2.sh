#!/bin/sh

var="var outside f"

f () {
    local var="var inside f"
    echo "$var"
}

f
echo "$var"
