---
layout: page
title: Podman
---

An alternative to Docker, which is definitely way beyond my understanding :D

{% include toc.html %}

## Installation on CentOS

```
$ sudo yum install -y podman
$ sudo chmod u+s /usr/bin/podman
```

Then to test:

```
$ podman ps
CONTAINER ID  IMAGE  COMMAND  CREATED  STATUS  PORTS  NAMES
```

## Security 101

### Rootless podman

**rootless Podman** means running Podman as a non-root user:

- podman itself runs as a non-root user on most systems
- [rootless Podman allows any container to be run as a normal user, without requiring elevated privileges](https://www.redhat.com/sysadmin/rootless-podman)
- Podman does this by mapping the user that launched Podman as UID/GID 0 in a rootless container - so the user effectively becomes **root** in the container
- This also means that **the processes inside the container are simply running (on the host system) as the user's UID** - [no matter what user you may appear to be in a rootless container, you’re still acting as your own user](https://www.redhat.com/sysadmin/rootless-podman)

If a container has users other than root:

- Podman will still map the current user's ID as root in the container, but Podman **also** needs to map in some extra UIDs, to allow UIDs `1` and above to exist inside the container
- In order for this to happen, [there must be an entry for their username in /etc/subuid and /etc/subgid which lists the UIDs for their user namespace.](https://podman.readthedocs.io/en/latest/markdown/podman-run.1.html)
- If an image uses a UID/GID that has not been mapped, then Podman will throw some error, like _"there might not be enough IDs available in the namespace"_
- Every user running rootless Podman must have an entry in `/etc/subuid` and `/etc/subgid` if they want to run containers with more than one UID.
- Make sure that the UID ranges you define in subuid and subgid don't overlap with any real UIDs on the system (otherwise the UID will be able to read/write files owned by that UID)
  - Could get the highest UID using this one-liner: `cat /etc/passwd | awk -F: '{print $3,$1}' | sort -n | tail -n 1`

### Other security things

- Running a container with a hardcoded UID can be impractical when using volumes. An alternative is to run a rootless container, where the container user is root - e.g. `-u root ...`
- To change the owner of the mount path, you can use `podman unshare chown UID:GID -R PATH`

### Observing /sys and /proc in rootless vs rootful podman

With rootless podman, the `/sys` directory is owned by nobody:nobody:

```
$ podman run --rm -it busybox ls -al / | grep sys
dr-xr-xr-x   13 nobody   nobody           0 Jan 20 07:58 sys
```

Even running as root and privileged, the same thing happens:

```
$ podman run --rm -u root --privileged -it busybox ls -al / | grep sys
dr-xr-xr-x   13 nobody   nobody           0 Jan 20 07:58 sys
```

But, when you run a rootful container, the directory is now owned by root:root:

```
$ sudo podman run --rm -it busybox ls -al / | grep sys
dr-xr-xr-x   13 root     root             0 Jan 20 07:58 sys
```

## Networking

### Networking backends

Podman can use different networking _stacks_ or backends:

- New stack from 4.0 based on [**netavark**](https://github.com/containers/netavark) and [**aardvark-dns**](https://github.com/containers/aardvark-dns)
- CNI (default stack for old/existing installations)

To find out which networking stack your installation is using, type `podman info` and look for the entry named _networkBackend_.

### Troubleshooting netavark and aardvark-dns

Netavark and aardvark-dns might write some logs. So, you could look for them:

```
journalctl -b | grep -i netav
journalctl -b | grep -i aardv
```

## Images

When pulling images rootless, they are saved to `.local/share/containers/storage`.

Which registries does podman search for images? podman uses the list of registries in the file `/etc/containers/registries.conf` when searching for images in public registries, i.e.:

    $ cat /etc/containers/registries.conf | grep 'registries ='
    registries = ['registry.access.redhat.com', 'docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.centos.org']
    ...

## Volumes

Podman in rootless mode makes the UID of the user running the command, ROOT inside the container.

## Pause process

The pause process is:

- `/run/user/1000/libpod/pause.pid`

## Cookbook

### Update to a new version of podman

Update containers to a new version of Podman:

    podman system migrate

### Start a container with a shell

Start a container with a shell as the entrypoint:

    podman run --entrypoint /bin/sh -it docker.io/library/python:3.7

### Mounting a volume with SELinux enabled

If SELinux is enforcing, add `:Z` to the volume definition, to get podman to do the relabelling to allow the `/var/data` directory to be used by the container:

    podman run -it --rm -v /var/data:/sqm:Z docker.io/library/alpine sh

e.g.:

    $ podman run --rm -it -v $(pwd):/slides:Z --entrypoint /bin/sh astefanutti/decktape
    $ ls -al / | grep slides
    drwxr-xr-x   14 root     root          4096 Sep 25 11:28 slides

This will mount the current directory as `/slides` inside the container, but as the `root:root` owner/group, and the container will run as whatever `USER` was assigned in the Dockerfile (for this example, the user is `uid=1000(node)`)

To keep the user's ID, and therefore make the volume writable by the container user, use `--userns=keep-id`, e.g.:

    $ podman run --rm -it -v $(pwd):/slides:Z --entrypoint /bin/sh --userns=keep-id astefanutti/decktape
    $  id
    uid=1000(node) gid=1000(node)
    $ ls -al / | grep slides
    drwxr-xr-x   14 node     node          4096 Sep 25 11:28 slides

The mount is now owned by `node:node`, which is the same as the container user.

### Allowing a mounted directory to be written by the container user

**Change the UID/GID of the volume directory to the same UID/GID of the container user**, which will make it writable. Use `podman unshare chown UID:GID -R PATH` to set up the default user namespace that podman uses, and modify the UID/GID of the directory on the host:

    $ podman unshare chown 200:200 -R /home/tdonohue/.local/share/nexus2

    # This will run the container as the user defined in the image (i.e. nexus:nexus)
    $ podman run -it --rm --name nexus2 \                               
        -v /home/tdonohue/.local/share/nexus2:/sonatype-work:Z \
        sonatype/nexus /bin/sh

    #~ ls -al / | grep sonatype-work
    drwxr-xr-x.  15 nexus nexus 4096 Sep 27 13:29 sonatype-work
    #~ touch /sonatype-work/hello.txt
    # Works OK because the directory AND I are both 'nexus:nexus'

Or, just **run as root**. You can run a rootless container with podman and still be `root` inside the container. Here I'm using a local directory as a volume, and all the files are owned by me:

    $ ls -al /home/tdonohue/.local/share/nexus2
    total 60
    drwxr-xr-x. 15 tdonohue tdonohue 4096 Sep 27 14:21 .
    drwx--x--x. 54 tdonohue tdonohue 4096 Sep 27 11:41 ..
    drwxr-xr-x.  3 tdonohue tdonohue 4096 Dec  1  2019 backup
    ...

Then I can start a rootless container, use `-u root` to run as root, and the files will still be written as my UID:

    $ podman run -it --rm --name nexus2 \
        -v /home/tdonohue/.local/share/nexus2:/sonatype-work:Z \
        -u root \
        sonatype/nexus /bin/sh
    #~ touch /sonatype-work/hello.txt
    #~ exit

    $ ls -al /home/tdonohue/.local/share/nexus2/hello.txt
    -rw-r--r--. 1 tdonohue tdonohue 0 Sep 27 14:25 /home/tdonohue/.local/share/nexus2/hello.txt

Thanks to: https://github.com/containers/podman/issues/4016

### Network between two rootless containers

Rootless containers are not assigned an IP address, because they don't have sufficient permission. So, to connect two rootless containers, set up port forwarding on the target container, and then you can access it from the source container by going via the forwarded port on the host. The IP address of the host is given in the `cni-podman0` network interface. e.g.:

```
$ podman run -d -p 8085:8081 sonatype/nexus

$ ip addr show cni-podman0
32: cni-podman0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 2a:52:39:3a:01:cd brd ff:ff:ff:ff:ff:ff
    inet 10.88.0.1/16 brd 10.88.255.255 scope global cni-podman0

# Now plug in the IP address of cni-podman0
$ IP_ADDR=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
$ podman exec -it myjenkins curl -v http://${IP_ADDR}:8085/nexus
HTTP/1.1 302 Found
```

### Find and remove orphaned files in volumes ('Permission denied' issue)

<https://github.com/containers/podman/issues/3799>

Sometimes Podman will create some files in your `.local/share/containers/storage` directory which are not owned by you, and which you cannot delete.

To list these files, use `podman unshare` and find any files not owned by the _root_ user (`0`):

```
$ podman unshare find ~/.local/share/containers ! -uid 0
/home/tdonohue/.local/share/containers/storage/vfs/dir/9d4902....d68e83a2/var/cache/apt/archives/partial
/home/tdonohue/.local/share/containers/storage/vfs/dir/e69a89....5ab29f85/var/cache/apt/archives/partial
...
```

To delete each volume one-by-one:

```
# Change owner/group to root:root
podman unshare chown root:root /home/tdonohue/.local/share/containers/storage/vfs/dir/9d4902....d68e83a2/var/cache/apt/archives/partial

# Then delete.
rm -rf ...
```

## Security troubleshooting

Set a user's mapping ranges in `subuid` and `subgid` to allow rootless Podman to run containers which have multiple UIDs:

    sudo usermod --add-subuids 10000-75535 brenda
    sudo usermod --add-subgids 10000-75535 brenda

    # OR: echo USERNAME:STARTING_ID:COUNT_OF_IDS >> /etc/subuid
    echo "brenda:10000:65536" | sudo tee -a /etc/subuid
    echo "brenda:10000:65536" | sudo tee -a /etc/subgid

Find all users and groups inside a container and sort them:

    # Assuming you're already inside a container
    find / -xdev -printf "%U:%G\n" | sort | uniq

Check the uid map inside a container:

    podman run docker.io/library/python:3.7 cat /proc/self/uid_map

Check the uid map inside a modified userspace - this example indicates that the user executing Podman unshare only has one UID, 1000, so it is not respecting the _subuid_ and _subgid_ files:

    $ podman unshare cat /proc/self/uid_map
             0       1000          1

And now here's a valid output from `podman unshare cat`:

    $ podman unshare cat /proc/self/uid_map
             0       1000          1
             1      10000      65536

## Troubleshooting

_"ERRO[0020] Error while applying layer: ApplyLayer exit status 1 stdout:  stderr: there might not be enough IDs available in the namespace (requested 0:42 for /etc/gshadow): lchown /etc/gshadow: invalid argument"_  
...and...  
_"WARN[0000] cannot find mappings for user fred: No subuid ranges found for user "fred" in /etc/subuid"_  
_"WARN[0000] using rootless single mapping into the namespace. This might break some images. Check /etc/subuid and /etc/subgid for adding subids"_

- There are no entries in `/etc/subuid` and `/etc/subgid` for the current user.
  - This is required when you use rootless Podman to run a container which has multiple UIDs
  - Podman needs to know how it should map UIDs > 0 in the container, and it does it using the ranges defined in _subuid_ and _subgid_
  - Set up some UID and GID ranges in the _subuid_ and _subgid_ files.
- If you've already added entries to `/etc/subuid` and `/etc/subgid` and still getting this error, then:
  - Check you have _newuidmap_ and _newgidmap_ installed - these are provided by _shadow-utils_ - `sudo yum install shadow-utils`
  - Check that the subuid/subgid mappings are being respected by podman: `podman unshare cat /proc/self/uid_map` - check that the mapping range appears in this command's output
  - Run `podman system migrate` if necessary to force podman to pick up the new mappings.
  - See: [libpod issue #3421](https://github.com/containers/libpod/issues/3421#issuecomment-544455837)

Builds take ages. Really very, very slow builds:

- You're not using fuse-overlayfs:
  - `podman info | grep GraphDriverName` => should **not** show **vfs**
  - You'll need to install it - `sudo dnf install -y fuse-overlayfs`
  - Doesn't exist in RHEL7 yet.

The process inside the container can't connect to web sites / has no DNS resolution:

- Test for DNS resolution with `bash`: `cat < /dev/tcp/smtp.mailgun.org/587`
- Check whether DNS resolution info has been copied into the container: `cat /etc/resolv.conf`
- Check whether the issue applies to a new container by running `ping` in an `alpine` container: `podman run -it docker.io/alpine ping -c 5 1.1.1.1`
- Try to restart the container/upgrade Podman

I can't do stuff inside the container which I can do as the user on the host system:

- Rootless podman restricts access to the system by the user inside the container, to even tighter restrictions than the user on the host system.
- To give the container the same permissions as the user who launched it, add `--privileged` to your podman command.
- `priveleged` releaxes Seccomp, SELinux and restrictions on mounts in `/proc` and `/sys`.
- Note that `privileged` in podman has a slightly different meaning from docker's `privileged`.

Some corruption when trying to run `podman images` or deleting containers with `podman rm $(podman ps -aq)`, like _"container 2ab05ed139dc86b9a056e60ccc5cf768822d34db63db2c51b401c953c7d455d3 is the infra container of pod 17c359d0b1a5f312b80e240e9c2f3082f4cb647a895042ba97fbae33806cfca0 and cannot be removed without removing the pod"_

- Nuclear option: just obliterate the containers storage directory completely: `rm -rf ~/.local/share/containers`
