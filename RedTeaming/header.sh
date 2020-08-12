#!/bin/bash

# [Display the Header]
fix5c=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 6 | head -n 1)
array[0]=$(echo "                 Human Stupidity, that’s why Hackers always win.              ")
array[1]=$(echo "            The quieter you become, the more you are able to hear…            ")
array[2]=$(echo "                     Never tell everything you know…                          ")
array[3]=$(echo "           We are simply an evolution, but are we the last?                   ")
size=${#array[@]}
index=$(($RANDOM % $size))
clear
echo "______________________________________________________________________________
|                                                                              |
|${array[$index]}|
|______________________________________________________________________________|
|                                                                              |
|                 Username:           [    $fix5c     ]                        |
|                                                                              |
|                 Password:           [   DontHackMe  ]                        |
|                                                                              |
|                                   [ OK ]                                     |
|______________________________________________________________________________|"
fortune 25% debian 25% debian-hints 50% computers -s -n 200 | cowthink -f tux -W 80
