---
layout: page
title: Keycloak
---

## Terminology

### Client > Client scopes

Some built-in client scopes are:

- openid - use this scope to signal that you're using OpenID Connect
- profile
- acr
- address
- basic
- email
- microprofile-jwt
- offline_access
- organization
- phone
- profile
- roles
- web-origins

## Cookbook

### Evaluate scopes and view a generated access token

Go to Clients -> (client name) -> Client scopes -> Evaluate.

This allows you to see **protocol mappers** in action, and effectively see what a generated access token would look like, with the current settings.

This is very useful when integrating other apps with Keycloak, to see what data will be shared with the third party app.
