---
layout: page
title: ActiveMQ
---

This page is about the legacy ActiveMQ (ActiveMQ Classic / 5.x).

## Developing

### Embedded ActiveMQ broker using VM transport

To create an embedded ActiveMQ broker with no persistence (for testing), just set your client connection factory's _brokerURL_ to this:

    vm://localhost?broker.persistent=false

## JDBC message store

The JDBC message store consists of three tables:

- `ACTIVEMQ_ACKS`
- `ACTIVEMQ_LOCK` - ensures that only one broker can access the database at one time
- `ACTIVEMQ_MSGS`

## Troubleshooting

Spring Boot: _"Error creating bean with name 'cachingJmsConnectionFactory'"_ due to _"java.lang.ClassNotFoundException: javax.jms.JMSContext"_:

- Spring Boot is trying to do something with the JMS 2.0 API (`JMSContext` is part of JMS 2)
- Migrate to Artemis or override Spring Boot's autoconfiguration.
