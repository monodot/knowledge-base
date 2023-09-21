---
layout: page
title: Kubernetes
---

## Quickstarts/demos

### Deploy NodeJS app

```
kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-node --type=LoadBalancer --port=8080
```

### Deploy the Kylie Fan Club homepage

```
kubectl create deployment nodejs --image=quay.io/swinches/nodejs-mongo-persistent:2.0
kubectl expose deployment nodejs --type=LoadBalancer --port=8080
```

### Deploy hello-java-spring-boot

Deploy a simple Java Spring Boot app.

On a cluster with an Ingress controller deployed:

```
kubectl create deploy cheese-app --image=monodot/hello-java-spring-boot:latest
kubectl expose deployment cheese-app --port=8080
kubectl create ingress cheese-app --rule="app.cheese.tld/*=cheese-app:8080"

curl -v -H 'Host: app.cheese.tld' http://<IP OF PROXY, e.g. ENVOY>/cheese
```

Without an Ingress controller, just using a NodePort service:

```
kubectl create deploy cheese-app --image=monodot/hello-java-spring-boot:latest
kubectl expose deployment cheese-app --type NodePort --port=8080
```

### Run whoami (useful tool for determining source IP)

```
kubectl create deployment whoami --image=containous/whoami:v1.5.0 --port=80
kubectl expose deploy whoami --port=80 --target-port=80 --type=ClusterIP
kubectl create ingress whoami --rule="whoami.apps.mndt.co.uk/*=whoami:80,tls=whoami-tls"
```

## Terminology

- **kubelet** - this is the "agent" that runs on each node in a Kubernetes cluster.

## Running locally

### k3s

See [k3s](k3s.html) article.

### Minikube on Fedora

Installing Minkube on Fedora:

    $ sudo dnf install libvirt-daemon-kvm qemu-kvm
    $ sudo systemctl enable libvirtd.service
    $ sudo systemctl start libvirtd.service
    $ sudo systemctl status libvirtd.service
    $ sudo usermod -a -G libvirt $(whoami)
    $ curl -Lo docker-machine-driver-kvm2 https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 \
        && chmod +x docker-machine-driver-kvm2 \
        && sudo cp docker-machine-driver-kvm2 /usr/local/bin/ \
        && rm docker-machine-driver-kvm2
    $ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
        && chmod +x minikube \
        && sudo cp minikube /usr/local/bin \
        && rm minikube

    # Caution pasting this next command in zsh as it'll escape the brackets...
    $ curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
        && chmod +x kubectl \
        && sudo cp kubectl /usr/local/bin \
        && rm kubectl

    # Install virsh command and the 'default.xml' config file for libvirt
    $ newgrp libvirt
    $ sudo dnf install libvirt-client libvirt-daemon-config-network
    $ virsh net-define /usr/share/libvirt/networks/default.xml
    $ virsh net-list --all      # should show a network named 'default'
    $ sudo virsh net-start default

    $ minikube start --vm-driver=kvm2

## Concepts

### Healthchecks

- A **readiness probe** lets Kubernetes know when an app is ready to serve traffic.
- A **liveness probe** lets Kubernetes know if an app is alive or dead. If an app is dead, Kubernetes will kill the pod and start a new one.

Example liveness and readiness checks for a Spring Boot/Camel app:

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: web
  initialDelaySeconds: 180
  periodSeconds: 10
#...
readinessProbe:
  httpGet:
    path: /health
    port: web
  initialDelaySeconds: 10
  periodSeconds: 10
#...
ports:
- containerPort: 8080
  name: web
  protocol: TCP
```

## Kubernetes API

### Accessing from within a Pod

Access the API from within a pod:

    $ KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
    $ curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
          https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/pods/$HOSTNAME

### Getting jobs

Using the Kubernetes API to get information about Jobs.

Example: Using OpenShift, log in as a user who has permissions to view jobs, then:

    $ OCTOKEN=$(oc whoami -t)
    $ OCMASTER=127.0.0.1:8443
    $ OCPROJECT=jobs
    $ OCJOBNAME=templatedjob-0bgrbatx
    $ curl -k -H "Authorization: Bearer $OCTOKEN" https://$OCMASTER/apis/batch/v1/namespaces/$OCPROJECT/jobs/$OCJOBNAME

A **running** job will have a `status` section in the response like this:

```json
"status": {
  "startTime": "2018-01-11T13:27:38Z",
  "active": 1
}
```

A **completed** job will have a `status` section in the response like this:

```json
"status": {
  "conditions": [
    {
      "type": "Complete",
      "status": "True",
      "lastProbeTime": "2018-01-11T13:28:45Z",
      "lastTransitionTime": "2018-01-11T13:28:45Z"
    }
  ],
  "startTime": "2018-01-11T13:27:38Z",
  "completionTime": "2018-01-11T13:28:45Z",
  "succeeded": 1
}
```

## Helm

### Using Helm with k3s

You'll need to tell Helm where it can find k3s kubeconfig:

```
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
helm install chartname chart/repo --namespace targetnamespace
```

## Cookbook

### Logging in

Use `kubectl config view`

### Switching namespaces

```
kubectl config set-context --current --namespace <namespace-to-switch-to>
```

### Get a pod name

{% raw %}
```
ARTEMIS_POD=$(kubectl get pod -n keda-demo -l run=artemis --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
```
{% endraw %}

### Jsonpath

Jsonpath is a way of extracting data from JSON. It's built in to the `kubectl` command.

#### Get a secret value

```
kubectl get secret mysecret -o jsonpath='{.data.password}' | base64 -d
```

## Troubleshooter's toolkit

### Create a pod and run a command

```
kubectl run -i --restart=Never --rm test-${RANDOM} --image=ubuntu --overrides='{"kind":"Pod", "apiVersion":"v1", "spec": {"dnsPolicy":"Default"}}' -- sh -c 'cat /etc/resolv.conf'
```

### Open a shell inside a container

```
kubectl exec -i -t my-pod --container main-app -- /bin/bash
```

Resume a shell session:

```
kubectl attach my-pod --container main-app -it
```

### Start a pod with curl installed

```
kubectl -n gel-helm run curl -it --image=curlimages/curl -- sh
```

Or using the Red Hat UBI image (containerised RHEL, basically):

```
kubectl -n myspace run my-little-debug-pod -it --attach --image docker.io/redhat/ubi8 --command --restart=Never --rm -- sh
```

### Debug a Deployment with a PVC

Pod not starting? Need to launch a container and step through commands?

{% raw %}
```shell
kubectl scale deploy/mydeploy --replicas=0

# command: [ "/bin/bash", "-c", "--" ]
# args: [ "while true; do sleep 30; done;" ]

# Get the actual command for the container
podman inspect --format "entrypoint: {{.Config.Entrypoint}}, cmd: {{.Config.Cmd}}" docker.io/bitnami/ghost:5.26.1
```
{% endraw %}

### Run a network test (curl, ping, etc.)

DNS lookup on internal/external hosts:

```
kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- nslookup kubernetes.default
kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- nslookup www.google.com
```

Ping a server:

```
kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- server.example.com
```

### View HTTP headers being received by a pod

```
kubectl -n tmp create deploy echo --image=mendhak/http-https-echo:28

kubectl -n tmp expose deploy echo --port=8080 --target-port=8080
```

Now create an Ingress to the Service.

### Network packet sniffing with Kubeshark

Kubeshark is a pretty good tool for observing traffic. First install Kubeshark. Then:

```
kubeshark tap -n <namespace> <pod-name>
```

If this is a remote cluster, you can create a tunnel to access the Kubeshark console:

```
ssh -R 80:localhost:8899 nokey@localhost.run
```

Then visit the web address shown in the output.

## Troubleshooting

Minikube: apiserver goes down (`apiserver: Stopped` in status):

- Check `minikube logs`
- Get the logs of the apiserver: `minikube ssh` then `{% raw %}docker logs $(docker ps -a --filter name=k8s_kube-apiserver --format={{.ID}}){% endraw %}`
- Check the status of the exited container: `minikube ssh` then `docker inspect <container-id>` - `ExitCode=137` could indicate an OOM condition

NodePort service times out when you `curl` to it:

- Check the configuration of kube-proxy: `kubectl describe ds/kube-proxy -n kube-system`
- Look at the logs of each kube-proxy Pod to see which IP address it's listening on:
  - See logs: `kubectl logs ds/kube-proxy -n kube-system`
  - e.g. _"Successfully retrieved node IP: 172.31.31.198"_
  - So try `curl 172.31.31.198:123456` (where 123456 is your NodePort service's port number)

Is my container actually running? I can't find it:

- If you're using CRI-O, then use `crictl ps` to see all the running containers on the node.

Some pods can't reach the internet... "dial tcp: lookup xxx.example.com on 10.43.0.10:53: server misbehaving"

- In k3s, you can `kubectl get ep -n kube-system` to see show the endpoints of _kube-dns_
- **Find out how the Pod is resolving DNS names.** go inside the misbehaving pod and type `cat /etc/resolv.conf`. This will show which _nameserver_ the Pod is trying to use.
- **Look at the IP of kube-dns.** `kubectl get svc kube-dns -n kube-system` should show the IP (e.g. 10.43.0.10).
- **Look at the kube-dns logs.** Find the kube-dns pod and see whether it's struggling to look up DNS entries (e.g. "AAAA: read udp 10.42.0.3:54383->1.1.1.1:53: read: no route to host")
- These should give you some clue where the problem is. Perhaps you need to add firewall rules?
