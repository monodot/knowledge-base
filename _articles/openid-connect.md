---
layout: page
title: OpenID Connect (OIDC)
---

## Cookbook

### Making a login request to an OpenID Connect Server (Not Tested)

```
curl -X https://login.microsoftonline.com/MY_TENANT_ID/oauth2/v2.0/authorize?
  client_id=YOUR_APPLICATION_ID
  &redirect_uri=https://openidconnect.net/callback
  &scope=openid profile
  &response_type=code
  &state=SOME_VALUE_GOES_HERE_NOT_SURE_WHAT
```

This will return a code (e.g. `0.AUYAbvDmnoOQOkGRF5FFh.....`)

### Getting an Access Token from a Code (Not Tested)

Assuming you have a code (looks like `0.AUYA...`):

```
curl -X POST
  https://login.microsoftonline.com/MY_TENANT_ID/oauth2/v2.0/token
  -d grant_type=authorization_code
  -d client_id=YOUR_APPLICATION_ID
  -d client_secret=YOUR_CLIENT_SECRET
  -d redirect_uri=https://yourapp.example.com/callback
  -d code=${THE_CODE}
```

This should return a token, like this:

```
HTTP/1.1 200
Content-Type: application/json
{
  "token_type": "Bearer",
  "scope": "openid profile email",
  "expires_in": 5069,
  "ext_expires_in": 5069,
  "access_token": "eyJ0eXAiOi......",
  "id_token": "eyJ0eXA......"
}
```

