# check_mysql_write
A simple monitoring plugin to check if MySQL/MariaDB host can do write operations

How does it work?
The plugin will connect to the given MySQL server and database given by -d parameter.
Within this database, a table "monitoring" must exist.
Here are the SQL commands to prepare the database on a mysql server, assuming you name the database 'mymonitoring':

```
CREATE DATABASE mymonitoring;
GRANT ALL ON mymonitoring.* TO 'monitoring'@'%';
CREATE TABLE mymonitoring.monitoring ( id INT(1), mytime INT(13) );
INSERT INTO mymonitoring.monitoring (id, mytime) VALUES (1, 1421421409); (current timestamp)
```

Every time the plugin runs, the "mytime" field of ID 1 of the table will be updated with the current timestamp.
