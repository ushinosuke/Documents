#!/bin/sh

string="三文字"
LANG=C; echo ${#string}
LANG=ja_JP.UTF-8; echo ${#string}
