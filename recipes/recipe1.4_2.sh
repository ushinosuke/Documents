#!/bin/sh

check=""
while [ -z "$check" ]; do
    echo -n "Do you like bretzel (Y/N) ? "
    read check
    case $check in
        [Yy]*)
            check="YES"
            ;;
        [Nn]*)
            check="NO"
            ;;
        *)
            echo 'Answer either "Y" or "N" '
            printf "\007"
            check=""
            ;;
    esac
done
