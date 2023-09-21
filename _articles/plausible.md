---
layout: page
title: Plausible Analytics
---

## Backing up

### User database (PostgreSQL) backup

```shell
# Backup the database (users, etc.)
podman exec plausible-db pg_dumpall -p 5432 -U plausible -l plausible > postgres12dump.sql
```

### Analytics database (Clickhouse) backup

#### Half-arsed backup

How to do a quick and dirty back up of the Clickhouse database by backing up the underlying Persistent Volume. 

This assumes that your Persistent Volume is actually somewhere on the host:

{% raw %}
```shell
LOCAL_PV_PATH=$(kubectl get pvc -n plausible data-plausible-events-db-0 -o template='{{.spec.volumeName}}' | xargs kubectl get pv -o template='{{.spec.hostPath.path}}')

tar -cf clickhouse-pv-$(date +%F).tar -C $LOCAL_PV_PATH .
```
{% endraw %}

(How much use would this be in a real DR situation? Anyone's guess...)

#### Disk backup, shipped manually to AWS

**NB:** I _think_ that this needs Clickhouse 22 or later because it uses the `BACKUP` command.

This hasn't been tested so don't use this for anything important ;-) 

First, [configure a backup destination in Clickhouse](https://clickhouse.com/docs/en/operations/backup/#configure-a-backup-destination).

Restart Clickhouse to pick up the changes.

Next set up a user in AWS:

```shell
# Create a policy that allows read/write to the backup bucket
aws iam create-policy --policy-name backup-robot-policy --policy-document file://backup-robot-policy.json

# Create a user group
aws iam create-group --group-name backup-agents

# Create a custom policy that allows write access to the backup bucket
aws iam create-policy --policy-name backup-agent-write \
    --description "Allows write access to the backup bucket" \
    --policy-document \
'{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RegistryWrite",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl",
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::backups.monodot",
                "arn:aws:s3:::backups.monodot/*"
            ]
        }
    ]
}'

# Attach the policy to the group
aws iam attach-group-policy --group-name backup-agents --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/backup-agent-write


aws iam create-user --user-name vinson-backup-robot

# Add the user to the group
aws iam add-user-to-group --user-name vinson-backup-robot --group-name backup-agents

# Create an access key for the user
aws iam create-access-key --user-name vinson-backup-robot

# Create a bucket for backups
aws s3 mb s3://backups.xxx
```


Then, drop to a shell with access to the Kubernetes cluster where Plausible and Clickhouse are running:

```shell
kubectl -n plausible exec plausible-events-db-0 -- clickhouse-client --query "BACKUP DATABASE plausible_dev TO Disk('backups', 'clickhouse-backup.zip')"

# Copy the zip file to local disk
kubectl -n plausible cp plausible-events-db-0:/tmp/backups/clickhouse-backup.zip ./clickhouse-backup.zip

# Ship it off to AWS
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

aws s3 cp ./clickhouse-backup.zip s3://backups.xxxxxx/plausible/clickhouse-backup-$(date +%F).zip

# Remove the backup file from the Pod
kubectl -n plausible exec plausible-events-db-0 -- rm /tmp/backups/clickhouse-backup.zip

```

#### Native S3 backup in Clickhouse

Clickhouse now has a native `S3` backup target. But this feature doesn't seem to be available in my version of Clickhouse so this is my future plan for backing up:

```shell
BACKUP DATABASE plausible_dev TO S3('https://backups.xxxx.s3.amazonaws.com/backup-S3/clickhouse_backup', 'xxxxxxxxx', 'xxxxxxx')
```

## Operations

### Viewing the latest analytics events in the DB

```shell
clickhouse-client

USE plausible_dev;
SELECT COUNT(*) FROM events;

SELECT name, user_id, session_id, hostname, pathname FROM events ORDER BY timestamp DESC LIMIT 100;

```

## Migrating/updating

```shell
# Start a container running the old DB
podman run --name plausible-db -e POSTGRES_PASSWORD=xxxxxxx -e POSTGRES_USER=plausible -e POSTGRES_DATABASE=plausible -v /opt/plausible/db-data:/var/lib/postgresql/data postgres:12

# Dump all of the DB contents
podman exec plausible-db pg_dumpall -p 5432 -U plausible -l plausible > postgres12dump.sql

# Launch a postgres 14 instance
# (apply some kube yaml here)

# Import the data from 12
kubectl exec -i plausible-db-0 -n plausible -- psql -d plausible -U postgres < postgres12dump.sql
```

## Troubleshooting

### Empty analytics data

- Check that there is data in Clickhouse - go to http://clickhouse:8123/play (or expose it somehow). Use the top-right boxes to provide the username and password for Clickhouse. Then try a query like `SHOW DATABASES` or `select count(*) from SCHEMA_NAME.events`

### Visitor numbers are tiny compared to page visits

- Plausible calculates visitors by hashing IP addresses. If it can't determine the visitor's IP address correctly, or if it's obfuscated by another network component (e.g. a load balancer), then it will be unable to correctly identify the visitor.
- I run Plausible on k3s which includes a load balancer, Traefik. In normal configuration it obfuscates the IP address of the client. To change this, set `hostNetwork: true` in the spec for the `traefik` deployment. This will expose the client's IP address to Plausible. (This is a bit of a hack, but it works.)

