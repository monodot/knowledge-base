---
layout: page
title: SSL and Certificates
---

## Certificate formats and converting between them

- PEM format - base64-encoded format, identified by `(BEGIN/END CERTIFICATE)`. Also sometimes used with extension `.crt`
- DER format - a binary format, e.g. as produced by Java `keytool -export ...`

## openssl Cookbook

### Read a PEM certificate

```
openssl x509 -in my_cert.pem -noout -text
```

### Read a PEM file

```
openssl x509 -in my_cert.der -inform DER -noout -text
```

### Convert a CRT to a PEM, via DER intermediary format

```
openssl x509 -in <filename>.crt -out <filename>.der -outform DER
openssl x509 -in <filename>.der -inform DER -out <filename>.pem -outform PEM
```

### View the `issuer` for a certificate

```
openssl x509 -in mycert.pem -noout -issuer
```

### View the entire certificate chain (when all certs are in a single .PEM file)

```
openssl crl2pkcs7 -nocrl -certfile bundle.pem | openssl pkcs7 -print_certs -noout
```

### Fetch certificate from a host and print its full details (useful for inspecting extensions such as _Subject Alternative Names_)

```
echo | openssl s_client -servername ${REMOTE_HOST} -connect ${REMOTE_HOST}:443 2>/dev/null | openssl x509 -noout -text
```

### Fetch certificate from a host and import into a Java truststore

```
REMOTE_HOST=myserver.example.com

echo | openssl s_client -servername ${REMOTE_HOST} -connect ${REMOTE_HOST}:443 2>/dev/null | openssl x509 > ${REMOTE_HOST}.pem

keytool -import -alias server -file ${REMOTE_HOST}.pem -keystore trust.jks
```

### Get fingerprint for an AWS key pair

Verify an AWS key pair against the fingerprint given in the EC2 Console (useful if you've got a `.pem` file lying around and you're not sure if it's the right Private Key for AWS):

```
openssl pkcs8 -in awskeypair.pem -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c
```

### Fetch a tls.crt from a Kubernetes secret and display its information

Use jq and openssl to display information about a certificate in a Kubernetes Secret (e.g. to know whether it's expired, etc.):

```
oc get secret my-secret -o json | jq -r '.data."tls.key"' | base64 -d - | openssl x509 -noout -text
```

## Creating your own CA and intermediate certs

This will generate:

- Your own root certificate authority (CA) cert, _NotVeriSign, Inc._ and private key (`notverisign-ca`)

- An intermediate certificate (`acmeplc`) for the company, _ACME plc_, signed by _NotVeriSign_

- The server's certificate (`cloudapps`), which is issued as a wildcard so that it can be used with multiple domains

How to do it:

```
# generates a private key for NotVerySigned
openssl genrsa -out notverysigned-ca.key 2048

# Generate a self-signed certificate for our new Certificate Authority, NotVeriSign
openssl req -new -x509 -key notverysigned-ca.key -out notverysigned-root-ca.crt -subj "/C=GB/ST=London/L=London/O=NotVerySigned Uncertificates Ltd/CN=NotVerySigned Root CA"

# (Optional) inspect the root CA cert
openssl x509 -in notverysigned-root-ca.crt -noout -text

# Generate a private key for the intermediate certificate
openssl genrsa -out acmeplc.key 2048

# Generate a certificate signing request (CSR) for ACME plc using the private key
openssl req -new -key acmeplc.key -out acmeplc.csr -subj "/C=GB/ST=London/L=London/O=Acme plc/OU=Security Department/CN=ACME plc Intermediate"

# (Optional) inspect the CSR
openssl req -in acmeplc.csr -noout -text

# (Optional) check the Signature Algorithm
openssl req -in acmeplc.csr -noout -text | grep 'Signature Algorithm'

# Using NotVeriSign's private key, sign the ACME plc certificate.
openssl x509 -req -in acmeplc.csr -CA notverysigned-root-ca.crt -CAkey notverysigned-ca.key -CAcreateserial -out acmeplc.crt

# (Optional) inspect the signed certificate - should show "Issuer" as "NotVeriSign Certificates Inc"
openssl x509 -in acmeplc.crt -noout -text

# Create a private key for the cloudapps cert
openssl genrsa -out acmeplc-cloudapps.key 2048

# Generate a CSR to be signed by the ACME intermediate cert.
openssl req -new -key acmeplc-cloudapps.key -out acmeplc-cloudapps.csr -subj "/C=GB/ST=London/L=London/O=Acme plc/OU=Cloud Apps/CN=*.cloudapps.acmeplc.xyz"

# Using ACME's private key, sign the ACME-cloudapps certificate.
openssl x509 -req -in acmeplc-cloudapps.csr -CA acmeplc.crt -CAkey acmeplc.key -CAcreateserial -out acmeplc-cloudapps.crt

# Create a bundle of all three certs
cat notverysigned-root-ca.crt acmeplc.crt acmeplc-cloudapps.crt > chain-all.pem
cat notverysigned-root-ca.crt acmeplc.crt > chain-cas.pem
```

Now import these for use with Java:

```
# Produce a password-protected file containing our public cert and private key.
openssl pkcs12 -export -in chain-all.pem -inkey cloudapps.key -out cloudapps.p12 -name cloudapps -passout pass:secretsquirrel
-CAfile chain-ca.pem

# Use Java's keytool to import the p12 bundle to a new keystore
keytool -importkeystore -alias cloudapps -srcstoretype PKCS12 -srckeystore cloudapps.p12 -srcstorepass secretsquirrel -destkeystore server.jks -deststorepass secretsquirrel -deststoretype pkcs12

# Import the chain of CAs into the trust store so that Java trusts them.
keytool -import -noprompt -trustcacerts -alias chain -file chain-cas.pem -keystore server.jks -storepass secretsquirrel
```

## Certificate management on RHEL

To add a certificate in the simple PEM or DER file formats to the list of CAs trusted on the system, copy it to `/etc/pki/ca-trust/source/anchors/`, then run:

```
update-ca-trust extract
```

## SSL testing

Make a test request to a host using Server Name Identification (SNI):

```
openssl s_client -connect myhost.example.com:443 -servername myhost.example.com
```

Get the SHA1 fingerprint of a certificate (to be able to compare against keystore, etc.):

```
openssl s_client -connect <host>:<port> < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin
```

## SSL and TLS with Java

### Java keystore/truststore properties

```
javax.net.ssl.keyStore
javax.net.ssl.keyStorePassword
```

### Java SSL debug logging

Enable Java SSL debug logging:

```
JAVA_OPTS="$JAVA_OPTS -Djavax.net.debug=ssl,handshake"
```

And some other options/variations:

```
-Djava.security.debug=certpath,provider
-Djavax.net.debug=ssl,keymanager,trustmanager
```

### Java keytool cookbook

Create self-signed certificates for a server and client, and add each certificate into the other party's truststore:

```
keytool -genkey -alias server -keypass changeit -keyalg RSA -keystore server.ks -dname "CN=server,L=Gimmerton" -storepass changeit
keytool -genkey -alias client -keypass changeit -keyalg RSA -keystore client.ks -dname "CN=client,L=Gimmerton" -storepass changeit

keytool -export -alias server -keystore server.ks -file server_cert -storepass changeit
keytool -import -alias server -keystore client.ts -file server_cert -storepass changeit -noprompt

keytool -export -alias client -keystore client.ks -file client_cert -storepass changeit
keytool -import -alias client -keystore server.ts -file client_cert -storepass changeit -noprompt
```

### Java SSL testing

Use the [testing tool from UniconLabs][unicon]:

```
git clone https://github.com/UniconLabs/java-keystore-ssl-test
cd java-keystore-ssl-test
mvn clean install
java -jar target/java-keystore-test-0.1.0.jar http://amq-interconnect-amqps-basic-demo.192.168.42.248.nip.io
```

### Java SSL troubleshooting

Client authentication (mutual authentication/2-way SSL) isn't working:

- Ensure that the `needsClientAuth` flag is set to `true`
- Ensure that the client's certificate has been added into the server's truststore.
- The server first presents an acceptable list of certificates to the client; the client reads this list and tries to present an acceptable certificate, if it can. If the client presents no certificate (`<Empty>`), then it's because the client couldn't find any certificate to present which matched the client's accepted list.
- If _"Warning: no suitable certificate found - continuing without client authentication"_ is seen in the Java `handshake` SSL debug logs, verify that the server is using the correct truststore.

[unicon]: https://github.com/UniconLabs/java-keystore-ssl-test
