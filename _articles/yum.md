---
layout: page
title: YUM/DNF
---

The package manager.

> DNF is the next upcoming major version of YUM, a package manager for RPM-based Linux distributions. It roughly maintains CLI compatibility with YUM and defines a strict API for extensions and plugins.

{% include toc.html %}

## Terminology

- Use `dnf` to install **packages** from official and non-official **repositories**.

- **Repositories** are sources to download software from.

- **Modules** in dnf are _package groups representing an application, language runtime or set of tools._ - e.g. `node`, `nginx`, `maven`, `mariadb`, `ruby`, `perl`.

- **Groups** are virtual collections of packages, e.g.:

  - `@c-development` - group containing C Development stuff including `gcc-c++`.


## Cookbook

Some things about dnf:

### Searching for packages

#### Searching with _yum_

Search for a package:

    yum [-v] search <package>

Add `-v` to enable verbose output, which will show the repository that provides each package.

#### Search but exclude a specific repository

    yum search <package> --disablerepo=ius

### Adding/removing packages

#### Install a package

```
$ dnf install <spec> # Where spec can be a package-spec, @module-spec or @group-spec
```

#### Remove a package

```
$ dnf remove packagename
```

#### List all installed packages

List all of the software you've got installed through dnf:

```
$ dnf list --installed
$ dnf list --installed mypackage
```



#### Remove a package using `rpm`

```
$ rpm -e packagename
```

#### Install something from an RPM file

```
$ dnf localinstall myrpmfile.rpm
```

#### Remove a package, but don't remove "unused dependencies"

```
$ dnf remove packagename --noautoremove
```

Or set `clean_requirements_on_remove=false` in `/etc/dnf/dnf.conf`. If still having issues, check if the dependent packages really do have a transitive dependency on the package you're trying to remove, e.g. trying to remove docker and it also wants to remove container-selinux:

```
$ dnf repoquery --requires docker | grep container-selinux
container-selinux >= 2:2.2-2
```



### Managing repositories

For configuration file format see `man 5 dnf.conf`

#### List all repositories

This lists all the repositories you've configured to search and install packages from:

```
$ dnf repolist
```

#### List all repo config files

Repository config files are usually located in `/etc/yum.repos.d/`:

```
ls /etc/yum.repos.d
_copr:copr.fedorainfracloud.org:sentry:v4l2loopback.repo  fedora-updates-modular.repo          home:manuelschneid3r.repo             rpmfusion-nonfree.repo
_copr_phracek-PyCharm.repo                                fedora-updates.repo                  nextdns.repo                          rpmfusion-nonfree-steam.repo
docker-ce.repo                                            fedora-updates-testing-modular.repo  rhel7-csb-stage.repo                  rpmfusion-nonfree-updates.repo
fedora-cisco-openh264.repo                                fedora-updates-testing.repo          rpmfusion-free.repo                   rpmfusion-nonfree-updates-testing.repo
fedora-cisco-openh264.repo.rpmnew                         fedora-updates-testing.repo.rpmnew   rpmfusion-free-updates.repo           screen.repo
fedora-modular.repo                                       google-chrome.repo                   rpmfusion-free-updates-testing.repo   teams.repo
fedora.repo                                               google-chrome.repo.rpmnew            rpmfusion-nonfree-nvidia-driver.repo  vscode.repo
```


#### Add a repository

```
$ dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
```

#### Disable a repository

```
$ dnf config-manager --set-disabled my-repo-id
```


### Finding and inspecting packages

#### Which packages which provide a given file? with _yum_

```
yum provides "*bin/top"
```

#### Which packages does package X depend on?

```
dnf repoquery rubygem-eventmachine --requires --resolve
```

#### Look inside an RPM file, if it's not installed

```
rpm -qlp <my-rpm.rpm>
```

#### Which group contains a specific package? with _yum_

```
yum groupinfo '*' | less +/sendmail-cf
```

#### Which package created file '/foo/bar.jpeg'?

Which package created/installed a particular file?

```
$ dnf repoquery -l texlive-cancel
/usr/share/licenses/texlive-cancel
/usr/share/licenses/texlive-cancel/pd.txt
/usr/share/texlive/texmf-dist/tex/latex/cancel
/usr/share/texlive/texmf-dist/tex/latex/cancel/cancel.sty

$ rpm -qf /usr/bin/mvn
maven-3.5.4-5.module_f28+3939+dc18cd75.noarch
```

#### Which packages require dependency 'foo'?

Can I safely delete package 'foo'?

```
$ dnf repoquery --installed --whatrequires ldacbt
ldacbt-0:2.0.2.3-7.fc30.x86_64

$ rpm --test -e ldacbt
# runs a test 'erase' command...should exit 0 if no dependencies
```

#### What are the contents of a local .rpm file?

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

### Admin/Miscellaneous

#### Get the current Fedora version with _rpm_

```
$ rpm -E %fedora
```

#### Which repository did you install a package from?

```
yum info <package>
```

#### What was installed recently?

Check `history`:

```
$ dnf history | grep ...
```

#### When was a particular package installed?

```
$ dnf repoquery --installed --qf '%{reason} %{installtime} %{name}-%{evr}.%{arch}' nano-default-editor
unknown 2020-12-02 18:26 nano-default-editor-5.3-4.fc33.noarch
```

### Modules

#### List all modules available

```
$ dnf module list
```

#### List the modules that are enabled (installed)

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

#### Disable a module if it's causing problems

Disable the _gimp_ module:

```
$ dnf module disable gimp
```

### Groups

#### List all groups

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

#### List all installed groups

```
$ dnf group list --installed
```

#### Install a group

```
$ dnf group install <group-spec>
```

#### List packages in a group

```
$ dnf group info <group-spec>
```

#### Find which groups contain a package (e.g. _gcc-c++_)

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

[**unitedrpms**](https://unitedrpms.github.io/): multimedia codecs and addons not available in official Fedora repositories.

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

## Troubleshooting

### 'rpmdb open failed' when trying to run 'yum update'

```
error: rpmdb: BDB0113 Thread/process 11763/140134931961664 failed: BDB1507 Thread died in Berkeley DB library
error: db5 error(-30973) from dbenv->failchk: BDB0087 DB_RUNRECOVERY: Fatal error, run database recovery
error: cannot open Packages index using db5 -  (-30973)
error: cannot open Packages database in /var/lib/rpm
Plugins failed to initialize with the following error message:
Error: rpmdb open failed
```

- This error seems to happen randomly. The yum package database is corrupt?
- Move the corrupt database and get the server to rebuild it: `mv /var/lib/rpm/__db* /tmp && rpm --rebuilddb && yum upgrade`
