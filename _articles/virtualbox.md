---
layout: page
title: VirtualBox
---

VirtualBox is <strike>Sun</strike> Oracle's desktop virtualisation software package.

## Networking

Virtual machines can run in various network modes:

| Mode | Details | When to use |
| - | - | - |
| Not attached | No network card attached | Configuring an OS (forces the OS to believe there is no network available) |
| Bridged networking | VirtualBox connects to one of your installed network cards and exchanges network packets directly, circumventing your host operating system's network stack. Most likely will request an IP from the DHCP server (e.g. router), usually an internal one, e.g. `192.168.1.106` | Running a server (e.g. httpd) that needs to be accessible over LAN |
| NetworkAddressTranslation&nbsp;(NAT) | Requires port forwarding if you want to run servers etc. | Simple web browsing/email/downloads |
| Host-only networking | Creates virtual network interface on host. Use with VirtualBox's built-in DHCP server. | Running a server (e.g. httpd) that needs to only be accessible on the host; preconfigured virtual appliances; where two appliances should be able to talk to each other but not the outside world |

To set up the common use case of an Ubuntu virtual machine with a LAMP configuration:

1. In the virtual machine's settings, use a single Adapter, and set it as _Bridged Adapter_, bridged to the host machine's network interface.
1. Restart the guest OS.
1. Update the <code>/etc/hosts</code> file on the host machine (if required).

## Management

- Disk images (`.vdi`) have a unique UUID which means that the same image cannot be used twice
- To clone disk images, use the syntax: `vboxmanage clonehd [source-vdi] [dest-vdi] --format VDI`


## File sharing

Use the _Shared Folders_ feature to share a folder with the guest:

1. In the guest, type <code>id</code> to get the ID of the current user.
2. Mount the drive with <code>mount -t vboxsf -o uid=12345,gid=12345 name-of-vbox-share ~/path/to/mount</code>
3. Unmount using <code>umount ~/path/to/mount</code>

## Using SSH with port forwarding

*If on a NAT network*, set up port forwarding (port 3022 to 22 on the guest):

```
$ VBoxManage modifyvm CentOS-6.5-i386-minimal --natpf1 delete ssh
$ VBoxManage modifyvm CentOS-6.5-i386-minimal --natpf1 delete http
$ VBoxManage modifyvm CentOS-6.5-i386-minimal --natpf1 "ssh,tcp,,3022,,22"
$ VBoxManage modifyvm CentOS-6.5-i386-minimal --natpf1 "http,tcp,,8080,,80"
```

Then you can SSH from the Host to the Guest using `ssh -p 3022 root@127.0.0.1`

## Using VirtualBox to create a Linux VM with a graphical desktop

We'll install a desktop environment, use a VNC server to bootstrap the desktop environment, and then connect to it.

1.  First initialise a **Debian** VM in VirtualBox:

    ```shell
    mkdir -p ~/vms/debian && cd ~/vms/debian

    cat <<EOF > Vagrantfile
    Vagrant.configure("2") do |config|
    config.vm.box = "debian/bullseye64"
    config.vm.network "private_network", type: "dhcp"
    end
    EOF

    vagrant up

    vagrant ssh
    ```

1.  Install a desktop environment:

    1.  To use [Xfce][xfce]:

        - Display manager: `lightdm`
        - Desktop environment: `xfce4`
        - Display server/protocol: `xorg`

        ```shell
        sudo apt-get update
        sudo apt-get install -y xorg xfce4 xfce4-goodies
        ```

    2.  To use GNOME:

        - Display manager: `gdm3`
        - Desktop environment: `gnome`
        - Display server/protocol: `xorg`

        ```shell
        sudo apt-get update
        sudo apt-get install -y xorg gnome gnome-shell
        ```

1.  Install a VNC server and start it:

    ```shell
    sudo apt install -y tightvncserver

    vncserver :1 -geometry 1024x768
    ```

    You'll be prompted for a password. Enter one, and then confirm it.

1.  On the host workstation, connect to the desktop (here's an example using Fedora because that's my host OS):

    ```shell
    sudo dnf install tigervnc

    # Show the IP address for eth0 (the host-only network)
    vagrant ssh -c 'ip addr show eth1' | grep 'inet ' | awk '{print $2}' | cut -d/ -f1
    # e.g. 192.168.56.3

    vncviewer 192.168.56.3::5901
    ```

1.  When finished, terminate the VNC server in the guest VM:

    ```shell
    vncserver -kill :1
    ```

☃

### Useful hints

- At any time you can see the default display manager that will be used (e.g.`lightdm`):

    ```
    $ cat /etc/X11/default-display-manager
    /usr/sbin/lightdm
    ```


## Troubleshooting

| Problem | Cause | Solution |
| - | - | - |
| _Failed to open/create the internal network 'HostInterfaceNetworking- Intel(R) 82566DM-2 Gigabit Network Connection' VERR_INTNET_FLT_IF_NOT_FOUND_ | The virtual machine has been downloaded from another location which has a differently named network interface | Update the virtual machine settings to use a valid network interface |
| "Invalid settings detected", cannot select a network interface for a Host-only Adapter connection; \
Then, in VirtualBox network preferences, _"failed to open /dev/vboxnetctl: No such file or directory"_ | The system/kernel was recently updated which affected VirtualBox drivers. | On OSX, run: <code>sudo /Library/StartupItems/VirtualBox/VirtualBox restart</code> to restart VirtualBox services, then recreate the host-only network <code>vboxnet0</code> from within Preferences. |
| Doesn't work in OS X High Sierra | | Follow the instructions at <https://developer.apple.com/library/archive/technotes/tn2459/_index.html> |

[xfce]: https://www.xfce.org/
