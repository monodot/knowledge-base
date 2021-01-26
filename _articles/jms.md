---
layout: page
title: Java Message Service (JMS) API
---

## Transactions

### Acknowledgement

> A message is consumed in three stages:

> 1. The client receives the message.

> 2. The client processes the message.

> 3. The message is acknowledged. Acknowledgment is initiated either by the JMS provider or by the client, depending on the session acknowledgment mode.

-- <https://javaee.github.io/tutorial/jms-concepts004.html#BNCGH>

When you use **transactions**, the acknowledgement happens **when the session is committed**.

- In transacted session, the commit/rollback steps happen server-side.

In **non-transacted sessions**, the acknowledgement depends on how the session has been created:

- `AUTO_ACKNOWLEDGE`

- `CLIENT_ACKNOWLEDGE`

- `DUPS_OK_ACKNOWLEDGE`

### JMS local transactions

> A transaction groups a series of operations into an atomic unit of work. If any one of the operations fails, the transaction can be rolled back, and the operations can be attempted again from the beginning. If all the operations succeed, the transaction can be committed.

-- <https://javaee.github.io/tutorial/jms-concepts004.html#BNCGH>

- To send multiple messages in the same unit of work, use JMS local transactions.

### XA transactions and alternatives

Alternatives to XA transactions:

- Implement duplicate detection on the consumer side

## JMS and Java EE

The standard (recommended?) way to integrate with a message broker from a Java EE application using the JMS API is **with a Resource Adapter (RA)**. This comes with the added benefit of being able to switch the underlying broker, with less effort.
