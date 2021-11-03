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

