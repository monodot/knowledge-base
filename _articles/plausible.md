---
layout: page
title: Plausible Analytics
---

## Migrating/updating

```
# Start a container running the old DB
podman run --name plausible-db -e POSTGRES_PASSWORD=xxxxxxx -e POSTGRES_USER=plausible -e POSTGRES_DATABASE=plausible -v /opt/plausible/db-data:/var/lib/postgresql/data postgres:12

# Dump all of the DB contents
podman exec plausible-db pg_dumpall -p 5432 -U plausible -l plausible > postgres12dump.sql

# Launch a postgres 14 instance
# (apply some kube yaml)

# Import the data from 12
kubectl exec -i plausible-db-0 -n plausible -- psql -d plausible -U postgres < postgres12dump.sql
```

## Troubleshooting

Empty analytics data:

- Check that there is data in Clickhouse - go to http://clickhouse:8123/play (or expose it somehow). Use the top-right boxes to provide the username and password for Clickhouse. Then try a query like `SHOW DATABASES` or `select count(*) from SCHEMA_NAME.events`

