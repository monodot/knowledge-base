---
layout: page
title: Nexus
---

## Seeding Nexus3 manually

For situations when you need to import a number of artifacts into a Nexus repository - e.g. for airgapped or secure environments, which cannot connect to the internet and must be seeded manually.

Firstly, set up a Maven project with the dependencies that you need in the POM.

Then, use `dependency:go-offline` to create an offline Maven repo containing all the artifacts required by the project:

    cd your-project
    mvn dependency:go-offline -Dmaven.repo.local=/path/to/repository

Now copy this archive to your secure network (e.g. tar it, upload it, virus scan it, extract it).

Finally, programmatically upload these artifacts to Nexus3:

    cd path/to/the/repository
    for i in $(find .);
    do
      curl -u <user>:<password> --upload-file $i http://nexus.example.com/repository/maven-releases/$(dirname $i | sed 's/^\.\///g')/$(basename $i)
    done

**NB:** If an uploaded artifact already exists in the remote repository, Nexus should return a 400 and won't overwrite it.

## Running locally

Running Nexus in a container on Fedora (note the `:z` suffix, required for SELinux):

    $ mkdir /opt/nexus/nexus-data && sudo chown -R 200:200 /opt/nexus/nexus-data
    $ docker run --rm -d -p 8085:8081 --name nexus -v /opt/nexus/nexus-data:/sonatype-work:z sonatype/nexus

## Deploying to OpenShift

Deploy a simple persistent Nexus to OpenShift:

    $ oc create -f https://raw.githubusercontent.com/redhat-cop/openshift-templates/master/nexus/nexus-deployment-template.yml
    $ oc new-app nexus
