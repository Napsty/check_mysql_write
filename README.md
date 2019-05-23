# check_mysql_write
A simple monitoring plugin to check if MySQL/MariaDB host can do write operations

How does it work?
The plugin will connect to the given MySQL server and database given by -d parameter.
Within this database, a table "monitoring" must exist.
Here are the SQL commands to prepare the database on a mysql server, assuming you name the database 'mymonitoring':

```
CREATE DATABASE mymonitoring;
GRANT ALL ON mymonitoring.* TO 'monitoring'@'%' IDENTIFIED BY 'secretpassword';
CREATE TABLE mymonitoring.monitoring ( host VARCHAR(100), mytime INT(13) );
```

Every time the plugin runs, the "mytime" column of the row matching the monitoring host will be updated with the current timestamp.
