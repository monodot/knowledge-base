---
layout: page
title: GlobalProtect
---

An annoying secure endpoint / VPN client thing.

## Installing

Get the distribution from the end user. Then:

```
$ sudo rpm -i GlobalProtect_rpm-5.1.1.0-17.rpm  
warning: GlobalProtect_rpm-5.1.1.0-17.rpm: Header V4 RSA/SHA1 Signature, key ID xxxxxx: NOKEY
Start installing gp...
Enable gp service...
Starting gp service...
Starting gpa...
```

## CLI commands

Connect:

```
globalprotect connect
```

Disconnect/reconnect:

```
globalprotect rediscover-network
```

Resubmit your host information:

```
globalprotect resubmit-hip
```

## Package contents

The RPM package provides these files:

```
$ rpm -ql GlobalProtect_rpm-5.1.1.0-17.rpm
warning: GlobalProtect_rpm-5.1.1.0-17.rpm: Header V4 RSA/SHA1 Signature, key ID 191a652b: NOKEY
/opt/paloaltonetworks/globalprotect/PanGPA
/opt/paloaltonetworks/globalprotect/PanGPS
/opt/paloaltonetworks/globalprotect/PanGpHip
/opt/paloaltonetworks/globalprotect/PanGpHipMp
/opt/paloaltonetworks/globalproCannot find <missing-patches> in the original hip report.
tect/PanMSInit.sh
/opt/paloaltonetworks/globalprotect/globalprotect
/opt/paloaltonetworks/globalprotect/gp_support.sh
/opt/paloaltonetworks/globalprotect/gpd.service
/opt/paloaltonetworks/globalprotect/gpshow.sh
/opt/paloaltonetworks/globalprotect/libwaapi.so
/opt/paloaltonetworks/globalprotect/libwaapi.so.4
/opt/paloaltonetworks/globalprotect/libwaapi.so.4.3.881.0
/opt/paloaltonetworks/globalprotect/libwaheap.so
/opt/paloaltonetworks/globalprotect/libwaheap.so.4
/opt/paloaltonetworks/globalprotect/libwalocal.so
/opt/paloaltonetworks/globalprotect/libwalocal.so.4
/opt/paloaltonetworks/globalprotect/libwalocal.so.4.3.881.0
/opt/paloaltonetworks/globalprotect/libwaresource.so
/opt/paloaltonetworks/globalprotect/libwautils.so
/opt/paloaltonetworks/globalprotect/libwautils.so.4
/opt/paloaltonetworks/globalprotect/libwautils.so.4.3.881.0
/opt/paloaltonetworks/globalprotect/license.cfg
/opt/paloaltonetworks/globalprotect/pangps.xml
/opt/paloaltonetworks/globalprotect/pre_exec_gps.sh
/usr/share/man/man1/globalprotect.1.gz
```

## System services

GlobalProtect creates a systemd service `gpd`:

```
$ systemctl status gpd
● gpd.service - GlobalProtect VPN client daemon
   Loaded: loaded (/usr/lib/systemd/system/gpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-05-06 08:21:11 BST; 2h 29min ago
  Process: 1360 ExecStartPre=/opt/paloaltonetworks/globalprotect/pre_exec_gps.sh (code=exited, status=0/SUCCESS)
 Main PID: 1417 (PanGPS)
    Tasks: 17 (limit: 4915)
   Memory: 472.1M
   CGroup: /system.slice/gpd.service
           └─1417 /opt/paloaltonetworks/globalprotect/PanGPS

May 06 08:21:11 tdonohue-f29 systemd[1]: Starting GlobalProtect VPN client daemon...
May 06 08:21:11 tdonohue-f29 pre_exec_gps.sh[1360]: no pid file
May 06 08:21:11 tdonohue-f29 systemd[1]: Started GlobalProtect VPN client daemon.
```

## Troubleshooting

Can't connect to any protected remote hosts:

- Your system doesn't meet the requirements of the remote partner (e.g. antivirus installed, disk encryption enabled, software patches are up-to-date).
- Satisfy the antivirus/encryption/etc criteria first, then wait for the daemon to pick up the change.
- Check your current host state using `globalprotect show --host-state`.

When running `globalprotect show --host-state`, get the error _"Host State info is not valid."_:

- Check the log file `less /opt/paloaltonetworks/globalprotect/PanGPS.log` for any information/clues.
- Might be something like `Cannot find <missing-patches> in the original hip report.`
