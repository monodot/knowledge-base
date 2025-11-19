---
layout: page
title: Docker
---

## Getting started

### Installing Docker and Docker Compose on Debian

Install the docker and docker-compose packages and add yourself to the docker group (so you can control docker without _sudo_):

```
sudo apt install -y docker docker-compose
sudo usermod -aG docker $USER
```

### Installing Docker server and client on Windows

You don't need Docker Desktop, despite what both Docker and Microsoft's documentation tells you.

1.  If you need to build and run Windows containers, go to Add/Remove Features and enable the _Containers_ feature.

2.  Follow the instructions here to install the Docker binaries for Windows: https://docs.docker.com/engine/install/binaries/#install-server-and-client-binaries-on-windows

3.  Add `C:\Program Files\Docker` to your PATH.

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

## Operations

### Where does Docker store its logs?

Find out your current Docker daemon's log configuration:

{% raw %}
```
$ docker info --format '{{.LoggingDriver}}'
json-file
```
{% endraw %}

Find the log file for a specific container:

```
$ docker inspect <container_name> | grep LogPath
        "LogPath": "/var/lib/docker/containers/ddd968988...7643e96/ddd968988...7643e96-json.log",
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

### Find all the JSON container log files

Assuming a default install with the log file path in /var/lib/docker/containers, find all of the log files and their sizes with:

```
sudo find /var/lib/docker/containers -name '*.log' | xargs ls -al
```

## Troubleshooting

Why did a container exit unexpectedly?

- `docker ps -a` to show exited containers
- `docker logs <container-id>` to see whether anything obvious was thrown in the logs
- `docker inspect <container-id>` - check the 'State' object, which should show the container's exit code
- Check `/var/log/messages` to see whether Docker was updated by a package manager (e.g. yum)

_"docker: Error response from daemon: cgroups: cgroup mountpoint does not exist: unknown."_

- Docker requires cgroups v1, but Fedora 31+ uses cgroups v2.

Why is my disk filling up but my container appears small?

- Your container log files might be enormous.
- Check the size of your log files and `truncate` the ones you're not bothered about.
- Also set up log file max sizes in your Docker Compose file.

