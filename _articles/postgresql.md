---
layout: page
title: PostgreSQL
---

## Running

### Running with Homebrew

Homebrew creates data directories in `/usr/local/var/postgres`.

To have launchd start postgresql now and restart at login:

    brew services start postgresql

Or, if you don't want/need a background service you can just run:

    pg_ctl -D /usr/local/var/postgres start

Then to connect:

    psql -d postgres

## Users and permissions

List all roles:

    \du

Create user:

    CREATE USER james WITH ENCRYPTED PASSWORD 'l0velypass';

Create a database:

    CREATE DATABASE testdb;

Grant privileges:

    GRANT ALL PRIVILEGES ON DATABASE testdb TO james;

## Troubleshooting

_"ERROR: could not serialize access due to read/write dependencies among transactions ... Reason code: Canceled on identification as a pivot, during write ... The transaction might succeed if retried."_

- Possible transaction conflict. Try using `SELECT ... FOR UPDATE SKIP LOCKED` within a transaction to ensure that any rows to be modified are locked first and the client is not blocked waiting for rows locked by other transactions.
