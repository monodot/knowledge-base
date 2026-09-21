---
layout: page
title: iOS Development
lede: Developing apps for iPhone and iPad
---

## Checklist for releasing an app

- **Monetisation:**
    - **Use a Sandbox account to test purchases (local Xcode/dev builds only):** Create a separate Sandbox account in App Store Connect -> Users and Access -> Sandbox. Set a password. On the test device, go to Settings -> Developer -> Sandbox Apple Account, sign in with the Sandbox account. When prompted, make sure to **not** go through account security upgrade as it will ask you to validate your email and phone number. Then, from Xcode, Run the app on the device.
    - **With a TestFlight build, test with your real Apple ID:** (no money will be taken)

## Monetisation and In-App Purchases

### Terminology

- **off-device-buy:** this is where a transaction was not initiated on the local device/app session, so the app should be able to detect and handle a previously completed purchase (e.g. Restore Purchases)

### .storekit files

`.storekit` file is a way to have a local mock of the App Store during development. If this file is active, StoreKit in your app doesn't talk to Apple's servers, but reads product details from the local file.

A `.storekit` file can also be optionally synced with App Store Connect, which just makes it easier to test with a list of products you've already defined "for real" in ASC, without having to type them all in locally.

- **synced** configs are fine for running an app (e.g. on a physical device), **NOT** for programmatic tests.
- **unsynced** configs are preferred for programmatic tests

## Troubleshooting

### Provisioning profile "iOS Team Store Provisioning Profile: com.example.Bundle" doesn't include the com.apple.xxx entitlement

- The local distribution provisioning profiles are out-of-date - they are missing some new capabilities that the app now needs (e.g. Push Notifications)
- Remove existing cached provisioning profiles: `rm ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles`

