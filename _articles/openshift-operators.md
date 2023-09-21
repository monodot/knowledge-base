---
layout: page
title: OpenShift - Operators
---

Running Operators on OpenShift. A sufficiently complex-enough topic for it to warrant its own dedicated page. :-)

## Concepts

### OperatorSource (opsrc)

An **OperatorSource** defines an external data store which holds Operator bundles (packages), e.g. `redhat-operators`, `certified-operators`, `community-operators`. When reconciled/resolved, the opsrc has a list of `packages`, e.g. `knative-camel-operator`, `grafana-operator`, etc.

OpenShift comes preconfigured with a bunch of _OperatorSource_ objects which point to the _appregistry_ Endpoint on _quay.io_:

```
$ oc get operatorsource -n openshift-marketplace
NAME                  TYPE          ENDPOINT              REGISTRY              DISPLAYNAME           PUBLISHER   STATUS      MESSAGE                                       AGE
certified-operators   appregistry   https://quay.io/cnr   certified-operators   Certified Operators   Red Hat     Succeeded   The object has been successfully reconciled   5d21h
community-operators   appregistry   https://quay.io/cnr   community-operators   Community Operators   Red Hat     Succeeded   The object has been successfully reconciled   5d21h
redhat-operators      appregistry   https://quay.io/cnr   redhat-operators      Red Hat Operators     Red Hat     Succeeded   The object has been successfully reconciled   5d21h
```

## Operator Lifecycle Manager (OLM)

[OLM][olmgithub] is effectively a package manager for Operators.

Some concepts of OLM:

- **Catalog** contains a set of **Packages**, which map "channels" to a particular application definition.
- **Channels** are a way of distributing different upgrade paths for different users (e.g. alpha vs. stable).
- Users add a **Subscription** to a channel which causes the Operator to be automatically updated when new versions are released.

Custom Resource Definitions which are provided by OLM:

- **InstallPlan** is the object that performs automated installation and dependency management
- **ClusterServiceVersion** is a definition of a package itself
- **CatalogSource** is the repository - basically a collection of **ClusterServiceVersions** (packages) - this is currently a _registry image_ as the backend but can be expanded to other types of source in the future.
- **OperatorSource** is a way of pointing to an external **appregistry** namespace which contains a catalog of operators. Applying an OperatorSource to a cluster makes the operators in that OperatorSource available for installation in that cluster.
- A **CatalogSourceConfig** makes an Operator which is present in an **OperatorSource** available on the cluster.

  - `targetNamespace` specifies the namespace where the Operator would be deployed and updated. OLM watches this namespace.
  - `packages` is a comma-separated list of packages which make up the Operator.

- **Subscription** is the object that keeps the Operator up-to-date with the latest releases

The Operator Lifecycle Manager will watch a namespace when it has been configured with an OperatorGroup.

To get all of these objects in a one-liner (useful for troubleshooting!):

```
oc get sub,csc,catsrc,csv,ip,og,opsrc,packagemanifests --all-namespaces
```

### Create a subscription with OLM

To create a subscription:

```
oc create -f - <<API
---
kind: List
apiVersion: v1
metadata:
  name: amq7-interconnect-operator
items:
- apiVersion: operators.coreos.com/v1alpha1
  kind: Subscription
  metadata:
    name: amq7-interconnect-operator  # should be the operator name
  spec:
    channel: 1.2.0  # corresponds to packagemanifest/channel
    installPlanApproval: Automatic
    name: amq7-interconnect-operator  # should be the operator name
    source: redhat-operators  # name of the CatalogSource containing the operator
    sourceNamespace: openshift-marketplace  # location of the CatalogSource
    startingCSV: amq7-interconnect-operator.v1.2.0
API
```

Example `CatalogSourceConfig`:

```
apiVersion: "operators.coreos.com/v2"
kind: "CatalogSourceConfig"
metadata:
  name: "installed-upstream-community-operators"
  namespace: "marketplace"
spec:
  targetNamespace: local-operators
  source: upstream-community-operators
  packages: jaeger
```

### Custom Resource Definitions

To list all CRD types (list all objects that the API can handle):

```
oc api-resources
```

## Quay.io App Registry

Quay provides an API at `https://quay.io/cnr/api/v1/`:

```
$ curl https://quay.io/cnr/api/v1/packages/
[{"channels":null,"created_at":"2017-03-24T11:32:34","default":"0.1.11","manifests":["helm"],"name":"charts/kube-lego","namespace":"charts","releases":["0.1.11","0.1.8"],"updated_at":"2017-09-14T17:09:32","visibility":"public"},{"channels":null,"created_at":"2017-03-24T11:32:39","default":"0.2.1","manifests":["helm"],"name":"charts/factorio","namespace":"charts","releases":["0.2.1","0.2.0"],"updated_at":"2017-09-14T17:10:07","visibility":"public"}....,{"channels":null,"created_at":"2020-03-17T10:26:45","default":"0.9.1","manifests":["helm"],"name":"hgao/howard-operator-test","namespace":"hgao","releases":["0.9.1"],"updated_at":"2020-03-17T10:26:45","visibility":"public"}]
```

List all operators in the `redhat-operators` namespace - note that the **manifests** field shows `helm`, which

```
$ curl https://quay.io/cnr/api/v1/packages?namespace=redhat-operators
#e.g.:
[{
  "channels": null,
  "created_at": "2019-07-23T15:40:41",
  "default": "5.0.0",
  "manifests": [
    "helm"
  ],
  "name": "redhat-operators/amq7-interconnect-operator",
  "namespace": "redhat-operators",
  "releases": [
    "5.0.0",
    "4.0.0",
    "3.0.0",
    "2.0.0",
    "1.0.0"
  ],
  "updated_at": "2020-02-25T15:57:57",
  "visibility": "public"
},...]
```

Get information on the `amq-broker` operator, version `1.0.0`:

```
$ curl https://quay.io/cnr/api/v1/packages/redhat-operators/amq-broker/1.0.0
[
  {
    "content": {
      "digest": "7e88de44af693e94c52a1c71b2984be2d73c1d83d0863f86de88b217c1650fc4",
      "mediaType": "application/vnd.cnr.package.helm.v0.tar+gzip",
      "size": 13582,
      "urls": []
    },
    "created_at": "2019-10-10T12:18:00",
    "digest": "sha256:76abdb52d34a8aa4a3935141eab57820fde168542973d0b2d887ee3f1e1a0be7",
    "mediaType": "application/vnd.cnr.package-manifest.helm.v0.json",
    "metadata": null,
    "package": "redhat-operators/amq-broker",
    "release": "1.0.0"
  }
]
```

Download the manifest for a resource, e.g. `https://quay.io/cnr/api/v1/packages/NAMESPACE/PACKAGE/VERSION/MANIFEST/pull` - this will contain ClusterServiceVersion, CRD and Package definition:

```
$ curl -o amq-broker-7.0.0.tgz https://quay.io/cnr/api/v1/packages/redhat-operators/amq-broker/7.0.0/helm/pull
$ tar --list -f amq-broker-7.0.0.tgz
amq-broker-ftx7n0_i/
amq-broker-ftx7n0_i/0.9.1/
amq-broker-ftx7n0_i/0.9.1/amq-broker-operator.v0.9.1.clusterserviceversion.yaml
amq-broker-ftx7n0_i/0.9.1/broker_v2alpha1_activemqartemis_crd.yaml
amq-broker-ftx7n0_i/0.9.1/broker_v2alpha1_activemqartemisaddress_crd.yaml
amq-broker-ftx7n0_i/0.9.1/broker_v2alpha1_activemqartemisscaledown_crd.yaml
amq-broker-ftx7n0_i/amq-broker.package.yaml
```

## Cookbook

Get all ClusterServiceVersions from a PackageManifest using a Go template:

{% raw %}

```
$ oc get packagemanifest amq7-cert-manager -n openshift-marketplace --template '{{range .status.channels}}{{.currentCSV}}{{end}}'
amq7-cert-manager.v1.0.0
```

{% endraw %}

## Troubleshooting

Places to look for troubleshooting:

- Get all Operator-related objects across all namespaces: `oc get sub,catsrc,csc,ip,opsrc,og --all-namespaces`
- **Logs for the pod `olm-operator`** in project `openshift-operator-lifecycle-manager`. It does stuff around resolving Subscriptions, etc.
- **Logs for the pod `catalog-operator`** in project `openshift-operator-lifecycle-manager`. It does stuff around resolving packages and might have some useful info, e.g.:

  - "Sync "openshift-operators" failed: {amq7-cert-manager alpha {redhat-operators openshift-marketplace}} not found: CatalogSource {redhat-operators openshift-marketplace} not found"

[olmgithub]: https://github.com/operator-framework/operator-lifecycle-manager
