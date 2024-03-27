---
layout: page
title: Gnome
---

GNOME is a free and open-source desktop environment for Unix-like operating systems. It is the default desktop environment on Fedora.

## Cheatsheet

Check the installed version of GNOME:

```
gnome-shell --version
```

Restart GNOME:

- Press **Alt+F2**
- Type `r` and hit **Enter**.

## Features

### Global search

### Tray/Legacy Tray

- Long-running applications used to add themselves to the GNOME Shell Legacy Tray.

- Use [TopIcons Plus](https://github.com/phocean/TopIcons-plus) GNOME Extension to bring the icons back.

### Applications and shortcuts

Shortcuts are configured using [desktop entry files][desktopfiles], which are usually found in `/usr/share/applications/myapp.desktop`, e.g.:

```
#!/usr/bin/env xdg-open
[Desktop Entry]
Categories=Utility;
Comment=A desktop agnostic launcher
Exec=albert
GenericName=Launcher
Icon=albert
Name=Albert
StartupNotify=false
Type=Application
Version=1.0
```

[desktopfiles]: https://developer.gnome.org/integration-guide/stable/desktop-files.html.en

## Troubleshooting

### Screencast recordings are dark

- Cause: unknown. Possibly caused by the screen-recorder's window/canvas casting a shadow over the content that it's trying to record.
- Possibly caused by "server-side window shadows"? 
- Possibly related: https://gitlab.gnome.org/GNOME/mutter/-/issues/468
- I have tried these (all didn't work):
  - adding `.window-frame { box-shadow: none; }` to `~/.config/gtk-4.0/gtk.css` and `~/.config/gtk-3.0/gtk.css` => didn't work
- I ended up migrating to XFCE to fix this problem (really)


