---
layout: page
title: WordPress
---

## Simple, quick WordPress installation on CentOS

    yum install mariadb
    curl -OL https://wordpress.org/latest.tar.gz
    tar -xvf latest.tar.gz -c /var/www/mysite/public_html/ --strip-components=1
    sudo su -
    mysql -u root -e "select host,user from mysql.user; show databases;" # To list all the current users and schemas in mysql
    mysql -u root -e "create database wp_MYSITE; create user 'wp_MYSITE'@'localhost' identified by 'password'; grant all privileges on wp_MYSITE.* to myuser;"

Update local file update flag (because WordPress expects the httpd user to own the directory):

    echo "define('FS_METHOD', 'direct');" >> /var/www/mysite/public_html/wp-config.php

## Migrating an existing site

To migrate a WordPress installation from one host to another.

Firstly **at the source location** (with bash help from https://tomjn.com/2014/03/01/wordpress-bash-magic/
):

    cd example.com/

    # (Create, gZip, Preserve permissions, Verbose, Filename)
    tar czpvf ../examplecom-wp.tgz .      

    WPDBHOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`;
    WPDBNAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`;
    WPDBUSER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`;
    WPDBPASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`;

    mysqldump -q -u $WPDBUSER -h $WPDBHOST -p$WPDBPASS $WPDBNAME | gzip -9 > ../examplecom.sql.gz

Then, at the **target location**:

    # First open phpMyAdmin and clear all tables in the target schema

    scp user@host:~/examplecom-wp.tgz .
    scp user@host:~/examplecom-sql.tgz .
    # OR, pop into a public folder somewhere and `curl`
    # curl -OL http://myserver.com/examplecom-wp.tgz
    # curl -OL http://myserver.com/examplecom-sql.gz

    cp public_html/wp-config.php .

    WPDBHOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`;
    WPDBNAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`;
    WPDBUSER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`;
    WPDBPASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`;

    gzip -d examplecom-sql.gz
    mysql -u $WPDBUSER -p$WPDBPASS $WPDBNAME < backup.sql

    rm -rf public_html/*

    # Important! extract tar from INSIDE public_html
    cd public_html/
    tar xvf examplecom-wp.tgz
    cp ../wp-config.php .
