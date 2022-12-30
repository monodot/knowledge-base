---
layout: page
title: ss
---

Linux utility that shows socket statistics. The replacement for `netstat` in some distros.

Things you can do with `ss`:

* Display socket statistics (similar to `netstat -s`) - e.g. to troubleshoot network issues
* View TCP and UDP connections, including local and remote addresses and ports
* Find sockets by protocol (e.g. TCP, UDP, etc.)
* See sockets associated with a particular process (PID)

## Reference

### Netid values

In the output of `ss`, Netid means "network protocol identifier". The following values are seen:

* `tcp` - TCP
* `udp` - UDP
* `nl` - [Netlink][netlink]
* `u_str` - Unix stream sockets
* `u_dgr` - Unix datagram sockets
* `u_seq` - Unix sequenced-packet sockets
* `p_dgr` - Packet datagram sockets
* `p_raw` - Packet raw sockets

## Cookbook

### Show all TCP sockets including established connections

```shell
ss --tcp --all
```


### Find out what's listening on a port

```shell
ss -ltnp sport = :<portnum>
```

For example:

```
$ ss -ltnp sport = :8080
State          Recv-Q         Send-Q     Local Address:Port   Peer Address:Port   Process         
LISTEN         0              100                    *:8080              *:*       users:(("java",pid=449045,fd=46))
```

[netlink]: https://en.wikipedia.org/wiki/Netlink
