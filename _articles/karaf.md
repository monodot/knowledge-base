---
layout: page
title: Karaf
---

### Karaf Maven Plugin

Configuration:

```xml
<plugin>
    <groupId>org.jboss.redhat-fuse</groupId>
    <artifactId>karaf-maven-plugin</artifactId>
    <version>${version.org.jboss.redhat-fuse}</version>
    <extensions>true</extensions>
    <executions>
        <execution>
            <id>karaf-assembly</id>
            <goals>
                <goal>assembly</goal>
            </goals>
            <phase>prepare-package</phase>
        </execution>
    </executions>
    <configuration>
        <javase>1.8</javase>
        <karafVersion>v4x</karafVersion>
        <framework>framework</framework>
        <useReferenceUrls>true</useReferenceUrls>
        <archiveTarGz>false</archiveTarGz>
        <includeBuildOutputDirectory>false</includeBuildOutputDirectory>

        <!-- Entries in startupFeatures are added to etc/startup.properties. This should include core functionality, e.g. felix, configadmin, features, pax url, etc. -->
        <startupFeatures>
            <!-- These are the features given in the karaf-camel-log-archetype archetype -->
            <feature>framework</feature>
            <feature>jaas</feature>
            <feature>log</feature>
            <feature>shell</feature>
            <feature>management</feature>
            <feature>aries-blueprint</feature>
            <feature>camel-blueprint</feature>
            <feature>fabric8-karaf-blueprint</feature>
            <feature>fabric8-karaf-checks</feature>
        </startupFeatures>

        <!-- Entries in bootFeatures are added to etc/org.apache.karaf.features.cfg. Application-level stuff like camel, cxf, spring, etc -->
        <bootFeatures>
            <!-- To get the bundle: commands -->
            <feature>bundle</feature>
            <!-- To get the service: commands, e.g. service:list -->
            <feature>service</feature>
        </bootFeatures>

        <!-- Where your own apps should go -->
        <startupBundles>
            <bundle>mvn:xyz.tomd.fusedemos/karaf-assembly-bundle/${project.version};start-level=80</bundle>
        </startupBundles>

        <!-- These are added into the lib/ directory of the Karaf assembly -->
        <libraries>
            <library>mvn:javax.annotation/javax.annotation-api/1.3;type:=endorsed;export:=true</library>
            <library>mvn:org.jboss.fuse.modules/fuse-branding/${version.org.jboss.fuse-branding};type:=default;export:=false</library>
        </libraries>
    </configuration>
</plugin>
```

More info:

- Uses `karaf-maven-plugin:assembly` to build a complete Karaf assembly from your Maven project.
  - Resolves startup features and bundles
  - Resolves boot repositories
  - Adds installed repositories, e.g. `camel-blueprint`
- Uses `fabric8-maven-plugin` and the `fuse7/fuse-karaf-openshift` container image as a base/builder
- Builds a file, `target/assembly/etc/profile.cfg` containing the features and bundles to install into your Karaf custom distribution.

Make sure to add these dependencies to your POM:

```xml
<dependency>
    <groupId>org.jboss.fuse</groupId>
    <artifactId>fuse-karaf-framework</artifactId>
    <type>kar</type>
    <scope>compile</scope>
</dependency>
<dependency>
    <groupId>io.fabric8</groupId>
    <artifactId>fabric8-karaf-features</artifactId>
    <classifier>features</classifier>
    <type>xml</type>
</dependency>
```
