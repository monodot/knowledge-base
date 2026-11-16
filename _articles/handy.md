---
layout: page
title: Handy
---

Really great, free speech-to-text program that also supports Linux. https://github.com/cjpais/Handy

## Installation on KDE Plasma desktop

1.  Get the RPM URL from the GitHub Releases page and run: `sudo dnf install <URL to .rpm>`

2.  Install dependencies:

    ```sh
    sudo dnf install gtk-layer-shell
    ```

3.  Launch Handy - pick the **Parakeet V3** model.

### Set up the system shortcut

1.  Open System Settings > Shortcuts > Custom Shortcuts
2.  Click Edit > New > Global Shortcut > Command/URL
3.  Name it `Toggle Handy Transcription`
4.  In the Trigger tab, set your desired key combination
5.  In the Action tab, set the command to `handy --toggle-transcription`

Suggested shortcut: `Ctrl + #`
