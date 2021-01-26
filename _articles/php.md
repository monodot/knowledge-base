---
layout: page
title: PHP
---

## Installing

### CentOS

The CentOS repositories contain an old version of PHP:

```
$ yum info php.x86_64 | grep Version
Version     : 5.4.16
```

But you can get a more-up-to-date version by adding the Software Collections (SCL) repository, or the `ius` repository.

## Running each website as a different user, using php-fpm pools

Requirements:

1.  Create a user, which should belong to its own group (e.g. `brian:brian`)
1.  Configure a new pool in _php-fpm_ - `/etc/`

## Developing locally

With containers/podman:

    podman run -d -p 8086:80 --name miphp -v "$PWD":/var/www/html:Z php:7-apache

