---
layout: page
title: AMQP
---

## AMQP test tools

### Camel/Fuse AMQP client

```
git clone https://github.com/fabric8-quickstarts/spring-boot-camel-amq

# Fuse 7.6 on Spring Boot 2.x
git checkout spring-boot-camel-amq-7.6.0.fuse-sb2-760045-redhat-00001
```

### fmtn/a

This ActiveMQ testing tool is a convenient CLI wrapper around the `org.apache.qpid:qpid-amqp-1-0-client-jms` library.

#### Put a message onto an address

To put a message to an address, using AMQP and where the remote broker/router secured using TLS:

```
java -jar target/a-1.5.0-SNAPSHOT-jar-with-dependencies.jar \
    -T --amqp --broker "amqps://router-myproject.example.com:443?ssl=true&trust-store=trust.jks&trust-store-password=changeit" \
    --put "YOYO" --user admin@router --pass admin \
    acme.foods.egg
```

- `-T` switch is important - it disable the default transactional behaviour of _fmtn/a_.

Another example:

```
java -jar target/a-1.5.0-SNAPSHOT-jar-with-dependencies.jar -T --amqp --broker "amqp://localhost:61616" --put "YO HELLO" --user=admin --pass admin my.demo.queue
```

#### Fetch the remote host's SSL certificate and add to keystore

If you're using TLS on the broker connection.....

Optionally, to fetch the remote host's SSL certificate using openssl and place it into a local Java keystore:

```
REMOTE_HOST=myserver.example.com

echo | openssl s_client -servername ${REMOTE_HOST} -connect ${REMOTE_HOST}:443 2>/dev/null | openssl x509 > ${REMOTE_HOST}.pem

keytool -import -alias server -file ${REMOTE_HOST}.pem -keystore trust.jks
```
