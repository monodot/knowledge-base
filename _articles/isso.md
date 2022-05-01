---
layout: page
title: Isso (commenting engine)
---

The open source commenting engine; an alternative to Disqus.

## Start/stop

Running with Podman:

```
sudo podman run --rm --name isso -d -v /opt/isso/config:/config -v /opt/isso/db:/db -p 8080:8080 wonderfall/isso
```

Running with docker-compose:

```
cd /opt/isso
sudo /usr/local/bin/docker-compose up -d
```

## Runbook for starting a new site

**1.** Create the directory structure:

```
mkdir -p /opt/isso/comments.example.com/db /opt/isso/comments.example.com/config
touch /opt/isso/comments.example.com/db/comments.db
chown -R isso:isso /opt/isso
```

**2.** Create config file (`./config/isso.cfg`):

```
dbpath = /db/comments.db
host =
    http://www.example.com/
    https://www.example.com/
    http://localhost:4001/
notify = smtp
[server]
listen = http://0.0.0.0:8080/
public-endpoint = https://comments.example.com
[moderation]
enabled = true
purge-after = 365d
[guard]
enabled = true
ratelimit = 2
direct-reply = 3
reply-to-self = true
require-author = true
require-email = false
[smtp]
username = youremail@example.com
password = fuvvvvvvvvvvvv
host = smtp.example.com
port = 587
security = starttls
to = info@example.com
from = info@example.com
timeout = 10
[admin]
enabled = true
password = Henlo-Henlo-Henlo
```

**3.** Create a new Nginx virtual host config (`/etc/nginx/conf.d/comments.example.com.conf`):

```
server {
    server_name comments.example.com;

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8087;
    }

    listen 80; listen [::]:80;
}
```

**4.** Add an `A` record in your nameserver (e.g. Cloudflare) to point to your server's IP address, e.g. `comments` &rarr; `1.2.3.4`

**5.** Restart nginx and test the new virtual host: `curl -v comments.example.com`

**6.** Run `certbot -d comments.example.com` to fetch and install a new SSL certificate.

**7.** Make a launch script (`./launch.sh`):

```bash
#!/bin/sh

echo "Starting isso..."
podman run -v /opt/isso/comments.example.com/config:/config:z -v /opt/isso/comments.example.com/db:/db:z --name isso-dc -d -p 8087:8080 docker.io/monodot/isso:latest
```

**8.** Run the launch script: `sudo su - isso && /opt/isso/comments.example.com/launch.sh`

## DB pruning/editing

```sql
-- will show (describe) the structure of the 'threads' table
.schema threads
```

Moving posts from an old URL to a new one:

```sql
-- get the ID
select * from threads where uri like '%<old-url>%';

-- get the thread ID
select id from comments where tid = <old-url-thread-id>; -- no quotes!
select text from comments where tid = <old-url-thread-id>;

-- update
update comments set tid=<new-tid> where tid=<old-tid>;
```

## API

Setup:

```
export ISSO_BASE=http://yoursite.com/isso
```

Get comments (for `/path/resource-name/`):

```
curl ${ISSO_BASE}/?uri=%2Fpath%2Fresource-name%2F
```

## Troubleshooting

Comment notification emails aren't being sent

- Check logs (`podman logs isso`) - there may be something like _"2020-08-06 17:14:43,727 ERROR: unable to connect to SMTP server"_
-