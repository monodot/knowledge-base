---
layout: page
title: Netlify
---

Notes on hosting sites on Netlify.

## Using external DNS (Cloudflare)

- From Netlify:
  - _"If you’re using external DNS, we strongly recommend setting the www subdomain (or another subdomain) as your primary domain. If you want to set an apex domain as your primary domain, we recommend using Netlify DNS. Our blog post How to Set Up Netlify DNS has more details on these recommendations."_
  - _"If you set the www subdomain as your primary domain, Netlify will automatically redirect the apex domain to the www subdomain."_

1.  Set primary domain to "www": Go to Netlify &rarr; Sites &rarr; (the site you want to change) &rarr; Custom Domains &rarr; www.yoursite.com &rarr; **Set as primary domain.**

2.  Ensure that there are 2 entries in the domains list for the site in Netlify - one apex (naked) domain like _example.com_ and one with the www prefix like _www.example.com_

In Cloudflare:

1.  Add the domain you want to proxy from Cloudflare.

2.  Add a CNAME record, host field `@` and value `apex-loadbalancer.netlify.com`

3.  Add a CNAME record, host field `www` and value `your-site.netlify.app`

