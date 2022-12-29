---
layout: page
title: ss
---

Linux utility that shows socket statistics. The replacement for `netstat` in some distros.

## Cookbook

### Find out what's listening on a port

```shell
ss -ltnp | grep 8080
```

For example:

```
# ss -ltnp | grep 443
LISTEN 0      128          0.0.0.0:443        0.0.0.0:*    users:(("nginx",pid=2226798,fd=9),("nginx",pid=2226797,fd=9),("nginx",pid=880,fd=9))   
LISTEN 0      128                *:6443             *:*    users:(("k3s-server",pid=2396150,fd=15))                                               
LISTEN 0      128                *:8443             *:*    users:(("traefik",pid=2423631,fd=7))                                                   
LISTEN 0      128             [::]:443           [::]:*    users:(("nginx",pid=2226798,fd=8),("nginx",pid=2226797,fd=8),("nginx",pid=880,fd=8))   
```