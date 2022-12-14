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

### Back up Clickhouse

Back up Clickhouse data (TODO):

```
# BACKUP TABLE events TO S3('https://backups.s3.amazonaws.com/backup-S3/clickhouse_backup', 'xxxxxxxxx', 'xxxxxxx')

# clickhouse-client --query="SELECT * FROM plausible_dev.events FORMAT TSVWithNames" > /var/lib/clickhouse/plausible_dev.events.tsv

# clickhouse-client --query="SELECT * FROM plausible_dev.schema_migrations FORMAT TSVWithNames" > /var/lib/clickhouse/plausible_dev.schema_migrations.tsv

# clickhouse-client --query="SELECT * FROM plausible_dev.sessions FORMAT TSVWithNames" > /var/lib/clickhouse/plausible_dev.sessions.tsv
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
