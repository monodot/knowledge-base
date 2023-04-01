---
layout: page
title: Debian
---

## apt

### List all installed packages

```
apt list --installed
```

### List files installed by a package

```
dpkg -L $packagename
```

### List which packages provide a command/file

```
dpkg -S update-ca-certificates
```