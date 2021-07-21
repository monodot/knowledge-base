---
layout: page
title: sdkman
---

Install GraalVM:

```
sdk install java 20.1.0.r11-grl
```

Use an existing install:

```
sdk install groovy 2.4.13-local /opt/groovy-2.4.13
```

List installed Java VMs:

```
sdk list java | grep installed
```

Switch to Java 8:

```
sdk use java 8.0.252.hs-adpt
```