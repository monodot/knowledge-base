---
layout: page
title: ActiveMQ Artemis
---

{% include toc.html %}

## Documentation

- [Artemis 2.6.0 (for AMQ 7.2)][artemis260docs]

## Clients

There are a few different ways that clients can connect to the broker. Java clients can:

- Use [Qpid JMS AMQP client](https://qpid.apache.org/components/jms/index.html) to connect to the broker using **AMQP 1.0**. (Note that _"The details of distributed transactions (XA) within AMQP are not provided in the [1.0 version of the specification](http://www.amqp.org/resources/download)"_ so XA transactions are not currently available when using AMQP)
- Use the [`org.apache.activemq:artemis-jms-client` dependency](https://github.com/apache/activemq-artemis/tree/master/artemis-jms-client) to connect to the broker using the **CORE** protocol.
- Use the old `org.apache.activemq:activemq-client` dependency to connect to the broker using the legacy **OpenWire** protocol.

### Spring Boot

If Spring Boot detects Artemis on the classpath, it will automatically create a connection factory [(see ArtemisXAConnectionFactoryConfiguration @ 1.5.19)][ArtemisXAConnectionFactoryConfiguration].

It will create this connection factory **using some default parameters** - i.e. `localhost` port `61616`. These can be overridden by setting the following properties:

    spring.artemis.mode=native
    spring.artemis.host=192.168.1.210
    spring.artemis.port=9876
    spring.artemis.user=admin
    spring.artemis.password=secret

## Concepts

### Queues and topics

Anycast vs multicast:

- **Anycast** means a **single queue** within the matching address, in a **point-to-point** manner.
- **Multicast** means **every** queue within the matching address, in a **publish-subscribe** manner.


- The address setting `auto-create-jms-queues` configures whether the broker should automatically create a JMS queue when a JMS message is sent to a queue whose name fits the address.

### Durability

- A **durable queue** is a queue which is persisted.
- Messages will survive a server crash or a restart, as long as the messages inside the queues **are also durable**.
- Auto-created queues are **non-durable**.

### Message grouping

**Message grouping** is where all messages for the same message group are sent to the same JMS consumer:

- Useful when you need all messages with a certain grouping to be processed **serially** by the same consumer.
- The JMS property name `JMSXGroupID` is used to identify a message group.
- In a cluster, a **grouping handler** routes messages to the node where the correct consumer is connected.

### Large messages

Large messages are handled differently by the broker:

- Large messages do not count towards a queue size.
- Even if `address-full-policy=BLOCK`, **a producer will not be blocked** from sending large messages. The messages will continue to arrive in the broker's large messages directory (e.g. `data/activemq/largemessages`)
- The threshold for what counts as a large message is set **at connection factory level**.

### Connectivity

- **Connectors** define the transport and parameters used to connect to the messaging server; e.g. `in-vm` connector, `http` connector
- **Acceptors** identify the type of connections accepted by the messaging server; e.g. `http` acceptor

### Bridges

- A **core bridge** connects two instances of Artemis together.
- A core bridge is also created implicitly when creating a **cluster connection** to another node.
- A core bridge isn't the same as a JMS bridge; and it doesn't use the JMS API.
- Core bridges use duplicate detection to guarantee once and only once delivery of messages across the bridge.

### Clustering

- When a node forms a cluster connection to another node, internally it creates a **core bridge** to that node.

### High availability

Failover:

- To properly test failover, you should kill the server abruptly, not gracefully, e.g.: `kill -9 <JAVA_PID>`

Relevant settings:

- `failover-on-shutdown=true` - in a shared-storage topology, this causes failover to be triggered when a server is gracefully shut down
- `check-for-live-server=true` -

## Configuration

### Creating queues and topics

- In Java EE 7, a deployment descriptor can include configuration for queues and topics (`<jms-destination>...</jms-destination>`)

### Configuration in EAP/Wildfly

See the EAP page on this site.

### Destination settings

Address full policy (`address-full-policy`) can be set for a specific destination, or as a wildcard (`#`):

- `PAGE` (default)
- `BLOCK`
- `DROP`

### Logging

Artemis uses JBoss Logging as its logging framework (`org.jboss.logmanager:jboss-logmanager`) and is configured in `logging.properties`, e.g.:

    # Additional logger names to configure (root logger is always configured)
    # Root logger option
    loggers=org.eclipse.jetty,org.jboss.logging,org.apache.activemq.artemis.core.server,org.apache.activemq.artemis.utils,org.apache.activemq.artemis.journal,org.apache.activemq.artemis.jms.server,org.apache.activemq.artemis.integration.bootstrap

    # Root logger level
    logger.level=INFO
    # ActiveMQ Artemis logger levels
    logger.org.apache.activemq.artemis.core.server.level=INFO
    logger.org.apache.activemq.artemis.journal.level=INFO
    logger.org.apache.activemq.artemis.utils.level=INFO
    logger.org.apache.activemq.artemis.jms.level=INFO
    logger.org.apache.activemq.artemis.integration.bootstrap.level=INFO
    logger.org.eclipse.jetty.level=WARN
    # Root logger handlers
    logger.handlers=FILE,CONSOLE

    # Console handler configuration
    handler.CONSOLE=org.jboss.logmanager.handlers.ConsoleHandler
    handler.CONSOLE.properties=autoFlush
    handler.CONSOLE.level=DEBUG
    handler.CONSOLE.autoFlush=true
    handler.CONSOLE.formatter=PATTERN

    # File handler configuration
    handler.FILE=org.jboss.logmanager.handlers.PeriodicRotatingFileHandler
    handler.FILE.level=DEBUG
    handler.FILE.properties=suffix,append,autoFlush,fileName
    handler.FILE.suffix=.yyyy-MM-dd
    handler.FILE.append=true
    handler.FILE.autoFlush=true
    handler.FILE.fileName=${artemis.instance}/log/artemis.log
    handler.FILE.formatter=PATTERN

    # Formatter pattern configuration
    formatter.PATTERN=org.jboss.logmanager.formatters.PatternFormatter
    formatter.PATTERN.properties=pattern
    formatter.PATTERN.pattern=%d %-5p [%c] %s%E%n

## Performance

Potential factors to investigate to improve performance:

Messages being delivered to an address **exceed its configured size**:

- In this instance, the queue will go into **page mode**.
- Page mode is bad for performance, because messages have to be written to disk.
- Once in page mode, a queue stays in that mode until it has been completely emptied.
- Look at `max-size-bytes` to change the queue size in memory.
- Alternatively, look at **blocking producer flow control**: set `address-full-policy=BLOCK` to block producers when `max-size-bytes` is reached.

## Benchmarks

Here are the some sample benchmarks **for message sending** (Camel=>ActiveMQ Artemis), executed in Mar 2020.

This was tested using a Camel on Spring Boot application which receives messages via HTTP (a Servlet) and then publishes the given message onto a queue.  Apache Bench was used to invoke the HTTP endpoint. A local containerised Postgres was used as the JDBC persistent store for Artemis.

This table shows the test results:

| Messages sent  | Size  | Concurrent requests | AMQ Persist. | Run  | Total time | Messages/sec | Mean (iii)   | Max request time |
| -------------- | ----- | ------------------- | ------------ | ---- | ---------- | -------------| ------------ | ---------------- |
| 1,000          | 10kb  | 1                   | File         |      | 3 secs     | 420          |              | 37 ms            |
| 1,000          | 10kb  | 1                   | JDBC         |      | 10 secs    | 101          | 9 ms         | 176 ms           |
| 1,000          | 100kb | 1                   | File         |      | 4 secs     | 271          | 4 ms         | 44 ms            |
| 1,000          | 100kb | 1                   | JDBC         |      | 16 secs    | 61           | 16 ms        | 123 ms           |
| 10,000         | 100kb | 1                   | File         |      | 38 secs    | 256          | 4 ms         | 1059 ms          |
| 10,000         | 100kb | 1                   | JDBC         |      | 259 secs   | 38           | 25 ms        | 2992 ms          |
| 10,000         | 10kb  | 100                 | File         |      | 32 secs    | 312          |              | 1217 ms          |
| 10,000         | 10kb  | 100                 | JDBC         |      | 48 secs    | 205          | 486 ms       | 1159 ms          |
| 10,000         | 100kb | 100                 | File         |      | 34 secs    | 288          | 346 ms       | 1163 ms          |
| 10,000         | 100kb | 100                 | JDBC         |      | 57 secs    | 172          | 579 ms       | 4154 ms          |
| 10,000         | 977K  | 100                 | File         |      | 156 secs   | 64           | 1560 ms (iv) | 15433 ms         |
| 10,000         | 977K  | 100                 | JDBC         |      | 2272 secs  | 4            | 22726 ms     | 66299 ms         |
| 50,000         | 10kb  | 200                 | File         | 1st  | 160 secs   | 312 (i)      |              | 1313 ms          |
|                |       |                     | File         | 2nd  | 177 secs   | 281          | 709 ms       | 1716 ms          |
| 50,000         | 10kb  | 300                 | File         | 1st  | 195 secs   | 256 (ii)     | 1172 ms      | 4340 ms          |
|                |       |                     | File         | 2nd  | 171 secs   | 292          | 1026 ms      | 2189 ms          |
| 10,000         | 10kb  | 1,000               | File         |      | 31 secs    | 316          |              | 4520 ms          |

Notes:

(i) Notice how these tests achieve the same number of messages/sec. This indicates that increasing concurrent requests in the Apache Bench test client had no effect. Possibly my laptop doesn't have enough resources to actually run 200 concurrent requests?

(ii) Decline in performance - possibly because I was restarting IntelliJ at the same time (not a good idea).

(iii) This is the 'Time per request' value from Apache Bench and is the mean time of a request, taking into account that there is concurrency.

(iv) Once the size of the message increases, the mean time starts increasing significantly

Other observations:

- Throughout these tests, the Spring Boot JVM hovered around **90 live threads**.
- The Spring Boot JVM averaged around **30% CPU**.
- The Artemis broker went to **100% CPU**.

Here is an extract from `top` during a test of 50,000 messages with 200 concurrent requests sending 10K, which shows the details for Artemis and Fuse:

      PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
    13775 tdonohue  20   0 8437244 688292  21864 S 105.3   4.2  18:23.80 java (Artemis)
    29153 tdonohue  20   0 7122824 394800  18092 S  30.2   2.4   5:46.77 java (Spring Boot/Fuse)

## Troubleshooting

_"constructor threw exception; nested exception is java.lang.NoClassDefFoundError: javax/json/JsonValue."_ when using the Artemis JMS Client dependency and the Red Hat Fuse Spring Boot BOM:

- The Fuse Spring Boot BOM explicitly excludes the JSON spec from Artemis's dependencies.
- Add the dependency `javax.json:javax.json-api` to your Maven POM.


[ArtemisXAConnectionFactoryConfiguration]: https://github.com/spring-projects/spring-boot/blob/v1.5.19.RELEASE/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/jms/artemis/ArtemisXAConnectionFactoryConfiguration.java
[artemis260docs]: https://activemq.apache.org/components/artemis/documentation/2.6.0
