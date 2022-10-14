---
layout: page
title: Dropbox
---

## Set Dropbox for Linux to run on startup

First, follow the official documentation to download and install the Dropbox daemon.

Then, run the `dropboxd` command for the first time to connect your client to your Dropbox account via the web.

Once set up, quit the program.

Then, create a systemd unit to manage the `dropboxd` daemon:

```
mkdir -p ~/.config/systemd/user.control/

cat << EOF | tee -a ~/.config/systemd/user.control/dropbox.service
[Unit]
Description=Dropbox

[Service]
ExecStart=/home/tdonohue/.dropbox-dist/dropboxd

[Install]
WantedBy=multi-user.target
EOF

systemctl --user enable dropbox.service

systemctl --user start dropbox.service
```

To see the logs:

```
journalctl --user -u dropbox
```

### Add the dropbox.py utility for managing your client

Download <https://www.dropbox.com/download?dl=packages/dropbox.py>.

```
mv ~/Downloads/dropbox.py ~/.local/bin
chmod u+x ~/.local/bin/dropbox.py


```