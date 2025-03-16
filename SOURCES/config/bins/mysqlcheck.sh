#!/bin/sh
[[ -f /etc/sysconfig/argos ]] && . /etc/sysconfig/argos
declare -x HOME=/root
MYSQLBIN=/usr/bin/mysql
[[ -L /usr/bin/mysql ]] && MYSQLBIN="$(readlink /usr/bin/mysql)"
MAXCONN=${MYSQL_MAXCONN:-40}
CONNECTED=$(echo 'show status where `variable_name` = "Threads_connected";' | "$MYSQLBIN" --connect-timeout=10 -rq --column-names=false | awk '{print $2}')
# Don't trigger a restart if MySQL is starting up...
[[ -z $CONNECTED || $CONNECTED -lt $MAXCONN ]]
RET=$?
echo $CONNECTED
exit $RET
