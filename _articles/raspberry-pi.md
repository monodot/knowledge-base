---
layout: page
title: Raspberry Pi
---

## Basic administration

### System information

To get the make & model:

```sh
$ cat /sys/firmware/devicetree/base/model;echo
Raspberry Pi 3 Model B Rev 1.2
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
