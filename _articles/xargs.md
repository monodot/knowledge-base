---
layout: page
title: xargs
---

xargs is a command that takes a list of arguments and runs a command with those arguments.

xargs can also be used to run commands in parallel, with the `--max-procs` argument.

## Cookbook

### Run a command on all files in a directory

```shell
ls | xargs -I {} echo "file: {}"
```

### Run long-running curl commands in parallel

```shell
time xargs --max-procs=2 -I {} sh -c 'eval "$1"' - {} <<'EOF'
curl -X DELETE -s -H "Authorization: Bearer $TOKEN" https://example.com/api/instances/instance1
curl -X DELETE -s -H "Authorization: Bearer $TOKEN" https://example.com/api/instances/instance2
curl -X DELETE -s -H "Authorization: Bearer $TOKEN" https://example.com/api/instances/instance3
EOF
```

### Delete all subnets within a Google VPC

This fetches a list of subnets from Google Cloud, fetching the _name_ and _region_ attributes of each subnetwork. Then it pipes the output to `xargs`, which runs a bash command for each line of input, where `$0` is the first argument, `$1` is the second argument, etc.

It also uses `max-args` to limit the number of arguments passed to each invocation of the command, and `max-procs` to limit the number of concurrent processes.

```shell
gcloud compute networks subnets list \
        --filter="(network:mynetwork)" \
        --project my-company-project \
        --format="value(name,region)" \
    | xargs --max-args=2 --max-procs=3 --no-run-if-empty bash -c \
            'gcloud compute networks subnets delete $0 \
                    --project my-company-project \
                    --region $1 --quiet; \
            echo Deleted subnet $0 in region $1'
```
