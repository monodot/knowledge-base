---
layout: page
title: Red Hat Fuse (JBoss Fuse) and Fuse Fabric
---

## Quickstarts

### Fuse 7.8 on OpenShift quick demo

A super-quick, quickstart to create and deploy a Fuse application on OpenShift. This assumes you're a developer without cluster-admin access:

1.  Create a new application from the Fuse Maven archetype, e.g.:

    For Fuse 7.8 / Spring Boot 2.x:

    ```
    mvn org.apache.maven.plugins:maven-archetype-plugin:2.4:generate \
    -DarchetypeCatalog=https://maven.repository.redhat.com/ga/io/fabric8/archetypes/archetypes-catalog/2.2.0.fuse-sb2-780040-redhat-00001/archetypes-catalog-2.2.0.fuse-sb2-780040-redhat-00001-archetype-catalog.xml \
    -DarchetypeGroupId=org.jboss.fuse.fis.archetypes \
    -DarchetypeArtifactId=spring-boot-camel-config-archetype \
    -DarchetypeVersion=2.2.0.fuse-sb2-780040-redhat-00001 \
    -DgroupId=foo \
    -DartifactId=bar \
    -Dpackage=com.foo.bar
    ```

2.  Create a secret containing your Red Hat credentials - this will allow OpenShift to pull the Fuse image from the registry:

    ```
    export RH_USERNAME=
    export RH_PASSWORD=
    oc create secret docker-registry redhat-secret --docker-username=${RH_USERNAME} --docker-password=${RH_PASSWORD} --docker-server=registry.redhat.io
    ```

3.  Install the Fuse imagestreams to your OpenShift cluster. This assumes you don't have cluster-admin permissions, and will just install the image streams into your local namespace:

    ```
    BASEURL=https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-750056-redhat-00004
    oc create [-n openshift] -f ${BASEURL}/fis-image-streams.json
    ```

4.  Log in to OpenShift, build and deploy the application:

    ```
    oc login -u ...
    oc new-project myproject
    mvn clean deploy -Popenshift -Dfabric8.generator.from=$(oc project -q)/fuse7-java-openshift:1.5
    ```

BOOM! 💣 🦕

## Component versions

### Fuse standalone

> The JBoss Fuse BOM (Bill of Materials) is a parent POM that **defines the versions for all of the Maven artifacts provided by JBoss Fuse**

- JBoss Fuse BOMs are located in the [Red Hat GA Maven repository][rhgafuseparent].

Here is a table of Fuse releases and the corresponding component versions (**not guaranteed to be 100% correct!**):

| Release                       | Java version(s) | jboss-fuse-parent BOM                              | fabric8-bom/fuse-project-bom                         | Wildfly Camel pom                          | Camel version        | Hibernate             | OpenJPA | Zookeeper       | Commons DBCP       | ActiveMQ             |
| ----------------------------- | --------------- | -------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------ | -------------------- | --------------------- | ------- | --------------- | ------------------ | -------------------- |
| [Fuse 6.0.0 GA][fuse600gapom] | 1.6, 1.7        | [esb-project/6.0.0.redhat-024][fuse600gabom]       | [fuse-project/7.2.0.redhat-024][fuseproject600gabom] | ...                                        | 2.10.0.redhat-60024  | ...                   | 2.2.0   |
| Fuse 6.1.0 GA                 | 1.6, 1.7        | [jboss-fuse-parent/6.1.0.redhat-379][fuse610gabom] | ...                                                  | ...                                        | ...                  | 4.2.9.Final           | ...     | ...             | ...                | ...                  |
| Fuse 6.2.1 R7                 | 1.7, 1.8        | [jboss-fuse-parent/6.2.1.redhat-186][fuse621r7bom] | [1.2.0.redhat-621186][fuse621r7fabricbom]            |                                            | 2.15.1.redhat-621186 |
| Fuse 6.3.0 R1                 | 1.7, 1.8        | [jboss-fuse-parent/6.3.0.redhat-224][fuse630r1bom] | [1.2.0.redhat-630224][fuse630r1fabricbom]            |                                            | 2.17.0.redhat-630224 |
| Fuse 6.3.0 R2                 | 1.7, 1.8        | [jboss-fuse-parent/6.3.0.redhat-254][fuse630r2bom] | [1.2.0.redhat-630254][fuse630r2fabricbom]            |                                            | 2.17.0.redhat-630254 |
| [Fuse 6.3.0 R3][fuse630r3pom] | 1.7, 1.8        | [jboss-fuse-parent/6.3.0.redhat-262][fuse630r3bom] | [1.2.0.redhat-630262][fuse630r3fabricbom]            |                                            | 2.17.0.redhat-630262 | 4.2.22.Final-redhat-1 | ...     | zookeeper-3.4.7 | commons-dbcp-1.4_3 | 5.11.0.redhat-630262 |
| Fuse 6.3.0 R4                 | 1.7, 1.8        | [jboss-fuse-parent/6.3.0.redhat-283][fuse630r4bom] | [1.2.0.redhat-630283][fuse630r4fabricbom]            | [2.4.0.redhat-630283][fuse630r4wildflybom] | 2.17.0.redhat-630283 |
| Fuse 6.3.0 R5                 | 1.7, 1.8        | [jboss-fuse-parent/6.3.0.redhat-310][fuse630r5bom] | [1.2.0.redhat-630310][fuse630r5fabricbom]            | [2.4.0.redhat-630310][fuse630r5wildflybom] | 2.17.0.redhat-630310 |

And for Fuse 7.0:

| Release                       | fuse-springboot BOM                                            |
| ----------------------------- | -------------------------------------------------------------- |
| Fuse 7.0.0                    | [fuse-springboot-bom/7.0.0.fuse-000027-redhat-1][fuse700sbbom] |

The BOM for Spring Boot projects should be referenced in a Maven POM like this (from Fuse 7.0 it's `org.jboss.redhat-fuse`):

```xml
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.jboss.redhat-fuse</groupId>
        <artifactId>fuse-springboot-bom</artifactId>
        <version>${bom.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
```

For older Fuse projects, the BOM is under `org.jboss.fuse.bom`:

```xml
<project ...>
  ...
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.jboss.fuse.bom</groupId>
        <artifactId>jboss-fuse-parent</artifactId>
        <version>${jboss.fuse.bom.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  ...
</project>
```

### Fuse Integration Services 2.0 (Fuse on OpenShift)

| FIS     | Fuse Release                  | OpenShift version(s) | fabric8-project-parent BOM             | fabric8-maven-plugin      | spring-cloud-k8s                                | camel                                   | Spring Boot archetype                                   | kubernetes-client    |
| ------- | ----------------------------- | -------------------- | -------------------------------------- | --------------------------| ----------------------------------------------- | --------------------------------------- | ------------------------------------------------------- | -------------------- |
| FIS 2.0 | JBoss Fuse 6.3.0 GA           | ...                  | 2.2.170.redhat-000004                  | 3.1.80.redhat-000004      | ...                                             |                                         |                                                         |                      |
| FIS 2.0 | JBoss Fuse 6.3.0 Roll Up 1    | ...                  | 2.2.170.redhat-000010                  | 3.1.80.redhat-000010      | ...                                             |                                         |                                                         |                      |
| FIS 2.0 | JBoss Fuse 6.3.0 Roll Up 2    | ...                  | 2.2.170.redhat-000013                  | 3.1.80.redhat-000013      | ...                                             |                                         | [2.2.195.redhat-000013][camelsbarchfis20630r2] (Oct 17) |                      |
| FIS 2.0 | JBoss Fuse 6.3.0 Roll Up 4    | ...                  | [2.2.170.redhat-000019][fis20bom630r4] | 3.1.80.redhat-000019      | [0.1.3.redhat-000020][springcloudk8sfis20630r4] | [2.18.1.redhat-000021][camelfis20630r4] |                                                         | 1.4.14.redhat-000021 |

The FIS BOM should be referenced in a Maven POM like this:

```xml
<project ...>
    ...
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>io.fabric8</groupId>
                <artifactId>fabric8-project-bom-camel-spring-boot</artifactId>
                <version>${fabric8.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    ...
</project>
```

### Fuse 7

Including Fuse on OpenShift (formerly known as Fuse Integration Services).

| Version | fuse-springboot-bom | Spring Boot 2 | fabric8-spring-boot | Templates/Image streams | Notes |
| ------- | ------------------- | ------------- | ------------------- |  --------- | ----- |
| 7.4 (August 2019) | [7.4.0.fuse-740036-redhat-00002][fuse740sb1bom] | [7.4.0.fuse-sb2-740019-redhat-00005][fuse740sb2bom] | [xxxxx][fuse740fabric8sb] | [2.1.fuse-740025-redhat-00003][fuse740templates] | Support for OCP 4.x, Operators |
| 7.3 (April 2019) | [7.3.0.fuse-730058-redhat-00001][fuse730sbbom] | N/A | [3.0.11.fuse-730075-redhat-00001][fuse730fabric8sb] | [2.1.fuse-730065-redhat-00002][fuse730templates] | |

## Distributions

Fuse is available as:

- Fuse on Apache Karaf (standalone)
- Fuse on Apache Karaf (containerised - for OpenShift)
- Fuse on Spring Boot
- Fuse on Wildfly/EAP

## Fuse on Spring Boot

### Image streams for OpenShift

To install the Fuse image streams:

    BASEURL=https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-740025-redhat-00003
    oc create -n openshift -f ${BASEURL}/fis-image-streams.json

## Fuse on Apache Karaf

The standalone (non-containerised) distribution of JBoss Fuse uses Apache Karaf as its runtime:

> Apache Karaf is a generic platform providing higher level features and services specifically designed for creating OSGi-based servers.

JBoss Fuse uses Apache Felix as the [OSGi][osgi] framework (this is configured in `etc/config.properties`)

### Red Hat Fuse default web port

The default port for web applications (e.g. CXF REST/SOAP services) is **8181**, as set in `org.ops4j.pax.web.cfg`:

````
cd $FUSE_HOME
grep 'http.port' etc/org.ops4j.pax.web.cfg
````

### Using Hot-deploy (Felix file installer)

Hot-deploy allows components to be dropped into a folder, automatically discovered and started. To debug this behaviour, set a logger in `org.ops4j.pax.logging.cfg`:

    log4j2.logger.felix.name = org.apache.felix.fileinstall
    log4j2.logger.felix.level = DEBUG

### Working with bundles in Fuse

- The `osgi:list` command doesn't show all bundles by default - use the `-t` command to set the start-level threshold to show all bundles, e.g. `osgi:list -t 0`

How to make sure you're using the correct Red Hat builds of bundles?

- Look at the file `org.apache.karaf.features.xml`
- This contains an element `bundleReplacements` which tells Karaf, when asked to install bundles at certain versions, to replace with the Red Hat-specific version of that bundle.

### Running JBoss Fuse with jenv

Running Fuse 6.0 on Mac OS X (with `jenv` installed to manage JRE versions):

    cd $FUSE_HOME
    jenv local 1.7
    jenv exec ./bin/fuse

### Fuse on Karaf on OpenShift

#### Binary builds

To do a binary build for the Fuse on Karaf image, make sure that you've built a Karaf assembly (`.zip`) using the `archive` goal of the `karaf-maven-plugin`.

Then, in your S2I _BuildConfig_, make sure that the environment variable `ARTIFACT_DIR` is set to `.`:

    strategy:
      sourceStrategy:
        env:
          - name: ARTIFACT_DIR
            value: .
        from:
          kind: ImageStreamTag
          name: fuse7-karaf-openshift:1.2
          namespace: openshift
      type: Source

Then, you can start the build like the command below, which will upload your Karaf assembly zip, and unpack it into the container image:

    oc start-build my-karaf-app --from-file=target/myapp-1.0.zip --follow

## Fuse 6 to 7 migration

Things to be aware of when migrating Fuse 6 to 7:

<img src="/assets/images/fuse6to7.excalidraw.svg"/>

## Fuse 6.x Fabric

Fabric is a Fuse feature that provides centralised configuration and bundle provisioning.

Fabric terminology 101:

- **Ensemble** - _"a collection of Fabric Servers that collectively maintain the state of the fabric registry"_
- **Fabric Server** - _"responsible for maintaining a replica of the fabric registry"_
- **Fabric Container/managed container** - where the actual bundles are deployed/run; _"can retrieve registry data from any Fabric Server in the Fabric Ensemble"_
- **Root container** - this is the first container when creating a Fabric; **NB:** it is not a Fabric-managed container, so it cannot be started/stopped using `container-start`, `container-stop` commands.

Other good things to know about Fabric:

- Fabric managed containers don't use Karaf's _features_ service. Provisioning happens exclusively via Fabric profiles. So `features:` commands won't be visible, unless you inherit from the `jboss-fuse-minimal` profile, which adds the commands to the container.

### Quick Fabric setup/demo

Create a quick Fabric and deploy an example feature:

    fabric:create --wait-for-provisioning
    fabric:container-create-child root fabric001
    fabric:profile-create --parent default foo
    fabric:container-change-profile fabric001 foo

    fabric:profile-edit --repository mvn:org.apache.camel/camel-example-osgi/2.17.0/xml/features foo
    fabric:profile-edit --feature camel-example-osgi foo

    fabric:profile-edit --delete --feature camel-example-osgi foo

### Advanced/recommended Fabric creation

Creating a Fabric with more appropriate settings for a 'real' environment:

    fabric:create ... --zookeeper-purge-interval 24 \
        --zookeeper-snap-retain-count 3

### Starting/stopping containers

To start **Managed Containers or Fabric Servers** (except the **root** container):

    fabric:container-start containername01
    fabric:container-stop containername01

**To start/stop the `root` container**, use the `start`/`stop` scripts in the Fuse directory, or a system service wrapper, if you have configured one.

### Viewing container info

How to view container info, including things like HTTP URLs (i.e. which port Jetty is running on), Jolokia URL, JMX URL, etc.:

    > fabric:container-info containername01
    ...
    SSH Url:        yourcontainer.example.com:21000
    JMX Url:        service:jmx:rmi://yourcontainer.example.....
    Http Url:       http://yourcontainer.exampe.com:21001
    ...etc...

### Inspecting profile config

Profiles are stored in Git inside `$KARAF_HOME/data/git/local/fabric/fabric`.

### Deleting a Fabric (not recommended!)

To delete a Fabric, shut down all containers then delete `data` and `instances` (NB: everything will be lost!):

    rm -rf data/
    rm -rf instances/

### Fabric versioning

- When creating a new version (`fabric:version-create`), Fabric **sorts version names based on the numeric version string**
- To add a text description to a version name, append it to the end of the version number, e.g. `1.0.myversion`

### Maven Proxy and Fabric Agent

The **Maven Proxy** runs on each Fabric server (ensemble member) and is a central cache of Maven artifacts for the Fabric containers.

- _"Managed containers try to download from the Maven proxy, before trying to download from the Internet"_
- Maven Proxies are configured in a _master-slave_ cluster on the Fabric servers
- Query Zookeeper to find out the current master: `cluster-list servlets/io.fabric8.fabric-maven-proxy`
- Artifacts are **not automatically replicated** between different Maven proxies in the cluster

The **Fabric Agent** runs on each managed container:

- The agent _"provisions the container according to the profiles assigned to it... It retrieves any required Maven artifacts from the Maven repositories specified by its profile, which are accessed through the Maven proxies managed by the fabric."_

OSGi property reference (change properties in the `default` profile to ensure they are **propagated across all containers** in the Fabric):

| PID | Property name | Description | Default value OOTB | Example custom value |
| --- | ------------- | ----------- | ------------------ | -------------------- |
| **Maven Proxy** |
| `io.fabric8.maven` | `io.fabric8.maven.repositories` | List of (remote) Maven repositories used by the Maven proxy. By default, it is configured to copy the contents of the `io.fabric8.agent/org.ops4j.pax.url.mvn.repositories` | `${profile:io.fabric8.agent/org.ops4j.pax.url.mvn.repositories}` |
| `io.fabric8.maven` | `io.fabric8.maven.defaultRepositories` | List of (local) Maven repositories searched in the first place by the Maven proxy. It should contain `${runtime.home}/${karaf.default.repository}` | `${profile:io.fabric8.agent/org.ops4j.pax.url.mvn.defaultRepositories}` | ... |
| **Fabric Agent** |
| `io.fabric8.agent` | `org.ops4j.pax.url.mvn.repositories` | List of Maven repositories that are searched (by the Fabric Agent) if an artifact is not found in the Maven proxies. | `http://repo1.maven.org/maven2@id=maven.central.repo,` <br/> `https://maven.repository.redhat.com/ga@id=redhat.ga.repo,` <br/> `https://maven.repository.redhat.com/earlyaccess/all@id=redhat.ea.repo,` <br/> `https://repository.jboss.org/nexus/content/groups/ea@id=fuseearlyaccess` | `http://mynexus:8081/nexus/repository/myrepo@id=myreleases` |
| `io.fabric8.agent` | `org.ops4j.pax.url.mvn.defaultRepositories` | File-based repositories searched by Fabric Agent during provisioning (configuration property for _AetherBasedResolver_) | `file:${runtime.home}/${karaf.default.repository}@snapshots@id=karaf-default,` <br/> `file:${runtime.data}/maven/upload@snapshots@id=fabric-upload,` <br/> `file:${user.home}/.m2/repository@snapshots@id=local` | ... |
| `io.fabric8.agent` | `org.ops4j.pax.url.mvn.repositories.updateReleases` | ... | `true` | ... |

### Clustered AMQ

Fabric can be used to create clusters of ActiveMQ brokers.

Create a broker using:

    fabric:mq-create mybroker
    # OR
    fabric:mq-create --group mybrokers broker1

MQ brokers have a Fabric profile created that follows the naming convention `x-y-z-BrokerGroup.BrokerName`, e.g. `mq-broker-central.broker1`

List the clusters managed by Fabric using:

    fabric:cluster-list amq

For brokers managed by Fabric, broker properties should be added to a PID named `io.fabric8.mq.fabric.server-$brokerName` ([see `MQService.java`][fabric8mqservice]), for example:

```
kind = MasterSlave
connectors = OpenWire
ssl = false
group = MyBrokerGroup    # this is the cluster name visible in fabric:cluster-list
                         # clients using discovery should connect to a group
broker-name = my-broker
```

**When creating Fabric brokers manually**, using profile configuration and specific ports (i.e. when not using MQ _discovery_), roughly follow these steps:

1. Create a parent Fabric profile for the brokers first, e.g. `mq-broker-mybrokerprofile` - inheriting `mq-base`
1. Set configuration in the PID `io.fabric8.mq.fabric.server-mybrokername`
1. Add the `activemq.xml` as a resource (file) into the profile
1. Use child profiles to override the `port` value for each broker in the cluster

For example: a parent profile `mybrokers` could inherit `mq-base`, with child profiles `mybrokers.broker1` and `mybrokers.broker2`.

## Patching JBoss Fuse on Karaf

To install a rollup patch into a **brand new environment**, just extract the rollup patch ZIP file:

> Since JBoss Fuse 6.2.1, **a rollup patch file is a complete new build of the official target distribution**. In other words, it is just like the original GA distribution, except that it includes later build artifacts.

-- [Configuring and Running JBoss Fuse][esbruntimeprepatched]

To patch **an existing** JBoss Fuse installation, you will need the following from the Red Hat Customer Portal:

- The latest JBoss Fuse GA distribution (e.g. `jboss-fuse-karaf-6.3.0.redhat-xxx.zip`).
- (Optional) A Patch Mechanism upgrade distribution (_Red Hat JBoss Fuse 6.x Rollup N Patch Management Package_ - e.g. `patch-management-package-6.3.0.redhat-yyy.zip`) (if applicable to this Fuse version)
- Latest Rollup Patch distribution (_Red Hat JBoss Fuse 6.x Rollup N on Karaf_ - e.g. `jboss-fuse-karaf-6.3.0.redhat-yyy.zip`)

To install a hotfix patch, follow the instructions in the Fabric Guide on **applying an incremental patch**.

### Patching steps

1. Provision a standalone Fuse container, using the GA release.
2. Copy the Patch Mechanism upgrade distribution to the remote server and follow the steps in [Configuring and Running JBoss Fuse - Chapter 19. Applying Patches][1].
3. Copy the Rollup Patch distribution to the remote server and follow the instructions for applying a Rollup Patch, which can be found in [the same guide][1].

For Fuse Patches, the container may need a restart. If it does, it will restart automatically. But you won't get a warning about this.

## Cookbook

### Developer cookbook

#### Creating a new project

##### JBoss Fuse

Archetypes are labelled under `io.fabric8.archetypes`, version `1.2.0.redhat-xxxxxx`. To create a new JBoss Fuse "router" project:

    mvn archetype:generate -DarchetypeGroupId=io.fabric8.archetypes \
        -DarchetypeVersion=1.2.0.redhat-630187 \
        -DarchetypeArtifactId=karaf-camel-cbr-archetype \
        -DgroupId=org.fusesource.example -DartifactId=camel-basic \
        -Dversion=1.0-SNAPSHOT -Dfabric8-profile=camel-basic-profile

Or substitute with one of the following archetypes depending on the use case:

| Group ID | Archetype Artifact ID | Description |
| --------------------- | ----------- |
| `io.fabric8.archetypes` | `karaf-camel-cbr-archetype` | Creates a new Camel Content-Based Router Example |
| `io.fabric8.archetypes` | `karaf-camel-log-archetype` | Creates a new Camel Log Example |
| `io.fabric8.archetypes` | `karaf-soap-archetype` | Creates a new SOAP example using JAXWS |

##### Fuse on OpenShift

To create a Fuse 7.4 on OpenShift application using the Maven archetype:

    mvn org.apache.maven.plugins:maven-archetype-plugin:2.4:generate \
      -DarchetypeCatalog=https://maven.repository.redhat.com/ga/io/fabric8/archetypes/archetypes-catalog/2.2.0.fuse-740017-redhat-00003/archetypes-catalog-2.2.0.fuse-740017-redhat-00003-archetype-catalog.xml \
      -DarchetypeGroupId=org.jboss.fuse.fis.archetypes \
      -DarchetypeArtifactId=spring-boot-camel-xml-archetype \
      -DarchetypeVersion=2.2.0.fuse-740017-redhat-00003

See the _Component Versions_ section at the top of the page for a table showing mappings of build versions Fuse releases.

#### Good practice

- Use the correct JBoss Fuse parent BOM for the version of Fuse that you are looking to target.

#### Persistence

- The Apache OpenJPA implementation of the Java Persistence API (JPA) is deprecated since 6.2.1. It is recommended to use the Hibernate implementation instead.

#### Connecting to ActiveMQ

A simple example (note the declaration of `init-method` and `destroy-method`):

```xml
<bean id="internalConnectionFactory" class="org.apache.activemq.ConnectionFactory">
  <argument value="tcp://localhost:61616" />
</bean>
<bean id="connectionFactory" class="org.apache.activemq.jms.pool.PooledConnectionFactory" init-method="start" destroy-method="stop">
  <property name="connectionFactory" ref="internalConnectionFactory"/>
  <property name="name" value="activemq" />
  <property name="maxConnections" value="2" />
  <property name="blockIfSessionPoolIsFull" value="true" />
</bean>
```

### Fuse 6.x Karaf command line

#### Working with bundles and features

Install a bundle in Apache Karaf:

    osgi:install -s mvn:groupId/artifactId/version

List all bundles with a start-level of 0 or higher, and show their location (e.g. Maven co-ordinates of the bundle):

    osgi:list -t 0 -l

Install a feature:

    features:addurl mvn:org.apache.camel/camel-example-osgi/2.17.0/xml/features
    features:install camel-example-osgi

Show OSGi manifest information about a bundle (shows `Export-Service`, `Export-Package`, `Import-Package`, etc.):

    osgi:headers camel-core

Show information about a feature:

    features:info jasypt-encryption
    features:info -t jasypt-encryption  # Shows feature tree

#### Debugging Karaf with IntelliJ

Find the specific JAR you want to debug and add it to the _External Libraries_ list in IntelliJ. Then add a Run Configuration for debugging (see the IntelliJ page). Then, run Fuse like this:

    export KARAF_DEBUG=true
    export JAVA_DEBUG_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005
    ./bin/fuse

#### OSGi Config Admin

View details of a specific OSGi Config Admin PID:

    config:list "(service.pid=com.example.my.pid.name)"

#### Jolokia

Get the root info from Jolokia:

    curl -vk -u admin:admin http://localhost:8181/jolokia/list

Get ActiveMQ broker info:

    curl http://quarkus:quarkus@localhost:8161/console/jolokia/read/org.apache.activemq.artemis:broker\=\*

#### User administration

Get the list of JAAS realms:

    jaas:realms

Taking the _index_ value of the realm you want to edit from the `jaas:realms` list above (usually the `karaf` realm), use the following to create a user and add it into the _manager_ and _viewer_ groups:

    jaas:manage --module io.fabric8.jaas.ZookeeperLoginModule --realm karaf
    jaas:useradd jsmith p455w0rd
    jaas:groupadd jsmith manager
    jaas:groupadd jsmith viewer
    jaas:update

To update an existing user's password, use `useradd` against the realm:

    jaas:useradd username newpassword

NB: If you update the password of the `admin` user, you will need to re-start your Fuse client session. (This is because it will still attempt to use the old password). Also, changing the admin password will not also update the Fabric Ensemble password. (You can verify this using `fabric:ensemble-password`) Details on how to update the Ensemble password are below.

#### Fabric

Add a URL to a feature repository to a Fabric profile:

    fabric:profile-edit --repository mvn:groupId/artifactId/version/xml/features my-profile-name

Show details of a profile (shows all repositories, features, etc):

    fabric:profile-display foo

Modify a config property:

    fabric:profile-edit --config MY_VAR=myvalue my-profile-name

Modify a PID value in a Fabric profile:

    fabric:profile-edit --pid "org.mypackage/org.hello.valueName=1234" my-profile-name

Increase global logging to `DEBUG` level (warning: very chatty!):

```
fabric:profile-edit --pid "org.ops4j.pax.logging/log4j.rootLogger=DEBUG, out, osgi:*" karaf
```

Change log file (`fuse.log`) max size and number of backups/rotation in Fabric:

    fabric:profile-edit --pid org.ops4j.pax.logging/log4j.appender.out.maxFileSize=100MB karaf
    fabric:profile-edit --pid org.ops4j.pax.logging/log4j.appender.out.maxBackupIndex=666 karaf

Set log levels for a specific Fabric profile:

    fabric:profile-edit --pid org.ops4j.pax.logging/log4j.category.org.example.mypackage=DEBUG my-profile-name

Change the Maven repositories searched by the Fabric Agent:

    fabric:profile-edit --pid io.fabric8.agent/org.ops4j.pax.url.mvn.repositories=http://nexus.example.com:8081/blah default

Update Zookeeper password:

    fabric:ensemble-password newpassword123
    // wait a few moments while the new password is propagated
    fabric:ensemble-password --commit

#### Zookeeper (for Fabric)

Install Zookeeper commands and query Zookeeper (you will need to add the feature to an appropriate profile - e.g. `fabric-ensemble-0000-1` or `default`):

    fabric:profile-edit --feature fabric-zookeeper-commands <profile-name>

    zk:list -r -d /fabric/registry/path
    zk:get /fabric/registry/path/mykey

Some useful locations of things in Zookeeper:

| ZK path                                                       | Description       | Sample value                      |
| ------------------------------------------------------------- | ----------------- | --------------------------------- |
| `/fabric/configs/ensemble/password`                           | Ensemble password | `ZKENC=YWRtaW43ODk=`              |
| `/fabric/registry/containers/alive` (path)                    | Alive containers  | `/fabric/registry/containers/alive/mychild1` <br/> `/fabric/registry/containers/alive/root` |
| `/fabric/registry/clusters/apis`                              | APIs              |
| `/fabric/registry/ports/containers/ContainerName/PID/KeyID`   | Port Service      | ... |

#### Other commands and one-liners

Connect to a remote Fuse (Karaf) instance:

    $ ./bin/client -a 8161 -h fuseserver.company.com -u admin

Extract the current Provision Status of a Fabric container, using `container-info` and `awk`:

    $ ./bin/client -u admin -p admin fabric:container-info my-container-name | grep 'Provision Status' | tr -s ' ' | awk -F": " '{print $2}'
    success

## Troubleshooting

Clear the Karaf cache (where bundles are stored):

    rm -rf data/cache

Bundles get stuck in `GracePeriod` status and then fail:

- Most often, the failure of a bundle is due to a missing dependency. Common reasons:
    - A Karaf _feature_ has not been installed (view all installed features using `features:list`). This might have neglected to be done manually, or perhaps the Fabric profile being used does not install or inherit the required feature.
    - A datasource does not exist, or is configured incorrectly.
    - An ActiveMQ connection is pointing at the wrong host/port (look for _"Failed to connect to [...] after: 10 attempt(s) continuing to retry."_)
- Check the logs (`log:display`) for lines like _Bundle my-bundle/1.0.0-SNAPSHOT is waiting for dependencies [(objectClass=com.example.MyClass), (objectClass=com.example.AnotherClass)]_ - this shows the classes that a bundle is waiting for, so that it can start.
    - Then look for the bundles which export those dependent classes. If those bundles fail to start, this will cause other bundles to wait and then eventually fail - use `osgi:find-class com.example.MyClass` to see which bundles contain a given class.
- Check the logs for _"Application context refresh failed"_ - this may give some clues, if a bean declared in the bundle's `blueprint.xml` is configured incorrectly or cannot be instantiated.
- If using Hibernate, check the logs for _"Error creating EntityManagerFactory"_ (can be seen as a `WARN` level log). This should be accompanied by a stack trace, which will show the reason why the EntityManager couldn't be created - often the result of an invalid JPA mapping.

Bundles stuck at `Resolved` status:

- Check that the `startlevel` property in `config.properties` is high enough to start all bundles. If bundles are assigned a start-level which is higher than the `startlevel` property, they will remain at _Resolved_ and not move to _Active_.

Fabric agent does not notice updated SNAPSHOT numbers, and continues to deploy old snapshot versions of bundles to Fabric containers:

- Remove the Fabric profile from containers (`container-remove-profile ...`), delete the profile (`profile-delete`) and then recreate it.
- (Generally this should only be a problem in your development environment)

Fabric Agent tries to resolve Fuse dependencies from online repositories (Maven Central, etc.) rather than through the local system repository of the Fabric Maven Proxy:

- Check that there is no web proxy configuration required to communicate with the Fabric Maven Proxy

`javax.management.InstanceAlreadyExistsException` occurs when starting Fuse:

- This happens when the installation directory is moved/copied to a new location

Bundles are waiting for `EntityManagerFactory` (error log seen is `Unable to start blueprint container for bundle ... due to unresolved dependencies (...osgi.unit.name=MyPersistenceUnit)(objectClass=javax.persistence.EntityManagerFactory)`):

- Check that the datasource bundle is exporting the data sources required, using `osgi:ls <bundle-id>`
- Look for any instances of `org.hibernate.MappingException` which may indicate that JPA mapping annotations are incorrect - e.g. repeated columns

Felix Fileinstall doesn't seem to pick up Blueprint XMLs / Karaf just ignores XML files in the hot-deploy folder:

- Check that the `deployer` feature is installed into Karaf. This provides the bundle `org.apache.karaf.deployer.blueprint`, amongst others.
- If there is not a suitable deployer present which can handle a file (e.g. a Blueprint XML file), Felix Fileinstall will just skip over it.

_karaf-maven-plugin_ fails to build a Karaf microcontainer; build fails with error "null":

- Check that all KAR archives have been downloaded successfully from Maven Central (or another mirror).
- The karaf-maven-plugin builds a Karaf microcontainer by downloading KAR archive(s) from a Maven repository.
- If the KAR file is corrupted, or hasn't been downloaded properly, you might not see an error -- instead, the process might just fail silently at some later stage, without giving a clue that the KAR was invalid.

_karaf-maven-plugin_ builds a Karaf container without the commands/features that you want:

- The logs from the assembly build should say something like: _"adding all non-blacklisted features from repository: mvn:org.jboss.fuse/fuse-karaf-framework/7.10.0.fuse-7_10_2.../xml/features"_
- Open this Maven artifact (it's an XML file) to see the details of the features, and which bundles they contain. This Maven artifact also pulls in other XML feature files.
- The feature called `bundle` is defined in org.apache.karaf.features/standard/4.2.12.../xml/features. It installs the bundle `org.apache.karaf.bundle.core`, which provides Karaf CLI commands like [list](https://github.com/apache/karaf/blob/main/bundle/core/src/main/java/org/apache/karaf/bundle/command/List.java)

[1]: https://access.redhat.com/documentation/en-us/red_hat_jboss_fuse/6.3/html/configuring_and_running_jboss_fuse/esbruntimepatching
[fuse600gapom]: http://repo.fusesource.com/nexus/content/groups/public/org/jboss/fuse/jboss-fuse/6.0.0.redhat-024/jboss-fuse-6.0.0.redhat-024.pom
[fuse600gabom]: http://repo.fusesource.com/nexus/content/groups/public/org/jboss/fuse/esb-project/6.0.0.redhat-024/esb-project-6.0.0.redhat-024.pom
[fuseproject600gabom]: http://repo.fusesource.com/nexus/content/groups/public/org/fusesource/fuse-project/7.2.0.redhat-024/fuse-project-7.2.0.redhat-024.pom
[fuse610gabom]: https://repo.fusesource.com/nexus/content/repositories/releases/org/jboss/fuse/bom/jboss-fuse-parent/6.1.0.redhat-379/jboss-fuse-parent-6.1.0.redhat-379.pom
[fuse621r7bom]: https://maven.repository.redhat.com/ga/org/jboss/fuse/bom/jboss-fuse-parent/6.2.1.redhat-186/jboss-fuse-parent-6.2.1.redhat-186.pom
[fuse621r7fabricbom]: https://maven.repository.redhat.com/ga/io/fabric8/bom/fabric8-bom/1.2.0.redhat-621186/fabric8-bom-1.2.0.redhat-621186.pom
[fuse630r1bom]: https://maven.repository.redhat.com/ga/org/jboss/fuse/bom/jboss-fuse-parent/6.3.0.redhat-224/jboss-fuse-parent-6.3.0.redhat-224.pom
[fuse630r1fabricbom]: https://maven.repository.redhat.com/ga/io/fabric8/bom/fabric8-bom/1.2.0.redhat-630224/fabric8-bom-1.2.0.redhat-630224.pom

[fuse630r2bom]: https://maven.repository.redhat.com/ga/org/jboss/fuse/bom/jboss-fuse-parent/6.3.0.redhat-254/jboss-fuse-parent-6.3.0.redhat-254.pom
[fuse630r2fabricbom]: https://maven.repository.redhat.com/ga/io/fabric8/bom/fabric8-bom/1.2.0.redhat-630254/fabric8-bom-1.2.0.redhat-630254.pom

[fuse630r3bom]: https://maven.repository.redhat.com/ga/org/jboss/fuse/bom/jboss-fuse-parent/6.3.0.redhat-262/jboss-fuse-parent-6.3.0.redhat-262.pom
[fuse630r3pom]: https://maven.repository.redhat.com/ga/org/jboss/fuse/jboss-fuse-karaf/6.3.0.redhat-262/jboss-fuse-karaf-6.3.0.redhat-262.pom
[fuse630r3fabricbom]: https://maven.repository.redhat.com/ga/io/fabric8/bom/fabric8-bom/1.2.0.redhat-630262/fabric8-bom-1.2.0.redhat-630262.pom

[fuse630r4bom]: https://maven.repository.redhat.com/ga/org/jboss/fuse/bom/jboss-fuse-parent/6.3.0.redhat-283/jboss-fuse-parent-6.3.0.redhat-283.pom
[fuse630r4fabricbom]: https://maven.repository.redhat.com/ga/io/fabric8/bom/fabric8-bom/1.2.0.redhat-630283/fabric8-bom-1.2.0.redhat-630283.pom
[fuse630r4wildflybom]: https://maven.repository.redhat.com/ga/org/wildfly/camel/wildfly-camel/2.4.0.redhat-630283/wildfly-camel-2.4.0.redhat-630283.pom

[fuse630r5bom]: https://maven.repository.redhat.com/ga/org/jboss/fuse/bom/jboss-fuse-parent/6.3.0.redhat-310/jboss-fuse-parent-6.3.0.redhat-310.pom
[fuse630r5fabricbom]: https://maven.repository.redhat.com/ga/io/fabric8/bom/fabric8-bom/1.2.0.redhat-630310/fabric8-bom-1.2.0.redhat-630310.pom
[fuse630r5wildflybom]: https://maven.repository.redhat.com/ga/org/wildfly/camel/wildfly-camel/2.4.0.redhat-630310/wildfly-camel-2.4.0.redhat-630310.pom

[fuse700sbbom]: https://maven.repository.redhat.com/ga/org/jboss/redhat-fuse/fuse-springboot-bom/7.0.0.fuse-000027-redhat-1/fuse-springboot-bom-7.0.0.fuse-000027-redhat-1.pom
[fuse730sbbom]: https://maven.repository.redhat.com/ga/org/jboss/redhat-fuse/fuse-springboot-bom/7.3.0.fuse-730058-redhat-00001/fuse-springboot-bom-7.3.0.fuse-730058-redhat-00001.pom
[fuse730templates]: https://github.com/jboss-fuse/application-templates/tree/application-templates-2.1.fuse-730065-redhat-00002
[fuse730fabric8sb]: https://maven.repository.redhat.com/ga/io/fabric8/fabric8-project-bom-camel-spring-boot/3.0.11.fuse-730075-redhat-00001/fabric8-project-bom-camel-spring-boot-3.0.11.fuse-730075-redhat-00001.pom
[fuse740sb2bom]: https://maven.repository.redhat.com/ga/org/jboss/redhat-fuse/fuse-springboot-bom/7.4.0.fuse-sb2-740019-redhat-00005/fuse-springboot-bom-7.4.0.fuse-sb2-740019-redhat-00005.pom
[fuse740sb1bom]: https://maven.repository.redhat.com/ga/org/jboss/redhat-fuse/fuse-springboot-bom/7.4.0.fuse-740036-redhat-00002/fuse-springboot-bom-7.4.0.fuse-740036-redhat-00002.pom
[fuse740fabric8sb]: https://maven.repository.redhat.com/ga/io/fabric8/fabric8-project-bom-camel-spring-boot/3.0.11.fuse-740029-redhat-00002/fabric8-project-bom-camel-spring-boot-3.0.11.fuse-740029-redhat-00002.pom
[fuse740templates]: https://github.com/jboss-fuse/application-templates/tree/application-templates-2.1.fuse-740025-redhat-00003

[camelsbarchfis20630r2]: https://maven.repository.redhat.com/ga/org/jboss/fuse/fis/archetypes/spring-boot-camel-xml-archetype/2.2.195.redhat-000013/spring-boot-camel-xml-archetype-2.2.195.redhat-000013.pom

[fis20bom630r4]: https://maven.repository.redhat.com/ga/io/fabric8/fabric8-project-bom-camel-spring-boot/2.2.170.redhat-000019/fabric8-project-bom-camel-spring-boot-2.2.170.redhat-000019.pom
[springcloudk8sfis20630r4]: https://maven.repository.redhat.com/ga/io/fabric8/spring-cloud-kubernetes-core/0.1.3.redhat-000020/spring-cloud-kubernetes-core-0.1.3.redhat-000020.pom
[camelfis20630r4]: https://maven.repository.redhat.com/ga/org/apache/camel/camel-core/2.18.1.redhat-000021/camel-core-2.18.1.redhat-000021.pom


[rhgafuseparent]: https://maven.repository.redhat.com/ga/org/jboss/fuse/bom/jboss-fuse-parent/
[esbruntimeprepatched]: https://access.redhat.com/documentation/en-us/red_hat_jboss_fuse/6.3/html/configuring_and_running_jboss_fuse/esbruntimeprepatched
[fabric8mqservice]: https://github.com/jboss-fuse/fabric8/blob/1.2.0.redhat-6-3-x/fabric/fabric-api/src/main/java/io/fabric8/api/MQService.java

[osgi]: {{ site.baseurl }}{% link _articles/osgi.md %}
