#!/bin/sh
[[ -f /etc/sysconfig/argos ]] && . /etc/sysconfig/argos
declare -x HOME=/root
MAXCONN=${MYSQL_MAXCONN:-40}
CONNECTED=$(echo 'show status where `variable_name` = "Threads_connected";' | mysql --connect-timeout=10 -rq --column-names=false | awk '{print $2}')
# Don't trigger a restart if MySQL is starting up...
[[ -z $CONNECTED || $CONNECTED -lt $MAXCONN ]]
RET=$?
echo $CONNECTED
exit $RET
