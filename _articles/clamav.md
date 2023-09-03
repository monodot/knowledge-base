---
layout: page
title: ClamAV
---

Open-source antivirus toolkit.

## Installation on Fedora

```bash
sudo dnf install clamav clamav-update 
```

List all the services you can start:

```
$ ls -al /usr/lib/systemd/system/clam*
-rw-r--r--. 1 root root 519 Feb 20 16:50 /usr/lib/systemd/system/clamav-clamonacc.service
-rw-r--r--. 1 root root 389 Feb 20 16:50 /usr/lib/systemd/system/clamav-freshclam.service
-rw-r--r--. 1 root root 398 Feb 20 16:44 /usr/lib/systemd/system/clamd@.service
lrwxrwxrwx. 1 root root  24 Feb 20 16:50 /usr/lib/systemd/system/clamonacc.service -> clamav-clamonacc.service
```

## Configuration

Before you can start the ClamAV scanning engine (using either clamd or clamscan), you must first have ClamAV Virus Database (.cvd) file(s) installed in the appropriate location on your system.

```bash
sudo freshclam
```

Then start ClamAV services:

```bash
sudo systemctl enable clamav-freshclam
sudo systemctl start clamav-freshclam
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-daemon
```

## Usage

```bash
sudo clamscan -r /home
```
