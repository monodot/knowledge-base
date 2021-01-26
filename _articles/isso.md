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