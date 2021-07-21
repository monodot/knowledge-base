---
layout: page
title: Red Hat AMQ Broker
---

{% include toc.html %}

## Quickstarts

### Running a local standalone broker

Create and run a broker named `mybroker`:

```
cd $AMQ_HOME
./bin/artemis create mybroker
./mybroker/bin/artemis run
```

### Running a local broker with Prometheus java agent

Note there is an Artemis metrics plugin, which uses Micrometer and is a better option than this.

To run an Artemis broker with the Prometheus java agent attached:

```
cd $BROKER_HOME

# Download the Prometheus Java agent
curl -o prometheus.jar -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar

# Add the Javaagent to the Artemis startup args
echo "JAVA_ARGS=\"\$JAVA_ARGS -javaagent:./prometheus.jar=8083:config.yaml\"" >> ./etc/artemis.profile

# Create a basic Prometheus config file
cat << EOF > config.yaml
---
# Source: https://github.com/prometheus/jmx_exporter/blob/master/example_configs/artemis-2.yml
# we don't specify host, port or jmxUrl, so we connect to the local JVM only
lowercaseOutputName: true
lowercaseOutputLabelNames: true
rules:
  - pattern: "^org.apache.activemq.artemis<broker=\"([^\"]*)\"><>([^:]*):\\\s(.*)"
    attrNameSnakeCase: true
    name: artemis_\$2
    type: COUNTER
  - pattern: "^org.apache.activemq.artemis<broker=\"([^\"]*)\",\\\s*component=addresses,\\\s*address=\"([^\"]*)\"><>([^:]*):\\\s(.*)"
    attrNameSnakeCase: true
    name: artemis_\$3
    type: COUNTER
    labels:
        address: \$2
  - pattern: "^org.apache.activemq.artemis<broker=\"([^\"]*)\",\\\s*component=addresses,\\\s*address=\"([^\"]*)\",\\\s*subcomponent=(queue|topic)s,\\\s*routing-type=\"([^\"]*)\",\\\s*(queue|topic)=\"([^\"]*)\"><>([^: ]*):\\\s(.*)"
    attrNameSnakeCase: true
    name: artemis_\$7
    type: COUNTER
    labels:
        address: \$2
        "\$5": \$6
EOF

./bin/artemis run
```

### Deploying AMQ Broker 7.2 on OpenShift

For a quick, demo, **non-persistent broker** (assuming no cluster-admin access):

```
oc new-project myproject
oc replace --force -f \
https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/72-1.2.GA/amq-broker-7-image-streams.yaml
oc import-image amq-broker-72-openshift:1.2
oc process -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/72-1.2.GA/templates/amq-broker-72-basic.yaml \
    -p IMAGE_STREAM_NAMESPACE=$(oc project -q) \
    -p AMQ_USER=admin -p AMQ_PASSWORD=admin | oc apply -f -
```

### Deploying AMQ Broker 7.4 on OpenShift

A demo, non-persistent broker, assuming you don't have cluster-admin access to install image streams into the _openshift_ namespace. Also you'll need to set up authentication to allow OpenShift to pull images from _registry.redhat.io_:

```
oc replace --force -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/74-7.4.0.GA/amq-broker-7-image-streams.yaml

oc process -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/74-7.4.0.GA/templates/amq-broker-74-basic.yaml \
  -p IMAGE_STREAM_NAMESPACE=$(oc project -q) \
  -p AMQ_PROTOCOL=openwire,amqp,stomp,mqtt,hornetq \
  -p AMQ_QUEUES=demoQueue -p AMQ_ADDRESSES=demoTopic \
  -p AMQ_USER=admin -p AMQ_PASSWORD=admin | oc apply -f -
```

### Deploying AMQ Broker 7.6 (persistent, non-clustered, SSL) on OpenShift

About this deployment:

- Creates self-signed broker certificate with a laughable password (which you don't want in production)
- No clustering, so each broker is isolated
- Includes a bit of `jq` to set the _storageClass_ of the VolumeClaimTemplate so that Artemis grabs the correct **type** of storage available (e.g. Amazon EBS or whatever)
- Doesn't use an image stream, it references the image in the Red Hat registry directly.

```
MYPROJECT=amq-demo
BROKER_NAME=mybroker
oc new-project ${MYPROJECT}

# set up the keystore and truststore
keytool -genkey -alias broker -keypass password -keyalg RSA -keystore broker.ks -dname "CN=broker,L=Gimmerton" -storepass password -deststoretype pkcs12
keytool -genkey -alias client -keypass password -keyalg RSA -keystore client.ks -dname "CN=client,L=Gimmerton" -storepass password -deststoretype pkcs12

keytool -export -alias broker -keystore broker.ks -file broker_cert -storepass password
keytool -import -alias broker -keystore client.ts -file broker_cert -storepass password -noprompt

keytool -export -alias client -keystore client.ks -file client_cert -storepass password
keytool -import -alias client -keystore broker.ts -file client_cert -storepass password -noprompt

oc create secret generic ${BROKER_NAME}-app-secret --from-file=broker.ks --from-file=broker.ts -n ${MYPROJECT}

oc process -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/78-7.8.1.GA/templates/amq-broker-78-persistence-clustered-ssl.yaml \
  -p AMQ_NAME=${BROKER_NAME} \
  -p APPLICATION_NAME=${BROKER_NAME} \
  -p AMQ_PROTOCOL=openwire,amqp,stomp,mqtt,hornetq \
  -p AMQ_QUEUES=acme.egg.queue \
  -p AMQ_USER=admin -p AMQ_PASSWORD=morningcoffee \
  -p AMQ_SECRET=${BROKER_NAME}-app-secret \
  -p AMQ_TRUSTSTORE=broker.ts -p AMQ_KEYSTORE=broker.ks \
  -p AMQ_REQUIRE_LOGIN=true \
  -p AMQ_TRUSTSTORE_PASSWORD=password -p AMQ_KEYSTORE_PASSWORD=password

TODO TODO TODO TODO TODO
   \
  | jq ".items[].spec.volumeClaimTemplates[]?.spec.storageClassName = \"my-artemis-ebs-storageclass\"" \
  | jq '(.items[] | select(.kind == "StatefulSet") | .spec.updateStrategy.type) |= "RollingUpdate"' \
  | oc apply -f -

oc scale sts/${BROKER_NAME}-amq --replicas=3
```

Then, to delete:

```
oc delete svc,route -l app=${BROKER_NAME}
oc delete sts -l application=${BROKER_NAME}
oc delete pvc -l app=${BROKER_NAME}-amq
oc delete secret ${BROKER_NAME}-app-secret
```

### Deploying a non-persistent, non-SSL 7.6 broker on OpenShift

```
oc process -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/76-7.6.0.GA/templates/amq-broker-76-basic.yaml \
  -p AMQ_NAME=${BROKER_NAME} -p APPLICATION_NAME=${BROKER_NAME} \
  -p AMQ_PROTOCOL=openwire,amqp,stomp,mqtt,hornetq \
  -p AMQ_QUEUES=acme.egg.queue \
  -p AMQ_USER=admin -p AMQ_PASSWORD=redstarcoffee \
  -p AMQ_REQUIRE_LOGIN=true \
  | oc apply -f -
```

### Deploying a persistent, clustered, 7.8 AMQ broker on OpenShift with templates

```
MYPROJECT=amq-demo
BROKER_NAME=mybroker
oc new-project ${MYPROJECT}

# set up the keystore and truststore
keytool -genkey -alias broker -keypass password -keyalg RSA -keystore broker.ks -dname "CN=broker,L=Gimmerton" -storepass password -deststoretype pkcs12
keytool -genkey -alias client -keypass password -keyalg RSA -keystore client.ks -dname "CN=client,L=Gimmerton" -storepass password -deststoretype pkcs12

keytool -export -alias broker -keystore broker.ks -file broker_cert -storepass password
keytool -import -alias broker -keystore client.ts -file broker_cert -storepass password -noprompt

keytool -export -alias client -keystore client.ks -file client_cert -storepass password
keytool -import -alias client -keystore broker.ts -file client_cert -storepass password -noprompt

oc create secret generic ${BROKER_NAME}-app-secret --from-file=broker.ks --from-file=broker.ts -n ${MYPROJECT}

oc process -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/76-7.6.0.GA/templates/amq-broker-76-persistence-ssl.yaml \
  -p AMQ_NAME=${BROKER_NAME} -p APPLICATION_NAME=${BROKER_NAME} \
  -p AMQ_PROTOCOL=openwire,amqp,stomp,mqtt,hornetq \
  -p AMQ_QUEUES=acme.egg.queue \
  -p AMQ_USER=admin -p AMQ_PASSWORD=redstarcoffee \
  -p AMQ_SECRET=${BROKER_NAME}-app-secret \
  -p AMQ_TRUSTSTORE=broker.ts -p AMQ_KEYSTORE=broker.ks \
  -p AMQ_REQUIRE_LOGIN=true \
  -p AMQ_TRUSTSTORE_PASSWORD=password -p AMQ_KEYSTORE_PASSWORD=password \
  | jq ".items[].spec.volumeClaimTemplates[]?.spec.storageClassName = \"my-artemis-ebs-storageclass\"" \
  | jq '(.items[] | select(.kind == "StatefulSet") | .spec.updateStrategy.type) |= "RollingUpdate"' \
  | oc apply -f -

oc scale sts/${BROKER_NAME}-amq --replicas=3
```

### Running a local 7.2 containerised broker

Running a simple containerised AMQ locally (for demo purposes):

```
podman run --rm --name amq \
  -e AMQ_USER=admin -e AMQ_PASSWORD=admin \
  -d -p 61616:61616 -p 8161:8161 registry.access.redhat.com/amq-broker-7/amq-broker-72-openshift:1.2
```

### Running a local 7.4 containerised broker

Running a 7.4 AMQ broker locally (for demo purposes) (didn't seem to work with podman due to some file system issue which I can't figure out yet...):

```
docker run --rm --name amq74 \
  -e AMQ_USER=admin -e AMQ_PASSWORD=admin \
  -d -p 61616:61616 -p 8161:8161 registry.redhat.io/amq7/amq-broker:7.4
```

### Running a local 7.6 containerised broker

Running AMQ Broker 7.6 locally (for demo purposes):

**NB:** Running `podman` as root, due to some [weird port forwarding issue][podman4935]:

```
sudo podman run --rm --name amq76 \
  -e AMQ_USER=admin -e AMQ_PASSWORD=admin \
  -p 61616:61616 -p 8161:8161 registry.redhat.io/amq7/amq-broker:7.6
```

## Templates and image streams

Details of the AMQ templates and image streams for OpenShift:

Product                    | Templates & Image Streams                                                                                                                                          | Info/notes
-------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------
AMQ 7.4 Interconnect (1.5) | (none)                                                                                                                                                             | Now uses Operators (Interconnect 1.5)
AMQ 7.3 Interconnect (1.3) | [jboss-container-images/amq-interconnect-1-openshift-image#amq-interconnect-1.3][amq-interconnect-1-openshift-image-amq-interconnect-1.3]                          |
AMQ 7.4 Broker             | [Templates](https://github.com/jboss-container-images/jboss-amq-7-broker-openshift-image/tree/74-7.4.0.GA/templates)                                               |
AMQ 7.3 Broker             | [Templates and Image Stream][jboss-amq-7-broker-openshift-image-73-7.3.0.ga] (Templates & Image Stream) / [Image build][jboss-amq-7-broker-image-73] (image build) |
AMQ 7.2 Broker             |

## Configuration

### Sample broker configuration for OpenShift

Here's an AMQ configuration which was generated out-of-the-box when using the AMQ 7.2 image for OpenShift:

```xml
<?xml version='1.0'?>
<!--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

<configuration xmlns="urn:activemq"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xi="http://www.w3.org/2001/XInclude"
               xsi:schemaLocation="urn:activemq /schema/artemis-configuration.xsd">

   <core xmlns="urn:activemq:core" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="urn:activemq:core ">

      <name>broker</name>

      <persistence-enabled>true</persistence-enabled>
      <!-- this could be ASYNCIO, MAPPED, NIO
           ASYNCIO: Linux Libaio
           MAPPED: mmap files
           NIO: Plain Java Files
       -->
      <journal-type>NIO</journal-type>
      <paging-directory>data/paging</paging-directory>
      <bindings-directory>data/bindings</bindings-directory>
      <journal-directory>data/journal</journal-directory>
      <large-messages-directory>data/large-messages</large-messages-directory>
      <journal-datasync>true</journal-datasync>
      <journal-min-files>2</journal-min-files>
      <journal-pool-files>10</journal-pool-files>
      <journal-file-size>10M</journal-file-size>

      <!--
       This value was determined through a calculation.
       Your system could perform 1.14 writes per millisecond
       on the current journal configuration.
       That translates as a sync write every 876000 nanoseconds.

       Note: If you specify 0 the system will perform writes directly to the disk.
             We recommend this to be 0 if you are using journalType=MAPPED and journal-datasync=false.
      -->
      <journal-buffer-timeout>876000</journal-buffer-timeout>

      <!--
        When using ASYNCIO, this will determine the writing queue depth for libaio.
       -->
      <journal-max-io>1</journal-max-io>
      <!--
        You can verify the network health of a particular NIC by specifying the <network-check-NIC> element.
         <network-check-NIC>theNicName</network-check-NIC>
        -->

      <!--
        Use this to use an HTTP server to validate the network
         <network-check-URL-list>http://www.apache.org</network-check-URL-list> -->

      <!-- <network-check-period>10000</network-check-period> -->
      <!-- <network-check-timeout>1000</network-check-timeout> -->

      <!-- this is a comma separated list, no spaces, just DNS or IPs
           it should accept IPV6

           Warning: Make sure you understand your network topology as this is meant to validate if your network is valid.
                    Using IPs that could eventually disappear or be partially visible may defeat the purpose.
                    You can use a list of multiple IPs, and if any successful ping will make the server OK to continue running -->
      <!-- <network-check-list>10.0.0.1</network-check-list> -->

      <!-- use this to customize the ping used for ipv4 addresses -->
      <!-- <network-check-ping-command>ping -c 1 -t %d %s</network-check-ping-command> -->

      <!-- use this to customize the ping used for ipv6 addresses -->
      <!-- <network-check-ping6-command>ping6 -c 1 %2$s</network-check-ping6-command> -->

      <!-- how often we are looking for how many bytes are being used on the disk in ms -->
      <disk-scan-period>5000</disk-scan-period>

      <!-- once the disk hits this limit the system will block, or close the connection in certain protocols
           that won't support flow control. -->
      <max-disk-usage>90</max-disk-usage>

      <!-- should the broker detect dead locks and other issues -->
      <critical-analyzer>true</critical-analyzer>

      <critical-analyzer-timeout>120000</critical-analyzer-timeout>

      <critical-analyzer-check-period>60000</critical-analyzer-check-period>

      <critical-analyzer-policy>HALT</critical-analyzer-policy>

      <!-- the system will enter into page mode once you hit this limit.
           This is an estimate in bytes of how much the messages are using in memory

            The system will use half of the available memory (-Xmx) by default for the global-max-size.
            You may specify a different value here if you need to customize it to your needs.

            <global-max-size>100Mb</global-max-size>

      -->

      <acceptors>

         <!-- useEpoll means: it will use Netty epoll if you are on a system (Linux) that supports it -->
         <!-- amqpCredits: The number of credits sent to AMQP producers -->
         <!-- amqpLowCredits: The server will send the # credits specified at amqpCredits at this low mark -->

         <!-- Note: If an acceptor needs to be compatible with HornetQ and/or Artemis 1.x clients add
                    "anycastPrefix=jms.queue.;multicastPrefix=jms.topic." to the acceptor url.
                    See https://issues.apache.org/jira/browse/ARTEMIS-1644 for more information. -->

         <!-- Acceptor for every supported protocol -->
         <acceptor name="artemis">tcp://0.0.0.0:61616?tcpSendBufferSize=1048576;tcpReceiveBufferSize=1048576;protocols=CORE,AMQP,STOMP,HORNETQ,MQTT,OPENWIRE;useEpoll=true;amqpCredits=1000;amqpLowCredits=300</acceptor>

         <!-- AMQP Acceptor.  Listens on default AMQP port for AMQP traffic.-->
         <acceptor name="amqp">tcp://0.0.0.0:5672?tcpSendBufferSize=1048576;tcpReceiveBufferSize=1048576;protocols=AMQP;useEpoll=true;amqpCredits=1000;amqpLowCredits=300</acceptor>

         <!-- STOMP Acceptor. -->
         <acceptor name="stomp">tcp://0.0.0.0:61613?tcpSendBufferSize=1048576;tcpReceiveBufferSize=1048576;protocols=STOMP;useEpoll=true</acceptor>

         <!-- HornetQ Compatibility Acceptor.  Enables HornetQ Core and STOMP for legacy HornetQ clients. -->
         <acceptor name="hornetq">tcp://0.0.0.0:5445?anycastPrefix=jms.queue.;multicastPrefix=jms.topic.;protocols=HORNETQ,STOMP;useEpoll=true</acceptor>

         <!-- MQTT Acceptor -->
         <acceptor name="mqtt">tcp://0.0.0.0:1883?tcpSendBufferSize=1048576;tcpReceiveBufferSize=1048576;protocols=MQTT;useEpoll=true</acceptor>

      </acceptors>


      <security-settings>
         <security-setting match="#">
            <permission type="createNonDurableQueue" roles="admin"/>
            <permission type="deleteNonDurableQueue" roles="admin"/>
            <permission type="createDurableQueue" roles="admin"/>
            <permission type="deleteDurableQueue" roles="admin"/>
            <permission type="createAddress" roles="admin"/>
            <permission type="deleteAddress" roles="admin"/>
            <permission type="consume" roles="admin"/>
            <permission type="browse" roles="admin"/>
            <permission type="send" roles="admin"/>
            <!-- we need this otherwise ./artemis data imp wouldn't work -->
            <permission type="manage" roles="admin"/>
         </security-setting>
      </security-settings>

      <address-settings>
         <!-- if you define auto-create on certain queues, management has to be auto-create -->
         <address-setting match="activemq.management#">
            <dead-letter-address>DLQ</dead-letter-address>
            <expiry-address>ExpiryQueue</expiry-address>
            <redelivery-delay>0</redelivery-delay>
            <!-- with -1 only the global-max-size is in use for limiting -->
            <max-size-bytes>-1</max-size-bytes>
            <message-counter-history-day-limit>10</message-counter-history-day-limit>
            <address-full-policy>PAGE</address-full-policy>
            <auto-create-queues>true</auto-create-queues>
            <auto-create-addresses>true</auto-create-addresses>
            <auto-create-jms-queues>true</auto-create-jms-queues>
            <auto-create-jms-topics>true</auto-create-jms-topics>
         </address-setting>
         <!--default for catch all-->
         <address-setting match="#">
            <dead-letter-address>DLQ</dead-letter-address>
            <expiry-address>ExpiryQueue</expiry-address>
            <redelivery-delay>0</redelivery-delay>
            <!-- with -1 only the global-max-size is in use for limiting -->
            <max-size-bytes>-1</max-size-bytes>
            <message-counter-history-day-limit>10</message-counter-history-day-limit>
            <address-full-policy>PAGE</address-full-policy>
            <auto-create-queues>true</auto-create-queues>
            <auto-create-addresses>true</auto-create-addresses>
            <auto-create-jms-queues>true</auto-create-jms-queues>
            <auto-create-jms-topics>true</auto-create-jms-topics>
         </address-setting>
      </address-settings>

      <addresses>
         <address name="DLQ">
            <anycast>
               <queue name="DLQ" />
            </anycast>
         </address>
         <address name="ExpiryQueue">
            <anycast>
               <queue name="ExpiryQueue" />
            </anycast>
         </address>

      </addresses>


      <!-- Uncomment the following if you want to use the Standard LoggingActiveMQServerPlugin pluging to log in events
      <broker-plugins>
         <broker-plugin class-name="org.apache.activemq.artemis.core.server.plugin.impl.LoggingActiveMQServerPlugin">
            <property key="LOG_ALL_EVENTS" value="true"/>
            <property key="LOG_CONNECTION_EVENTS" value="true"/>
            <property key="LOG_SESSION_EVENTS" value="true"/>
            <property key="LOG_CONSUMER_EVENTS" value="true"/>
            <property key="LOG_DELIVERING_EVENTS" value="true"/>
            <property key="LOG_SENDING_EVENTS" value="true"/>
            <property key="LOG_INTERNAL_EVENTS" value="true"/>
         </broker-plugin>
      </broker-plugins>
      -->

   </core>
</configuration>
```

## Cookbook

### Adding legacy OpenWire support

Add a dependency on `org.apache.activemq:activemq-client:5.11.0.redhat-xxxxx`:

```xml
<dependency>
  <groupId>org.apache.activemq</groupId>
  <artifactId>activemq-client</artifactId>
  <version>5.11.0.redhat-630329</version>
</dependency>
```

Then:

- Create an `org.apache.activemq.ActiveMQConnectionFactory`
- Configure the Camel JMS component, if needed.

[amq-interconnect-1-openshift-image-amq-interconnect-1.3]: https://github.com/jboss-container-images/amq-interconnect-1-openshift-image/tree/amq-interconnect-1.3
[jboss-amq-7-broker-image-73]: https://github.com/jboss-container-images/jboss-amq-7-broker-image/tree/amq-broker-73
[jboss-amq-7-broker-openshift-image-73-7.3.0.ga]: https://github.com/jboss-container-images/jboss-amq-7-broker-openshift-image/tree/73-7.3.0.GA
[podman4935]: https://github.com/containers/libpod/issues/4935
