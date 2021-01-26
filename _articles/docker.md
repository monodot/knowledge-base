---
layout: page
title: Docker
---

{% include toc.html %}

## Installing Docker on Fedora

```
$ sudo dnf install -y docker origin-clients

# (Optional) Add yourself into the `docker` user group to avoid needing sudo
$ sudo groupadd docker && sudo gpasswd -a ${USER} docker && sudo systemctl restart docker
$ sudo systemctl start docker

# Then in `/etc/containers/registries.conf`, add 172.30.0.0/16 to `registries.insecure`

$ newgrp docker
$ oc cluster up
```

Also see: <https://www.projectatomic.io/blog/2015/08/why-we-dont-let-non-root-users-run-docker-in-centos-fedora-or-rhel/>

## Simple demos

### Demo with docker aliased to podman on Fedora

```
sudo dnf install podman-docker

# Ensure you're not running a zsh terminal because it'll b0rk
bash

docker pull hello-world
docker run hello-world
```

### Show that a container is just a process

Start 3 x mongodb containers, see the processes on the host, but each container can only see itself:

```
docker run -d mongo
docker run -d mongo
docker run -d mongo

# See all 3 containers
docker ps

# I can see all 3 containers on my host
ps -ef | grep mongo

# But the container can only see itself
docker exec $CONTAINER_ID ps -ef
# should just show 1 x mongodb instance....
```

## Cookbook

### Start a container with a bash prompt

```
$ docker run --entrypoint /bin/bash -i -t <image_name>
```

### Start a shell inside a running container

```
$ docker exec -it <container name> /bin/bash
```

### Mount a volume in a container with SELinux

```
$ docker run -d -p 49001:8080 -v $JENKINS_VOLUME:/var/jenkins_home:z -t jenkins
```

### Maintenance: Pruning old images and volumes

Remove a specific Docker image:

```
$ docker rmi ...
```

Use `docker info | grep "Docker Root Dir"` to find the images location and `du` to check the size. Then use `docker prune` to remove images and unused volumes:

```
$ df -h /
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   49G   46G  834M  99% /
# Yikes I have hardly any space left! Damn those Docker images.

$ docker info | grep 'Root Dir'
 Docker Root Dir: /var/lib/docker
$ sudo du -sh /var/lib/docker
11G      /var/lib/docker

$ docker system prune
$ docker image prune -a
$ docker volume prune

$ df -h /
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/fedora-root   49G   37G   11G  79% /
```

## Troubleshooting

Why did a container exit unexpectedly?

- `docker ps -a` to show exited containers
- `docker logs <container-id>` to see whether anything obvious was thrown in the logs
- `docker inspect <container-id>` - check the 'State' object, which should show the container's exit code
- Check `/var/log/messages` to see whether Docker was updated by a package manager (e.g. yum)

_"docker: Error response from daemon: cgroups: cgroup mountpoint does not exist: unknown."_

- Docker requires cgroups v1, but Fedora 31+ uses cgroups v2.
