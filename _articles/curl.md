---
layout: page
title: cURL
---

Handy command-line tool for transferring data to or from a server over many protocols, like HTTP, FTP, LDAP, SMTP, MQTT.....

Powered by `libcurl`.

## Cookbook

### Send some JSON to an API

```
curl -X POST -u "username:password" -H "Content-Type: application/json" https://localhost:8123/api/fruits \
    -d "{\"fruits\":\"yummy_yummy\"}"
```
