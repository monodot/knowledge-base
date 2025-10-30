---
layout: page
title: PostgreSQL
---

## Deployment

### Installing PostgreSQL on Fedora

    sudo dnf install postgresql

### Running on MacOS with Homebrew

Homebrew creates data directories in `/usr/local/var/postgres`.

To get _launchd_ to start postgresql now and restart it at login:

    brew services start postgresql

Or, if you don't want/need a background service you can just run:

    pg_ctl -D /usr/local/var/postgres start

Then to connect:

    psql -d postgres

## Using the `psql` command line tool

### Connecting to an instance with `psql`

To connect to a PostgreSQL instance, first install the `psql` command line tool for your operating system. Then:

    psql --password --host dbhost1 --port 5432 --username scott megacorp

    psql -W -h dbhost1 -p 5432 -U scott megacorp

### Special commands you need to know

The list of bizarre commands you need to basically memorise to view database information.

Once you're connected to the database, execute SQL or use the following commands:

- `\du+` - list users
- `\dt` - list tables
- `\d table_name` - describe table
- `\l` - list all databases
- `\l+` - list all databases, with a bit of extra info
- `\c database_name` - connect to database
- `\q` - quit
- `\?` - help

### Users and permissions

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
