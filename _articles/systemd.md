---
layout: page
title: Systemd
---

## Cookbook

To manually add a new unit file (i.e. a new service that you want systemd to manage), add it into `/etc/systemd/system`, e.g.:

```
/etc/systemd/system/isso.service
```

To create an override/drop-in file to customise variables for a service:

```
systemctl edit myservice.service
# opens a Nano editor
systemctl daemon-reload
systemctl restart myservice.service
```

To view the content of a service unit and all its override/drop-in files:

```
systemctl cat myservice.service
```

## Examples

An example unit file which launches the _isso_ commenting engine from a container using _podman_:

```
[Unit]
Description=Isso container

[Service]
Restart=on-failure
ExecStartPre=/usr/bin/rm -f /%t/%n-pid /%t/%n-cid
ExecStart=/usr/bin/podman run --conmon-pidfile /%t/%n-pid --cidfile /%t/%n-cid -v /opt/isso/config:/config -v /opt/isso/db:/db -d -p 8080:8080 --net=host docker.io/monodot/isso:latest
ExecStop=/usr/bin/sh -c "/usr/bin/podman rm -f `cat /%t/%n-cid`"
KillMode=none
Type=forking
PIDFile=/%t/%n-pid

[Install]
WantedBy=multi-user.target
```
