#!/bin/sh
PID=`pidof mysqld`
if [[ -z "$PID" ]] ; then 
	systemctl stop mariadb
	exit $?
fi
/bin/kill -9 $PID
exit 0


