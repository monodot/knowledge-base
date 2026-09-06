---
layout: page
title: Xcode
lede: Xcode is the worst IDE of all time.
---

## Running and debugging

### Test changes to a Watch app on a physical Watch

For an Xcode project with an independent Watch target, you should select the Watch target.

1.  (Optional but recommended) Connect your phone to the Mac using a USB cable.
1.  In Xcode, select the **watch app** from the **Scheme** dropdown at the top of the IDE.
2.  Select the **physical watch** as the **Destination**.
3.  Click **Run** (or Cmd+R).

## Screenshots

### Take a screenshot

To take a screenshot from a physical device:

1.  From Xcode, open **Window > Devices & Simulators**
2.  Select the device in question.
3.  Click **Take Screenshot**.

## Troubleshooting

### Cannot test target “APP_NAME” on “Any iOS Simulator Device”: Tests must be run on a concrete device

You can't run tests on the _Any iOS Simulator Device_ pseudo-device (which is usually found under the _Build_ heading).

In the navigator bar at the top of Xcode, choose a specific iOS Simulator device (like "iPhone 16"), or a real physical device.
