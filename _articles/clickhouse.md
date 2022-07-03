---
layout: page
title: Clickhouse
---

## Some examples

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

