---
layout: page
title: Swift Testing
lede: "Testing Swift applications for iOS"
---

## XCTest

### Verify an onboarding flow shows at first launch

```swift
@MainActor
func testOnboardingShowsAtFirstLaunch() throws {
    let app = XCUIApplication()
    app.launchArguments = ["-\(UserDefaultsKeys.onboardingCompleted)", "NO"]
    app.launch()
    
    XCTAssertTrue(app.staticTexts["Some Onboarding Screen Text"].waitForExistence(timeout: 5)) // Wait for the first onboarding screen to show
    XCTAssertTrue(app.buttons["The Next Button"].exists)
}
```
