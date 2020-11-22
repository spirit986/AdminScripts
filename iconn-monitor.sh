#!/bin/sh

## Checks your internet connection 
## The checks are done in two ways:
## First the script checks with a ping against your gateway (router) IP address
##   in order to determine if your local network is configured properly.
## Then two checks are done with curl agains google and yahoo.
##   Only if both do not open then the script decides that 
##     there is an internet connection problem.
## Reports only the changes and how long the previous state lasted.

api_check () {
	if [[ -z "$SITE" ]]
	then
		echo "SITE must be set!"
		exit 1
	else
		curl --connect-timeout 1 --max-time 1 -s $SITE >/dev/null
	fi
}

## Set this to your router's IP
GATEWAY_IP="172.16.0.1"

CURRENT_STATE="0"
PAST="$(date "+%s")"

while :
do

	ping -c1 -w1 -W1 "$GATEWAY_IP" >/dev/null
	if [[ ! $? -eq 0 ]]
	then
		GATEWAY=0
		GW_PRESENT_STATE="GATEWAY = ERROR"
	else
		GATEWAY=1
		GW_PRESENT_STATE="GATEWAY = OK"
	fi

	SITE="https://google.com"
	api_check

	if [[ ! $? -eq 0 ]]
	then
		GOOGLEOK=0
	else
		GOOGLEOK=1
	fi

	SITE="https://yahoo.com"
	api_check

	if [[ ! $? -eq 0 ]]
	then
		YAHOOOK=0
	else
		YAHOOOK=1
	fi

	if [[ $GOOGLEOK -eq 0 ]] && [[ $YAHOOOK -eq 0 ]]
	then
		INTERNET_PRESENT_STATE="INTERNET = ERROR"
	else
		INTERNET_PRESENT_STATE="INTERNET = OK"
	fi

	PRESENT_STATE="$GW_PRESENT_STATE | $INTERNET_PRESENT_STATE"

	if [[ $PRESENT_STATE != $CURRENT_STATE ]]
	then
		PRESENT="$(date "+%s")"
		CHANGE=`expr $PRESENT - $PAST`

		echo "$(date "+%FT%T") | $PRESENT_STATE | Last change was: $CHANGE seconds ago"
	fi

	CURRENT_STATE=$PRESENT_STATE
	PAST=$PRESENT

	sleep 1

done

