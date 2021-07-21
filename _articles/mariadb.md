---
layout: page
title: MariaDB
---

## Creating a new user account

List all of the users and schemas in mysql:

```
mysql -u root -e "select host,user from mysql.user; show databases;"
```

Then create a database, create a user and grant all privileges on the database to it:

```
mysql -u root -e "create database sendy; create user 'sendy'@'localhost' identified by 'xxxxxxxxx'; grant all privileges on sendy.* to sendy;"
```
