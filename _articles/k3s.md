---
layout: page
title: k3s
---

[k3s](https://k3s.io/) is a lightweight Kubernetes distribution "for IoT and Edge Computing".


## Installation

```
dnf install -y container-selinux selinux-policy-base
rpm -i https://rpm.rancher.io/k3s-selinux-0.1.1-rc1.el7.noarch.rpm

curl -sfL https://get.k3s.io | sh -
# wait....
k3s kubectl get node
```

You'll need to be root to interact with the cluster:

```
sudo k3s kubectl get node
```

### Uninstalling

Kill, uninstall:

```
/usr/local/bin/k3s-killall.sh
/usr/local/bin/k3s-uninstall.sh
```

## Networking

### How DNS works

- Uses **coredns** using image `docker.io/rancher/coredns-coredns`
- This runs as a _ReplicaSet_ in namespace `kube-system`
- CoreDNS gets settings from the configmap `coredns` in namespace `kube-system` - this is mounted as `/etc/coredns/Corefile` in the container
- Each container uses CoreDNS for DNS resolution, due to  `nameserver <kube-dns Service IP>` in `/etc/resolv.conf`

### How Networking/Ingress works

<object type="image/svg+xml" data="/assets/diagrams/k3s-networking.excalidraw.svg"></object>

- **IP addresses:**
  - Pod IP addresses are allocated from a default CIDR of `10.42.0.0/16` (this can be configured on startup with the `--cluster-cidr` option) [^2]
  - Service IP addresses are allocated from a default CIDR of `10.43.0.0/16`
- ServiceLB (formerly known as Klipper) is used for load balancing. It watches Kubernetes Services with the spec.type field set to LoadBalancer. [^3]
- **ClusterIP service and Ingress:** To expose an app outside the cluster, you can just create a Service of type _ClusterIP_ and expose it with an _Ingress_.
- **LoadBalancer service:** Alternatively, create a Service of type _LoadBalancer_. This will create a new **klipper** load balancer DaemonSet (`svclb-*`) in the namespace `kube-system`. However, your Service **must** expose a port which isn't already in use. For example, Traefik occupies ports 80 and 443, so pick a different port.

### Middlewares with Traefik



#### Example Ingress and Middleware for an HTTPS service

You can also tell Traefik to redirect clients to HTTPS by creating a `Middleware` resource:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: redirect-https
spec:
  redirectScheme:
    scheme: https
    permanent: true
```

Then create the Ingress, with the appropriate annotations so that Traefik will use it. This assumes you're using cert-manager in the cluster to issue Let's Encrypt TLS certificates:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.middlewares: default-redirect-https@kubernetescrd
  name: myapp
  namespace: plausible
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - backend:
          service:
            name: myapp
            port:
              number: 8000
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
```

## Cookbook

### Monitoring with Kubernetes Dashboard

Add the Kubernetes Dashboard:

```
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
```

### Using k9s with k3s

If you want to view the cluster using the excellent `k9s`, you will need to pass the location of the rancher _kubeconfig_ file:

```
k9s --kubeconfig /etc/rancher/k3s/k3s.yaml
```

### Accessing a service remotely

If you're running a service in a remote cluster, but you don't want to expose it with an Ingress, you can use a local port-forward and an SSH reverse tunnel service like localhost.run to access it from your local computer:

```shell
# assuming your app runs on port 8080. 8123 can be any port you like
k3s kubectl -n namespace port-forward svc/my-app 8123:8080

# 
ssh -R 80:localhost:8123 nokey@localhost.run
```

## Misc

Some more info about k3s:

- It'll create a service to run on startup: `/etc/systemd/system/multi-user.target.wants/k3s.service`
- Use the `k3s` command to interact with the cluster.
- It runs as `root`.
- It is [configured to automatically restart after node reboots or if the process crashes or is killed](https://rancher.com/docs/k3s/latest/en/quick-start/)
- There is a config file in `/etc/rancher/k3s/k3s.yaml`
- You can use the scripts `/usr/local/bin/k3s-killall.sh` and `k3s-uninstall.sh` to stop and uninstall, etc.

## Troubleshooting

metrics-server fails, with error _"Failed to scrape node ... http://your_ip:10250 no route to host"_:

- Likely firewall is preventing traffic from the pod network to your host.
- Add a rule: `firewall-cmd --permanent --add-port=10250/tcp && firewall-cmd --reload`

Can't seem to use _kubectl_ with any other Kubernetes clusters except k3s: _"error: error loading config file "/etc/rancher/k3s/k3s.yaml": open /etc/rancher/k3s/k3s.yaml: permission denied"_:

- The kubectl that's distributed with k3s is modified to always load config from `/etc/rancher/k3s/k3s.yaml` [^1]
- But the default behaviour for a regular kubectl binary is to read config from `~/.kube/config`.
- To work with other clusters: install your own kubectl binary (e.g. from the Kubernetes website, or via a package) then symlink it, so that it overrides the k3s kubectl binary in your PATH:
  - `sudo dnf install -y kubernetes-client --repo fedora`
  - `ln -s /usr/bin/kubectl ~/.local/bin/kubectl`

[^1]: https://github.com/k3s-io/k3s/issues/1541#issuecomment-672099924
[^2]: https://docs.k3s.io/reference/server-config
[^3]: https://docs.k3s.io/networking#service-load-balancer
