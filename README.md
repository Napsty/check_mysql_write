# check_mysql_write
A simple monitoring plugin to check if MySQL/MariaDB host can do write operations

## How does it work?

The plugin will connect to the given MySQL server and database given by -d parameter.
Within this database, a table "monitoring" must exist.
Here are the SQL commands to prepare the database on a mysql server, assuming you name the database 'monitoring':

```
CREATE DATABASE monitoring;
GRANT ALL ON monitoring.* TO 'monitoring'@'%' IDENTIFIED BY 'secretpassword';
CREATE TABLE monitoring.monitoring ( id INT(3) NOT NULL AUTO_INCREMENT, host VARCHAR(100), mytime INT(13), PRIMARY KEY (id) );
```

If the table `monitoring` does not exist, the plugin will attempt to create the table on the first run.

Every time the plugin runs, the "mytime" column of the row matching the monitoring host will be updated with the current timestamp.

## But why? 

You might wonder why this plugin exists in the first place. Probably you already monitor your MySQL/MariaDB servers with the `check_mysql` monitoring plugin? Well, that is good and you should not stop doing this. However there are a couple of situations the `check_mysql` plugin still returns OK, even if the database is not correctly working. The best known such situation is when the disk space (of `/var/lib/mysql`) runs out of space. Only a write operation check, with `check_mysql_write` will correctly identify that there is an issue.

## Does it support Galera clusters?

Yes. The challenge with Galera clusters is the concurrent write into multiple (active) Galera nodes. This is why the `monitoring` table has been adjusted to circumvent this problem and to avoid concurrent writes into the same row. 

See [How to monitor MySQL or MariaDB Galera Cluster writes and avoid deadlocks](https://www.claudiokuenzler.com/blog/858/how-to-monitor-mysql-mariadb-percona-galera-cluster-writes-avoid-deadlocks) for more information.

