---
layout: page
title: Message-Driven Beans (MDBs)
---

## Lifecycle of an MDB

When a message arrives into a queue, the container retrieves it, starts a transaction, and assigns a MDB instance from the pool to service it. 

The sequence of events is as follows:

1.  A message is delivered to a JMS session listener
2.  An idle MDB is pulled out of the pool.
3.  The `MessageDrivenContext` is injected into the bean
4.  The container executes the `onMessage` method of the bean, passing in the actual message.
5.  When the `onMessage` method finishes executing, the bean is pushed back into the _idle-ready_ pool.

Specifying a `minSession` config property means that the application server should ensure that there are always the given number of instances of the MDB in the pool, in the **method-ready state**.

## Key facts about MDBs

> In a **queue-based JMS application** (point-to-point model), each MDB instance has its own (JMS) session.

> In a **topic-based JMS application** (the publish/subscribe model), all local instances of an MDB share a JMS session. A given message is distributed to multiple MDBs—one copy to each subscribing MDB. If multiple MDBs are deployed to listen on the same topic, then each MDB receives a copy of every message. A message is processed by one instance of each MDB that listens to the topic.

-- <https://docs.oracle.com/html/E13719_01/message_beans.htm>


