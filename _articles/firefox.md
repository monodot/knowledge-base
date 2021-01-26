---
layout: page
title: Firefox
---

## Troubleshooting

Gmail won't open, with _"Temporary Error"_, and the Fraidycat extension doesn't work:

- There was [a bug][bug] in Firefox 82 on Fedora. Upgrade to 82.0.2-3

Some websites display a white screen. When you inspect the console, the error _"Uncaught DOMException: The quota has been exceeded."_ is logged. (Seen in Fedora 33, Jan 2021)

- I seemed to resolve the issue by clearing cookies and site data (Firefox &rarr; Preferences &rarr; Privacy and Security &rarr; Clear Data)
- Test your Firefox's local storage limit using <https://arty.name/localstorage.html>. My result said _"5200000 characters were stored successfully, but 5300000 weren't."_, so I'm able to store 5Mb-ish.
- 

[bug]: https://bugzilla.redhat.com/show_bug.cgi?id=1893474
