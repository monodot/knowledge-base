---
layout: page
title: Red Hat Enterprise Linux/CentOS
---

## CentOS 8

Repositories out of the box:

- AppStream
- BaseOS
- extras

## Working with yum

List installed packages:

```
$ yum list installed
```

## Common tools/packages

To enable a graphical desktop environment:

```
sudo yum groupinstall gnome-desktop x11 fonts
```

To set up a simple web server:

```
sudo yum install -y httpd
# Then, modify web content in /var/www
sudo systemctl start httpd
```

## Services

To reload Nginx:

```
sudo service nginx reload
```

### sshd

Check the sshd logs (to see why you're being denied a log on):

    journalctl --follow --unit sshd

This will show the latest sshd logs. Press **Shift+G** to show the latest logs (at the bottom).

## Subscription Manager

Get all the employee SKU subscriptions:

```
sudo subscription-manager list --available --matches '${EMPLOYEE_SKU}' --pool-only
```

## Troubleshooting

_"Not using ius/repomd.xml because it is older than what we have"_

- Try cleaning yum's cache, using `yum clean all`
