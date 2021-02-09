---
layout: page
title: Concourse CI
---

A CICD tool.

## Terminology

- **Pipelines**
- **Jobs** - a job can contain several _Tasks_

## Quickstart

### Deploy on OpenShift with Helm

You need to be cluster-admin to do this, because it creates some funky objects like a _ClusterRole_.

This will install Helm into your _current_ namespace, and create an additional namespace for the 'main' team, called `${HELM_RELEASE}-main`, e.g. `toms-ci-main`:

```
oc new-project toms-concourse

HELM_RELEASE=toms-ci

helm repo add concourse https://concourse-charts.storage.googleapis.com/

CONCOURSE_EXTERNAL_URL=https://$HELM_RELEASE-web-$(oc project -q).$(oc set env deploy/router-default -n openshift-ingress --list | grep ROUTER_CANONICAL_HOSTNAME | cut -d '=' -f 2)

CONCOURSE_USER="myuser"
CONCOURSE_PASSWORD="mypass"

helm install \
  --set postgresql.volumePermissions.securityContext.runAsUser="auto" \
  --set postgresql.securityContext.enabled=false \
  --set postgresql.shmVolume.chmod.enabled=false \
  --set concourse.web.externalUrl=${CONCOURSE_EXTERNAL_URL} \
  --set secrets.localUsers="${CONCOURSE_USER}:${CONCOURSE_PASSWORD}" \
  --set concourse.web.auth.mainTeam.localUser="${CONCOURSE_USER}" \
  ${HELM_RELEASE} concourse/concourse
```

Then a couple of tweaks to get it to work on OpenShift without having to modify the Helm chart:

```
# Allow the concourse-worker pods to run as privileged
oc adm policy add-scc-to-user privileged -z ${HELM_RELEASE}-worker

# Create a Route to the Concourse web console
oc create route edge ${HELM_RELEASE}-web --service=${HELM_RELEASE}-web

# Only needed if you are running Postgresql as a specific user, and not "auto"
# oc adm policy add-scc-to-user anyuid -z default
```

Then run a simple demo job - see the section "Basic demo" further below.

### Deploy on Fedora/Podman using docker-compose

**NB: I attempted this and it didn't work. I'm just leaving these notes here, to come back to in future and maybe get it working.**

The recommended docker-compose from the official docs seems to be missing a definition for a _worker_. So use the docker-compose from the `concourse/concourse-docker` repo instead:

```
git clone https://github.com/concourse/concourse-docker
cd concourse-docker

# Add the SELinux label, so that the container user can write to the volume
sed -i 's/\/keys /\/keys:Z /g' keys/generate

# Run the key generation script
./keys/generate

# Set the
yq e '.services.web.environment.CONCOURSE_WORKER_BAGGAGECLAIM_DRIVER = "overlay"' -i docker-compose.yml

podman-compose up -d
```

### Deploy on Fedora/Podman using explicit podman commands

**NB: I couldn't get this to work, either. Leaving it here in case it's useful.**

This is just an imperative equivalent of the declarative docker-compose config:

```
podman pod create --publish 8080:8080 --name concourse

podman run --rm --detach --pod concourse --name concourse_db \
  -e POSTGRES_DB=concourse \
  -e POSTGRES_USER=concourse_user \
  -e POSTGRES_PASSWORD=concourse_pass \
  postgres

podman run --rm --detach --pod concourse --name concourse_web \
  -e CONCOURSE_EXTERNAL_URL=http://localhost:8080 \
  -e CONCOURSE_POSTGRES_HOST=localhost \
  -e CONCOURSE_POSTGRES_USER=concourse_user \
  -e CONCOURSE_POSTGRES_PASSWORD=concourse_pass \
  -e CONCOURSE_POSTGRES_DATABASE=concourse \
  -e CONCOURSE_ADD_LOCAL_USER=test:test \
  -e CONCOURSE_MAIN_TEAM_LOCAL_USER=test \
  -e CONCOURSE_WORKER_BAGGAGECLAIM_DRIVER=overlay \
  -v $(pwd)/keys/web:/concourse-keys:Z concourse/concourse web

# Start worker
sudo podman run --rm --pod concourse --name concourse_worker \
  --stop-signal=SIGUSR2 \
  -u root --privileged \
  -e CONCOURSE_TSA_HOST=127.0.0.1:2222 \
  -e CONCOURSE_BAGGAGECLAIM_DRIVER=overlay \
  -v $(pwd)/keys/worker:/concourse-keys:Z concourse/concourse worker

podman pod stop concourse

podman pod rm concourse
```

My notes from doing this:

- I got a few errors - it didn't work on Fedora 33/Podman 2.2.1
- Error: _"bulk starter: mounting subsystem 'cpuset' in '/sys/fs/cgroup/cpuset': operation not permitted"_
- It seems that starting the 'worker' container as root (`sudo podman run ...`) helped somewhat; but inside the container, the `/sys` and `/proc` directories are unwritable, which still causes the error above.
- So the worker container kept stopping.

Cleaning up: stop and remove any existing Podman pods.

```
podman pod stop concourse
podman pod rm concourse
```

_big frown and shrug_

## Demos

### Run a task that prints a message

From [concourse-tutorial](https://concoursetutorial.com/). Using `-k` to skip verification of SSL:

```
cat << EOF > task.yml
---
platform: linux

image_resource:
  type: docker-image
  source: {repository: ubuntu}

run:
  path: uname
  args: [-a]
EOF

fly -t tutorial login -k -c ${CONCOURSE_EXTERNAL_URL} -u ${CONCOURSE_USER} -p ${CONCOURSE_PASSWORD}
fly -t tutorial execute -c task.yml
```

### Create and run a job that prints hello world

```
cat << EOF > pipeline.yml
---
jobs:
  - name: job-hello-world
    public: true
    plan:
      - task: hello-world
        config:
          platform: linux
          image_resource:
            type: docker-image
            source: {repository: busybox}
          run:
            path: echo
            args: [hello world]
EOF

fly -t tutorial set-pipeline -c pipeline.yml -p hello-world

# There should now be 1 job listed in the output of this:
fly -t tutorial jobs -p hello-world

# Unpause the pipeline and job
fly -t tutorial unpause-pipeline -p hello-world
fly -t tutorial unpause-job --job hello-world/job-hello-world

# The pipeline job should now run...
# To run the job again:
fly -t tutorial trigger-job --job hello-world/job-hello-world
```

### Build a Java app

This will attempt to build the app at <https://github.com/monodot/hello-java>.

The actual `build` _Task_ definition is contained within the application's repository itself.

```
git clone https://github.com/monodot/hello-java
cd hello-java

fly -t tutorial set-pipeline -c concourse/pipeline.yml -p hello-java

# Unpause the job - it will go grey
fly -t tutorial unpause-pipeline -p hello-java

# Run
fly -t tutorial unpause-job --job hello-java/build
```

## Cookbook

List/remove targets:

```
$ fly ts
$ fly delete-target -t tutorial
```

