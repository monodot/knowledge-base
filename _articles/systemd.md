---
layout: page
title: Systemd
---

## Paths and locations

For the full up-to-date list of paths searched by _systemd_, see `man 5 systemd.unit`, and see the list of System Unit Search Paths and User Unit Search Paths.

### System unit files

To manually add a new unit file (i.e. a new service that you want systemd to manage), add it into `/etc/systemd/system`, e.g.:

```
/etc/systemd/system/isso.service
```

### User unit search paths

Some places to put user-level units:

- ~/.config/systemd/user.control/
- ~/.config/systemd/user/

## Cookbook

### View the content of a service unit

To view the content of a service unit **and** all its override/drop-in files:

```
systemctl cat myservice.service
```

### Override service configuration (e.g. provide environment variables)

You can override a unit's configuration without changing the original `.service` file. For example, you might want to add environment variables, or make some customisations to the service:

```
systemctl edit myservice.service
# opens a Nano editor

systemctl daemon-reload

systemctl restart myservice.service
```

**Inside the override file:** For example, to set some environment variables for a service, just add the following to the override file:

```
[Service]
Environment=MY_ENV_VAR=foo ANOTHER_ENV_VAR=barrrr
```

## Examples

### Run promtail as a service

```
cat << EOF | sudo tee -a /etc/systemd/system/promtail.service
[Unit]
Description=Promtail

[Service]
ExecStart=/usr/local/bin/promtail \\
    -config.file=/etc/promtail-config-cloud.yaml \\
    -config.expand-env=true

[Install]
WantedBy=multi-user.target
EOF
```

Then enable and start the service:

```
# Creates symlink from /etc/systemd/system/multi-user.target.wants/promtail.service to the actual unit
sudo systemctl enable promtail

sudo systemctl start promtail
```

### Run isso commenting engine as a service with Podman

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

## Troubleshooting

Process terminates, with _"main process exited, code=killed, status=9/KILL"_:

- Check why it was killed, with this command: `dmesg -T| grep -E -i -B100 'killed process'`
- The result should be shown, e.g. _"Out of memory: Killed process 3994 (java) total-vm:2715460kB, anon-rss:162732kB, file-rss:0kB, shmem-rss:0kB, UID:1005 pgtables:644kB oom_score_adj:0"_

