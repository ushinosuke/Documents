#!/bin/sh

local="ushinosuke"
global="debunesu"

export global

./recipe2.4_child.sh

echo "  local@parent  : $local"
echo "  global@parent : $global"
