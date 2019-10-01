#!/bin/sh

### Help Messenger ######################################

#                                                       #

#  Usage : helpmsgr.sh [ -h | --help ]                  #

#                                                       #

#  (Do nothing when no option or invalid option given)  #

#                                                       #

#########################################################

if [ \( "_$1" = "_-h" \) -o \( "_$1" = "_--help" \) ]; then
    awk "/^### /,/^####/{print \$0}" $0
fi
