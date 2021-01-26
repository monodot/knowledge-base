---
layout: page
title: Kerberos
---

Info about Kerberos. Caveat: some of this may not be fully correct terminology, but it's how I understand it. :-)

## What is it?

## Concepts

- **Keytab** file - contains keys for a specific service. It's equivalent to a password file or private key, and needs to be treated as a highly sensitive secret[1][1]
- **Principal** - equivalent to a user in an operating system. Usually takes the form `component1/component2@REALM`
  - A **User Principal** is ...?
  - A **Service Principal** represents an application or a computer, e.g. `nfs/myhost.example.com@EXAMPLE.COM`, `HTTP/localhost@JBOSS.ORG`
  - **Service Principal Name (SPN)** is a unique identifier of a service instance - i.e. to associate an instance of a service (like an application server) with a specific logon account.
- **Ticket Granting Ticket (TGT)** - issued by the Authentication Service when a user successfully authenticates.

The key components in a Kerberos interaction are:

- **Key Distribution Center (KDC)** - the authentication component that contains:
  - **Authentication Service (AS)** - responsible for the initial challenge to users. The AS grants a _Ticket-Granting Ticket_ for authenticating with the TGS.
  - **Ticket Granting Service (TGS)** - given a _Ticket-Granting Ticket_ and destination, it issues the user a _Service Ticket_.
- **Client** - the principal who is requesting access to a resource.
- **Server** - the secured service which is protected by Kerberos.

## Service Principals

Service Principal Names follow this convention:

    <service class>/<host>:<port>/<service name>
    <service class>/<fqdn>@REALM
    
For example:

    MyDBService/host1.example.com/CN=hrdb,OU=mktg,DC=example,DC=com
    HTTP/athena.example.com@EXAMPLEPLC.COM

Further notes:

- ["If you install multiple instances of a service on computers throughout a forest, each instance must have its own SPN."][2] - this means that each server which needs a Kerberos account should have its own, rather than sharing them.

## Cookbook

List user's current Kerberos tickets (Linux):

    $ klist
    Ticket cache: FILE:/tmp/krb5cc_185
    Default principal: hnelson@JBOSS.ORG

    Valid starting       Expires              Service principal
    11/19/2018 10:40:40  11/20/2018 10:40:40  krbtgt/JBOSS.ORG@JBOSS.ORG

## SSO for web applications with Kerberos

It is possible to use Kerberos as an authentication mechanism for web applications. This allows a user to log on to a web application using just their Kerberos identity (via a ticket).

On the server side:

- The protocol that allows Kerberos to be used as a form of authentication is called **SPNEGO**.
- Check that the application server has support for SPNEGO, e.g. using a library or module.
- Define all of the Kerberos connection parameters in a file `krb5.conf` and ensure that the application server uses this to communicate with Kerberos.
- Also create a `keytab` file for the application server. This is similar to a private key for the application server, allowing it to communicate with Kerberos.
- Implement a fallback authentication mechanism which should be used in case the user isn't logging on from a Kerberos-configured PC.

On the client side:

- Single Sign-on allows a user to be automatically signed in to a web application using the existing Kerberos infrastructure and login.
- For example, if a user has already authenticated with Kerberos on Linux using `kinit`, a web browser can read their ticket (TGT), pass it to the Kerberos server to obtain a service ticket (ST) for the web app, and then pass this to the application server as proof of identity.
- SSO with Kerberos works **only** if the user is already logged on to Kerberos **on that machine** - it's an entirely different concept from the "SSO" concept used by, for example, Google Accounts, Microsoft Live, etc.

## Examples

### Configuration file

An example `krb5.conf` configuration file:

```
[libdefaults]
    default_realm = JBOSS.ORG
    default_tgs_enctypes = des-cbc-md5 des3-cbc-sha1-kd rc4-hmac
    default_tkt_enctypes = des-cbc-md5 des3-cbc-sha1-kd rc4-hmac
    kdc_timeout = 5000
    dns_lookup_realm = false
    dns_lookup_kdc = false
    dns_canonicalize_hostname = false
    rdns = false
    ignore_acceptor_hostname = true
    allow_weak_crypto = yes

[realms]
    JBOSS.ORG = {
        kdc = localhost:6088
    }

[domain_realm]
    localhost = JBOSS.ORG
```

## Cookbook

Inspect the contents of a keytab file:

    $ klist -k -t /tmp/spnego-demo-testdir/jbosstest.keytab
    Keytab name: FILE:/tmp/spnego-demo-testdir/jbosstest.keytab
    KVNO Timestamp           Principal
    ---- ------------------- ------------------------------------------------------
       0 11/21/2018 07:14:41 JBOSSTEST/localhost@JBOSS.ORG
       0 11/21/2018 07:14:41 JBOSSTEST/localhost@JBOSS.ORG
       0 11/21/2018 07:14:41 JBOSSTEST/localhost@JBOSS.ORG
       0 11/21/2018 07:14:41 JBOSSTEST/localhost@JBOSS.ORG
       0 11/21/2018 07:14:41 JBOSSTEST/localhost@JBOSS.ORG


[1]: https://ssimo.org/blog/id_016.html
[2]: https://docs.microsoft.com/en-us/windows/desktop/ad/service-principal-names
