---
layout: page
title: Sendy
---

## Upgrades

Take a backup of the database first:

```
sudo su -
mysqldump sendy | gzip > sendy-$(date -I).sql.gz
```

Back up the old version:

```
tar cvfz sendy-src-$(date -I).tar.gz -C /var/www/sendy.example.com sendy/

tar cvf /var/www/sendy.example.com/sendy
```

Deploy the new version:

```
mkdir tmp && cd tmp
unzip sendy-new-version.zip
cp /var/www/sendy.example.com/sendy/includes/config.php ./sendy/includes/
/bin/cp -rp sendy /var/www/sendy.example.com/

chown -R nginx:nginx /var/www/sendy.example.com/sendy/uploads
chmod -R 775 /var/www/sendy.example.com/sendy/uploads
```