---
layout: page
title: Jenkins
---

## Installation

Installation on Fedora:

```
$ sudo dnf install jenkins
```

Run in a container - this will make Jenkins available at <http://localhost:49001>:

```
$ podman run --rm --name jenkins -d -p 49001:8080 jenkins/jenkins:lts
```

## Pipelines

- Declarative Pipelines are a more simplified and opinionated syntax on top of the Pipeline sub-system.

### Example - declarative pipeline using OpenShift/Kubernetes pods

```groovy
pipeline {
    agent {
      label "master"
    }
    stages {
        stage('build') {
            steps {
                sh 'echo HEY YALL'
            }
        }
    }
}
```

### Pipeline cookbook

#### Cloning a Git repository at a specific tag

Due to [JENKINS-27018][gitbranch], you can't check out a tag using the `git` step. You need to use the `checkout` step, e.g.:

```groovy
checkout([
    $class: 'GitSCM',
    branches: [[name: 'refs/tags/my-tag-name']],
    userRemoteConfigs: [[
        credentialsId: 'my-git-credentials-id',
        url: 'https://gitlab.examplecat.com/team/my-repo.git'
    ]]
])
```

#### Store the contents of a file in a variable

```groovy
script {
    env.SOME_FILE_CONTENT="cat path/to/some_file.txt".execute().text
}
```

#### Starting a job

To run another Jenkins build job from your pipeline:

```groovy
build job: 'my-job-name',
      parameters: [[$class: 'StringParameterValue', name: 'APP_NAME', value: "${APP_NAME}" ],
                   [$class: 'StringParameterValue', name: 'PORT', value: "8080" ]],
      wait: false
```

#### Use string interpolation but escape one placeholder

Use Groovy string interpolation to expand variables in a command, but prevent Groovy from trying to replace a `${}` placeholder. The trick is to escape the dollar sign three times:

```groovy
sh "sed -i \"s/\\\${PLACEHOLDER_IN_THE_FILE}/${anActualJenkinsVariable}/g\" config/${params.A_JOB_PARAMETER}.conf"
```

#### Curl a list of URLs with variable expansions

```groovy
withCredentials([usernamePassword(credentialsId: 'my-credentials', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
  sh 'while read -r line; do eval curl -s -k "\$line" -u $GIT_USER:$GIT_PASS; done < urls.txt'
}
```

#### Waiting for a StatefulSet to become ready

Grant Jenkins permissions to view objects in the namespace:

```
oc policy add-role-to-user view -z jenkins
```

Then:

```groovy
pipeline {
  agent {
    label "master"
  }
  stages {
    stage('deploy statefulset') {
      steps {
        sh 'echo WELCOME TO MY PIPELINE YALL'

        // DO SOMETHING here to create the StatefulSet first...

        script {
          openshift.withCluster() {
            openshift.withProject("tad-cicd") {
              echo 'Checking StatefulSet pods are all ready...'
              def sts = openshift.selector("sts", "sleepy-python")

              // If the time limit is reached, the build will be aborted with a FlowInterruptedException
              timeout (time: 5, unit: 'MINUTES') {
                sts.untilEach(1){
                  def stsMap = it.object()
                  return (stsMap.status.replicas.equals(stsMap.status.readyReplicas))
                }
              }

              echo 'We think the StatefulSet is now ready!'
            }
          }
        }
      }
    }
  }
}
```

#### Working with JSON and YAML

```
myProperties = readJSON text: methodToGetTheJson()

thePassword = myProperties.details.sections[0].fields.find { it.name == 'the-password' }
assert thePassword != null
```

And YAML:

```
myYAML = readYaml text: """
routers:
- name: intra
  replicas: 2
- name: inter
  replicas: 3
"""

intraRouter = props.routers.find { it.name == 'intra' }
assert intraReplicaCount.replicas == 2
```

## Shared libraries

Fetching a shared library from a private repo. Firstly add credentials into Jenkins, and then:

```groovy
library identifier: 'mylibraryname@master', //'master' refers to a valid git-ref
retriever: modernSCM([
  $class: 'GitSCMSource',
  credentialsId: 'your-credentials-id',
  remote: 'https://github.com/monodot/private-jenkins-library.git'
])

pipeline {
    agent any
    stages {
        stage('Demo') {
            steps {
                echo 'Hello world'
                sayHello 'Dave'
            }
        }
    }
}
```

## REST API

To use the Jenkins REST API, you'll first need the user's API token:

1. Go to the user Configure page (`$JENKINS_URL/user/$USER/configure`)
2. Click the button to get your API Token.

Then you can access the API using `curl`.

### API Cookbook

The following examples expect these environment variables to be set:

```
export JENKINS_URL=http://myjenkins.example.com
export JENKINS_USER=myusername
export JENKINS_TOKEN=xyzyxzyxzyxzyzy
export JENKINS_FOLDER=foldername
export JENKINS_JOB_NAME=myjobname
```

Get a crumb token (if Cross Site Request Forgery protection is enabled):

```
$ curl -s --user $JENKINS_USER:$JENKINS_PASSWORD $JENKINS_URL/crumbIssuer/api/json
{"_class":"hudson.security.csrf.DefaultCrumbIssuer","crumb":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","crumbRequestField":"Jenkins-Crumb"}
$ export JENKINS_CRUMB=$(curl -s --user $JENKINS_USER:$JENKINS_PASSWORD $JENKINS_URL/crumbIssuer/api/json | jq -r '.crumb')
```

Start a job using default parameters (these don't work....yet):

```
$ curl -X POST $JENKINS_URL/job/$JENKINS_FOLDER/job/$JENKINS_JOB_NAME/build \
    -H Jenkins-Crumb:$JENKINS_CRUMB \
    --user $JENKINS_USER:$JENKINS_TOKEN

$ curl -X POST -H Jenkins-Crumb:$JENKINS_CRUMB \
    $JENKINS_URL/job/$JENKINS_FOLDER/job/$JENKINS_JOB_NAME/build?token=$JENKINS_TOKEN
```

### Troubleshooting

_"java.io.IOException: Failed to dynamically deploy this plugin"_ when starting up Jenkins:

- This may be caused by Jenkins failing to install one of the plugin's dependencies.
- Check the first occurrence of this error in the logs.
- e.g. _"SSH Credentials Plugin v1.16 failed to load. You must update Jenkins from v2.60.3 to v2.73.3 or later to run this plugin"_ => update Jenkins.

[gitbranch]: https://issues.jenkins-ci.org/browse/JENKINS-27018
