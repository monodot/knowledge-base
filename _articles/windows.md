---
layout: page
title: Windows
---

## Cookbook

### View application logs using Powershell

This command saves you having to use Windows Event Viewer. It gets the 5 most recent logs from the `Application` log, for the source (application) named `Alloy`:

```
Get-EventLog -LogName Application -Source Alloy -Newest 5 | format-table -wrap
```

Gives a readable, wrapped output like this:

```
PS C:\Users\azureuser> Get-EventLog -LogName Application -Source Alloy -Newest 5 | format-table -wrap

   Index Time          EntryType   Source                 InstanceID Message
   ----- ----          ---------   ------                 ---------- -------
    2136 Feb 02 13:53  Information Alloy                           1 ts=2026-02-02T13:53:50.4427297Z level=info
                                                                     msg="series GC completed" component_path=/remotecf
                                                                     g/self_monitoring_metrics.default
                                                                     component_id=prometheus.remote_write.default
                                                                     subcomponent=wal duration=568.3µs

    2135 Feb 02 13:53  Information Alloy                           1 ts=2026-02-02T13:53:50.1793796Z level=info
                                                                     msg="series GC completed" component_path=/ compone
                                                                     nt_id=prometheus.remote_write.metrics_service
                                                                     subcomponent=wal duration=369.1µs

    2130 Feb 02 12:32  Information Alloy                           1 ts=2026-02-02T12:32:47.8926766Z level=info
                                                                     msg="usage report sent with success"

    2129 Feb 02 12:32  Information Alloy                           1 ts=2026-02-02T12:32:47.7702492Z level=info
                                                                     msg="reporting Alloy stats"
                                                                     date=2026-02-02T12:32:47.770Z

    2124 Feb 02 11:53  Information Alloy                           1 ts=2026-02-02T11:53:50.014528Z level=info
                                                                     msg="WAL checkpoint complete" component_path=/remo
                                                                     tecfg/self_monitoring_metrics.default
                                                                     component_id=prometheus.remote_write.default
                                                                     subcomponent=wal first=95 last=96
                                                                     duration=51.352ms
```
