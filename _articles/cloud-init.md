---
layout: page
title: cloud-init
---

## Running on GCP

- You can run cloud-init on a GCP instance.
- The content of your provided cloud-init config script appears to be written to:
  - `/var/lib/cloud/instances/xxxxxxxxxxxxxxx/cloud-config.txt`
  - or `/var/lib/cloud/instances/xxxxxxxxxxxxxxx/user-data.txt`

Places it looks for YAML:

- /etc/cloud/cloud.cfg.d/91-datasource.cfg
- /etc/cloud/cloud.cfg.d/10-disable_ssh_publish_hostkeys.cfg
- /etc/cloud/cloud.cfg.d/05_logging.cfg
- /run/cloud-init/cloud.cfg
- /var/lib/cloud/instance/cloud-config.txt

When it runs, it looks for YAML in `/var/lib/cloud/instance/cloud-config.txt`. Here's the log:

```
Reading from /var/lib/cloud/instance/cloud-config.txt (quiet=False)
2022-10-10 14:13:25,700 - util.py[DEBUG]: Read 26 bytes from /var/lib/cloud/instance/cloud-config.txt
```

## Cookbook

### Check logs of a cloud-init run

After cloud-init has run on startup, you can see the results:

- High level in the system journal: `sudo journalctl -u cloud-init`
- With more details in a log file: `less /var/log/cloud-init.log`
```

This will give

### Delete previous run and re-run init script

```
rm -f /var/log/cloud-init.log \
&& rm -Rf /var/lib/cloud/* \
&& cloud-init -d init \
&& cloud-init -d modules --mode final
```

You can also specify a cloud init file with `--file`, e.g.:

```
cloud-init --file /home/tom/cloudinit.yml -d modules --mode final
```
