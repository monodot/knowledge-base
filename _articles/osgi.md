---
layout: page
title: OSGi
---

OSGi is a framework for building **modular applications** in the JVM.

{% include toc.html %}

## OSGi concepts

### Bundles

- A **bundle** is the unit of modularisation in OSGi. _"It is simply a JAR with additional information. This information allows you to control what packages are imported, exported, as well as which ones are private and/or hidden."_ (Instant OSGi Starter)

### Lifecycle

Bundles have a lifecycle:

- On **Install**: Installed &rarr; Resolved &rarr; Starting &rarr; **Active**
- Then on **Stop**: &rarr; Stopping &rarr; **Resolved**
- Then on **Uninstall**: &rarr; **Uninstalled**

### Start level

A bundle's start level is a number that indicates when a bundle should be started. A bundle is started if: **OSGI framework start-level >= bundle start level**

> **When booting, the OSGi framework starts all bundles whose start level is equal to or lower than that of the framework’s active start level**. This is done in ascending order; that is, the framework starts all bundles whose start level is n, then n+1, n+2, ..., until n is equal to the framework’s active start level.

> For example, if the active start level is 2, then first you’ll start all bundles whose start level is 0, then those whose start level is 1, and then finally those whose start level is 2.

-- OSGi in Depth by Alexandre de Castro Alves, Chapter 11: Launching OSGi using start levels

- The default **start-level** of a Fuse container is `100`. This means it will start all bundles where the start level is 100 or less.

### Services

Services are a way of publishing objects (beans) to a central registry, so that they can be consumed by bundles.

Use `osgi:service` to define/expose a service, e.g.:

    <bean id="myHelloService" .../>
    <osgi:service ref="myHelloService" interface="xyz.tomd.HelloService"/>

Use `osgi:reference` to reference it from another bundle, e.g.:

    <osgi:reference id="myHelloService" interface="xyz.tomd.HelloService"/>

### Features

- **Features** are simply a set of OSGi bundles grouped together into a single deployment
- To upgrade a feature in Karaf/Felix, you have to _stop_ and _uninstall_ the feature first. Use `removeurl` and then `addurl` to add the URL (`mvn:...`) to the new version.

## Good practices

- Make bundles as restrictive as possible by exporting (via `Export-Package`) only the classes that absolutely must be shared
- Avoid the `Require-Bundle` header, as it can cause _split packages_ (where a package may be split across two bundles that export it); favour _fragment bundles_ instead
- Avoid `DynamicImport-Package` because it means the class is only searched for when it is needed, rather than at bundle resolution time. Favour using _optional packages_ or other alternatives.
