---
layout: page
title: Keycloak
---

## Terminology

- **Claim configuration**
- **Client**
- **Client scope**
- **Protocol mapper**
- **Token**

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

### Include group membership in a user's token

If you want to include group membership in a user's token, you can do so on a per-client basis:

1.  Navigate to Clients -> (your client app) -> Client scopes.
2.  Click the `client-name-dedicated` scope to edit it.
3.  Click **Configure a new mapper** -> **Group membership**
4.  Enter the details of the new mapper:
        - Name: anything you like
        - Token Claim Name: `groups` (this is the key name it will appear under, in the JSON)
        - Click Save.
5.  The new mapper should appear as Category=Token mapper, Type=Group Membership. 
and click **Add**.
6.  Verify the information is included in the user token by using the **Evaluate** tab (described above).
