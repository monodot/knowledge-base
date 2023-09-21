---
layout: page
title: Codeready Workspaces
---

Web-based development environments, based on Eclipse Che.

## Concepts

Components included in Codeready Workspaces:

- [**Theia**][theia] - platform for building web-based IDEs
- [**Che-Theia**][che-theia] - a customised Theia specifically for the Eclipse Che project

Concepts:

- A **factory** enables workspace automation and is packaged as a consumer-friendly URL.
- A **workspace** is where your projects live and run. When creating a workspace manually, you specify things like:
  - Workspace name
  - Stack (basically a development environment for a given language/framework)
  - RAM
  - Projects
- A **stack** defines how to start a workspace.

Things to bear in mind:

- A workspace uses a Persistent Volume Claim for persistence - so a Persistent Volume needs to be available

## Getting started

### CRW 1.x Installation on 3.11 using the `deploy.sh` script

This install script provisions:

- 1 `codeready` pod
- 1 `keycloak` pod
- 1 `postgres` pod
- 1 `codeready-operator` pod

This will create a CRD named `checluster`:

    $ oc get crd checlusters.org.eclipse.che
    NAME                          CREATED AT
    checlusters.org.eclipse.che   2019-12-01T18:30:11Z

and create an initial `checluster`:

    $ oc get checluster
    NAME        AGE
    codeready   7m

Info about workspaces:

- Once provisioned, there will be a URL to access Che, e.g.: https://codeready-tommys-workspaces.apps.example.com
- To log on as a local user, use the credentials given in the CRD attributes _Identity Provider Admin User Name_ and _Identity Provider Password_.
- Workspaces are accessed using URLs like this: `https://codeready-tommys-workspaces.apps.examplecat.com/dashboard/#/ide/admin/my-fusey-workspace`

### CRW 2.x installation on OCP 3.11 using crwctl

    oc new-project my-workspaces
    ./crwctl server:start --platform=openshift --installer=operator \
      --domain=apps.fec1.example.opentlc.com

This will:

- create its own namespace, `workspaces`, and deploy _codeready-operator_, _devfile-registry_, _keycloak_, _plugin-registry_ and _postgres_
- start up future workspaces in the `workspaces` namespace.

### CRW 2.x shutdown on OCP 3.11 using crwctl

Prerequisites:

- Get the installation binary (_crwctl_ tool) - download it from  the Red Hat Developer website.
- cluster-admin role on the OpenShift cluster to deploy to (the installation process needs to view serviceaccounts in the `default` namespace)

**To install**, using

**To shut down**, you might need to grab a token first:

    curl --data "grant_type=password&client_id=codeready-public&username=admin&password=admin" \
         http://keycloak-workspaces.apps.examplecat.com/auth/realms/codeready/protocol/openid-connect/token

(Where the values for `client_id` and `realm` are given in the ConfigMap in the `workspaces` namespace.)

Then, to shut down:

    ./crwctl server:stop --access-token=xxxxxxxx

## Component versions

- Codeready Workspaces 1.2.2.GA = Eclipse Che 6.19.x.
- Codeready Workspaces 2.0.0.GA = Eclipse Che 7.3.2

## Stacks

A stack basically defines a workspace, and includes:

- a runtime `recipe` section which defines how to create the workspace, which Docker image should be used.
- _installers_, such as `org.eclipse.che.ls.java`, `org.eclipse.che.ls.camel` (Camel support), `com.redhat.bayesian.lsp` (?)

```json
[
  {
    "recipe": {
      "content": "registry.redhat.io/codeready-workspaces/stacks-java-rhel8",
      "type": "dockerimage"
    }
    ...
  }
]
```

Community stacks:

- There are some stacks in the [community-stacks repository][communitystacks].

Red Hat/product stacks:

- In CRW 1.2, Red Hat stacks (EAP, Fuse, etc.) are defined in the file [`stacks.json`][stacksjson12]
- Some sample Red Hat provided stack images:
  - `registry.redhat.io/codeready-workspaces/stacks-java-rhel8` (~600MB approx.)


[theia]: https://github.com/eclipse-theia/theia
[che-theia]: https://github.com/eclipse/che-theia
[stacksjson12]: https://github.com/redhat-developer/codeready-workspaces/blob/1.2.0.GA/ide/codeready-ide-stacks/src/main/resources/stacks.json
[communitystacks]: https://github.com/che-samples/community-stacks
