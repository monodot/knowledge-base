---
layout: page
title: Clickhouse
---

Clickhouse is a columnar database used by [Plausible Analytics][plausible].

## Administration

### Run the Clickhouse CLI

Jump inside your Clickhouse container:

```shell
# Podman....
$ podman exec -it clickhouse sh
# Kubernetes....
$ kubectl exec -it clickhouse-0 -- sh
```

Once inside the container, run the Clickhouse cli:

```shell
clickhouse-client --user USER --password PASSWORD --database DATABASE
```

### Dump a table to a TSV file

```shell
clickhouse-client --user USER --password PASSWORD --database DATABASE --query="SELECT * FROM TABLE FORMAT TSVWithNames" > TABLE.tsv
```

### Import a TSV file into a table

```shell
clickhouse-client --user USER --password PASSWORD --database DATABASE --query="INSERT INTO TABLE FORMAT TSVWithNames" < TABLE.tsv
```

### Back up Clickhouse

First create a user and bucket in AWS:

```shell
aws iam create-user --user-name clickhouse-backup

# Attach full access for now, we'll tighten this up later
aws iam attach-user-policy --user-name clickhouse-backup --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create an access key for the user
aws iam create-access-key --user-name clickhouse-backup

# Create a bucket for backups
aws s3 mb s3://backups.xxx
```

Now drop to a shell on the node (or Pod) where Clickhouse is running:

```shell
clickhouse-client --user $CLICKHOUSE_USER --password $CLICKHOUSE_PASSWORD --database $CLICKHOUSE_DB

BACKUP TABLE test.table TO Disk('backups', '1.zip')

BACKUP TABLE events TO S3('https://backups.s3.amazonaws.com/backup-S3/clickhouse_backup', 'xxxxxxxxx', 'xxxxxxx')
```

## Examples

### Run Clickhouse, view users

Run Clickhouse in a container and find out which users are available:

```
$ podman run --rm --name clickhouse  \
  -v $HOME/clickhouse/clickhouse-data:/var/lib/clickhouse \
  -v $HOME/clickhouse-config.xml:/etc/clickhouse-server/config.d/logging.xml:ro \
  -v $HOME/clickhouse-user-config.xml:/etc/clickhouse-server/users.d/logging.xml:ro \
  --ulimit nofile=262144:262144  \
  -p 8123:8123 \
  docker.io/yandex/clickhouse-server:latest

$ podman exec -it clickhouse sh

# clickhouse-client

:) show databases

SHOW DATABASES

Query id: 128bbe62-b95a-4d03-8e30-a356a6aa5979

┌─name───────────────┐
│ INFORMATION_SCHEMA │
│ default            │
│ information_schema │
│ plausible_dev      │
│ system             │
└────────────────────┘

:) use plausible_dev

...

:) show tables

SHOW TABLES

Query id: 4391035e-69be-4086-aa9e-9cca8c35ada0

┌─name──────────────┐
│ events            │
│ schema_migrations │
│ sessions          │
└───────────────────┘

3 rows in set. Elapsed: 0.004 sec.

:) select count(*) from events

SELECT count(*)
FROM events

Query id: b625acfc-d7fc-4534-8811-8227832ef12d

┌─count()─┐
│ 1580194 │
└─────────┘

1 rows in set. Elapsed: 0.004 sec.
```

### Restore Clickhouse

Restore Clickhouse data:

```shell
$ podman exec -it clickhouse sh

# TODO
```

[plausible]: {% link _articles/plausible.md %}
