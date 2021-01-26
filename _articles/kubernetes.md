---
layout: page
title: Kubernetes
---

{% include toc.html %}

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

## Quickstarts/demos

### Deploy NodeJS app

```
kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
kubectl expose deployment hello-node --type=LoadBalancer --port=8080
```

Deploy the Kylie Fan Club homepage:

```
kubectl create deployment nodejs --image=quay.io/swinches/nodejs-mongo-persistent:2.0
kubectl expose deployment nodejs --type=LoadBalancer --port=8080
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
kubectl run curl --image=radial/busyboxplus:curl -i --tty
```

### Network tests (curl, ping, etc.)

DNS lookup on internal/external hosts:

```
kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- nslookup kubernetes.default
kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- nslookup www.google.com
```

Ping a server:

```
kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- server.example.com
```

## Troubleshooting

Minikube: apiserver goes down (`apiserver: Stopped` in status):

- Check `minikube logs`
- Get the logs of the apiserver: `minikube ssh` then `{% raw %}docker logs $(docker ps -a --filter name=k8s_kube-apiserver --format={{.ID}}){% endraw %}`
- Check the status of the exited container: `minikube ssh` then `docker inspect <container-id>` - `ExitCode=137` could indicate an OOM condition
