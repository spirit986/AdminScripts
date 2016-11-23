#!/bin/bash

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

grep -rnw $LOCATION -e "$PATTERN";

