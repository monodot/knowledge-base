---
layout: page
title: Ezoic
---

For the ads.

## Troubleshooting

### Stylesheet caching problems (for Cloudflare integration)

Cloudflare caches CSS, which means that if you update a CSS file on your site, users might still see the old styles.

"Clear Optimization Settings" in Ezoic Leap doesn't seem to fix this. The stale file still seems to be served from the Cloudflare cache.

So:

1.  Deploy the CSS changes as normal.

1.  Log in to Cloudflare Dashboard &rarr; Caching &rarr; Configuration &rarr; Purge Cache.

1.  Do a Custom Purge for your stylesheet URL (e.g. `https://www.example.com/assets/style.css`)

Give it 30 seconds, and the updated CSS should be available.

See also: <https://support.ezoic.com/kb/article/67>
