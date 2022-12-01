---
layout: page
title: MariaDB (and probably MySQL too)
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

## Cookbook

### Deploy a troubleshooting pod into a Kubernetes cluster

```
kubectl -n foospace run phpmyadmin-tmp \
    --image=docker.io/library/phpmyadmin \
    --env="PMA_HOST=1.2.3.4" --port=80

kubectl -n foospace port-forward phpmyadmin-tmp 8001:80
```

Now you can access phpMyAdmin at <http://localhost:8001>.

