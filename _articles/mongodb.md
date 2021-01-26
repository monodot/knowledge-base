---
layout: page
title: MongoDB
---

MongoDB is a document store.

{% include toc.html %}

## Cookbook

### Run in a container

Running a simple Mongo container:

    $ docker run --rm --name mongo -d -p 27017:27017 mongo

### Import bulk data with mongoimport

Useful for pipelines. Replace a bunch of documents defined in a JSON file, using `upsert` to replace documents matching the same `name`:

    $ mongoimport --host=mongodb.example.com:27017 \
        --db ${DATABASE_NAME} --collection ${COLLECTION_NAME} \
        --upsert --upsertFields=name --file organisations.json --jsonArray \
        --username=${MONGODB_USERNAME} --password=${MONGODB_PASSWORD}

## GUIs

- [Azure Cosmos DB plugin for VS Code][azurecosmosdb]


[azurecosmosdb]: https://code.visualstudio.com/docs/azure/mongodb
