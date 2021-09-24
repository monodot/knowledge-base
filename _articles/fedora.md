---
layout: page
title: Fedora
---

For more desktop-y stuff. See RHEL/CentOS page for server-y stuff.

{% include toc.html %}

## Desktop

### GNOME Desktop concepts

Here is a list of things in Fedora/GNOME which it took me a while to figure out **the name of**:

- **System Tray** (GNOME desktop) - this was the area within (usually) the top edge of the screen, where some applications displayed an icon, such as Dropbox, SpiderOak Groups, etc. It has been removed, but you can get it back by installing an extension such as **Topiconsfix**.

- **Activities Search** (GNOME desktop) - this is the search that gets initiated when you press the Super/Windows key and then start typing. It can search Documents, Files, Characters, etc. It can be configured from the GNOME control-center. See [SearchProvider].

### Switching desktop modes

Ensure Fedora starts up in graphical desktop mode:

```
sudo systemctl set-default graphical.target
```

## Networking

Test open ports with bash:

```
cat < /dev/tcp/google.com/443
```

### Networking with NetworkManager

Networking is provided by NetworkManager (`nmcli`).

NetworkManager takes it upon itself to keep `/etc/resolv.conf` updated.

To list all connections that NetworkManager knows about:

```
nmcli connection
```

Show the DNS settings for a connection (e.g. a Wifi network connection)

```
nmcli -f ipv6.dns,ipv4.dns connection show "Hyperoptic 1Gb Fibre 5Ghz"
# or
nmcli c s "Hyperoptic 1Gb Fibre 5Ghz" | grep dns
```

Modify the DNS settings for a connection - e.g. to set NextDNS:

```
nmcli con mod "Hyperoptic 1Gb Fibre 2.4Ghz" ipv6.dns xxxx:xxxx::xx:xxxx,xxxx:xxxx::xx:xxxx
nmcli con mod "Hyperoptic 1Gb Fibre 2.4Ghz" ipv6.ignore-auto-dns yes
nmcli con mod "Hyperoptic 1Gb Fibre 2.4Ghz" ipv4.dns 1.2.3.4,1.2.3.4
nmcli con mod "Hyperoptic 1Gb Fibre 2.4Ghz" ipv4.ignore-auto-dns yes
```

To force an update to `/etc/resolv.conf` after updating settings on a connection:

```
sudo nmcli con up "Hyperoptic 1Gb Fibre 5Ghz"
```

#### VPN connections

To import a VPN connection from an _.ovpn_ file:

```
nmcli connection import type openvpn file /path/to/your.ovpn
```

To make a connection from the command line:

```
nmcli connection up <connection_name>
```

To see the logs, in case something goes wrong when trying to connect:

```
journalctl -u NetworkManager.service
```

Then press `G` to see the most recent log entries.

### Bluetooth

Show all paired Bluetooth devices:

```
bluetoothctl paired-devices
```

Un-pair and re-pair (apparently this is supposed to work):

```
$ DEVICE_ID=11:22:33:44:55:66
$ bluetoothctl
[bluetoothctl] devices
[bluetoothctl] untrust 11:22:33:44:55:66
[bluetoothctl] remove 11:22:33:44:55:66
[bluetoothctl] scan on
[bluetoothctl] scan off
[bluetoothctl] connect 11:22:33:44:55:66
[bluetoothctl] pair 11:22:33:44:55:66
```

You can connect a device using its _Address_, e.g.:

```
$ echo -e "connect 11:22:33:44:55:66" | bluetoothctl
Agent registered
[bluetooth]# connect 11:22:33:44:55:66
Attempting to connect to 11:22:33:44:55:66
```

Check whether some headphones are detected as headphone or headset:

```
$ pactl list | grep head
```


## Tools/apps

### Fonts

Search for fonts:

```
$ dnf search fonts
```

Manually install a font:

```
$ tar xvf the-font-archive.tgz
$ sudo mkdir -p /usr/share/fonts/the-font-name
$ sudo cp *.otf /usr/share/fonts/the-font-name
$ fc-cache -v
```

Reset the font cache:

```
$ fc-cache
```

### Resizing images

In _Software_ app, add the image resizer feature to the Nautilus file browser:

```
$ dnf install nautilus-image-converter
$ nautilus -q
```

### Compressing images

Try Trimage. Installing Trimage on Fedora 29:

```
$ sudo dnf install jpegoptim pngcrush advancecomp
$ git clone https://github.com/Kilian/Trimage && cd Trimage
$ chmod u+x setup.py
$ ./setup.py build
$ sudo ./setup.py install
```

### gnome-software

`gnome-software` provides the GUI application _Software_ for installing updates:

Problem: _"Unable to download firmware updates from 'fwupd' ... failed to download <https://cdn.fwupd.org/downloads/firmware.xml.gz.asc>: Cannot resolve hostname"_

```
$ dnf update gnome-software
```

## Maintenance

### Disk housekeeping

For when your hard disk is embarrassingly too small.

#### Check free disk space

Use `df`:

```
$ df -h /
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   49G   46G  834M  99% /
# Yikes I have hardly any space left! Damn those Docker images
```

#### Check sizes of directories

See the total sizes of files in directories, starting at the root (/):

```
du -h -d 1 /
```

#### View disk usage interactively

Use the _Disk Usage Analyzer_ GUI app for a visual analysis of disk space in use.

**OR** package `ncdu` to view disk usage interactively, using an [ncurses](https://en.wikipedia.org/wiki/Ncurses) style app:

```
$ sudo dnf install ncdu
```

#### Delete Docker images and stuff

Delete Docker stuff to keep the fedora-root partition down to size.

Files in `/var/cache/PackageKit` can reach double-digit GBs. These files are used by GNOME PackageKit (an alternative to `dnf`?).

- Prune using `pkcon refresh force -c 2592000` (2592000 = 1 month in seconds)
- You can remove cached packages by executing `dnf clean packages`
- Find and remove old Docker images (`docker rmi ...`). Use `docker info | grep "Docker Root Dir"` to find the images location and `du` to check the size:

```
$ docker info | grep 'Root Dir'
 Docker Root Dir: /var/lib/docker
$ sudo du -sh /var/lib/docker
11G      /var/lib/docker
$ docker system prune
$ docker image prune -a
$ docker volume prune
$ df -h /
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   49G   37G   11G  79% /
```

#### Prune Podman stuff

Podman puts a lot of files in `$HOME/.local/share/containers`. You can delete it:

```
podman system prune
```

#### Reduce the system journal size

- Journals are kept in `/var/log/journal`
- Edit `/etc/systemd/journald.conf` and set `SystemMaxUse=1G`
- `systemtl restart systemd-journald`

#### Other things to try to reduce disk space

- `minishift delete` to delete the Minishift VM

## Upgrading

To upgrade Fedora, follow the process described at:

https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/

### Troubleshooting upgrades

Error when running `sudo dnf system-upgrade download ...`:

```
Problem: package gstreamer1-plugins-bad-free-gtk-1.16.2-8.fc30.x86_64 requires gstreamer1-plugins-bad-free = 1.16.2-8.fc30, but none of the providers can be installed
  - gstreamer1-plugins-bad-free-1.16.2-8.fc30.x86_64 does not belong to a distupgrade repository
  - problem with installed package gstreamer1-plugins-bad-free-gtk-1.16.2-8.fc30.x86_64
(try to add '--skip-broken' to skip uninstallable packages)
```

- "If some of your packages have unsatisfied dependencies, the upgrade will refuse to continue until you run it again with an extra --allowerasing option. This often happens with packages installed from third-party repositories for which an updated repositories hasn't been yet published." (from the upgrade docs)
- Add `--allowerasing` to the `sudo dnf system-upgrade download` command. This will show the packages that will be erased.

```
Error: Transaction test error:
  file /usr/lib64/libldacBT_abr.so.2.0.2.3 from install of libldac-2.0.2.3-5.fc32.x86_64 conflicts with file from package ldacbt-2.0.2.3-7.fc30.x86_64
  file /usr/lib64/libldacBT_enc.so.2.0.2.3 from install of libldac-2.0.2.3-5.fc32.x86_64 conflicts with file from package ldacbt-2.0.2.3-7.fc30.x86_64
```

- Check which package put the file there: `rpm -qf /usr/lib64/libldacBT_abr.so.2.0.2.3` => `ldacbt-2.0.2.3-7.fc30.x86_64`
- Check which package requires `ldacbt` as a dependency `dnf repoquery --installed --whatrequires ldacbt`
- View info about the package: `dnf info ldacbt`
- Finally, remove it: `dnf remove ldacbt`

## Troubleshooting

**tracker-miner-fs** seems to consume 100% CPU:

- Seems to be a process which indexes files and puts the results in `~/.local/share/tracker`
- Check overall status of the tracker using `tracker status`
- See what each individual daemon is doing by using `tracker daemon`
- If necessary, delete the files/folders which are causing the daemon to go out of control

Fedora no longer boots into a graphical desktop:

- `systemctl set-default graphical.target` seems to have no effect.
- See `systemctl list-units --type target` to see all "targets", or `systemctl list-unit-files --type target`.
- GDM appears to be dead - `systemctl status gdm` reports _inactive_

Why the hell is my default editor now nano? Why are Git commit prompts opening Nano instead of vi?

- Check your environment variables: `env | grep EDITOR`, you'll see that this environment variable points to nano as your default editor.
- To see how it was set, you can run `zsh -xl` which will list all of the commands that are run when you open a new shell. Within this output is a line somewhere that runs a script: `/etc/profile.d/nano-default-editor.sh`
- You can see what package installs this file: `dnf provides /etc/profile.d/nano-default-editor.sh` - it's the `nano-default-editor` package.
- To find out when this package was installed: `dnf repoquery --installed --qf '%{installtime}' nano-default-editor`
- Cross-referencing that with the output from `dnf history` shows that it was installed **when I upgraded to Fedora 33**. [CONTROVERSIAL.][nano]

Some websites aren't loading, and resolve to IP address 0.0.0.0:

- Some websites/scripts don't load in the browser.
- Trying to look up these domains, e.g. `nslookup pagead2.googlesyndication.com`, gives a result of 0.0.0.0
- Have a look at `/etc/resolv.conf`, to see which _nameserver_ you're using. When I looked, mine was showing 127.0.0.53
- 127.0.0.53 is (probably) the address of a caching DNS resolver. Probably _resolved_. Check its status with: `systemd-resolve --status`
- There is a command `resolvectl flush-caches`, but this didn't seem to do anything for me. Instead, you might clear the cache by just restarting _resolved_.
- **To reset the _resolved_ DNS cache, just restart _resolved_: `sudo systemctl restart systemd-resolved`**

[searchprovider]: https://developer.gnome.org/SearchProvider/
[nano]: https://fedoraproject.org/wiki/Changes/UseNanoByDefault
