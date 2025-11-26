---
layout: page
title: SSH
---

## Cookbook

### Add a new authorized key (temporarily allow password authentication)

Assuming you already have access to the remote host, enable password based authentication:

1.  Edit `/etc/ssh/sshd_config` and set `PasswordAuthentication yes`

2.  Restart ssh: `systemctl restart ssh`

1.  From the new host:

    ```sh
    ssh-keygen -t ed25519

    ssh-copy-id user@host
    ```

1.  Disable password authentication again. Edit `/etc/ssh/sshd_config` and set `PasswordAuthentication no`

1.  `systemctl restart ssh`
