---
layout: page
title: jq
---

## jq cookbook

### Merge a JSON file with some other keys and wrap with a top level key

```
jq --arg job_title "Telephone Sanitiser" \
  '{employee_wrapped: (. + {job_title: $contents})}' \
  /path/to/employee.json
```

### Generate a command for each entry in a map

This will generate the command `python adduser.py $slug $username $password $email`:

```
cat document.json | jq -r '.users | to_entries[] | "python adduser.py \(.value.stack_slug) \(.value.username) \(.value.password) \(.value.email)"'
```

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

### Using jq in a while loop

```shell
while read -r email slug; do
    # do stuff

done < <(jq --raw-output '.workshop_users | to_entries[] | "\(.key) \(.value | .stack_slug)"' myfile.json)
```

### Iterate over multiple JSON files and execute jq on each of them

Example:

```shell
for d in /workshops/provisioned-workshops/${WORKSHOP_NAME}/${WORKSHOP_NAME:0:3}*/; do
    jq -r '(.username + ":" + .password)' "$d/complete-config.json"
done
```

### List all containers which deploy a certain image, and show their container CPU limits

This will strip 'm' from the end of millicore values, add '000' to the end of (full-)core values and set 'N/A' if a limit is not set:

```shell
kubectl -n NAMESPACE get pod -o json | jq -r '.items[] | .metadata.name as $pod_name | .spec.containers[] | [$pod_name, .name, .image, (.resources.limits.cpu | if . == null then "N/A" elif . | endswith("m") then .[:-1] else . + "000" end)] | @tsv' | grep my-app-image
```

Example output:

```
ingester-0	ingester	myapp/my-app-image:v1.6.0	2000
ingester-1	ingester	myapp/my-app-image:v1.6.0	2000
ingester-2	ingester	myapp/my-app-image:v1.6.0	2000
```
