#!/bin/sh

check=""
while [ -z "$check" ]; do
    echo "Enter your cat's name"
    echo "    1. p-chan"
    echo "    2. ushinosuke"
    echo "    56. komegoro"
    echo -n "Input (1,2,56) ? "
    read check
    case $check in
        1)
            echo "DEBUNESU!"
            ;;
        2)
            echo "Hiyokko-taiyo"
            ;;
        3)
            echo "He's torajiro"
            ;;
        *)
            echo '**** Bad choice !'
            check=""
            ;;
    esac
done
