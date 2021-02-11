---
layout: page
title: OpenShift Container Platform
---

This page is where I put commands and _script-fu_ that I tend to use most often for [OpenShift][os] 3 (Kubernetes/Docker). Originally written to aid my poor memory, but I share it here in case you find it useful.

OpenShift is an awesome platform for developing and deploying apps in containers. To try it out, you can:

- get [Minishift], or
- get the [Red Hat Container Development Kit][cdk], or
- on a machine with Docker and the [`oc` client tools][occlient] installed, just type `oc cluster up`

{% include toc.html %}

## Info

Releases:

Version | Release date   | Notes
------- | -------------- | ---------------------------------------------------------------------------------------------------
4.1     | June 2019      |
4.0     | April/May 2019 | Preview release only
3.11    | October 2018   |
3.10    | July 2018      |
3.9     | March 2018     | Includes [features and fixes from Kubernetes 1.8 and 1.9][ocp19]. There was [no 3.8 release][no38].
3.7     | November 2017  |
3.6     | August 2017    |
3.5     | April 2017

## Getting started

### Using minishift (for OpenShift 3.x only)

Up and running with the upstream minishift, on **Fedora:**

```
sudo dnf install libvirt qemu-kvm
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt
sudo curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.10.0/docker-machine-driver-kvm-centos7 -o /usr/local/bin/docker-machine-driver-kvm
sudo chmod +x /usr/local/bin/docker-machine-driver-kvm

MINISHIFT_VERSION=1.33.0
curl -OL https://github.com/minishift/minishift/releases/download/v${MINISHIFT_VERSION}/minishift-${MINISHIFT_VERSION}-linux-amd64.tgz
tar -xvf minishift-${MINISHIFT_VERSION}-linux-amd64.tgz

mv minishift-${MINISHIFT_VERSION}-linux-amd64/minishift ~/bin

sudo systemctl start virtlogd
sudo systemctl enable virtlogd
sudo systemctl start libvirtd
sudo systemctl enable libvirtd

minishift oc-env
```

### Container Development Kit - Using a Red Hat developer subscription

Upstream minishift doesn't support a RHEL-based VM and productised OpenShift out of the box.

To use a RHEL-based VM and productised OpenShift, install the Container Development Kit (CDK), first [download the CDK from the Red Hat Developers site][downloadcdk] (ensure third-party cookies are enabled and you have a valid Developer subscription) - this is a large download as it includes a RHEL7 ISO.

Then set up the CDK as below:

```
mv ~/Downloads/cdk-3.9.0-1-minishift-linux-amd64 ~/bin/minishift
chmod u+x ~/bin/minishift
minishift setup-cdk
export MINISHIFT_USERNAME=your-rh-developers-username
echo export MINISHIFT_USERNAME=$MINISHIFT_USERNAME >> ~/.bashrc

minishift start    # first run may take 5-10 mins to start up
minishift console
```

### Using oc cluster up

**Mac:** [Start a simple local all-in-one OpenShift cluster][clusterup] with a configured registry, router, image streams, and default templates:

```
brew install openshift-cli
oc cluster up
```

**Fedora:** Start an all-in-one cluster with `oc cluster up`:

```
$ sudo dnf install -y docker origin-clients

# (Optional) Add yourself into the `docker` user group to avoid needing sudo
$ sudo groupadd docker && sudo gpasswd -a ${USER} docker && sudo systemctl restart docker
$ sudo systemctl start docker

# Then in `/etc/containers/registries.conf`, add 172.30.0.0/16 to `registries.insecure`

$ newgrp docker
$ oc cluster up
```

### Single node cluster in AWS

Start a cluster in AWS - first spin up a RHEL machine, then (example instructions from Wildfly-Camel docs):

```
ssh -i ~/.ssh/id_rsa_ec2.pem ec2-user@1.2.3.4

curl -fsSL https://get.docker.com/ | sh
sudo usermod -aG docker ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker
docker run hello-world

curl -L https://github.com/openshift/origin/releases/download/v3.10.0/openshift-origin-server-v3.10.0-dd10d17-linux-64bit.tar.gz
tar xzf openshift-origin-server-v3.10.0-dd10d17-linux-64bit.tar.gz
oc cluster up --public-hostname=ec2-1-2-3-4.eu-west-1.compute.amazonaws.com --routing-suffix=1.2.3.4.xip.io
```

And updated on 03/09/2019\. First start a RHEL instance in AWS (RHEL 8.x seems to be OK), allow incoming traffic to ports 22, 80 and 443, then:

```
sudo yum install -y podman podman-docker
curl -OL https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar xzvf openshift-origin-server-v3.11.0-0cbc58b-linux-64bit.tar.gz
EXTERNAL_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

mkdir ~/.local/bin
mv openshift-origin-server-v3.11.0-0cbc58b-linux-64bit/* ~/.local/bin/
oc cluster up --public-hostname=${EXTERNAL_HOSTNAME}

sudo dnf clean all
sudo subscription-manager register
sudo subscription-manager attach
sudo subscription-manager repos --enable rhel-7-server-devtools-rpms

sudo rm -r /var/cache/dnf
```

### Installing Helm

```
sudo curl -L https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64 -o /usr/local/bin/helm
sudo chmod +x /usr/local/bin/helm
```

## Concepts

**Container-Native Storage** comprises two technologies:

- _Red Hat Gluster Storage_ - containerized distributed storage. Each Red Hat Gluster Storage volume is composed of a collection of bricks, where each brick is the combination of a node and an export directory.
- _Heketi_ - for Red Hat Gluster Storage volume life cycle management

### Images and image streams

The `image` field inside a Pod spec in a Deployment Config object:

- When deploying from an image stream:

  - Set the `dc.spec.template.spec.containers.image` field to the name of the image. This will cause OpenShift to resolve the full spec to the image from the image stream.
  - Also, under triggers, add an ImageChange trigger which references the `ImageStreamTag`, and set `automatic: true`

- When the OpenShift console is used to deploy an image (using Add to Project -> Deploy Image) and an imagestream is selected, the deploymentconfig that ultimately gets created contains the full image spec of the image, e.g. `"image": "yourregistry.yourcompany.com:5000/jboss-datagrid-7/datagrid71-openshift@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"`

- If `triggers[0].imageChangeParams.automatic` is `false`, OpenShift will not automatically rollout the DC when it is created.

To build your own custom layers on top of "gold" vendor-distributed images from an external registry:

1. Create an Image Stream for the gold image, e.g. RHEL
2. Create a BuildConfig which has an `ImageChangeTrigger` on the external image **and** uses the external image as the `base`/`from`
3. Define a schedule for importing/updating the external imagestream, because it is uses an external registry which won't be automatically updated. e.g. use `oc import-image` (this imports the metadata for the Image Stream)

## Networking

Networking inside a pod:

- Pods take the contents of their host node's `resolv.conf` DNS configuration file.
- OpenShift appends `search` and `nameserver` details, and `dnsIP`, which is set in `/etc/origin/node/node-config.yml`. If not set, the Kubernetes service IP is used.

Communicating from OpenShift pods to external services:

- By default, traffic **from** pods in OpenShift **to external destinations** will have the source IP of whatever node the pod is currently running on.
- If the nodes have NAT configured, then the address will be different and dependent on the NAT configuration.
- Alternatively, you can configure OpenShift to add an Egress IP against a particular namespace (`netnamespace`)

Accessing services in another namespace:

- If a service `myapp` is defined in namespace `goats` then it can be accessed using the DNS name `myapp.goats.svc.cluster.local` - this is achieved using the [ovs-subnet SDN plugin][sdn] (default).
- Namespaces can be optionally isolated using the [ovs-multitenant SDN (Software-Defined Networking) plugin][sdn] which means pods in different namespaces cannot send/receive packets to/from pods in another namespace.

### Router

The default router is HAProxy. Plugins are available to use other routers if required.

## Security

### Authenticating to the cluster

In OpenShift you don't define users - that responsibility is delegated to the **identity provider** which has been configured, e.g.:

- Htpasswd (authentication via an htpasswd file which should exist on all of the master nodes)
- LDAP
- Keystone
- etc.

Permissions are granted by **adding a user to a group**, and then defining a **role binding for the group**, which grants role(s) to the group.

The `kubeadmin` user is created on installation and the password is written to the install log. To delete the kubeadmin user:

```
oc delete secret kubeadmin -n kube-system
```

### Security inside containers and SCCs

OpenShift runs containers using an **arbitrarily assigned user ID**, by default:

- This appears to be [a random user ID, overriding what user ID the image itself may specify that it should run as.](https://cookbook.openshift.org/users-and-role-based-access-control/why-do-my-applications-run-as-a-random-user-id.html)
- This is because Pods run under the default [Security Context Constraint](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_scc.html#listing-security-context-constraints) called `restricted`, which has its _Run As User strategy_ set to `MustRunAsRange` (try: `oc describe scc restricted`)
- `MustRunAsRange` means that the exact user ID is chosen from a range, which is set on the Project, using the annotation `openshift.io/sa.scc.uid-range`
- A Pod definition **may** request the user ID which it should be run as, [using the field `spec.securityContext.runAsUser`][runasuser].

The user inside the container is also **always a member of the `root` group**:

- "For an image to support running as an arbitrary user, **directories and files** that may be written to by processes in the image [should be owned by the root group and be read/writable by that group.][311imageguidelines]"

Pods can also run as `root` if required:

- For images that expect to run as `root`, run them under a named service account, and then give that service account the `anyuid` SCC
- e.g. `oc adm policy add-scc-to-user anyuid system:serviceaccount:myproject:mysvcacct`

## Cookbook

### Applying YAML

To apply some arbitrary YAML to the cluster (multi-line):

```
oc create -f - <<API
...YAML GOES HERE...
API
```

For example - to create a **ServiceAccount**:

```
oc create -f - <<API
apiVersion: v1
kind: ServiceAccount
metadata:
name: metrics-deployer
secrets:
- name: metrics-deployer
API
```

### Working with objects

Copy a bunch of objects from one namespace to another, removing all of the metadata we don't want:

```
oc get dc,svc,is,route -l app=kylie-fan-club -o json | jq 'del( .items[].status, \
  .items[].metadata.id, \
  .items[].metadata.namespace, \
  .items[].metadata.uid, \
  .items[].metadata.selfLink, \
  .items[].metadata.resourceVersion, \
  .items[].metadata.creationTimestamp, \
  .items[].metadata.generation), \
  .items[].spec.clusterIP' | oc apply -n mynewnamespace -f -
```

### Pods

Get a pod name using `awk` and `head`:

```
oc get pods | grep your-pod-base-name | awk '{ print $1 }' | head -1
```

Get the pod name(s) from a deployment (e.g. matching a given label):

```
oc get pod -l application=sso --output=jsonpath='{.items..metadata.name}'
```

### Builds

Start a build and follow (tail) the log onscreen:

```
oc start-build your-build-name --follow
```

Add a trigger to a build, on completion of another build (e.g. if the build pushes to the ImageStreamTag `my-build:latest`):

```
oc set trigger bc/my-build-after --from-image=my-build:latest
```

Add a source secret to an existing build using `oc patch` (e.g. when cloning from a Git repository that requires credentials, or a certificate):

```
oc patch bc/your-build-name -p '{"spec":{"source":{"sourceSecret":{"name":"builder-secret-name"}}}}'
```

### Routes

Create ("expose") a Route from a Service:

```
oc expose service your-service-name
```

Get the hostname (`host`) of the Route using the **Template** output format:

{% raw %} oc get route your-route -o template --template='{{.spec.host}}' {% endraw %}

### Images and image streams

Create an empty image stream:

```
oc create is your-image-stream-name
```

To import an image from an external registry (create an image stream from an external image) use `oc import-image ...`. If the image stream doesn't already exist you'll need to add `--confirm`. Some examples:

```
oc import-image fuse-java-openshift:1.7 --from=registry.redhat.io/fuse7/fuse-java-openshift:1.7 --confirm
oc import-image jaeger-agent --from=docker.io/jaegertracing/jaeger-agent --confirm -n mynamespace
# and in the old public RH registry...
oc import-image amq-interconnect-1.3-openshift:latest -n openshift --from=registry.access.redhat.com/amq7/amq-interconnect --confirm
oc import-image jboss-amq-62:1.3 --from=registry.access.redhat.com/jboss-amq-6/amq62-openshift -n openshift --confirm
```

Import image stream definitions, and then import a specific image tag:

```
oc replace --force  -f \
https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/72-1.2.GA/amq-broker-7-image-streams.yaml
oc import-image amq-broker-72-openshift:1.2
```

To **add a new tag to an existing image stream**, use `import-image` and specify the source (`from`) manually. This is useful when you have an image stream that is pointing to images in an external repository, e.g. the Red Hat Container Registry:

```
oc import-image fuse7-java-openshift:1.3 --from=registry.redhat.io/fuse7/fuse-java-openshift:1.3 -n openshift --as=system:admin
```

Grant permissions for a build to pull an image from another project:

```
oc policy add-role-to-user system:image-puller system:serviceaccount:yourbuildproject:builder -n namespace-to-pull-from
```

### ConfigMaps

Create a ConfigMap containing a bunch of arbitrary XML (e.g. an AMQ Broker config file):

```
--
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-broker-configmap
data:
  broker.xml: |
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <configuration xmlns="urn:activemq"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="urn:activemq /schema/artemis-configuration.xsd">
    </configuration>
```

### Secrets

Secrets also have different `type`s:

- `gitlab.com/basic-auth`

Create a new source secret for a build (where the source is located in a Git repository that requires authentication):

```
oc create secret generic gitlab-secret \
    --from-literal=username=MYUSERNAME \
    --from-literal=password=MYPASSWORD \
    --type=kubernetes.io/basic-auth
```

Get the `username` value from a secret using the `template` option:

{% raw %}

```
oc get secret -n my-project mongodb --template="{{ .data.username }}"
```

{% endraw %}

Applying a secret:

```
oc create -f - <<API
apiVersion: v1
kind: Secret
metadata:
  name: my-test-secret
type: Opaque
stringData:
  truststorepassword: changeit
  keystorepassword: changeit
API
```

### Templates

Create resources from a Template, and set a parameter:

```
oc process mytemplate -p BARLOW_TYPE=deirdre | oc create -f -
```

### Operators

See the dedicated page on [OpenShift Operators]({{ site.baseurl }}{% link _articles/openshift-operators.md %}).

### StatefulSets

#### Basic StatefulSet

```
oc create -f - <<API
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  generation: 1
  labels:
    test: tom
  name: my-statefulset
spec:
  podManagementPolicy: Parallel
  replicas: 1
  selector:
    matchLabels:
      app: my-statefulset
  serviceName: spring-boot-camel-xa-headless
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: my-statefulset
    spec:
      containers:
        - env:
            - name: KUBERNETES_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
          image: this-image-does-not-exist-eggs
          imagePullPolicy: IfNotPresent
          name: app-container
          ports:
            - containerPort: 8080
              name: http
              protocol: TCP
            - containerPort: 9779
              name: prometheus
              protocol: TCP
            - containerPort: 8778
              name: jolokia
              protocol: TCP
          resources:
            limits:
              cpu: '1'
              memory: 256Mi
            requests:
              cpu: 200m
              memory: 256Mi
          securityContext:
            privileged: false
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      terminationGracePeriodSeconds: 180
  updateStrategy:
    type: RollingUpdate
API
```

### Working with Red Hat images

#### Pulling images

Red Hat images on `redhat.io` now **require authentication**. The simplest way to do this is to create a Secret in the `openshift` namespace to authenticate against the Red Hat registry:

```
export RH_USERNAME=
export RH_PASSWORD=
oc create secret docker-registry rh-secret --docker-username=${RH_USERNAME} --docker-password=${RH_PASSWORD} --docker-server=registry.redhat.io -n openshift --as system:admin
```

Then try to reimport the ImageStreamTag:

```
oc import-image fuse7-java-openshift:1.2 -n openshift --as=system:admin
```

Or, if needing authentication so that Jenkins can pull images from the Red Hat Container Registry:

```
oc create secret docker-registry rh-secret .....
oc secrets link deployer rh-secret
```

Using a Red Hat base image where authentication is required, in a **build**:

```
oc create secret docker-registry rh-secret ...
oc secrets link builder rh-secret
oc new-build registry.redhat.io/amq7/amq-broker:7.4~https://example.com/my-repo
```

#### Inspecting S2I images

Get the location of the S2I scripts for an image:

```
podman inspect registry.redhat.io/amq7/amq-broker:7.5 | grep s2i.scripts-url
```

Cat the `run` script:

```
podman run --rm registry.redhat.io/amq7/amq-broker:7.5 cat /usr/local/s2i/run
```

#### Red Hat Middleware for OpenShift

JBoss Fuse, AMQ, EAP. _All the lush and beautiful things._

Install the JBoss middleware image streams:

```
oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json -n openshift
```

Install the AMQ image streams:

```
# 7.2 (1.2) GA
oc create -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/72-1.2.GA/amq-broker-7-image-streams.yaml
```

Install one of the [JBoss middleware templates][jbosstpl] to allow you to create AMQ, EAP, etc instances, from the web console or CLI:

```
oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/amq/amq62-persistent-ssl.json -n openshift
```

Create a new app using one of the templates, and download dependencies from a local Maven mirror, instead of Maven Central:

```
oc new-app jboss-webserver30-tomcat8-openshift~https://github.com/monodot/helloworld-gwt -e MAVEN_MIRROR_URL=http://nexus.yourcompany.com:8081/nexus/content/groups/public/
```

#### Jolokia agent in Java images

To list all available Jolokia operations on a Java container which has the Jolokia agent installed:

```
OCTOKEN=$(oc whoami -t)
OCMASTER=openshift.yourcompany.com
OCPROJECT=yourprojectname
OCPOD=yourpod-1z21ag
curl -k -H "Authorization: Bearer $OCTOKEN" https://$OCMASTER:8443/api/v1/namespaces/$OCPROJECT/pods/https:$OCPOD:8778/proxy/jolokia/list
```

View heap memory usage (`watch` this to monitor the heap in realtime without needing Hawtio):

```
$ curl -k -H "Authorization: Bearer $OCTOKEN" https://$OCMASTER:8443/api/v1/namespaces/$OCPROJECT/pods/https:$OCPOD:8778/proxy/jolokia/read/java.lang:type=Memory/HeapMemoryUsage
{"request":{"mbean":"java.lang:type=Memory","attribute":"HeapMemoryUsage","type":"read"},"value":{"init":1004535808,"committed":897581056,"max":954728448,"used":253232560},"timestamp":1524736318,"status":200}
```

View cache size for any local Infinispan caches:

```
$ CACHENAME=mycachename
$ curl -k -H "Authorization: Bearer $OCTOKEN" https://$OCMASTER:8443/api/v1/namespaces/$OCPROJECT/pods/https:$OCPOD:8778/proxy/jolokia/read/org.infinispan:type\=Cache,name\=%22$CACHENAME%28local%29%22,manager\=%22DefaultCacheManager%22,component\=Statistics/numberOfEntries
{"request":{"mbean":"org.infinispan:component=Statistics,manager=\"DefaultCacheManager\",name=\"position(local)\",type=Cache","attribute":"numberOfEntries","type":"read"},"value":11263,"timestamp":1525446701,"status":200}
```

View Artemis broker info:

```
ARTEMIS_POD=artemis-12345
curl http://quarkus:quarkus@127.0.0.1:8161/console/jolokia/read/org.apache.activemq.artemis:broker\=\"${ARTEMIS_POD}\"
```

### Internal Docker registry

Verify that the registry is up and running in the `default` project:

```
oc get all -n default
```

Find the IP address of the Docker registry (by showing all services in the `default` project):

```
oc get svc -n default
```

Redeploy the internal Docker registry:

```
oc deploy docker-registry --retry
```

### Security

#### Get information about rolebindings

See information about all _ClusterRoleBindings_:

```
oc describe clusterrolebinding.rbac
```

Looking at a _ClusterRoleBinding_ named `admin` (although it can be named anything):

```
$ oc describe clusterrolebinding.rbac/admin
Name:         admin
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  admin
Subjects:
  Kind  Name                 Namespace
  ----  ----                 ---------
  User  tdonohue@example.com  
```

Means that I have the `admin` _ClusterRole_. Which is:

```
$ oc describe clusterrole/admin
Name:         admin
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
PolicyRule:
  Resources                                                  Non-Resource URLs  Resource Names                                Verbs
  ---------                                                  -----------------  --------------                                -----
  applications.argoproj.io                                   []                 []                                            [* create update patch delete get list watch]

  ....snip....

  builds/details                                             []                 []                                            [update]
  builds.build.openshift.io/details                          []                 []                                            [update]
```

Get `role` or `clusterrole` for a specific user:

```
$ oc get clusterrolebindings.authorization \
  -ocustom-columns=name:.metadata.name,role:.roleRef.name,user:.userNames.* | \
  awk -v user=JEFF_MILLS '$3 == user {print}'
edit-21           edit     JEFF_MILLS
```

Which shows that the user only has the clusterrolebinding `edit-21` assigned to them, which is:

```
$ oc describe clusterrolebinding edit-21
Name:         edit-21
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  edit
Subjects:
  Kind  Name                     Namespace
  ----  ----                     ---------
  User  JEFF_MILLS
```

This will give you the `clusterrole` that has been assigned to the user. You can figure out what permissions that role has:

```
$ oc describe clusterrole edit
```

#### Create a group and add users

To grant permissions to individual users, you can add them to a **group**, and then define a **role binding** for that group. To create the group and add members:

```
oc adm groups new my-new-group
oc adm groups add-users my-new-group dave barry
```

#### Give Jenkins permissions to do stuff outside its namespace

Grant the _admin_ cluster role to the `jenkins` service account user and the `ocp-devs` group, and allow images to be pulled from another namespace.

Bind user groups to roles for each of the new project - i.e. give "ocp-devs" edit permissions in the projects:

```
oc create rolebinding ocp-devs_admin_role --clusterrole=admin --group=ocp-devs -n myapp-dev
oc create rolebinding ocp-devs_admin_role --clusterrole=admin --group=ocp-devs -n myapp-test
oc create rolebinding ocp-devs_admin_role --clusterrole=admin --group=ocp-devs -n myapp-perftest
```

Allow Jenkins to operate outside of the project he's created in:

```
oc create rolebinding serviceaccount-labs-ci-cd-jenkins-edit-role --clusterrole=admin --serviceaccount=labs-ci-cd:jenkins -n myapp-dev
oc create rolebinding serviceaccount-labs-ci-cd-jenkins-edit-role --clusterrole=admin --serviceaccount=labs-ci-cd:jenkins -n myapp-test
oc create rolebinding serviceaccount-labs-ci-cd-jenkins-edit-role --clusterrole=admin --serviceaccount=labs-ci-cd:jenkins -n myapp-perftest
```

Give Jenkins the `image-puller` role, so he can fetch Docker images stored in another namespace:

```
oc create rolebinding serviceaccount-labs-ci-cd-default-edit-role --clusterrole=system:image-puller --serviceaccount=labs-ci-cd:default -n myapp-dev
oc create rolebinding serviceaccount-labs-ci-cd-default-edit-role --clusterrole=system:image-puller --serviceaccount=labs-ci-cd:default -n myapp-test
oc create rolebinding serviceaccount-labs-ci-cd-default-edit-role --clusterrole=system:image-puller --serviceaccount=labs-ci-cd:default -n myapp-perftest
```

#### Create a rolebinding in YAML

Role bindings in YAML: to define a role binding which grants the `admin` **Role** to the group `junior-devs` in the project `development`:

```
apiVersion: authorization.openshift.io/v1
kind: RoleBinding
metadata:
  name: my-admin-role
  namespace: development
groupNames:
- junior-devs
roleRef:
  name: admin
subjects:
- kind: Group
  name: junior-devs
userNames: null
```

#### View information about a role

#### Grant a user sudoer / system:admin

Create a **clusterrolebinding**, to allow a basic user to impersonate a privileged user (e.g. when running a local cluster using `oc cluster up` and granting `system:admin` impersonation):

```
oc create clusterrolebinding willsmith-sudo --clusterrole=sudoer --user=will-smith
```

#### Allow a container to run as root

Need to run a container as root? Or you're running a RH container as a random user, which seems to have no write access to the filesystem inside the container? Then create a service account which allows a pod to run as root, then configure the DeploymentConfig to use that service account:

```
oc create serviceaccount useroot
oc adm policy add-scc-to-user anyuid -z useroot
oc patch dc/appthatneedsroot --patch '{"spec":{"template":{"spec":{"serviceAccountName": "useroot"}}}}'
```

#### Set up an _htpasswd_ provider and create a user

Create an _htpasswd_ file and define a user:

```
$ touch htpasswd
$ htpasswd -Bb htpasswd tom letmein
```

Now set up the identity provider:

```
oc --user=admin create secret generic htpasswd \
    --from-file=htpasswd -n openshift-config

oc replace -f - <<API
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: Local Password
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpasswd
API

oc adm groups new mylocaladmins

oc adm groups add-users mylocaladmins tom bernie cliff

oc get groups

oc adm policy add-cluster-role-to-group cluster-admin mylocaladmins
```

#### Create a custom resource and grant permissions

Once you've created a _CustomResourceDefinition_ (e.g. `pizzas.dominos.io`), you can grant users with the _ClusterRoles_ `admin` or `edit` permissions to create/delete instances of the CRD with this YAML below.

Use the special _aggregate-to-admin_ and _aggregate-to-edit_ labels to make sure these permissions are added into the `admin` and `edit` roles:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
items:
  - metadata:
      name: aggregate-pizzas-admin-edit
      labels:
        rbac.authorization.k8s.io/aggregate-to-admin: "true"
        rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rules:
      - apiGroups: ["dominos.io"]
        resources: ["pizzas"]
        verbs: ["get", "list", "watch", "create",
                "update", "patch", "delete", "deletecollection"]
  - metadata:
      name: aggregate-pizzas-view
      labels:
        # Add these permissions to the "view" default role.
        rbac.authorization.k8s.io/aggregate-to-view: "true"
        rbac.authorization.k8s.io/aggregate-to-cluster-reader: "true"
    rules:
      - apiGroups: ["dominos.io"]
        resources: ["pizzas"]
        verbs: ["get", "list", "watch"]
```

### oc patch-fu

Fun uses of `oc patch`.

Modify a BuildConfig to [not use cached layers in a Docker build][nocache]:

```
oc patch bc/myapp -p '{"spec":{"strategy":{"dockerStrategy":{"noCache":true}}}}'
```

Modify the timeout of a Knative Service to 20 seconds:

```
oc patch ksvc greeter -n knativetutorial --type=json -p='[{"op": "replace", "path": "/spec/template/spec/timeoutSeconds", "value":20}]'
```

#### Add an environment variable populated from a ConfigMap to a DeploymentConfig

This uses the `/-` trick to add an additional element to the `env` array in the JSON, which populates an environment variable from a key in a ConfigMap - in this case, updating the AMQ `BROKER_XML` environment variable:

```
oc patch dc/london-amq --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": { "name": "BROKER_XML", "valueFrom": { "configMapKeyRef": { "name": "london-broker", "key": "broker.xml" }}}}]'
```

Thanks to <https://json-patch-builder-online.github.io/>

### OpenShift API

The OpenShift API is documented using Swagger at (when using `oc-cluster up`):

```
https://localhost:8443/swaggerapi/
```

### Administration

Get the version of OpenShift:

```
oc get clusterversion
```

### Monitoring

#### Get pod usage statistics for a project (memory)

You need `cluster-reader` for this:

```
oc adm top pods -n myproject
```

### Maintenance

Deleting/pruning old pods using an `initContainer`:

```
initContainers:
- command: ["oc", "delete", "jobs", "-l", "foo=bar"]
  image: openshift3/ose
  imagePullPolicy: IfNotPresent
  name: mypod-cleanup
```

## Demos & wonderful little things

### Sample app - Basic Apache HTTP Server web site

Deploy a basic demonstration web site running on Apache HTTPD:

```
oc new-app centos/httpd-24-centos7~https://github.com/openshift/httpd-ex
oc expose svc/httpd-ex
```

### StatefulSet - Python simple web server, with a 30s delay on startup

This uses the **python** image from Docker Hub to run a simple HTTP server and serve some basic content. With a delay on startup using `sleep`:

```yaml
apiVersion: v1
kind: List
items:
- apiVersion: apps/v1beta1
  kind: StatefulSet
  metadata:
    labels:
      test: test
    name: sleepy-python
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: sleepy-python
    template:
      metadata:
        creationTimestamp: null
        labels:
          app: sleepy-python
      spec:
        containers:
          - command: ["/bin/sh", "-c"]
            args: ["echo Sleeping... && sleep 30 && echo Starting web server... && echo HELLO >> /tmp/index.html && python -m http.server 8000 --directory /tmp/"]
            image: python:3.8
            imagePullPolicy: IfNotPresent
            name: python
            ports:
              - containerPort: 8000
                name: http
                protocol: TCP
            readinessProbe:
              httpGet:
                path: /
                port: 8000
              initialDelaySeconds: 10
            livenessProbe:
              httpGet:
                path: /
                port: 8000
              initialDelaySeconds: 30
```

## Troubleshooting

### The `oc` command line tool

(Windows) Tell OC to use your local C: drive as the location for its `.kube` config file. Useful in environments where your home drive is set to a network drive, or your `.kube` config file is otherwise inaccessible:

```
set KUBECONFIG=C:\Users\username\.kube\config
```

Or use these:

```
set HOMEDRIVE=C:
set HOMEPATH=C:\Users\username
```

### minishift/Container Development Kit

Delete the Minishift VM because something's gone wrong:

```
$ minishift delete [--clear-cache]
$ rm -rf ~/.kube       # optional, but sometimes necessary
```

Start the CDK when inside an evil corporate network/behind a proxy (or just try and avoid running behind a proxy if possible):

```
$ minishift setup-cdk
$ minishift start --http-proxy http://<YOURPROXY>:<PORT> --https-proxy https://<YOURPROXY>:<PORT>
```

To see full logs when starting up, add:

```
$ minishift [...] --show-libmachine-logs --v=10 --alsologtostderr
```

_"Could not set oc CLI context for 'minishift' profile: Error during setting 'minishift' as active profile: The specified path to the kube config '/Users/tdonohue/.minishift/machines/minishift_kubeconfig' does not exist"_ means something went wrong with your minishift config:

```
$ minishift delete && rm -rf ~/.minishift
```

Build fails when building **from** an image stream in the Red Hat Container Registry - 401 Unauthorized when trying to pull the image (e.g. the Fuse base image, etc.):

- Try deploying the image manually (Web Console → Add to Project → Deploy Image → point to the image stream tag). This should work (deployer seems to have permissions to deploy the image, but perhaps builder does not)

### The all-in-one cluster (`oc cluster up`)

The all-in-one cluster is a local OpenShift cluster on a single machine, incorporating a registry, router, image streams and default templates. All of these run as (Docker) containers.

See all OpenShift infrastructure containers (e.g. registry, router, etc) running on your workstation:

```
docker ps
```

Open a terminal in the `origin` container (where the all-in-one OpenShift server is located):

```
docker exec -it origin bash
```

View logs from the `origin` container:

```
docker logs origin
```

View the _master-config_ file in the `origin` container:

```
docker exec -it origin cat /var/lib/origin/openshift.local.config/master/master-config.yaml
```

Edit the _master-config_ file, when using the [`oc-cluster` wrapper utility][wrapper]:

```
vim ~/.oc/profiles/[profile-name]/config/master/master-config.yml
```

List the `kube` utils that are available in the `origin` container:

```
# docker exec origin ls /usr/bin | grep kube
kube-apiserver
kube-controller-manager
kubectl
kubelet
kube-proxy
kubernetes
kube-scheduler
```

### Other problems and solutions

**Q. My computer starts burning up and/or running out of RAM. Also, Java containers are hanging on startup.**

- Increase the RAM available to Docker for Mac (this will require a Docker restart)
- `docker stop` any non-essential containers that you may be running _outside_ OpenShift
- Check `docker stats` to see CPU usage of the `origin` container; `docker restart origin` if necessary

**Q. The Router does not seem to start properly when running OpenShift locally.**

```
$ oc get pods -n default | grep router
router-1-deploy                 0/1       Error       0          11m
```

Possibly you might have a port conflict. Check the events in the `default` namespace:

```
$ oc get events -n default
...
14m       14m       1         router-1-uc7mo   Pod                 Warning   FailedSync   kubelet, localhost   Error syncing pod, skipping: failed to "StartContainer" for "POD" with RunContainerError: "runContainer: Error response from daemon: {\"message\":\"driver failed programming external connectivity on endpoint k8s_POD.ec88479e_router-1-uc7mo_default_7b212800-f797-11e7-a5c3-fe66a2ce528b_5b61cfa1 (a039fa984569e6ab4d2f4cae417b454578190c52ec7a824c5e8e8ea29adbe90f): Error starting userland proxy: Bind for 0.0.0.0:80: unexpected error (Failure EADDRINUSE)\"}"
```

Apps that might cause this: _Laravel Valet_. Terminate the offending app and restart the router:

```
$ oc deploy router -n default --retry
```

**Q. Multiple pods are running even though I only want one!**

Maybe you've got multiple pods with different index numbers running:

```
$ oc get pods
NAME                          READY     STATUS              RESTARTS   AGE
ocp-job-manager-5-oo9yc       0/1       ContainerCreating   0          1s
ocp-job-manager-6-cqqvv       0/1       ContainerCreating   0          1s
```

This is probably because you're trying to roll out more than one ReplicationController:

```
$ oc get rc
NAME                DESIRED   CURRENT   READY     AGE
...
ocp-job-manager-4   0         0         0         14m
ocp-job-manager-5   1         1         0         9m
ocp-job-manager-6   1         1         0         33s
```

Just scale down the one you don't want:

```
$ oc scale rc/ocp-job-manager-5 --replicas=0
```

**Q. I've pushed a new image to a tag but my pods still seem to be using the _old_ image.**

Check whether your pod is using the cached image that is already present on the node:

```
$ oc get events | grep 'already present'
6m        6m        1         funbobby-nknku84e-debug   Pod       spec.containers{int0032}   Normal    Pulled       kubelet, 10.165.5.85   Container image "172.x.x.x:5000/mynamespace/funbobby:1.0.0-SNAPSHOT" already present on machine
```

If so, update your template or deploymentconfig and set `ImagePullPolicy` to `Always`.

**Q. ImagePullBackOff. What?**

- You've specified an `image` in your DeploymentConfig with an invalid value.

  - OpenShift may be trying to pull the image from _registry.access.redhat.com_
  - If using ImageStreams, leave `image` blank and just set your imagestream details in the `triggers` section of your DeploymentConfig object.

**Q. I can't log in as `system:admin`**

- Probably some mismatch in your local `.kube` configuration. Delete the `.kube` directory and start again.

**Q. I do `oc new-app` from a template but nothing happens. `oc status` says "deployment #1 waiting on image or update"**

- The deployment is waiting for the image to exist first.
- Check the `image:` attribute in the Deployment Config. Does it point to an Image Stream Tag which exists?
- Is the `image:` pointing to the correct namespace? If the namespace is omitted, it will assume the default namespace (`openshift`). For example, the spec `image: myimage:1.1` expects an Image Stream Tag called `myimage:1.1` to exist in the `openshift` namespace.
- If the app is an S2I/binary build, then you need to wait for the image to be built, before it can be deployed automatically.

**Q. I get this error: "No API token found for service account "deployer", retry after the token is automatically created and added to the service account"**

- Delete the service account and it should be recreated again, e.g.: `oc delete sa deployer`

**Q. I can't use `--as=system:admin` in commands: "Error from server (Forbidden): users "system:admin" is forbidden: User "developer" cannot impersonate users at the cluster scope: no RBAC policy matched"**

- `oc create clusterrolebinding developer-as-admin --clusterrole=sudoer --user=developer`

**Q. `oc cluster down` leaves some directories mounted, which means that `openshift.local.clusterup` cannot be deleted.**

- You can use the `mount` command to see that some directories are still mounted: `mount | grep openshift`
- Unmount using: `for i in $(mount | grep openshift | awk '{ print $3}'); do sudo umount "$i"; done && sudo rm -rf ./openshift.local.clusterup`

### General troubleshooting tips

If something's not working, or not deploying:

```
oc status -v
```

If something's still not working:

```
oc get events
```

Changing the log level of a build:

```
oc set env bc/my-build-name BUILD_LOGLEVEL=[1-5]
```

Problems pulling images? Check the integrated Docker registry logs:

```
oc logs docker-registry-n-{xxxxx} -n default | less
```

Get diagnostics information on your OpenShift cluster:

```
oc adm diagnostics
```

## Administration and security

Grant the `admin` user permissions to administer the cluster (e.g. to create a PersistentVolume):

```
oc adm policy add-cluster-role-to-user cluster-admin admin
```

Grant edit permissions in the current namespace to the service account called `jenkins`:

```
oc policy add-role-to-user edit -z jenkins
```

Check which users can perform a certain action (useful e.g. when debugging why Jenkins can't create slave pods):

```
oc policy who-can create pod
```

## Bonus section: Docker!

Pull an image by its SHA256 digest; sometimes useful to inspect the same image that was used in a build. (In OpenShift, the SHA256 digest of the image used in a Build is given on the Build's details page, under Builder Image)

```
docker pull registry.access.redhat.com/openshift3/jenkins-2-rhel7@sha256:2f480e81e85f7d335e630050fa8188b611805483b1bf6b68ccee6351ba530bff
```

Delete all exited Docker containers:

```
docker rm $(docker ps -aq)
```

View the size of the Docker storage file (Docker for Mac):

```
du -h -d 1 ~/Library/Containers/com.docker.docker
```

View stats on all containers with their names:

```
docker stats $(docker ps | awk '{if(NR>1) print $NF}')
```

[311imageguidelines]: https://docs.openshift.com/container-platform/3.11/creating_images/guidelines.html
[cdk]: https://developers.redhat.com/products/cdk/overview/
[clusterup]: https://github.com/openshift/origin/blob/v3.11.0/docs/cluster_up_down.md
[downloadcdk]: https://developers.redhat.com/products/cdk/download
[jbosstpl]: https://github.com/jboss-openshift/application-templates
[minishift]: https://www.openshift.org/minishift/
[no38]: https://docs.openshift.com/container-platform/3.9/release_notes/ocp_3_9_release_notes.html#ocp-39-about-this-release
[nocache]: https://docs.openshift.org/latest/dev_guide/builds/build_strategies.html#no-cache
[occlient]: https://github.com/openshift/origin/releases
[ocp19]: https://docs.openshift.com/container-platform/3.9/upgrading/automated_upgrades.html
[os]: https://www.openshift.org/
[runasuser]: https://docs.openshift.com/container-platform/3.11/admin_guide/manage_scc.html#example-security-context-constraints
[sdn]: https://docs.openshift.com/container-platform/3.11/architecture/networking/sdn.html#architecture-additional-concepts-sdn
[wrapper]: https://github.com/openshift-evangelists/oc-cluster-wrapper


DSI-C = "our client"
suboffice pu north which is site C.
other areas which we don't worry about.
also have a cousin in London - NCSC. public-facing side of what we do. (DSI-N) - a subset of DSI-C.
