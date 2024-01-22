MySQL replication playground

run `docker-compose up`

Open MySQL console on master with `mysql -P 3306 -h 127.0.0.1 -u root -p` using password `root`

Grant replication to user

```
GRANT REPLICATION SLAVE ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

Lock the db

```
USE mydb; 
FLUSH TABLES WITH READ LOCK;
```

Check master status
```
SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+----------------------------------------+
| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set           |
+------------------+----------+--------------+------------------+----------------------------------------+
| mysql-bin.000003 |   197 | mydb     |
```

Make a dump

```
mysqldump -P 3306 -h 127.0.0.1 -u root -p mydb > mydb.sql
```

Unlock tables

```
UNLOCK TABLES;
```

On both replicas then use dump to restore db with `mysql -P 3307 -h 127.0.0.1 -u root -p mydb < mydb.sql` and `mysql -P 3308 -h 127.0.0.1 -u root -p mydb < mydb.sql` respectively

on both replicas run the command to start proper replication

```
CHANGE MASTER TO MASTER_HOST=‘mysql-master’, MASTER_USER=‘root’,MASTER_PASSWORD=‘root’,MASTER_LOG_FILE=‘mysql-bin.000003’,MASTER_LOG_POS=197;
START SLAVE;
```

Check status

```
mysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: mysql-master
                  Master_User: root
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 427
               Relay_Log_File: 7241d8811793-relay-bin.000002
                Relay_Log_Pos: 556
        Relay_Master_Log_File: mysql-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
```

Create the db on master node:

```
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    amount INT NOT NULL,
    note TEXT,
    weight DECIMAL(8, 2)
);
```

observe it was created on the replicas

run the script `./script.sh` to continuosly write random data to the table

tried `STOP SLAVE;` and `START SLAVE;` - stopped properly and after start applied all missed changes

tried rmeoving the last column `weight` from the slave - replication continued, but ofc without this field

tried removing the column from the middle `price` - replication stopped b/c of incompatibility of the binlogs