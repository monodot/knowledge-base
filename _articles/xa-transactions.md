---
layout: page
title: XA transactions
---

## Alternatives to XA

- message deduplication (e.g. Camel Idempotent Consumer)
- Change Data Capture?

## Cookbook

### XA transactions with Oracle AQ and Camel on Spring Boot

Here's how to configure a Camel JMS component wrapping Oracle AQ, to work with XA transactions, on Spring Boot:

- First add a transaction manager, such as Narayana - easily done with the [Narayana for Spring Boot][narayana-spring-boot] starter dependency. Narayana will implement the JTA (`TransactionManager`) and Spring (`PlatformTransactionManager`) transaction manager interfaces.

- Add a generic, auto-enlisting, pooled connection factory such as **pooled-jms** from **messaginghub**. This will enlist the Oracle XA resource in the transaction.

```java
@Bean(name = "oracleaq")
JmsComponent oracleAQJmsComponent(org.springframework.transaction.PlatformTransactionManager transactionManager,
                                  javax.transaction.TransactionManager jtaTransactionManager)
        throws JMSException, SQLException {
    oracle.jdbc.xa.client.OracleXADataSource oracleXADataSource = new OracleXADataSource();
    oracleXADataSource.setURL("jdbc:oracle:thin:@localhost:1521:ORCLCDB");
    oracleXADataSource.setUser("scott");
    oracleXADataSource.setPassword("tiger");

    // Now we've created the XA datasource, we need something that will generate an XAConnection for us. A factory, perhaps!
    // Oracle client has a curious static method to do this.
    javax.jms.XAConnectionFactory oracleXACF = oracle.jms.AQjmsFactory.getXAConnectionFactory(oracleXADataSource);

    // Presumably this is a non-enlisting XAConnectionFactory.
    // So we need to wrap it in an enlisting connection factory?
    // Similar to: https://access.redhat.com/documentation/en-us/red_hat_fuse/7.2/html-single/apache_karaf_transaction_guide/index#manual-deployment-connection-factories
    org.messaginghub.pooled.jms.JmsPoolXAConnectionFactory pooledJmsXACF = new JmsPoolXAConnectionFactory();
    pooledJmsXACF.setConnectionFactory(oracleXACF);
    pooledJmsXACF.setTransactionManager(jtaTransactionManager); // Narayana implementing the JTA interface

    // Now create a Camel JMS component and wire in the enlisting connection factory and Narayana
    org.apache.camel.component.jms.JmsComponent jms = new JmsComponent();
    jms.setConnectionFactory(pooledJmsXACF);
    jms.setTransactionManager(transactionManager); // again Narayana, implementing the Spring interface
    jms.setTransacted(false);

    return jms;
}
```

When this is run with the Byteman rules (see below), this should happen in the logs (this is an example transaction with Oracle AQ, Postgresql and ActiveMQ Artemis):

```
***** JTA Transaction#init                     (TransactionImple < ac, NoTransaction >)
***** JTA Transaction#registerSynchronization  (TransactionImple < ac, BasicAction: 0:ffffc0a801ea:85d3:5de3ea97:21 status: ActionStatus.RUNNING >,sync=org.messaginghub.pooled.jms.pool.PooledXAConnection$Synchronization@14f834b1)
***** JTA Transaction#enlistResource           (xaRes=oracle.jms.AQjmsXAResource@1c4bc8d6)
***** JTA-XA XAResource#setTransactionTimeout  (oracle.jms.AQjmsXAResource@1c4bc8d6;seconds=60)
***** JTA-XA XAResource#setTransactionTimeout  (oracle.jdbc.driver.T4CXAResource@7fd2f093;seconds=60)
***** JTA-XA XAResource#start                  (oracle.jms.AQjmsXAResource@1c4bc8d6)
2019-12-01 16:30:26.774  INFO 25735 --- [sumer[FOOQUEUE]] route4                                   : Message sent to outbound: TEST JAVA
***** JTA-XA XAResource#isSameRM               (oracle.jms.AQjmsXAResource@1c4bc8d6;xares=org.postgresql.xa.PGXAConnection@935d3f9)
***** JTA-XA XAResource#isSameRM               (oracle.jdbc.driver.T4CXAResource@7fd2f093;xares=org.postgresql.xa.PGXAConnection@935d3f9)
***** JTA-XA XAResource#setTransactionTimeout  (org.postgresql.xa.PGXAConnection@935d3f9;seconds=60)
***** JTA-XA XAResource#start                  (org.postgresql.xa.PGXAConnection@935d3f9)
***** JMS-XA XAConnectionFactory#createXAConnection     (org.apache.activemq.ActiveMQXAConnectionFactory@1d239476)
***** JTA-XA XAResource#init                   (TransactionContext{transactionId=null,connection=null})
***** JTA Transaction#enlistResource           (xaRes=TransactionContext{transactionId=null,connection=ActiveMQConnection...})
***** JTA-XA XAResource#isSameRM               (org.postgresql.xa.PGXAConnection@935d3f9)
***** JTA-XA XAResource#isSameRM               (oracle.jms.AQjmsXAResource@1c4bc8d6)
***** JTA-XA XAResource#isSameRM               (oracle.jdbc.driver.T4CXAResource@7fd2f093)
***** JTA-XA XAResource#setTransactionTimeout  (TransactionContext{transactionId=null,connection=ActiveMQConnection...)
***** JTA-XA XAResource#start                  (TransactionContext{transactionId=null,connection=ActiveMQConnection...)
***** JTA Transaction#delistResource           (xaRes=org.postgresql.xa.PGXAConnection@935d3f9,flag=67108864)
***** JTA-XA XAResource#end                    (org.postgresql.xa.PGXAConnection@935d3f9)
***** JTA-XA XAResource#end                    (oracle.jms.AQjmsXAResource@1c4bc8d6)
***** JTA-XA XAResource#prepare                (oracle.jms.AQjmsXAResource@1c4bc8d6)
***** JTA-XA XAResource#prepare                (org.postgresql.xa.PGXAConnection@935d3f9)
***** JTA-XA XAResource#end                    (TransactionContext{..,connection=ActiveMQConnection)
***** JTA-XA XAResource#prepare                (TransactionContext{..,connection=ActiveMQConnection)
***** JTA-XA XAResource#commit                 (oracle.jms.AQjmsXAResource@1c4bc8d6)
***** JTA-XA XAResource#commit                 (org.postgresql.xa.PGXAConnection@935d3f9)
***** JTA-XA XAResource#commit                 (TransactionContext{transactionId=null)
```

## Testing and monitoring

### Unit testing

This [sample test from the Narayana Spring Boot repo][failcommittest] shows how to use Byteman to enforce a failure before committing, testing that XA is working:

```java
@Test
@BMRule(name = "Fail before commit",
        targetClass = "com.arjuna.ats.arjuna.coordinator.BasicAction",
        targetMethod = "phase2Commit",
        targetLocation = "ENTRY",
        helper = "me.snowdrop.boot.narayana.utils.BytemanHelper",
        action = "incrementCommitsCounter(); failFirstCommit($0.get_uid());")
public void testCrashBeforeCommit() throws Exception {
    // Setup dummy XAResource and its recovery helper
    setupXaMocks();

    this.transactionManager.begin();
    this.transactionManager.getTransaction()
            .enlistResource(this.xaResource);
    this.messagesService.sendMessage("test-message");
    Entry entry = this.entriesService.createEntry("test-value");
    try {
        // Byteman rule will cause commit to fail
        this.transactionManager.commit();
        fail("Exception was expected");
    } catch (Exception ignored) {
    }

    // Just after crash message and entry shouldn't be available
    assertThat(this.messagesService.getReceivedMessages())
            .isEmpty();
    assertThat(this.entriesService.getEntries())
            .isEmpty();

    await("Wait for the recovery to happen")
            .atMost(Duration.ofSeconds(30))
            .untilAsserted(() -> {
                assertThat(this.messagesService.getReceivedMessages())
                        .as("Test message should have been received after transaction was committed")
                        .containsOnly("test-message");
                assertThat(this.entriesService.getEntries())
                        .as("Test entry should exist after transaction was committed")
                        .containsOnly(entry);
            });
}
```

The test above references [this helper class for Byteman][BytemanHelper]:

```java
public class BytemanHelper {

    private static int commitsCounter;

    public static void reset() {
        commitsCounter = 0;
    }

    public void failFirstCommit(Uid uid) {
        // Increment is called first, so counter should be 1
        if (commitsCounter == 1) {
            System.out.println(BytemanHelper.class.getName() + " fail first commit");
            ActionManager.manager().remove(uid);
            ThreadActionData.popAction();
            throw new RuntimeException("Failing first commit");
        }
    }

    public void incrementCommitsCounter() {
        commitsCounter++;
        System.out.println(BytemanHelper.class.getName() + " increment commits counter: " + commitsCounter);
    }

}
```

### Instrumentation with Byteman

Here are some sample Byteman rules, which will print log statements at key phases during a transaction - useful for monitoring the status of a transaction:

```
RULE Transaction.<init>
INTERFACE javax.transaction.Transaction
METHOD <init>
AT ENTRY
IF TRUE
DO traceln("***** JTA ***** Transaction#<init>: " + $0)
ENDRULE

RULE Transaction.commit
INTERFACE javax.transaction.Transaction
METHOD commit()
IF TRUE
DO traceln("***** JTA ***** Transaction#commit: " + $0)
ENDRULE

RULE Transaction.rollback
INTERFACE javax.transaction.Transaction
METHOD rollback()
IF TRUE
DO traceln("***** JTA ***** Transaction#rollback: " + $0)
ENDRULE


#############


RULE XAResource.<init>
INTERFACE javax.transaction.xa.XAResource
METHOD <init>
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- create : " + $0)
ENDRULE

RULE follow XAResource start
INTERFACE javax.transaction.xa.XAResource
METHOD start(Xid, int )
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- start : " + $0)
ENDRULE

RULE follow XAResource commit
INTERFACE javax.transaction.xa.XAResource
METHOD commit(Xid, boolean )
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- commit  : " + $0)
ENDRULE

RULE follow XAResource end
INTERFACE javax.transaction.xa.XAResource
METHOD end(Xid, int )
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- end  : " + $0)
ENDRULE


RULE follow XAResource prepare
INTERFACE javax.transaction.xa.XAResource
METHOD prepare(Xid)
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- prepare  : " + $0)
ENDRULE

RULE follow XAResource recover
INTERFACE javax.transaction.xa.XAResource
METHOD recover(int)
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- recover  : " + $0)
ENDRULE


RULE follow XAResource rollback
INTERFACE javax.transaction.xa.XAResource
METHOD rollback(Xid)
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- rollback  : " + $0)
ENDRULE

RULE follow XAResource forget
INTERFACE javax.transaction.xa.XAResource
METHOD forget(Xid)
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- forget  : " + $0)
ENDRULE

RULE follow XAResource isSameRM
INTERFACE javax.transaction.xa.XAResource
METHOD isSameRM(XAResource)
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- isSameRM  : " + $0)
ENDRULE

RULE follow XAResource setTransactionTimeout
INTERFACE javax.transaction.xa.XAResource
METHOD setTransactionTimeout(int)
AT ENTRY
IF TRUE
DO traceln("XA-BTM ***** XAResource -- setTransactionTimeout  : " + $0)
ENDRULE
```


[failcommittest]: https://github.com/snowdrop/narayana-spring-boot/blob/949b2c236dd6c6488229ee52387d762b8bff103a/narayana-spring-boot-starter-it/src/test/java/me/snowdrop/boot/narayana/generic/GenericRecoveryIT.java#L91-L129
[BytemanHelper]: https://github.com/snowdrop/narayana-spring-boot/blob/949b2c236dd6c6488229ee52387d762b8bff103a/narayana-spring-boot-starter-it/src/test/java/me/snowdrop/boot/narayana/utils/BytemanHelper.java#L26-L49
[narayana-spring-boot]: https://github.com/snowdrop/narayana-spring-boot
