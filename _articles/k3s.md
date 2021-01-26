---
layout: page
title: k3s
---

[k3s](https://k3s.io/) is a lightweight Kubernetes distribution "for IoT and Edge Computing":

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

## Concepts

DNS:

- Uses **coredns** using image `docker.io/rancher/coredns-coredns`
- This runs as a _ReplicaSet_ in namespace `kube-system`
- CoreDNS gets settings from the configmap `coredns` in namespace `kube-system` - this is mounted as `/etc/coredns/Corefile` in the container
- Each container uses CoreDNS for DNS resolution, due to  `nameserver <kube-dns Service IP>` in `/etc/resolv.conf`

## Cookbook

Kill, uninstall:

```
/usr/local/bin/k3s-killall.sh
/usr/local/bin/k3s-uninstall.sh
```

Adding the Kubernetes Dashboard:

```
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
```

Some more info about k3s:

- It'll create a service to run on startup: `/etc/systemd/system/multi-user.target.wants/k3s.service`
- Use the `k3s` command to interact with the cluster.
- It runs as `root`.
- It is [configured to automatically restart after node reboots or if the process crashes or is killed](https://rancher.com/docs/k3s/latest/en/quick-start/)
- There is a config file in `/etc/rancher/k3s/k3s.yaml`
- You can use the scripts `/usr/local/bin/k3s-killall.sh` and `k3s-uninstall.sh` to stop and uninstall, etc.
