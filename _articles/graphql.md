---
layout: page
title: GraphQL
---

## Example GraphQL schema

This is a photo album schema, taken from the AWS Amplify workshop:

```
type Album
@model
@auth(rules: [{allow: owner}]) {
    id: ID!
    name: String!
    photos: [Photo] @connection(keyName: "byAlbum", fields: ["id"])
}

type Photo
@model
@key(name: "byAlbum", fields: ["albumId"], queryField: "listPhotosByAlbum")
@auth(rules: [{allow: owner}]) {
    id: ID!
    albumId: ID!
    album: Album @connection(fields: ["albumId"])
    bucket: String!
    fullsize: PhotoS3Info!
    thumbnail: PhotoS3Info!
}

type PhotoS3Info {
    key: String!
    width: Int!
    height: Int!
}
```