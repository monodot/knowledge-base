---
layout: page
title: "OpenShift Install Knative"
---

# Install Knative on OpenShift

1.  Install the _Red Hat Serverless_ operator from OperatorHub, into **all namespaces.**

  - Set 4.6 as the update channel.
  - This will install the operator into `openshift-serverless` namespace.

2.  Create an instance of KnativeEventing in the `knative-eventing` namespace.

        oc apply -f - <<API
        apiVersion: operator.knative.dev/v1alpha1
        kind: KnativeEventing
        metadata:
            name: knative-eventing
            namespace: knative-eventing
        API

3.  Create an instance of KnativeServing in the `knative-serving` namespace.

        oc apply -f - <<API
        apiVersion: operator.knative.dev/v1alpha1
        kind: KnativeServing
        metadata:
            name: knative-serving
            namespace: knative-serving
        API
