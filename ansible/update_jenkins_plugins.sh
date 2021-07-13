#!/bin/bash

## A script to update all jenkins plugins from the command line.
## It is best run at the same jenkins server
##
## REQUIREMENTS:
## - openjdk-8 (at this time)
## - jenkins-cli | https://www.jenkins.io/doc/book/managing/cli/#downloading-the-client

JENKINS_SELF_URL='http://127.0.0.1:8080'
CREDENTIALS='[JENKINS-ADMIN]:[JENKINS-PASSWORD]'

UPDATE_LIST=$( java -jar ./jenkins-cli.jar -s $JENKINS_SELF_URL -auth $CREDENTIALS  list-plugins | grep -e ')$' | awk '{ print $1 }' );
if [ ! -z "${UPDATE_LIST}" ]
then
        echo Updating Jenkins Plugins: ${UPDATE_LIST};
        echo
        read -p "Are you sure you want to update all of the plugins above? Press 'Enter' to continue or 'CTRL+C' to cancel"
        echo

        java -jar ./jenkins-cli.jar -s $JENKINS_SELF_URL -auth $CREDENTIALS install-plugin ${UPDATE_LIST}
        echo

        read -p "Press 'Enter' to restart Jenkins or 'CTRL+C' to cancel"
        echo
        java -jar ./jenkins-cli.jar -s $JENKINS_SELF_URL -auth $CREDENTIALS safe-restart
fi
