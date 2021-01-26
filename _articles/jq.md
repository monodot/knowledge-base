---
layout: page
title: jq
---

## jq cookbook

### Get AWS EC2 InstanceIds

Fetch a list of Amazon EC2 instances and get their InstanceID:

```
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {InstanceId}'
```

### Set a field in a Kubernetes List, if its parent exists

Update a value in an array element, where the array element has a specific value for a key (where `kind` is `StatefulSet`):

```
cat list.json | jq '(.items[] | select(.kind == "StatefulSet") | .spec.updateStrategy.type) |= "RollingUpdate"'
```

Another, less elegant way of doing the same (doesn't search for the `StatefulSet` specifically but finds the tree location by the `volumeClaimTemplates` block):

```
cat output.json | jq '.items[].spec.volumeClaimTemplates[]?.spec.storageClassName = "myebs"'
```

### Set node affinity on a DeploymentConfig

```
AZ_KEY=xyz.tomd.mylabel
AZ_VALUE=fun_node

cat list.json | jq "(.items[] | select(.kind == \"DeploymentConfig\") | .spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms) |= [ { \"matchExpressions\": [ { \"key\": \"${AZ_KEY}\", \"operator\": \"In\", \"values\": [ \"${AZ_VALUE}\" ] } ] }]" \
```

### Get a tls.crt file from a Secret

```
oc get secret my-secret -o json | jq -r '.data."tls.key"' | base64 -d - | openssl x509 -noout -text
```

### Get Kinesis stream ARN

```
$ aws kinesis describe-stream --stream-name CillasTrades | jq -r '.StreamDescription.StreamARN'
arn:aws:kinesis:eu-west-1:XXXXXXXXXXXX:stream/CillasTrades
```

