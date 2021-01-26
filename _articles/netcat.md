---
layout: page
title: Netcat (nc, ncat)
---

In RHEL 6.9, use `ncat`.

## Reverse proxy

Set up a reverse proxy, forwarding connections to local port `1521` to `dbserver.example.local:1521`:

    ncat -k -l -p 1521 -c "ncat dbserver.example.local 1521"
