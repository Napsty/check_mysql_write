#!/bin/bash
#########################################################################
# Script:    check_mysql_write.sh                                       #
# Author:    Claudio Kuenzler www.claudiokuenzler.com                   #
# History:                                                              #
# 20150119   Created script                                             #
#########################################################################
# Usage: ./check_mysql_write.sh -H dbhost -P port -u dbuser -p dbpass -d database -q query
#########################################################################
# How does it work?
# The plugin will connect to the given MySQL server and awaits a database given by -d parameter.
# Within this database, a table "monitoring" must exist.
# Here are the SQL commands to prepare the database on a mysql server, 
# assuming you name the database 'mymonitoring':

# CREATE DATABASE mymonitoring;
# GRANT ALL ON mymonitoring.* TO 'monitoring'@'%';
# CREATE TABLE mymonitoring.monitoring ( id INT(1), mytime INT(13) );
# INSERT INTO mymonitoring.monitoring (id, mytime) VALUES (1, 1421421409); (current timestamp)

# Every time the plugin runs, the "mytime" field of ID 1 of the table will be updated with the current timestamp.
#########################################################################
STATE_OK=0              # define the exit code if status is OK
STATE_WARNING=1         # define the exit code if status is Warning (not really used)
STATE_CRITICAL=2        # define the exit code if status is Critical
STATE_UNKNOWN=3         # define the exit code if status is Unknown
curtime=`date +%s`
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin # Set path


for cmd in mysql awk grep [
do
 if ! `which ${cmd} &>/dev/null`
 then
  echo "UNKNOWN: This script requires the command '${cmd}' but it does not exist; please check if command exists and PATH is correct"
  exit ${STATE_UNKNOWN}
 fi
done


# Important given variables for the DB-Connect
#########################################################################
while getopts "H:P:u:p:d:" Input;
do
        case ${Input} in
        H)      host=${OPTARG};;
        P)      port=${OPTARG};;
        u)      user=${OPTARG};;
        p)      password=${OPTARG};;
        d)      database=${OPTARG};;
        \?)     echo "Wrong option given. Please use options -H for host, -P for port, -u for user, -p for password, -d for database and -q for query"
                exit 1
                ;;
        esac
done

# Connect to the DB server and store output in vars
#########################################################################
ConnectionResult=`mysql -h ${host} -P ${port} -u ${user} --password=${password} -D $database -e "UPDATE monitoring SET mytime=$curtime WHERE id=1" 2>&1`
if [[ -n $(echo ${ConnectionResult}) ]]; then
        echo -e "CRITICAL: There was an error trying to write into ${database}.monitoring.  Do a manual check."
        exit ${STATE_CRITICAL}
else echo -e "OK: Update query successful (UPDATE monitoring SET mytime=$curtime WHERE id=1)"
        exit ${STATE_OK}
fi

echo "Script should never arrive here"
exit ${STATE_UNKNOWN}

