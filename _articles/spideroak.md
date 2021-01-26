---
layout: page
title: SpiderOak
---

Backup solution. This page focuses on **SpiderOak Groups**, the enterprise backup product.

## Cheatsheet

Where is SpiderOak Groups located on Linux?

    /usr/bin/SpiderOakGroups

Check for running SpiderOak processes:

    $ ps ax | grep -i SpiderOak
    17803 pts/0    S+     0:00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn -i SpiderOak
    18833 tty2     Sl+    7:46 /opt/SpiderOak Groups/lib/SpiderOakGroups
    19035 tty2     Sl+   13:21 /opt/SpiderOak Groups/lib/SpiderOakGroups --spider
    19090 tty2     S+     0:06 /opt/SpiderOak Groups/lib/inotify_dir_watcher 19035 /home/tdonohue/.config/SpiderOak Groups/config.txt /home/YOURUSER/.config/SpiderOak Groups/exclude.txt /home/YOURUSER/.config/SpiderOak Groups/fs_notify__dir_watcher_ignore


## Troubleshooting:

_"Gui has already been started, exiting"_ when trying to run SpiderOakGroups from the command line:

- This is because SpiderOak Groups is running, but its icon lives in the GNOME System Tray.
- But the Tray was removed in 2017, in GNOME 3.26 (who knows why!)
- So to see the icon, install a GNOME Extension to bring back the tray, such as [TopIconsFix][topiconsfix].


[topiconsfix]: https://extensions.gnome.org/extension/1674/topiconsfix/
