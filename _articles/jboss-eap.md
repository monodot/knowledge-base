---
layout: page
title: JBoss EAP
---

The Java application server, based on Wildfly.

{% include toc.html %}

## Concepts

EAP can run in one of two modes, **standalone** or **domain** mode:

- **standalone server** (standalone mode in EAP 6) is a single server instance with a single config file. Use this if centralised management isn't needed.
- **managed domain** (domain mode in EAP 6) is for centralised management setups. In this style of deployment, there is a domain controller, and host controllers. Each host has a host controller, with 0 or more server instances. A separate process controller manages the startup/shutdown of host controllers and servers instances.

Common terminology:

- **host controller** (_domain mode_) - responsible for server management (i.e. starting and stopping server process on the host). A domain can have multiple host controllers. The host controller is configured from `domain/configuration/host.xml`
- **domain controller** - is a specialised _host controller_ that maintains the domain / central management / etc. Configured using `domain/configuration/domain.xml`. On failure, any other host controller can become a domain controller.
  - Specify a host controller to be a domain controller by setting `<domain-controller><local/><domain-controller>` in `host.xml`.
- **server groups** (_domain mode_) - a collection of server instances in a domain. Instances in a group share the same config & deployments. There can be multiple server groups in a domain. Configured under `<server-group-name>`.
- **subsystem** - the different parts that make up EAP, e.g. _elytron_ (security), _infinispan_ (caching), _messaging-activemq_ (Artemis), _jpa_ (persistence)

An EAP server instance is run with a profile. A profile configures the _subsystems_ that will be available on the server. These are the standard profiles:

- `default` - includes the most commonly used subsystems, but **no messaging**
- `ha` - same as `default` but with `jgroups` for clustering
- `full` - adds messaging and other subsystems
- `full-ha` - same as `full` but with clustering

## Component versions

| Release                | Artemis version    |
| ---------------------- | ------------------ |
| EAP 7.0                | 1.1.0              |

## Installation and setup

Installation is usually done using one of these methods:

- `yum install` from RHEL repos
- JAR based installer (a GUI application which sets up users, etc.) - you can also run the installer with `-console` or specify an installation config file for an unattended install
- Extract the zip file, for a simple out-of-the-box setup

### Example EC2 installation

Demo installation on a basic RHEL EC2 instance (assuming that the EAP binary has been copied into a private S3 bucket):

    $ sudo yum install -y java-1.8.0-openjdk-devel unzip
    $ curl -O https://bootstrap.pypa.io/get-pip.py
    $ sudo python get-pip.py

    $ sudo useradd jboss
    $ sudo mkdir -p /opt/jboss
    $ sudo chown -R jboss:jboss /opt/jboss

    $ sudo su jboss
    $ pip install awscli --upgrade --user

    $ cd /opt/jboss
    $ ~/.local/bin/aws s3 cp s3://YOURBUCKET/dists/jboss-eap-7.1.0.zip .
    $ unzip jboss-eap-7.1.0.zip
    $ cd jboss-eap-7.1.0/
    $ ./bin/standalone.sh \
        -c standalone-full-ha.xml \
        -b 0.0.0.0 \
        -bmanagement 0.0.0.0

And then to install and run the quickstarts - first install Maven (see [Maven][maven] doc for an example), then:

    $ sudo su jboss
    $ ~/.local/bin/aws s3 cp s3://YOURBUCKET/dists/jboss-eap-quickstarts-7.0.0.GA.zip .
    $ unzip jboss-eap-quickstarts-7.0.0.GA.zip

    $ cd jboss-eap-quickstarts-7.0.0.GA/helloworld-mdb
    $ mvn clean wildfly:deploy \
        -Dwildfly.host=localhost \
        -Dwildfly.port=9992 \
        -Dcheckstyle.skip

    $ ./bin/jboss-cli.sh
    [/] connect broker1:port
    # enable statistics
    [/] /subsystem=messaging-activemq/server=default:write-attribute(name=statistics-enabled,value=true)
    [/] /subsystem=messaging-activemq/server=default/jms-queue=HelloWorldMDBQueue:read-resource(include-runtime=true)

    $ curl http://localhost:8082/helloworld-mdb/HelloWorldMDBServletClient

    # get messages added to the queue - should be 5L
    [/] /subsystem=messaging-activemq/server=default/runtime-queue=jms.queue.HelloWorldMDBQueue:read-attribute(name=messages-added)

## Basic standalone start/stop

To start EAP as a standalone server:

    $ ./bin/standalone.sh    # uses standalone.xml
    $ ./bin/standalone.sh \
        -c standalone-full-ha.xml \
        -b 0.0.0.0 \
        -bmanagement 0.0.0.0

To stop, either Ctrl+C if running in interactive mode, or if background:

    $ ./bin/jboss-cli.sh --connect
    [/] shutdown

To add an initial admin user (update the disabled OOTB `admin` user):

    $ ./bin/add-user.sh
    $ ./bin/add-user.sh -u 'admin' -p 'adminpw'
    $ ./bin/add-user.sh -a -u 'quickstartUser' -p 'quickstartPwd1!' -g 'guest'
    $ ./bin/add-user.sh -sc path/to/server1/configuration ...

The web console is found at **http://localhost:9990/console**.

To modify environment variables (e.g. to set `JAVA_OPTS`), edit `./bin/standalone.conf`, e.g.:

    JAVA_OPTS="$JAVA_OPTS -Djboss.modules.metrics=true"

### Setting up multiple standalone servers

To run multiple standalone servers on the same host:

    $ cp -a ./standalone ./myserver1
    $ cp -a ./standalone ./myserver2
    $ ./bin/standalone.sh \
        -Djboss.node.name=myserver1 \
        -Djboss.server.base.dir=$JBOSS_HOME/myserver1 \
        -c standalone.xml

If running on a single host, with a single IP address, then use the `-Djboss.socket.binding.port-offset` property to avoid port conflicts.

## Domain mode start/stop

To start in domain mode (starts a process controller, which starts the host controller(s)):

    $ ./bin/domain.sh   # starts listening on localhost only;
                        # external hosts won't be able to connect

    $ ./bin/domain.sh -Djboss.bind.address.management=192.168.0.14

This will start, by default (in EAP 7):

- 2 x server instances, which are defined in `main-server-group` in the the `full` profile
- There is a third server instance (server-three) which is not started because it is defined in `other-server-group`

To start a host controller in another machine:

    $ ./domain.sh -Djboss.bind.address.management=192.168.0.15 \
        -Djboss.domain.master.address=192.168.0.14

Starting/stopping a server from the JBoss CLI:

    $ /host=myhost/server-config=my-server-name:restart

Reloading a host:

    $ reload --host=myhostname

### Configuring a domain

To configure the domain:

- Edit `./domain/configuration/domain.xml`
- This defines which server groups should start under which profile(s), e.g. `<server-group name="main-server-group" profile="full"> ... </server-group>`
- Can use `--domain-config` to provide an alternative location for the `domain.xml` file

To configure a host:

- Edit `./domain/configuration/host.xml`
- This defines server instances, and which server groups they belong to
- Can use `--host-config` to provide an alternative location for the `host.xml` file

Once a domain is running, info about the domain can be found in the web console at Runtime -> Browse Domain by Hosts -> (host name) -> (server1, server2, server3, ...)

To configure a host's connection to the domain controller (to set the `domain-controller` element in the host's XML config):

```
/host=myhost:read-attribute(name=domain-controller)
/host=myhost:write-remote-domain-controller(security-realm=xxx,...)
/host=myhost:reload
```


Other domain info:

- Each **host** defines a _management interface_ - this is usually on port 9999, so if running multiple _hosts_ on one _machine_, then make sure `jboss.management.native.port` is set to a unique value.
- Configure **server groups** inside `domain.xml` - define a profile

### Other startup examples

Start a dedicated domain controller (no servers) using the `host-master` config file:

    $ ./bin/domain.sh --host-config=host-master.xml

## Quickstarts and demos

A bunch of quickstarts are available at: <https://github.com/wildfly/quickstart>

## Monitoring queues

**Browsing messages** with full text is not possible yet, but is raised as an enhancement:  <https://issues.jboss.org/browse/WFLY-8736>.

## EAP CLI

The EAP CLI is a tool to configure EAP from the command line:

    $ ./bin/jboss-cli.sh
    [/] connect   # connects to localhost:9990 by default
    [/] connect localhost:9991

Find help on a command:

    [/] jms-queue --help --commands
    add
    add-jndi
    ...

To undeploy an application:

    [/] undeploy my-app-name.war

Execute a series of commands as a batch/atomically:

    [/] batch
    # do stuff
    [/] run-batch

## Messaging (Artemis/EAP 7)

Messaging requires running EAP with the `full` profile - even for clients, as the profile configures a connection factory. The broker will write this log line on startup:

    AMQ221007: Server is now live
    AMQ221001: Apache ActiveMQ Artemis Message Broker version 1.5.5.008-redhat-1 [default, nodeID=xxxx-xxx....]

Backup brokers will write this on startup:

    [org.apache.activemq.artemis.core.server] (Thread-1 (ActiveMQ-server-org.apache.activemq.artemis.core.server.impl.ActiveMQServerImpl$3@49a26cdf)) AMQ221031: backup announced

If an embedded Artemis server isn't needed, then just remove the configuration section from the `messaging-activemq` module.

To configure messaging in EAP 7 (Artemis):

1. Define connection factories, connectors and acceptors
2. Define destination topics and queues - either durable or non-durable
3. Configure Artemis features, e.g. security, persistence, etc.

### Configuration

A message broker will be started if the following exists in EAP's XML config file (`domain.xml` or `standalone.xml`):

```xml
<subsystem xmlns="urn:jboss:domain:messaging-activemq:2.0">
    <server name="default">
    </server>
</subsystem>
```

### Connectors and acceptors

**Connectors** define how to connect to an Artemis server - and are used by JMS clients:

- `in-vm` connector - for clients inside the same JVM
- `netty` connector - when clients are connecting from a different JVM
- `http` connector - uses `socket-binding="http"`, meaning that communication to the broker happens over HTTP and the default port (8080).

An **acceptor** defines which kind of connections are accepted by Artemis.

### Connection factories

Define connection factories within the `messaging-activemq` subsystem.

- A connection factory is configured with **connectors** - either `in-vm` or `netty`
- A connection factory also specifies **entries** - which are the the name(s) that the CF will register in JNDI

Two connection factories are defined out-of-the-box - one local and one remote:

```xml
<connection-factory name="InVmConnectionFactory"
    entries="java:/ConnectionFactory"
    connectors="in-vm"/>
<connection-factory name="RemoteConnectionFactory"
    entries="java:jboss/exported/jms/RemoteConnectionFactory"
    connectors="http-connector" ha="true"
    block-on-acknowledge="true" reconnect-attempts="-1"/>
```

Remote clients get a reference to a `ConnectionFactory` via JNDI (as long as the JNDI name is bound in the `java:jboss/exported` namespace). Then get the connection factory like this:

```java
Properties env = new Properties();
env.put(Context.PROVIDER_URL, "http-remoting://127.0.0.1:8080");
Context namingContext = new InitialContext(env);
ConnectionFactory connectionFactory =
    (ConnectionFactory) namingContext.lookup("jms/RemoteConnectionFactory");
```

#### Pooled connection factories

- Pooled connection factories are only for **local clients**, not remote clients.
- With a pooled connection factory, once once a client no longer needs a connection, it returns it back to the pool.
- You need to ensure that a pooled connection factory has sufficient connections set, to be able to cater for the MDB instances that will use the connection factory.

To read pooled connection factories:

    [/] /subsystem=messaging-activemq/server=default:read-children-resources(child-type=pooled-connection-factory)

To read connection statistics:

    /deployment=MYDEPLOYMENT.rar/subsystem=resource-adapters/statistics=statistics/connection-definitions=java\:\/myJndiName:read-resource(include-runtime=true)

### Destinations

Destinations are **durable** or **non-durable**.

To create a destination:

    [/] /subsystem=messaging-activemq/server=default/jms-queue=myQueue/:add(
        entries=["queue/myQueue","java:jboss/exported/jms/myQueue"],
        durable=true)
    # OR
    [/] jms-queue add --queue-address=hello.myqueue
        --entries=[hello/myQueue bye/myQueue]
    [/] jms-queue add --queue-address=HelloWorldMDBQueue
        --entries=[queue/HELLOWORLDMDBQueue]
    # AMQ221003: Deploying queue jms.queue.HelloWorldMDBQueue

To update destination policies - e.g. for all queues (`jms.queue.#`):

    [/] /subsystem=messaging-activemq/server=default/address-setting=jms.queue.#:add(
        max-size-bytes=100000,
        address-full-policy=BLOCK)

To view all jms queues and topics:

    [/] /subsystem=messaging-activemq/server=default:read-children-resources(child-type=jms-queue)
    [/] /subsystem=messaging-activemq/server=default:read-children-resources(child-type=jms-topic)

### Disk-based journal

**Journal location:** Normally, ActiveMQ journal files are written to `$JBOSS_HOME/standalone/data`.

**Journal type** can be either:

- Java NIO
- [Linux Asynchronous IO (AIO)][libaio] - can provide better performance than NIO

To **change the location** of the journal file, in `standalone-full.xml`:

- Add a `<path>` entry (below `<extensions>`) and define some path to write to
- Then, in the `messaging-activemq` subsystem, modify the following properties, referencing the paths defined above:
  - `journal-directory`
  - `paging-directory`
  - `large-messages-directory`
  - `bindings-directory`

Reading the settings using the CLI:

    [/] /subsystem=messaging-activemq/server=default:read-children-resources(child-type=path)
    {
        "outcome" => "success",
        "result" => {
            "bindings-directory" => {
                "path" => "activemq/bindings",
                "relative-to" => "jboss.server.data.dir"
            },
            "journal-directory" => {
                "path" => "activemq/journal",
                "relative-to" => "jboss.server.data.dir"
            },
            "large-messages-directory" => {
                "path" => "activemq/largemessages",
                "relative-to" => "jboss.server.data.dir"
            },
            "paging-directory" => {
                "path" => "activemq/paging",
                "relative-to" => "jboss.server.data.dir"
            }
        }
    }

### Quickstart/demo application

Ensure that the server is running with the `full` or `full-ha` profiles and then run:

    $ cd jboss-eap-7.1.0.GA-quickstarts/helloworld-mdb
    $ mvn clean wildfly:deploy \
        -Dwildfly.host=localhost \
        -Dwildfly.port=9992

And create the jms queue:

    [/] jms-queue add --queue-address=HelloWorldMDBQueue --entries=[queue/HELLOWORLDMDBQueue]

### Security

#### Local in-vm connections

When connecting to a local broker using the **in-vm** connector, the client will be unauthenticated, and will have permissions to create queues and topics by default.

### High availability

Setting up messaging with high availability:

- Backing up a server can be done using either **replication** or via **shared store**.
    - **Replication** = all data received by the live server is duplicated to the backup. A live and backup pair must be part of a cluster - set this using the `cluster-connection` and `group-name` config attributes.
    - **Shared store** = journal is in a shared location, and the backup server activates if the file lock on the journal is released (by the live server going down)
- A live server can have only one backup server; and a backup server can be owned by only one live server.
- The choice of replication method is set using the CLI in the `ha-policy` configuration element - e.g. `/subsystem=messaging-activemq/server=default/ha-policy=replication-master:add`

Example:

    mkdir $AMQ_DATA
    mkdir -p $AMQ_DATA/bindings
    mkdir -p $AMQ_DATA/journal
    mkdir -p $AMQ_DATA/
    export JBOSS_HOME=/path/to/your/jboss
    export JBOSS_HOME=$(pwd)

    cp -a ./standalone ./broker1
    cp -a ./standalone ./broker2
    rm -rf broker1/data/activemq
    rm -rf broker2/data/activemq
    ./bin/add-user.sh -sc broker1/configuration -a -u 'jeffrey' -p 'jeffrey' -g 'guest'
    ./bin/add-user.sh -sc broker2/configuration -a -u 'jeffrey' -p 'jeffrey' -g 'guest'
    ./bin/standalone.sh -Djboss.node.name=broker1 -Djboss.server.base.dir=$JBOSS_HOME/broker1 -c standalone-full-ha.xml
    ./bin/standalone.sh -Djboss.node.name=broker2 -Djboss.server.base.dir=$JBOSS_HOME/broker2 -Djboss.socket.binding.port-offset=1 -c standalone-full-ha.xml

    ./bin/jboss-cli.sh

    connect broker1:port

    # for shared storage replication
    cd /subsystem=messaging-activemq/server=default
    ./ha-policy=shared-store-master:add(failover-on-server-shutdown=true)
    ./:write-attribute(name=cluster-password,value=letmein)
    ./path=journal-directory:write-attribute(name=relative-to,value=jboss.home.dir)
    ./path=bindings-directory:write-attribute(name=relative-to,value=jboss.home.dir)
    ./path=large-messages-directory:write-attribute(name=relative-to,value=jboss.home.dir)
    ./path=paging-directory:write-attribute(name=relative-to,value=jboss.home.dir)

    reload

    # For broker discovery
    # if there is already a broadcast group defined (bg-group1)
    # then don't add this one as well, or you'll get this error:
    # "more than one servers on the network broadcasting the same node id"
    ./broadcast-group=my-broadcast-group:add(connectors=[http-connector],jgroups-channel=activemq-cluster)
    ./discovery-group=my-discovery-group:add(refresh-timeout=10000,jgroups-channel=activemq-cluster)

    # For static discovery
    /socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=broker-slave:add(host=broker2,port=PORT)
    ./http-connector=broker-slave-connector:add(endpoint=http-acceptor,socket-binding=broker-slave)
    ./discovery-group=dg-group1:remove
    ./cluster-connection=my-cluster:remove
    ./cluster-connection=my-cluster:add(static-connectors=[broker-slave-connector],connector-name=http-connector,cluster-connection-address=jms)

    connect broker2:port

    cd /subsystem=messaging-activemq/server=default
    ./ha-policy=shared-store-slave:add(allow-failback=true)
    ./:write-attribute(name=cluster-password,value=letmein)
    ./path=journal-directory:write-attribute(name=relative-to,value=jboss.home.dir)
    ./path=bindings-directory:write-attribute(name=relative-to,value=jboss.home.dir)
    ./path=large-messages-directory:write-attribute(name=relative-to,value=jboss.home.dir)
    ./path=paging-directory:write-attribute(name=relative-to,value=jboss.home.dir)

    # For static discovery
    /socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=broker-master:add(host=broker1,port=PORT)
    ./http-connector=broker-master-connector:add(endpoint=http-acceptor,socket-binding=broker-master)
    ./discovery-group=dg-group1:remove
    ./cluster-connection=my-cluster:remove
    ./cluster-connection=my-cluster:add(static-connectors=[broker-master-connector],connector-name=http-connector,cluster-connection-address=jms)

    reload

Enable queue statistics on the broker:

    [/] /subsystem=messaging-activemq/server=default:write-attribute(name=statistics-enabled,value=true)
    [/] /subsystem=messaging-activemq/server=default/jms-queue=HelloWorldMDBQueue:read-resource(include-runtime=true)
    [/] /subsystem=messaging-activemq/server=default/jms-queue=HelloWorldMDBQueue:read-attribute(name=messages-added)

### Connecting to a remote broker

For remote clients connecting into **this** broker, there is a preconfigured connection factory named `RemoteConnectionFactory`. Remote clients should look up this connection factory using JNDI name `jms/RemoteConnectionFactory`.

However, for connections **from** applications on an instance **to a remote broker**:

1.  Add a _remote destination outbound socket binding_ (to the remote broker server)
2.  In Artemis configuration, add a new, **remote** HTTP connector which points to the same port as the remote server's _http-acceptor_.
3.  Also in Artemis configuration, create a new pooled connection factory which uses the new remote HTTP connector, and exports a JNDI name that can be used by your app.

**Configuration steps:** start EAP using the `full` or `full-ha` profiles (because this deploys the required resource adapter), and configure using the CLI:

    # Start the client
    $ ./bin/standalone.sh -Djboss.node.name=clientapp -Djboss.server.base.dir=$JBOSS_HOME/clientapp -Djboss.socket.binding.port-offset=2 -c standalone.xml
    $ ./bin/add-user.sh -sc broker2/configuration -a -u 'jeffrey' -p 'jeffrey' -g 'guest'
    $ ./bin/jboss-cli.sh

    [/] connect <client app host>:<client app port>
    [/] /socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=remote-server:add(host=localhost,port=8080)
    {"outcome" => "success"}
    [/] /subsystem=messaging-activemq/server=default/http-connector=remote-http-connector:add(socket-binding=remote-server,endpoint=http-acceptor)
    [/] /subsystem=messaging-activemq/server=default/pooled-connection-factory=remote-artemis:add(connectors=[remote-http-connector],entries=[java:/jms/remoteCF],user=MYUSERNAME,password=MYPASSWORD,ha=true)
    [/] /:reload

To manually update the credentials for the pooled CF:

    [/] /subsystem=messaging-activemq/server=default/pooled-connection-factory=remote-artemis:write-attribute(name=user,value=jeffrey)
    [/] /subsystem=messaging-activemq/server=default/pooled-connection-factory=remote-artemis:write-attribute(name=password,value=jeffrey)

When a backup server becomes live, it will throw this into the logs:

    INFO  [org.apache.activemq.artemis.core.server] (AMQ119000: Activation for server ActiveMQServerImpl::serverUUID=null) AMQ221037: ActiveMQServerImpl::serverUUID=1faab8b5-9176-11e7-998f-e315f7e56406 to become 'live'
    INFO  [org.apache.activemq.artemis.core.server] (AMQ119000: Activation for server ActiveMQServerImpl::serverUUID=null) AMQ221007: Server is now live


#### Specifying config in an application

An MDB will try to use the default JMS connection factory (defined by `jms-connection-factory="java:jboss/DefaultJMSConnectionFactory"`). This means that one `pooled-connection-factory` must export `java:jboss/DefaultJMSConnectionFactory` as a JNDI entry. To use a different connection factory, specify it in the application itself.

You can explicitly **specify the name of the resource adapter** that the application will use. First add this dependency to your project's POM:

```xml
<dependency>
    <groupId>org.jboss.ejb3</groupId>
    <artifactId>jboss-ejb3-ext-api</artifactId>
    <scope>provided</scope>
</dependency>
```

Then add this annotation to the MDB class:

```java
import org.jboss.ejb3.annotation.ResourceAdapter;

@ResourceAdapter("remote-artemis")...
```

**Remote broker credentials** can be explicitly specified by adding these annotations to an MDB class:

```java
@MessageDriven(name = "HelloWorldQueueMDB", activationConfig = {
  @ActivationConfigProperty(propertyName = "user", propertyValue = "myuser"),
  @ActivationConfigProperty(propertyName = "password", propertyValue = "mypassword"),... }
public class MyMDBClass implements MessageListener { ... }
```

For ad-hoc (non-MDB) JMS connections, use `@JMSConnectionFactory` annotation to **specify the connection factory** that the JMS context will use:

```java
@Inject
@JMSConnectionFactory("java:/jms/remoteCF")
@JMSPasswordCredential(userName="jeffrey",password="jeffrey")
private JMSContext context;
```

Queues and topics may need to be created first before deploying.

### Messaging cookbook

To add a connection factory using the CLI:

    $ ./connection-factory=MyConnectionFactory:add(
        entries=["java:/MyCF"],
        failover-on-server-shutdown=true,
        call-timeout=10000,
        connector={"netty"=>{....}}
    )

Read all _runtime queues_:

    [/] /subsystem=messaging-activemq/server=default/runtime-queue=*:read-resource

With statistics enabled, read the number of messages added to a queue:

    /subsystem=messaging-activemq/server=default \
      /jms-queue=HelloWorldMDBQueue:read-attribute(name=messages-added)

    /subsystem=messaging-activemq/server=default \
      /jms-queue=HelloWorldMDBQueue:read-resource(include-runtime=true)

    /subsystem=messaging-activemq/server=default \
      /runtime-queue=jms.queue.HelloWorldMDBQueue:read-resource(include-runtime=true)

And if running in domain mode:

    /host=myhost/server=myserver/subsystem=messaging-activemq/ \
      server=default/jms-queue=HelloWorldMDBQueue:read-attribute(name=messages-added)

### Gotchas/issues

- If HA configuration is done once a broker has already started, then the second broker will have the same _node ID_ as the first broker. Reset the second broker's _node ID_ by deleting the `data/activemq` directory.

- If running multiple domains within the same network (or on the same host), make sure to set `jboss.default.multicast.address` to something unique for each domain, or else servers from different domains will attempt to form a combined cluster. Set this by a `system-property`, for example.

## Message-Driven Beans (MDBs)

To stop message delivery to an MDB:

    /deployment=jboss-helloworld-mdb.war/subsystem=ejb3/ \
        message-driven-bean=HelloWorldQueueMDB:stop-delivery

## Security

Defining users:

- Management users are defined in `mgmt-users.properties`
- Application users are defined in `application-users.properties`

In domain mode:

- Management realm is configured in `host.xml` - i.e. host -> domain -> management -> security-realms -> `ManagementRealm`.
- Application realm is configured in `domain.xml` - elytron subsystem -> security-realms -> property-realm name=`ApplicationRealm`.

### Setting up Vault

To set up Vault (to store sensitive values):

    $ mkdir vault
    $ keytool -genseckey -alias vault -storetype jceks \
        -keyalg AES -keysize 128 \
        -storepass secret -validity 365 \
        -keystore $JBOSS_HOME/vault/vault.keystore

    $ ./bin/vault.sh \
        --keystore $JBOSS_HOME/vault/vault.keystore \
        --keystore-password secret \
        --alias vault \
        --vault-block vb \
        --attribute MY_THING_TO_STORE \
        --sec-attr MY_SECRET_VALUE \
        --enc-dir $JBOSS_HOME/vault/ \
        --iteration 120 \
        --salt wi2kd91s

Now configure EAP to use Vault - for **standalone mode**:

    [/] /core-service=vault:add(vault-options=[("KEYSTORE_URL" => "/Users/tdonohue/Documents/servers/eap71/jboss-eap-7.1/vault/vault.keystore"),("KEYSTORE_PASSWORD" => "MASK-Ad9wVS4K6KH"),("KEYSTORE_ALIAS" => "vault"),("SALT" => "wi2kd91s"),("ITERATION_COUNT" => "120"),("ENC_FILE_DIR" => "/Users/tdonohue/Documents/servers/eap71/jboss-eap-7.1/vault/")])

Reference a value from vault using:

    ${VAULT::blockname::MY_THING_TO_STORE::1}

### Securing the HTTP interface with TLS

First, create a keystore, private key and certificate:

    $ keytool -genkeypair -alias localhost \
        -keyalg RSA -keysize 1024 -validity 365 \
        -keystore $JBOSS_HOME/myserver1/keystore.jks \
        -dname "CN=localhost" \
        -keypass secret -storepass secret

#### EAP 7 with Elytron

    [/] connect
    [/] /subsystem=elytron/key-store=httpsKS:add(path=keystore.jks, relative-to=jboss.server.base.dir, credential-reference={clear-text=secret}, type=JKS)
    [/] /subsystem=elytron/key-manager=httpsKM:add(key-store=httpsKS, algorithm="SunX509", credential-reference={clear-text=secret})
    [/] /subsystem=elytron/server-ssl-context=httpsSSC:add(key-manager=httpsKM, protocols=["TLSv1.2"])

    # Remove reference to legacy security realm, add Elytron ssl-context
    [/] /subsystem=undertow/server=default-server/https-listener=https:read-attribute(name=security-realm)
    [/] batch
    [/ #] /subsystem=undertow/server=default-server/https- listener=https:undefine-attribute(name=security-realm)
    [/ #] /subsystem=undertow/server=default-server/https- listener=https:write-attribute(name=ssl-context, value=httpsSSC)
    [/] run-batch
    [/] /:reload

#### EAP 7.0 and earlier (legacy)

In **domain mode** - update Undertow to serve on HTTPS port and update Remoting to HTTPS too:

    $ mkdir $JBOSS_HOME/domain/configuration/keys
    $ cp server.ks $JBOSS_HOME/domain/configuration/keys/

    /host=master/core-service=management/security-realm=HTTPSRealm:add
    /host=master/core-service=management/security-realm=HTTPSRealm/server-identity=ssl:add(keystore-path=keys/server.ks,keystore-relative-to=jboss.server.config.dir,keystore-password=changeit,alias=server)

    # add HTTPS listener
    /profile=full/subsystem=undertow/server=default-server/https-listener=https:add(socket-binding=https,security-realm=HTTPSRealm)

    # remove HTTP port
    /profile=full/subsystem=undertow/server=default-server/http-listener=default:remove

    # update remoting to use HTTPS
    /profile=full/subsystem=remoting/http-connector=http-remoting-connector:write-attribute(name=connector-ref,value=https)

    /server-group=main-server-group:reload-servers
    /server-group=other-server-group/:reload-servers

With the above, note that:

- `alias=server` should point to the alias of the certificate inside the keystore

This will give the following configuration in `host.xml`:

    <security-realm name="HTTPSRealm">
        <server-identities>
            <ssl>
                <keystore path="keys/server.ks" relative-to="jboss.domain.config.dir" keystore-password="changeit" alias="server"/>
            </ssl>
        </server-identities>
    </security-realm>

### Securing the messaging transport with TLS

Follow the instructions above to set up the HTTPS port. Then update the broker to serve on the HTTPS port:

    cd /subsystem=messaging-activemq/server=default
    ./
    ./http-acceptor=http-acceptor:write-attribute(name=http-listener,value=https)
    ./http-acceptor=http-acceptor-throughput:write-attribute(name=http-listener,value=https)
    ./http-connector=http-connector:write-attribute(name=socket-binding,value=https)
    ./http-connector=http-connector-throughput:write-attribute(name=socket-binding,value=https)

    # if using TCP (static discovery)
    ./http-connector=broker-slave-connector:add(socket-binding=broker-slave, endpoint=http-acceptor)

    /socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=broker-slave-ssl:add(host=HOSTNAME,value=8443)
    ./http-connector=broker-slave-connector:write-attribute(name=socket-binding,value=broker-slave-ssl)
    ./http-connector=broker-slave-connector:map-put(name=params,key=ssl-enabled,value=true)
    ./http-connector=broker-slave-connector:map-put(name=params,key=trust-store-path,value=/Users/tdonohue/Documents/servers/eap71/jboss-eap-7.1/broker1/client.jceks)
    ./http-connector=broker-slave-connector:map-put(name=params,key=trust-store-password,value=secret)
    ./http-connector=broker-slave-connector:map-put(name=params,key=trust-store-provider,value=JCEKS)

    reload

And update the client(s):

    $ keytool -genkeypair -alias localhost \
        -keyalg RSA -keysize 1024 -validity 365 \
        -keystore $JBOSS_HOME/clientapp/keystore.jks \
        -dname "CN=localhost" \
        -keypass secret -storepass secret
    $ keytool -export -alias localhost \
        -keystore $JBOSS_HOME/broker1/server.jks \
        -file server_cert \
        -storepass secret -keypass secret
    $ keytool -import -alias server \
        -keystore $JBOSS_HOME/clientapp/client.ts \
        -file server_cert \
        -storepass secret -noprompt

    $ ./bin/jboss-cli.sh

    [/] connect localhost:9992

    [/] /socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=remote-server:write-attribute(name=port,value=8443)
    [/] /subsystem=messaging-activemq/server=default/http-connector=remote-http-connector:map-put(name=params,key=ssl-enabled,value=true)
    # truststore and password need to be set as params
    [/] /subsystem=messaging-activemq/server=default/http-connector=remote-http-connector:map-put(name=params,key=trust-store-path,value=/Users/tdonohue/Documents/servers/eap71/jboss-eap-7.1/clientapp/client.ts)
    [/] /subsystem=messaging-activemq/server=default/http-connector=remote-http-connector:map-put(name=params,key=trust-store-password,value=secret)
    [/] reload

And to remove SSL config from the `http-connector` (if no longer needed):

    [/] connect clientapp:port
    [/] /socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=remote-server:write-attribute(name=port,value=8080)
    [/] /subsystem=messaging-activemq/server=default/http-connector=remote-http-connector:map-remove(key=ssl-enabled,name=params)
    [/] /subsystem=messaging-activemq/server=default/http-connector=remote-http-connector:map-remove(key=trust-store-path,name=params)
    [/] /subsystem=messaging-activemq/server=default/http-connector=remote-http-connector:map-remove(key=trust-store-password,name=params)

### Adding client authentication

To add client authentication to a broker pair, add `needs-client-auth` to its `remote-connector` and ensure that the other broker's certificate has been added into the default trust store, or that a trust store is explicitly configured.

    <remote-acceptor name="remote-acceptor" socket-binding="artemis-ssl">
        <param name="ssl-enabled" value="true"/>
        <param name="key-store-path" value="${keystore.path}"/>
        <param name="key-store-password" value="${keystore.password}"/>
        <param name="key-store-provider" value="${keystore.provider:JKS}"/>
        <!-- Explicit trust store settings required, or it'll use the default cacerts to verify the client -->
        <param name="trust-store-path" value="${truststore.path}"/>
        <param name="trust-store-password" value="${truststore.password}"/>
        <param name="trust-store-provider" value="${truststore.provider:JKS}"/>
        <param name="needs-client-auth" value="true"/>
    </remote-acceptor>

As always, use the `-Djavax.net.debug=ssl,handshake` JVM property to see logs: see whether the client is using the correct truststore, and also see the list of acceptable certificates that the server presents at the start of the handshake.

### Single Sign-on with Kerberos

Here is an example _security-domain_ that can be used for SSO with Kerberos:

```xml
<security-domain name="host" cache-type="default">
    <authentication>
        <login-module code="Kerberos" flag="required">
            <module-option name="debug" value="true"/>
            <module-option name="storeKey" value="true"/>
            <module-option name="refreshKrb5Config" value="true"/>
            <module-option name="useKeyTab" value="true"/>
            <module-option name="doNotPrompt" value="true"/>
            <module-option name="keyTab" value="/tmp/spnego-demo-testdir/http.keytab"/>
            <module-option name="principal" value="HTTP/localhost@JBOSS.ORG"/>
        </login-module>
    </authentication>
</security-domain>
```

### Troubleshooting SSL issues

Enable SSL debug logging by adding this to `domain.conf` or `standalone.conf`:

    JAVA_OPTS="$JAVA_OPTS -Djavax.net.debug=ssl,handshake"

If seeing "unable to find valid certification path to requested target" in the logs:

- If using self-signed certificates, remember a broker must also trust its own certificate, so make sure the certificate is added into the truststore.

## Clustering

JGroups is used for clustering.

### Troubleshooting

For Artemis clustering, watch for the following entries in the logs, which will show when new members join the JGroups cluster:

    2018-10-04 08:59:22,803 INFO  [org.infinispan.remoting.transport.jgroups.JGroupsTransport] (thread-2) ISPN000094: Received new cluster view for channel ejb: [host0:browser-one|1] (2) [host0:browser-one, host1:browser-two]
    2018-10-04 08:59:22,803 INFO  [org.infinispan.remoting.transport.jgroups.JGroupsTransport] (thread-2) ISPN000094: Received new cluster view for channel ejb: [host0:browser-one|1] (2) [host0:browser-one, host1:browser-two]

If running multiple domains on the same host, or multiple clusters, make sure that an independent multicast address is set (or machines across domains will try and form a cluster together):

    <server-group name="app-server-group" profile="full-ha">
        ...
        <system-properties>
            <property name="jboss.default.multicast.address" value="230.0.2.4" boot-time="true"/>
        </system-properties>
    </server-group>

## Upgrades

### EAP 6 to EAP 7

Major changes from EAP 6 to EAP 7:

- _web_ (JBoss Web) subsystem replaced by _undertow_
- _jgroups_ now uses `private` instead of `public` interface
- _messaging_ (HornetQ) subsystem replaced by _messaging-activemq_ (Artemis)
- The number of exposed ports is lower, as all services are multiplexed (using _HTTP upgrade_) on port 8080, with management on 9990.
- Default EJB remoting is now over HTTP, so use `http-remoting://` rather than `remote://`
- Elytron security subsystem, new in EAP 7.1
- Java EE 8 support in EAP 7.2

Unsupported features lists:

- EAP 7.0: https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.0/html-single/7.0.0_release_notes/#release_notes_unsupported_and_deprecated_functionality
- EAP 7.1: https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/html-single/7.1.0_release_notes/#unsupported_and_deprecated_functionality
- EAP 7.2: https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.2/html-single/7.2.0_release_notes/index#unsupported_and_deprecated_functionality


## Monitoring

### Monitoring with JVisualVM

- For monitoring / threads / sampling / profiling
- A valid management user is required
- Run JVisualVM using this script: <https://github.com/johnaohara/jboss-as-tool-integration/blob/master/visualvm/visualvm.sh>
- EAP 7: connect to `service:jmx:remote+http://jbosshost:9990`

### JMX with JConsole

Run JConsole as normal, then you can find some useful stats as follows:

| Area      | Where to find     |
| --------- | ----------------- |
| MDBs      | `jboss.as` &rarr; (deployment name) &rarr; `ejb3` &rarr; (MDB name) &rarr; Attributes. <br/> Shows `poolCurrentSize`, `poolMaxSize`, etc. |
| Messaging | `jboss.as` &rarr; `messaging-activemq` &rarr; `default` &rarr; (queue name) &rarr; Attributes. <br/> Shows `consumerCount`, `messageCount`, etc. |

### Monitoring EJBs

**To monitor an MDB in JConsole:** Browse to the MDB &rarr; inspect `poolCurrentSize`, `poolMaxSize`, etc.

View stats on all MDBs:

    /subsystem=ejb3:read-resource(recursive=true,include-runtime=true,include-defaults=true)

To get `pool-available-count` (max number of MDB instances that can be created) using the CLI:

    /deployment=MYDEPLOYMENT.war/subsystem=ejb3/ \
        message-driven-bean=MyMDBName:read-resource(include-runtime=true)
    {
        "outcome" => "success",
        "result" => {
            ...
            "pool-available-count" => 16,
    }

## Performance and tuning

### MDB tuning

- An MDB will create 15 consumers (JCA RA sessions) to a queue by default; this is because the default for the `maxSession` `@ActivationConfigProperty` is 15.
- MDB pool size and `maxSession` are related. Example: if an MDB pool is 250 and `maxSession` is 250, there will be a pool size of 250 and 250 consumers on the queue.
- Ensure that `maxSession <= MDB max-pool-size`, so that there are always enough MDB instances to service the JMS session listeners. If there are more sessions than instances in the pool, the sessions could be idle, waiting for bean instances to become available.
- `derive-size` in a Strict Max Pool can be set to:
  - `from-worker-pools` which equals the thread size (cores * 8)
  - `from-cpu-count` which is set to the number of CPUs

To **change** the default MDB instance pool:

    /subsystem=ejb3:write-attribute(name=default-mdb-instance-pool, \
        value=my-instance-pool-name)

Change the default (`mdb-strict-max-pool`) pool size, by first undefining the default `derive-size` attribute which sizes the pool based on the number of cores, and then set the max value explicitly:

    /subsystem=ejb3/strict-max-bean-instance-pool=mdb-strict-max-pool \
        :undefine-attribute(name=derive-size)

    /subsystem=ejb3/strict-max-bean-instance-pool=mdb-strict-max-pool \
        :write-attribute(name=max-pool-size,value=7)

    # To effect the changes
    reload

    # The changes will be visible in the pool-available-count attribute
    /deployment=helloworld-mdb-consumer.war/subsystem=ejb3 \
        /message-driven-bean=HelloWorldQueueMDB \
        :read-attribute(name=pool-available-count)
    {
        "outcome" => "success",
        "result" => 7
    }

## Config properties

- `jboss.domain.config.dir`
-

## General troubleshooting

Log categories to turn up:

- `org.apache.activemq.artemis` - for messaging and ActiveMQ
- ``

[libaio]: https://activemq.apache.org/artemis/docs/1.0.0/libaio.html
[maven]: maven.html
