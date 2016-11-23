#!/bin/bash

##############################################################################
# The command `grep -rnw /path/to/dir -e "pattern"`
# is the one of the commands that I use very often so I created a script
# that will ease it for me
# 
# This is provided as is, without any warranties.
# Use it at your own risk.
##############################################################################

if [ -z ${1+x} ]; 
 then 
 echo "LOCATION is not set! \n\nUsage:\nrnw [LOCATION] [PATTERN]\n\n";
 exit
fi

if [ -z ${2+x} ]; 
 then 
 echo "PATTERN is not set! \n\nUsage:\nrnw [LOCATION] [PATTERN]\n\n";
 exit
fi

LOCATION=$1;
PATTERN=$2;

grep --color=always -rnw $LOCATION -e "$PATTERN";

