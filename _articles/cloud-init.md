---
layout: page
title: cloud-init
---

## Examples

### Clone a repo, then bring up its Docker Compose stack, with custom vars

```yaml
#cloud-config

# Write a file to the filesystem, containing some env vars that the application will use
write_files:
- path: /etc/myapp.env
  owner: root:root
  permissions: '0644'
  content: |
    HELLO=world
    MY_GRAFANA_ENDPOINT=xxxxxxxx
    PROMETHEUS_ENDPOINT=yyyyyyyy

# Add GitHub's public key fingerprints to known_hosts, so we can verify our connection to GitHub
# See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
- path: /etc/ssh/known_hosts
  owner: root:root
  permissions: '0644'
  content: |
    github.com ecdsa-sha2-nistp256 AAAA....
    github.com ssh-rsa AAAA.....
    github.com ssh-ed25519 AAAA....

# Update SSH config to use a custom private key (given below) so we can clone from GitHub
- path: /etc/ssh/ssh_config
  owner: root:root
  permissions: '0600'
  content: |
    # Copyright 2019 The Chromium OS Authors. All rights reserved.
    # Use of this source code is governed by a BSD-style license that can be
    # found in the LICENSE file.

    Host *

    Protocol 2
    ForwardAgent no
    ForwardX11 no
    HostbasedAuthentication no
    StrictHostKeyChecking no
    Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc
    Tunnel no

    # Google Compute Engine times out connections after 10 minutes of inactivity.
    # Keep alive ssh connections by sending a packet every 7 minutes.
    ServerAliveInterval 420

    Host github.com
      HostName github.com
      IdentityFile /etc/ssh/ssh_host_rsa_key

# Define an SSH key which has read-only access to a GitHub repo
ssh_keys:
  rsa_private: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3B...
    ...
    xxx==
    -----END OPENSSH PRIVATE KEY-----
  rsa_public: ssh-rsa AAA...qq9= your-key@example.mycorp.com

# Here are some commands which will run on startup
# 1. Clone a repo
# 2. Use containerised docker-compose to bring up a Docker Compose stack
# 3. Write a file to indicate that the cloud-init script has completed
runcmd:
  - sudo git -C /var clone git@github.com:monodot/myrepo myapp
  - docker run -itd -v /var/run/docker.sock:/var/run/docker.sock -v /var/myapp:/var/myapp --env-file /etc/myapp.env docker/compose:1.29.2 -f /var/myapp/docker-compose.yml up --build -d
  - echo 'done' > /tmp/CLOUD_INIT_COMPLETED
```

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
