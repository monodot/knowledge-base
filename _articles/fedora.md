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


## Package management with dnf

Use `dnf` to install packages from official and non-official repos.

- **Modules** in dnf are _package groups representing an application, language runtime or set of tools._ - e.g. `node`, `nginx`, `maven`, `mariadb`, `ruby`, `perl`.

- **Groups** are kind of like modules, but, erm, broader? (can you tell I haven't a clue what I'm talking about)

### dnf and rpm Cookbook

Some things about dnf:

Install something:

```
$ dnf install <spec> # Where spec can be a package-spec, @module-spec or @group-spec
```

List all repos:

```
$ dnf repolist
```

Add a repository:

```
$ dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
```

List all installed software:

```
$ dnf list --installed
$ dnf list --installed mypackage
```

Install something from an RPM file:

```
$ dnf localinstall myrpmfile.rpm
```

Remove a package using `rpm`:

```
$ rpm -e packagename
```

Remove a package but don't remove "unused dependencies":

```
$ dnf remove packagename --noautoremove
```

Or set `clean_requirements_on_remove=false` in `/etc/dnf/dnf.conf`. If still having issues, check if the dependent packages really do have a transitive dependency on the package you're trying to remove, e.g. trying to remove docker and it also wants to remove container-selinux:

```
$ dnf repoquery --requires docker | grep container-selinux
container-selinux >= 2:2.2-2
```

(Yum) Find which group contains a specific package:

```
yum groupinfo '*' | less +/sendmail-cf
```

Get the current Fedora version:

```
$ rpm -E %fedora
```

What application or command is file `<x>` used for? Which package put it there?

```
$ dnf repoquery -l texlive-cancel
/usr/share/licenses/texlive-cancel
/usr/share/licenses/texlive-cancel/pd.txt
/usr/share/texlive/texmf-dist/tex/latex/cancel
/usr/share/texlive/texmf-dist/tex/latex/cancel/cancel.sty

$ rpm -qf /usr/bin/mvn
maven-3.5.4-5.module_f28+3939+dc18cd75.noarch
```

What package requires a specific dependency / can I safely delete a package?

```
$ dnf repoquery --installed --whatrequires ldacbt
ldacbt-0:2.0.2.3-7.fc30.x86_64

$ rpm --test -e ldacbt
# runs a test 'erase' command...should exit 0 if no dependencies
```

What's inside a local RPM file?

```
$ rpm -qlp ~/Downloads/Insomnia.Core-2020.4.1.rpm
/opt/Insomnia/LICENSE.electron.txt
/opt/Insomnia/LICENSES.chromium.html
/opt/Insomnia/chrome-sandbox
/opt/Insomnia/chrome_100_percent.pak
/opt/Insomnia/chrome_200_percent.pak
/opt/Insomnia/icudtl.dat
/opt/Insomnia/insomnia
```

Show dnf history - to see what was installed, and when:

```
$ dnf history | grep ...
```

Find out when a particular package was installed:

```
$ dnf repoquery --installed --qf '%{reason} %{installtime} %{name}-%{evr}.%{arch}' nano-default-editor
unknown 2020-12-02 18:26 nano-default-editor-5.3-4.fc33.noarch
```

### Modules

List all modules available:

```
$ dnf module list
```

List the modules that are enabled (installed):

```
$ dnf module list --enabled
Fedora Modular 30 - x86_64
Name   Stream       Profiles           Summary                                                 
ant    1.10 [d][e]  default [d]        Java build tool                                         
gimp   2.10 [d][e]  default [d], devel GIMP                                                    
maven  3.5 [d][e]   default [d]        Java project management and project comprehension tool  
scala  2.10 [d][e]  default [d]        A hybrid functional/object-oriented language for the JVM

Fedora Modular 30 - x86_64 - Updates
Name   Stream       Profiles           Summary                                                 
ant    1.10 [d][e]  default [d]        Java build tool                                         
gimp   2.10 [d][e]  default [d], devel GIMP                                                    
maven  3.5 [d][e]   default [d]        Java project management and project comprehension tool  

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Disable a module if it's causing problems (e.g. `gimp`):

```
$ dnf module disable gimp
```

### Groups

**Groups** are virtual collections of packages, e.g.:

- `@c-development` - group containing C Development stuff including `gcc-c++`.

List all groups:

```
$ dnf group list --ids
Available Environment Groups:
   Fedora Custom Operating System (custom-environment)
   Minimal Install (minimal-environment)
   Fedora Server Edition (server-product-environment)
   Fedora Workstation (workstation-product-environment)
   Fedora Cloud Server (cloud-server-environment)
   KDE Plasma Workspaces (kde-desktop-environment)
...
```

List all installed groups:

```
$ dnf group list --installed
```

Install a group:

```
$ dnf group install <group-spec>
```

Display package lists of a group:

```
$ dnf group info <group-spec>
```

Find which groups contain a package (e.g. `gcc-c++`):

```
$ dnf group info '*' | less +/gcc-c++
```

### Non-Fedora repositories

**rpmfusion**: a place for packages which can't be distributed in the main Fedora repos, for example:

- _Open Broadcaster Software_
- VLC media player

```
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

[**unitedrpms**][<https://unitedrpms.github.io/>]: multimedia codecs and addons not available in official Fedora repositories.

```
sudo rpm --import https://raw.githubusercontent.com/UnitedRPMs/unitedrpms/master/URPMS-GPG-PUBLICKEY-Fedora
sudo dnf -y install https://github.com/UnitedRPMs/unitedrpms/releases/download/15/unitedrpms-$(rpm -E %fedora)-15.fc$(rpm -E %fedora).noarch.rpm
```

### Installing things manually

It seems to be common practice to install things in `/opt`.

For example, to install an early GraalVM build and add a _relative_ symlink in `/opt/java/graalvm`:

```
sudo mkdir -p /opt/java
sudo chown -R tdonohue:tdonohue /opt/java
tar -C /opt/java -xvf graalvm-ce-1.0.0-rc15-linux-amd64.tar.gz
ln -r -s graalvm-ce-1.0.0-rc15 /opt/java/graalvm
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

**Checking disk space.** Use _Disk Usage Analyzer_ app for a visual analysis of disk space in use. Or use `df`:

```
$ df -h /
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   49G   46G  834M  99% /
# Yikes I have hardly any space left! Damn those Docker images.
```

**Keeping the fedora-root partition down to size.** Files in `/var/cache/PackageKit` can reach double-digit GBs. These files are used by GNOME PackageKit (an alternative to `dnf`?).

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

**Reducing journal size:**

- Journals are kept in `/var/log/journal`
- Edit `/etc/systemd/journald.conf` and set `SystemMaxUse=1G`
- `systemtl restart systemd-journald`

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

[searchprovider]: https://developer.gnome.org/SearchProvider/
[nano]: https://fedoraproject.org/wiki/Changes/UseNanoByDefault
