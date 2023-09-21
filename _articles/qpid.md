---
layout: page
title: Apache Qpid
---

## Qpid JMS Client

[Qpid JMS Client][qpidjms] is a JMS 2.0 client built using Qpid Proton (a messaging library).

Configure `jndi.properties` as required:

```
java.naming.factory.initial = org.apache.qpid.jms.jndi.JmsInitialContextFactory
```

### Cookbook

When testing, you can configure Qpid JMS client to trust all server certificates by adding this to the transport URI (this option exists since Qpid JMS 0.24.0, and probably even earlier than that):

```
?transport.trustAll=true
```

## Qpid Dispatch Router

### Installation

To install using `yum`:

```
yum install qpid-dispatch-router qpid-dispatch-tools
```

To install the examples:

```
yum install python-qpid-proton
```

### Routing mechanisms

The two types of routing mechanism are:

**Message routing** (the default option; used when link routes aren't configured)

- Can be used for messaging between clients (direct-routed messaging) or to/from broker queues (brokered messaging)
- You can use it to shard messages across multiple brokers, as long as delivery order isn't important.
- When configuring message routing via a broker:

  - configure the addresses as _waypoints_
  - create a connection to the broker
  - then, all messages sent to the waypoint address are routed to the broker queue
  - is an autolink needed then? (TODO)

**Link routing** is like _"a "virtual connection" or "tunnel" that travels from a sender, through the router network, to a receiver."_:

- Provides a tight association between endpoints - i.e. messages flowing over a link will always go from same producer to same consumer (no load balancing)
- Use when you need sharding across multiple brokers, with guaranteed delivery order.
- Use when you need **transactional messaging** (although no distributed transaction support is available though). This is because the routers can't handle transactions themselves - see the error _"The router can't coordinate transactions by itself, a linkRoute to a coordinator must be configured to use transactions"_.
- The routers don't take part in distributing messages, they just pass the messages (and any settlement) between the two endpoints - kind of like a tunnel.

### Links and Autolinks

Client links - when a consumer simply connects to a router:

- A Connection is created - if the client is consuming messages, then from the router's perspective this is an "outbound" connection
- Within the Connection, there is a Link for the AMQP Address which is being consumed over that Connection, e.g.:

  - Link: type=endpoint, Address=my.incoming.address, Settle rate=0, etc.

**Autolinks**:

- Autolinks are required if the router needs to initiate a sending or receiving link, because the other party can't do it itself. This includes AMQ/Artemis brokers, because they can't (yet) initiate their own outbound links to the routers.
- An autolink basically mimics a broker connecting to the routing network itself, and advertising that it is a destination for certain addresses.
- An autolink configures a "mobile address" for a queue on the broker - in other words, it creates an address for queue `a.b.c` and propagates it around the network so that the routers know about it.

### Waypoints

- A waypoint is a special type of `address` which identifies a queue on a broker to which you want to route messages.
- A waypoint address identifies the queue, and then an `autoLink` is required to connect a router to the broker.

Example:

```
address {
    prefix: mycompany.finance
    waypoint: yes
}

autoLink {
    addr: mycompany.finance    # the address of the broker queue
    direction: in              # RECEIVES messages from the broker queue
    connection: my_conn
}
```

### Connectors

Connectors are outbound connections to other brokers (or AMQP entities), and can be of different types:

- **route-container** - is a connection to a broker, or a resource that holds known addresses.
- **inter-router** - is a connection to another router in the network.

Example:

```
connector {
    name: MyLocalBroker
    host: broker-amq-amqp
    port: 5672
    role: route-container
    saslMechanisms: plain
    saslUsername: amq-demo-user
    saslPassword: password
}
```

### Example - address-level authorization to access queues on Artemis

- Populate a SASLDB file containing users.
- Configure Qpid Dispatch Router with `policy` and `vhost` blocks.
- Configure role-level access in the Artemis broker
- Add users to roles in Artemis

First, **populate a SASLDB file** which Qpid Dispatch Router will use to authenticate the user against:

```
echo madge | saslpasswd2 -c -p -u router-mesh madge -f sasl2/qdrouterd.sasldb
echo harold | saslpasswd2 -c -p -u router-mesh harold -f sasl2/qdrouterd.sasldb
```

**Configure Qpid Dispatch Router**. This adds a vhost policy which restricts access to certain addresses, and also connects to the broker as a static `router`/`router` user:

```
router {
    mode: interior
    id: myrouter
    saslConfigDir: /home/tdonohue/qpid-demo/sasl2/
}

listener {
    host: 0.0.0.0
    port: 15672
    role: normal
}
listener {
    host: 0.0.0.0
    port: 8080
    role: normal
    http: true
    authenticatePeer: true
}
listener {
    host: 0.0.0.0
    port: 5671
    role: normal
}
listener {
    name: health-and-stats
    port: 8888
    http: true
    healthz: true
    metrics: true
    websockets: false
    httpRootDir: invalid
}

listener {
    role: edge
    host: 0.0.0.0
    port: 45672
}

address {
    prefix: closest
    distribution: closest
}
address {
    prefix: multicast
    distribution: multicast
}
address {
    prefix: unicast
    distribution: closest
}
address {
    prefix: exclusive
    distribution: closest
}
address {
    prefix: broadcast
    distribution: multicast
}

linkRoute {
    prefix: logistics
    direction: in
    connection: my-broker
}
linkRoute {
    prefix: logistics
    direction: out
    connection: my-broker
}

connector {
    name: my-broker
    host: localhost
    port: 5672
    role: route-container
    verifyHostname: false
    # adding explicit credentials here to authenticate to the broker
    saslUsername: router
    saslPassword: router
}

log {
    module: DEFAULT
    enable: info
    includeTimestamp: yes
}

# Dispatch Router provides a policy mechanism that you can use to enforce user connection restrictions and AMQP resource access control.
# You must enable the router to use vhost policies before you can create the policies.
policy {
    enableVhostPolicy: true
    enableVhostNamePatterns: true
    defaultVhost: $default
}

vhost {
    hostname: localhost
    maxConnectionsPerUser: 10
    allowUnknownUser: false
    groups: {
        admin: {
            users: admin@router
            remoteHosts: *
            sources: *
            targets: *
            allowAnonymousSender: true
            allowDynamicSource: true
        }
        madge: {
            users: madge@router-mesh
            remoteHosts: *
            sources: logistics.madge
            targets: logistics.madge
        }
        harold: {
            users: harold@router-mesh
            remoteHosts: *
            sources: logistics.harold
            targets: logistics.harold
        }
        $default: {
            remoteHosts: *
        }
    }
}
```

**Add a `security-setting`** block into Artemis configuration:

```
<security-settings>
   ...
   <security-setting match="logistics.#">
      <permission type="consume" roles="amq,router"/>
      <permission type="browse" roles="amq,router"/>
      <permission type="send" roles="amq,router"/>
      <permission type="manage" roles="amq,router"/>
   </security-setting>
</security-settings>
```

In `artemis-roles.properties`, **define the users who should be part of the `router` group**:

```
amq = dave
admin = susan
router = router
```

Now you can connect to the router using `amqp://localhost:15672`, user `harold@router-mesh`, password `harold`, and be allowed to send/receive from the address `logistics.harold`.

## Troubleshooting

Can't access the Interconnect web console:

- Check that a NetworkPolicy is not blocking traffic into the namespace (if running on OpenShift)
- Check that vhost policies are not preventing login to the web console. Make sure that `allowAnonymousSender: true` and `allowDynamicSource: true` are set.

[qpidjms]: https://qpid.apache.org/components/jms/index.html
