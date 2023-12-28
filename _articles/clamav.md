---
layout: page
title: ClamAV
---

Open source antivirus toolkit.

The various components are:

- **clamd** - a multi-threaded daemon that listens for scan requests on a network socket (TCP) or unix socket (local). Client applications for clamd include clamdtop, clamdscan, clamav-milter, and clamonacc.
- **clamscan** - the command-line scanner. Scan files and directories without needing the clamd daemon to be running.
- **freshclam** - the virus database updater
- **clamonacc** - a daemon that receives on-access events from the kernel, so that it can run real-time scans through ClamD.

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

### Set up a cron job to run a daily scan and update the virus database

To set up a daily scan, su to root and edit the crontab:

```
sudo su -
crontab -e
```

Then add this line to the crontab to run a scan every day at 15:52.

```
52 15 * * * clamscan --infected --log /var/log/clamav/scan.log --recursive /
30 09 * * * freshclam 
```

### Set up and run the clamd daemon



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
