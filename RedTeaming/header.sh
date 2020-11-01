#!/bin/bash
BLUE='\033[1;94m'
YELLOW='\033[1;93m'
GREEN='\033[1;92m'
RED='\033[1;91m'
RESETCOLOR='\033[0m'
# [Display the Header]
fix5c=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 6 | head -n 1)
array[0]=$(echo -e $RED"                 Human Stupidity, that’s why Hackers always win.              "$RESETCOLOR)
array[1]=$(echo -e $BLUE"            The quieter you become, the more you are able to hear…            "$RESETCOLOR)
array[2]=$(echo -e $YELLOW"                     Never tell everything you know…                          "$RESETCOLOR)
array[3]=$(echo -e $GREEN"           We are simply an evolution, but are we the last?                   "$RESETCOLOR)
size=${#array[@]}
index=$(($RANDOM % $size))
clear
echo -e " ______________________________________________________________________________
|                                                                              |
|${array[$index]}|
|______________________________________________________________________________|
|                                                                              |
|                 Username:           [    $GREEN $fix5c $RESETCOLOR   ]                        |
|                                                                              |
|                 Password:           [   DontHackMe  ]                        |
|                                                                              |
|                                   [$YELLOW OK $RESETCOLOR]                                     |
|______________________________________________________________________________|"
fortune 25% debian 25% debian-hints 50% computers -s -n 200 | cowthink -f tux -W 80
