# check_mysql_write
A simple monitoring plugin to check if MySQL/MariaDB host can do write operations

How does it work?
The plugin will connect to the given MySQL server and database given by -d parameter.
Within this database, a table "monitoring" must exist.
Here are the SQL commands to prepare the database on a mysql server, assuming you name the database 'monitoring':

```
CREATE DATABASE monitoring;
GRANT ALL ON monitoring.* TO 'monitoring'@'%' IDENTIFIED BY 'secretpassword';
CREATE TABLE monitoring.monitoring ( id INT(3) NOT NULL AUTO_INCREMENT, host VARCHAR(100), mytime INT(13), PRIMARY KEY (id) );
```

Every time the plugin runs, the "mytime" column of the row matching the monitoring host will be updated with the current timestamp.
