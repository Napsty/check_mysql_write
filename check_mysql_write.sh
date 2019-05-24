#!/bin/bash
##################################################################################
# Script:    check_mysql_write.sh                                                #
# Author:    Claudio Kuenzler www.claudiokuenzler.com                            #
# History:                                                                       #
# 20150119   Created script                                                      #
# 20190523   Adapt script for multi-master clusters (use different row per host) #
##################################################################################
# Usage: ./check_mysql_write.sh -H dbhost -P port -u dbuser -p dbpass -d database 
##################################################################################
# How does it work?
# The plugin will connect to the given MySQL server and awaits a database given by -d parameter.
# Within this database, a table "monitoring" must exist.
# Here are the SQL commands to prepare the database on a mysql server,
# assuming you name the database 'mymonitoring':

# CREATE DATABASE mymonitoring;
# GRANT ALL ON mymonitoring.* TO 'monitoring'@'%';
# CREATE TABLE mymonitoring.monitoring ( host VARCHAR(100), mytime INT(13) );

# Every time the plugin runs, the "mytime" column of the row matching the host will be updated with the current timestamp.
#########################################################################
STATE_OK=0              # define the exit code if status is OK
STATE_WARNING=1         # define the exit code if status is Warning (not really used)
STATE_CRITICAL=2        # define the exit code if status is Critical
STATE_UNKNOWN=3         # define the exit code if status is Unknown
curtime=`date +%s`
port=3306
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
# Check if we already have a row for our monitoring host where this script runs on
hostcheck=$(mysql -h ${host} -P ${port} -u ${user} --password=${password} -D $database -Bse "SELECT COUNT(host) FROM monitoring WHERE host = '$(hostname)'")
if [[ $hostcheck -eq 0 ]]
  then # We need to create the first row entry for this host
  mysql -h ${host} -P ${port} -u ${user} --password=${password} -D $database -e "INSERT INTO monitoring (host, mytime) VALUES ('$(hostname)', $curtime)"
  result=$?
  else # Our host already has a row, update the row
  mysql -h ${host} -P ${port} -u ${user} --password=${password} -D $database -e "UPDATE monitoring SET mytime=$curtime WHERE host = '$(hostname)'"
  result=$?
fi

if [[ $result -gt 0 ]]; then
        echo -e "CRITICAL: There was an error trying to write into ${database}.monitoring.  Do a manual check."
        exit ${STATE_CRITICAL}
else echo -e "OK: Write query successful (UPDATE monitoring SET mytime=$curtime WHERE host='$(hostname)')"
        exit ${STATE_OK}
fi

echo "Script should never arrive here"
exit ${STATE_UNKNOWN}
