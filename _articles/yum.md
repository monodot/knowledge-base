---
layout: page
title: YUM
---

The package manager.

## Terminology

- **Repositories** are sources to download software from.

## Cookbook

### Configuring repositories

Repositories are usually located in `/etc/yum.repos.d/`.

List all configured repositories:

    yum repolist

### Searching

Search for a package:

    yum [-v] search <package>

Add `-v` to enable verbose output, which will show the repository that provides each package.

Disable searching a specific repository:

    yum search <package> --disablerepo=ius

### Installed packages

List all repositories configured on the system:

    yum repolist

Find which repository you installed a package from:

    yum info <package>

### Inspecting packages

Find packages which provide a given file:

```
yum provides "*bin/top"
```

Inspecting an RPM file, if it's not installed:

    rpm -qlp <my-rpm.rpm>
