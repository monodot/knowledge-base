---
layout: page
title: Let's Encrypt
---

Let's Encrypt installation and configuration.

## Nginx on CentOS/RHEL 7

To configure Let's Encrypt for Nginx on CentOS/RHEL:

    $ sudo yum install certbot-nginx
    $ sudo certbot --nginx

This will start the Certbot configurer for Nginx. Simply follow the prompts to add a new site and set up TLS.

```
$ sudo certbot --nginx
[sudo] password for tdonohue:
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Starting new HTTPS connection (1): acme-v01.api.letsencrypt.org

Which names would you like to activate HTTPS for?
-------------------------------------------------------------------------------
1: borderof.com
2: cleverbuilder.com
-------------------------------------------------------------------------------
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

Certificates will be saved into `/etc/letsencrypt/live/example.com/`

## Testing

Test SSL configuration using this URL:

    https://www.ssllabs.com/ssltest/analyze.html?d=example.com

