---
layout: page
title: Discourse
---

## Start/stop

    cd /var/discourse
    sudo ./launcher start app

And to stop:

    sudo ./launcher stop app

## Troubleshooting

Logs are located in `/var/discourse/shared/standalone/log/rails/production.log`.

To **rebuild Discourse** (e.g. after a config change): `cd /var/discourse; ./launcher rebuild app`

Initial activation email not working, due to the From address not being recognised by SMTP provider (Mailgun):

- Set the initial 'from' address manually, by uncommenting this line in `app.yml`: `exec: rails r "SiteSetting.notification_email='forum@mg.example.com'"`
- Rebuild Discourse

