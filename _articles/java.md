---
layout: page
title: Java (JDK/JRE)
---

## Installation

Java 11 on Fedora:

    $ sudo dnf install java-11-openjdk-devel

## Tuning and profiling

Using Java Mission Control on Mac OS X:

    $ find /Library/Java -name jmc
    $ jmc &

    # Now run your application with these JVM flags
    $ java -XX:+UnlockCommercialFeatures -XX:+FlightRecorder -jar myapp.jar

## Cookbook

- Default Java Home on Mac (symlinked): `/Library/Java/Home`
- Other Java Homes located at: `/Library/Java/JavaVirtualMachines/jdk1.x.y_nn.jdk/Contents/Home`

List Java Homes on a Mac:

    /usr/libexec/java_home -V

### JARs

Extract a file to stdout:

    jar xvf myjar.jar META-INF/MANIFEST.MF
    cat META-INF/MANIFEST.MF

Or on Linux:

    unzip -p myjar.jar META-INF/MANIFEST.MF

### Jenv

Install Jenv to manage multiple versions

    brew install jenv

Install `jenv` for zsh:

    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(jenv init -)"' >> ~/.zshrc

Add JVMs:

    jenv add /Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home/
    jenv add /Library/Java/JavaVirtualMachines/jdk1.8.0_74.jdk/Contents/Home/

Set Java version for a specific project path:

    jenv local
