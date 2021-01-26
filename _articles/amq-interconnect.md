---
layout: page
title: Red Hat AMQ Interconnect
---

Message router based on [Apache Qpid][qpid].

{% include toc.html %}

## Quickstarts

### Simple 2-node AMQ Interconnect 1.7 router network on OpenShift 3.11 (with inter-router SSL, no Operators)

What this deploys:

- A 2-node router network (mesh)
- Creates a root CA and certificates for inter-router connections - i.e. connections between Interconnect routers
- The [Operator][qdr-operator] can be used to deploy Interconnect from OCP 4.0 onwards.
- For a non-operator deployment, the [Interconnect container image][irimage] v1.3 still includes some OpenShift templates, which we can use as a base and customise to fit.
- Clients will authenticate to the routers using SASL, not certificates

```
MYPROJECT=amq-demo
IMAGE_STREAM_NAMESPACE=amq-demo
ROUTER_NAME=myrouter

oc new-project ${MYPROJECT}

oc create secret docker-registry redhat-registry-secret --docker-username=yourlogin@redhat.com --docker-password=yourpassword --docker-server=registry.redhat.io -n ${IMAGE_STREAM_NAMESPACE}

oc import-image amq-interconnect:latest -n ${IMAGE_STREAM_NAMESPACE} --from=registry.redhat.io/amq7/amq-interconnect:1.7 --confirm
```

Create CA certs for inter-router and client/server connections:

```
# Create a CA certificate for inter-router connections
mkdir internal-certs
openssl genrsa -out internal-certs/ca-key.pem 2048
openssl req -new -batch -key internal-certs/ca-key.pem -subj "/C=GB/ST=London/L=London/O=Acme plc/OU=Head Office/CN=acmeplc.xyz" -out internal-certs/ca-csr.pem
openssl x509 -req -in internal-certs/ca-csr.pem -signkey internal-certs/ca-key.pem -out internal-certs/ca.crt

# Create a certificate for the router, signed by the CA.
openssl genrsa -out internal-certs/tls.key 2048
openssl req -new -batch -subj "/CN=${ROUTER_NAME}.${MYPROJECT}.svc.cluster.local" -key internal-certs/tls.key -out internal-certs/server-csr.pem
openssl x509 -req -in internal-certs/server-csr.pem -CA internal-certs/ca.crt -CAkey internal-certs/ca-key.pem -out internal-certs/tls.crt -CAcreateserial

oc create secret generic ${ROUTER_NAME}-inter-router-certs --from-file=tls.crt=internal-certs/tls.crt  --from-file=tls.key=internal-certs/tls.key  --from-file=ca.crt=internal-certs/ca.crt -n ${MYPROJECT}

# Create a CA certificate for client connections.
mkdir client-certs
openssl genrsa -out client-certs/ca-key.pem 2048
openssl req -new -batch -key client-certs/ca-key.pem -out client-certs/ca-csr.pem -subj "/C=GB/ST=Manchester/L=Manchester/O=ClientCo plc/OU=Head Office/CN=ClientCo"
openssl x509 -req -in client-certs/ca-csr.pem -signkey client-certs/ca-key.pem -out client-certs/ca.crt

oc create secret generic ${ROUTER_NAME}-client-ca --from-file=ca.crt=client-certs/ca.crt -n ${MYPROJECT}

# Optional - Create a secret to allow a client application to authenticate to the routers using certificates
openssl genrsa -out client-certs/tls.key 2048
openssl req -new -batch -subj "/CN=messaging-client" -key client-certs/tls.key -out client-certs/client-csr.pem
openssl x509 -req -in client-certs/client-csr.pem -CA client-certs/ca.crt -CAkey client-certs/ca-key.pem -out client-certs/tls.crt -CAcreateserial

# Start with the Interconnect 1.3 template and add some extra bits
AZ_KEY=kubernetes.io/hostname
AZ_VALUE=node-0.sharedocp311cns.lab.example.com

oc process -f https://raw.githubusercontent.com/jboss-container-images/amq-interconnect-1-openshift-image/amq-interconnect-1.3/templates/amq-interconnect-1-tls-auth.yaml \
  -p APPLICATION_NAME=${ROUTER_NAME} \
  -p INTER_ROUTER_CERTS_SECRET=${ROUTER_NAME}-inter-router-certs \
  -p CLIENT_CA_SECRET=${ROUTER_NAME}-client-ca \
  -p IMAGE_STREAM_NAMESPACE=${IMAGE_STREAM_NAMESPACE} \
  | oc apply -n ${MYPROJECT} -f -
```

To access the console:

{% raw %}

```
xdg-open <https://$(oc get route ${ROUTER_NAME}-console -o template --template='{{.spec.host}}')

# log in with:
# Address=<console URL>
# Port=443
# Username=admin@${ROUTER_NAME}
# ROUTER_PASSWORD=$(oc get secret ${ROUTER_NAME}-users -o template --template='{{.data.admin}}' | base64 -d -)
```

{% endraw %}

To delete all related objects once you've finished:

```
oc delete svc,dc,sa,rolebinding,cm,secret,route -l application=${ROUTER_NAME}
oc delete secret ${ROUTER_NAME}-client-ca ${ROUTER_NAME}-inter-router-certs
```

## Concepts

### Connection roles

- Use `role=inter-router` on a `listener` if it is an interior router accepting connections from other interior routers
- Use `role=edge` on a `listener` if it is an interior router accepting connections from edge routers.

### Edge vs interior routers

An **interior router** generally has:

- A listener on 55671, `role=inter-router`, `authenticatePeer=true` and an SSL profile configured, for accepting connections from other interior routers.
- A listener on 45672, `role=edge`, for accepting connections from edge routers.
- _"Interior routers establish connections with each other and automatically compute the lowest cost paths across the network"_

An **edge router** will have:

- A listener on 5672, `role=normal`, for accepting connections from external clients.
- A `connector` to the interior routers (e.g. `router-mesh`)
- _"Edge routers do not participate in the routing protocol or route computation."_

## Using the web console

In the _Topology_ diagram/view:

- **Artemis brokers** are rendered uniquely based on the `name` of the broker as specified in `broker.xml`. So, if two separate brokers in a mesh have the same `name`, they will appear as one broker in the diagram, regardless of whether they have different hostnames.

## Interconnect 1.7

The router is configured using the config file `qdrouterd.conf`:

- Configured by providing it in the env var `QDROUTERD_CONF`
- Located on the file system at `/opt/interconnect/etc/qdrouterd.conf`
- Users: `/etc/qpid-dispatch/sasl-users/` and `/tmp/qdrouterd.sasldb`

## Cookbook

### Check the auto-mesh query results generated by the startup script

Auto-mesh discovers other routers, either by querying the project/namespace (`QUERY`), or by deriving the other pods' IDs in the StatefulSet (`INFER`), and adds connectors for them to the qdrouterd.conf file. To find what connectors are added by auto-mesh, just `tail` the conf files:

```
for pod in $(oc get pods -l application=router | awk 'NR>1 {print $1}'); do oc exec $pod -- tail -n 20 /opt/interconnect/etc/qdrouterd.conf; done
```

### Check router connections

```
for pod in $(oc get pods -l application=router-mesh -o name); do oc exec $pod qdstat; done
```

### Troubleshooting

Can't connect to a router from the AMQ Interconnect console. _"There was a connection error: Unable to connect to amq-interconnect-console.example.com:80"_ is shown on screen, and in the Javascript console logs: _"QDR-main: failed to auto-connect to amqc-tdonohue-amq-demo.example.com:80"_

- Note that the web console uses Websockets to connect to the web console port of the router (see _"Attempting AMQP over websockets connection using address:port of browser (amqc-tdonohue-amq-demo.example.com:80)"_ in the console logs)
- Using public wifi can break this connection, if a dumb proxy is in the middle. Look for `Cache-Miss` responses in the Javascript console. Use a different connection if possible (e.g. mobile tethering)

Router doesn't start automesh properly - this is seen in the logs: _"Traceback (most recent call last): File "/opt/interconnect/bin/auto_mesh.py", line 241, in module connectors = query() ... File "/opt/interconnect/bin/auto_mesh.py", line 226, in query ... si = ip_list.index(ip) ... ValueError: '10.254.4.107' is not in list .. Error configuring automesh: '10.254.4.107' is not in list"`_

- The startup script for AMQ Interconnect uses the Kubernetes API to find other router pods in the namespace. Ensure that the Pod is running under a Service Account which has permissions (`view` role) to get pods in the namespace.
- The startup script discovers other router pods by looking for pods which have the label `application=your-router-name`. Ensure that the pods (or Deployment.spec.template) have that label assigned, or else the script won't discover itself or other pods.

[qpid]: {{ site.baseurl }}{% link _articles/qpid.md %}

[irimage]: https://github.com/jboss-container-images/amq-interconnect-1-openshift-image/
[qdr-operator]: https://github.com/interconnectedcloud/qdr-operator
