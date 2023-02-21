---
layout: page
title: Systemd
---

## Terminology

- A systemd **user instance** runs services for a user. You can interact with it using `systemctl --user ...` 
- **Log metadata fields** are extra fields which can be associated with a log entry in the journal using `LogExtraFields` option, and then visible in the journal using: `journalctl ... -o verbose`

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

### View the contents of a service unit

To view the contents of a service unit **and** all of its override/drop-in files:

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

### Create a user service for a user without logging in first

To run `systemd --user` jobs you usually need a user service running. According to the docs, pam_systemd will set up a systemd user instance for the user when they `ssh` into the server.

If you don't do this, when you try to run `systemd --user` you might get an error like: _"Failed to connect to bus: $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR not defined"_

But what if your user isn't a real person (with an SSH login), but you want to allow them to create `systemd --user` jobs? This should do the trick:

```
export UID=$(id -u johnsmith)
mkdir -p /run/user/$UID
chown johnsmith /run/user/$UID
systemctl start user@$UID
systemctl status user@$UID
```

H/T: https://unix.stackexchange.com/a/641190


### Run an ad-hoc process with systemd

You can start a temporary or "transient" job using `systemd-run`, which means it will run in the background and have its logs sent to the journal. 

This example sets a custom identifier for the job, and uses `--user`, which invokes the **user-level service manager** (so it needs the user service to be available - see above):

```
systemd-run \
    --user \
    --property SyslogIdentifier=my-custom-identifier \
    sh -c "sleep 1 && ./my-script.sh"
```

**NB:** If you want to capture logs from your process, with all the correct metadata attached (like process ID, user, etc.), make sure your process is sufficiently long-lived so that _journald_ can attach itself to your program and capture its metadata. This can be as simple as adding a `sleep` to the start of your job. Without this, log files will appear in the journal, but may not be correctly associated with your job.

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

