---
layout: page
title: GoAccess
---

GoAccess is an awesome web log analyser.

## Installation

Simple:

    sudo yum install goaccess

## Filtering

Just use `grep`:

```
zcat -f /var/log/nginx/mysite.com.log-202012* | grep -ir 'GET /jenkins-shared-library/' | goaccess --ignore-crawlers --log-format=COMBINED -a 
```

To remove all `/isso` entries:

```
zcat -f /var/log/nginx/mysite.com.log-202012* | grep -iv 'isso' | goaccess --ignore-crawlers --log-format=COMBINED -a 
```

## Example - produce a separate GoAccess log page for multiple Nginx virtual hosts

Configure each virtual host in nginx to write logs to its own file - e.g.:

```
server {
    access_log /var/log/nginx/example.com.log combined;
    ...
}
```

Use logrotate to rotate the Nginx logs daily, and keep **N** days of data - for example, to keep 365 days:

```
/var/log/nginx/*log {
    create 0644 nginx nginx
    daily
    rotate 365
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
        /bin/kill -USR1 `cat /run/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
```

Create a shell script -- e.g. `scripts/publish-stats.sh` to run _goaccess_ for each log file, and publish an HTML file in the webroot of each website:

```
#!/bin/sh

zcat -f /var/log/nginx/example.com.log* | goaccess --log-format=COMBINED -a -o /var/www/example.com/public_html/stats.html -
zcat -f /var/log/nginx/examplecat.com.log* | goaccess --log-format=COMBINED -a -o /var/www/examplecat.com/public_html/stats.html -
```

And then add this script to the crontab so that it runs whenever you like. For example, to run it every hour:

```
$ crontab -l
@hourly /home/fred/scripts/publish-stats.sh
```
