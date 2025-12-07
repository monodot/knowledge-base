---
layout: page
title: Xcode
lede: Xcode is the worst IDE of all time.
---

## Troubleshooting

### Cannot test target “APP_NAME” on “Any iOS Simulator Device”: Tests must be run on a concrete device

You can't run tests on the _Any iOS Simulator Device_ pseudo-device (which is usually found under the _Build_ heading).

In the navigator bar at the top of Xcode, choose a specific iOS Simulator device (like "iPhone 16"), or a real physical device.
