---
layout: page
title: OpenShift - Jenkins
---

Info about working with Jenkins in OpenShift.

## Managing Jenkins

- To see the _Manage Jenkins_ link, you need the _admin local_ role for the namespace where Jenkins is running.

## Credentials/secrets

OpenShift Sync Plugin can make secrets you create in your OpenShift namespaces available to Jenkins. Use the label `credential.sync.jenkins.openshift.io`, e.g. on a Template which creates a Secret:

```
---
apiVersion: v1
kind: Template
labels:
  template: secret-template
  credential.sync.jenkins.openshift.io: "true"
```

## Agents/slaves

OpenShift Jenkins comes preconfigured with 2 x Kubernetes Pod Templates, which define Jenkins slave/agents `maven` and `nodejs`. Both of these are configured to pull images from `docker.io`.

To [add more slaves][addslaves]:

- create an ImageStream with the label `role` set to `jenkins-slave`, or
- create an ImageStreamTag which has the annotation `role` set to `jenkins-slave`.

Once you've added a new slave, you will need to **restart Jenkins** for the slave image to be picked up, or you will need to manually add the new slave image into Jenkins config (Manage Jenkins).

Further Jenkins slaves can be built from the community maintained repos at [Red Hat Open Innovation Labs - Labs-ci-cd repo][rht-labs-jenkins-slaves]:

```bash
$ export CQ_RELEASE=v1.4
$ oc process -f https://raw.githubusercontent.com/redhat-cop/containers-quickstarts/${CQ_RELEASE}/jenkins-slaves/templates/jenkins-slave-generic-template.yml \
    -p SOURCE_REPOSITORY_URL=https://github.com/redhat-cop/containers-quickstarts.git \
    -p SOURCE_REPOSITORY_REF=${CQ_RELEASE} \
    -p SOURCE_CONTEXT_DIR=jenkins-slaves/jenkins-slave-ansible \
    -p BUILDER_IMAGE_NAME=openshift/jenkins-slave-base-centos7:v3.11 \
    -p SLAVE_IMAGE_TAG=latest \
    -p NAME=jenkins-slave-ansible \
    -p DOCKERFILE_PATH=Dockerfile | oc create -f -
```

Getting a terminal on the Maven agent image:

    podman run --entrypoint /bin/sh --rm -it --name mvnslave registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7


## Pipeline builds

Pipeline builds are a way of creating and managing Jenkins pipelines from within OpenShift itself, synced across to Jenkins.

- To create a pipeline build, create a BuildConfig with a `strategy.type` of `JenkinsPipeline`. Can also use the `jenkinsFilePath` attribute to set the path to the Jenkinsfile.
- [If a Jenkins instance does not already exist in the given namespace, OpenShift will create one automatically.][create-jenkins]
- The [OpenShift Jenkins Sync Plug-in][syncplugin] will then automatically create a Build Job in Jenkins, using the details in the BuildConfig, and sync it with the object in OpenShift.

Advanced things:

- **Git clone secret** - use the `spec.source.sourceSecret` attribute on the BuildConfig to give the name of the Secret which contains your Git username/password. Jenkins will then use this to clone the repo to fetch the _Jenkinsfile_.
- **Build parameters** - you can make the pipeline configurable by adding environment variables to the BuildConfig, using the `spec.strategy.jenkinsPipelineStrategy.env` object.

Here's an example of a pipeline BuildConfig, which has a source secret, and some environment variables which are passed to the job:

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  labels:
    application: maven-cd-app
    template: maven-cd-app-jenkins-pipeline
  name: maven-cd-app-pipeline
  namespace: tdonohue-cicd
spec:
  nodeSelector: null
  output: {}
  postCommit: {}
  resources: {}
  runPolicy: Serial
  source:
    git:
      ref: master
      uri: https://github.com/monodot/maven-cd-pipeline.git
    sourceSecret:
      name: maven-cd-app-git
    type: Git
  strategy:
    jenkinsPipelineStrategy:
      env:
      - name: APPLICATION_SOURCE_REPO
        value: https://github.com/monodot/maven-cd-pipeline.git
      - name: APPLICATION_SOURCE_REF
        value: master
      - name: BUILD_CONTEXT_DIR
        value: maven-cd-app
      jenkinsfilePath: Jenkinsfile
    type: JenkinsPipeline
  triggers:
  - github:
      secret: ABCDEFG
    type: GitHub
  - type: ConfigChange
```

## Debugging slaves

Sometimes you want to step through a build manually. Then you can do this in a debug pod.

First create a DeploymentConfig for the slave image. The easiest way to do this is via `oc new-app <image-stream-name>` and immediately scale the pods to 0. Then use `oc debug`, e.g.:

    $ oc new-app jenkins-agent-mvn
    $ oc scale dc/jenkins-agent-mvn --replicas=0
    $ oc debug dc/jenkins-agent-mvn
    $ oc delete all -l app=jenkins-agent-mvn

If cloning repositories, you may need to set the following environment variables inside the debug pod, to avoid the issue _"fatal: unable to look up current user in the passwd file: no such user"_:

    $ export GIT_SSL_NO_VERIFY=true
    $ export GIT_COMMITTER_NAME=Tom
    $ export GIT_COMMITTER_EMAIL=tom@example.com

## Cookbook

### Seeding a Mongo DB from a pipeline

Firstly create a Jenkins slave image containing the mongo client tools and **jq**.

Then in the pipeline:

```java
export MONGODB_USERNAME=$(oc get secret ${APP_NAME}-mongo -n ${PROJECT_NAMESPACE} -o json --export | jq -r '.data."database-user"' | base64 -d -)
export MONGODB_PASSWORD=$(oc get secret ${APP_NAME}-mongo -n ${PROJECT_NAMESPACE} -o json --export | jq -r '.data."database-password"' | base64 -d -)

mongoimport --db ${DATABASE_NAME} --collection ${COLLECTION_NAME} --upsert --upsertFields=name --file seed/${COLLECTION_NAME}.json --jsonArray --username=${MONGODB_USERNAME} --password=${MONGODB_PASSWORD} --host=${APP_NAME}-mongo.${PROJECT_NAMESPACE}.svc.cluster.local:27017
```

[create-jenkins]: https://docs.openshift.com/container-platform/3.9/architecture/core_concepts/builds_and_image_streams.html#pipeline-build
[syncplugin]: https://github.com/openshift/jenkins-sync-plugin
[addslaves]: https://docs.okd.io/latest/using_images/other_images/jenkins.html
[rht-labs-jenkins-slaves]: https://github.com/rht-labs/labs-ci-cd/tree/master/params/jenkins-slaves
