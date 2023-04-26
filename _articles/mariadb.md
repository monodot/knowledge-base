---
layout: page
title: MariaDB (and probably MySQL too)
---

## Cookbook

### Administration

#### Create a new user account

List all of the users and schemas in mysql:

```
mysql -u root -e "select host,user from mysql.user; show databases;"
```

Then create a database, create a user and grant all privileges on the database to it:

```
mysql -u root -e "create database sendy; create user 'sendy'@'localhost' identified by 'xxxxxxxxx'; grant all privileges on sendy.* to sendy;"
```

#### Show disk space usage of databases

```
MariaDB [(none)]> select table_schema as database_name, sum( data_length + index_length ) / 1024 / 1024 as size_in_mb from information_schema.tables group by table_schema;
+--------------------+-------------+
| database_name      | size_in_mb  |
+--------------------+-------------+
| information_schema |  0.07031250 |
| mysql              |  0.62878609 |
| performance_schema |  0.00000000 |
| sendy              |  1.85937500 |
| wp_flathaus        |  1.84375000 |
| wp_intwire         |  6.02453995 |
| wp_monodot         |  1.95312500 |
| wp_tibtest         | 30.78352451 |
+--------------------+-------------+
8 rows in set (0.04 sec)
```


### Backup/restore

#### Create a backup of all databases

```
mysqldump -u root --all-databases > /tmp/all-databases.sql
```

#### Create a dump of a single database and archive it

```
mysqldump -u root --databases mydb > /tmp/mydb.sql
tar -czvf /tmp/mydb.sql.tar.gz /tmp/mydb.sql
```



### Troubleshooting

#### Deploy a troubleshooting pod into a Kubernetes cluster

```
kubectl -n foospace run phpmyadmin-tmp \
    --image=docker.io/library/phpmyadmin \
    --env="PMA_HOST=1.2.3.4" --port=80

kubectl -n foospace port-forward phpmyadmin-tmp 8001:80
```

Now you can access phpMyAdmin at <http://localhost:8001>.

