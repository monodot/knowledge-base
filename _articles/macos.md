---
layout: page
title: macOS
---

## Keyboard shortcuts

On my Varmilo keyboard:

- **Win + Alt + Fn + F5** shows the Accessibility Shortcuts menu - useful for enabling Full Keyboard Access when connecting a Bluetooth mouse

## Unexpected restarts

Some useful commands to investigate why your system restarted:

```sh
# Recent reboot history
last reboot | head -10

# Last boot time
who -b

# Power management log — sleep/wake/shutdown events
pmset -g log | grep -E "(Sleep|Wake|Shutdown|Restart|Panic|reboot)" | tail -20

# Shutdown cause codes and kernel panics
pmset -g log | grep -E "(Shutdown Cause|shutdown cause|kernel panic)" | tail -10

# System log search for shutdown/restart/panic events (adjust --last as needed)
log show --last 24h --predicate 'eventMessage contains "shutdown" OR eventMessage contains "restart" OR eventMessage contains "panic"' --style syslog | tail -30

# Recent crash/diagnostic reports (kernel panics, watchdog resets, etc.)
ls -lt ~/Library/Logs/DiagnosticReports/ | head -10
ls -lt /Library/Logs/DiagnosticReports/ | head -10

# Software update history
softwareupdate --history

# Recent software install history (all apps)
system_profiler SPInstallHistoryDataType | grep -B2 -A3 "Date:"
```

