#!/bin/sh

echo "start $0"

echo "  local@child  : $local"
echo "  global@child : $global"

local="gorin"
global="tora"

export global

echo "end $0"
