---
layout: page
title: Raspberry Pi
---

## Basic administration

### System information

To get the make & model:

```sh
$ cat /proc/cpuinfo | grep Model
Model		: Raspberry Pi 3 Model B Rev 1.2
```

Check CPU architecture:

```sh
$ uname -m
armv7l
```

To get the current OS:

```sh
$ cat /etc/os-release 
PRETTY_NAME="Raspbian GNU/Linux 11 (bullseye)"
NAME="Raspbian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=raspbian
ID_LIKE=debian
HOME_URL="http://www.raspbian.org/"
SUPPORT_URL="http://www.raspbian.org/RaspbianForums"
BUG_REPORT_URL="http://www.raspbian.org/RaspbianBugs"
```

### File system

Check free disk space:

```sh
$ df -h .
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        58G  4.2G   51G   8% /
```
