---
layout: page
title: Playwright
---

A funky browser automation framework.

## Usage

### Recording new tests

```
npx playwright codegen https://mywebsite.example.com
```

## Cookbook

### Testing xterm

```js
// Open the web terminal and log in
test.beforeEach(async ({ page }) => {
    await page.goto(process.env.WETTY_URL);

    // Check that we can see the string "login:"
    const line1 = page.locator(`#terminal .xterm-rows div:nth-child(2):not(.xterm-cursor)`);
    await expect(line1).toContainText('login:', {timeout: 5000});

    await page.keyboard.type(process.env.USERNAME, {delay: 100});
    await page.keyboard.press("Enter");

    await page.keyboard.type(process.env.PASSWORD, {delay: 100});
    await page.keyboard.press("Enter");

    // If we're logged in, "username@" will be somehwere on the screen
    const line7 = page.locator(`#terminal .xterm-rows`);
    await expect(line7).toContainText(`${process.env.USERNAME}@wetty`, {timeout: 5000});
});
```

