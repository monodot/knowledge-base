---
layout: page
title: Quarkus
---

Things about Quarkus:

- _build_ phase builds a runner jar, e.g. `myapp-1.0-runner.jar`
- _native-image_ phase runs a GraalVM `native-image` build:

  - with `-Dnative-image.docker-build=true`, it will run a build inside a Docker container, e.g. using image `quay.io/quarkus/centos-quarkus-native-image`.
  - without this, it will look for the env var `GRAALVM_HOME` to be set, and expect GraalVM to be installed locally.

## Cookbook

The Quarkus Maven Plugin needs Maven > 3.6.2 because....???

### Create a new Quarkus Maven project

```
mvn io.quarkus:quarkus-maven-plugin:1.3.2.Final:create
```

### List all extensions

```
mvn io.quarkus:quarkus-maven-plugin:1.3.2.Final:list-extensions
```

### Building a native image

```
export GRAALVM_HOME=/opt/java/graalvm-ce-19.0.0
sdk install java 20.1.0.r11-grl
```

## Debugging

To debug a Quarkus application locally, connect a debugger to port 5005\. Optionally add `-Ddebug` to make Quarkus wait for a debugger to be connected before starting:

```
$ mvn compile quarkus:dev -Ddebug
```

## Troubleshooting

Historic things I've looked at.

CORS filters on Undertow don't seem to work:

- Add a debug breakpoint on `io.undertow.servlet.core.ManagedFilter#doFilter` to see what's in the current `FilterChain`.

  - There should be a CORSFilter in there: _"ManagedFilter{filterInfo=FilterInfo{filterClass=class io.quarkus.undertow.runtime.filters.CORSFilter, name='io.quarkus.undertow.runtime.filters.CORSFilter'}}"_

- Add a Field Watchpoint on `io.quarkus.undertow.runtime.HttpConfig.cors` and ensure the app is run with `-Ddebug` so that Quarkus will wait for a debugger before starting.

- `io.quarkus.runtime.generated`
