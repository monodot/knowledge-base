---
layout: page
title: Playwright
---

A funky browser automation framework.

## Installation

### Installing Playwright in a container

Installing Playwright in a container seems to be a whole level of faff, because it doesn't like being installed as a `global` package. (And I'm probably also misusing global packages). But this seems to work:

1.  Create a skeleton `package.json` in a parent directory to where your tests are located.

1.  `npm install @playwright/test`, to add Playwright as a dependency.

1.  In your Dockerfile:

    ```dockerfile
    # Install dependencies that Playwright needs to control browsers
    USER root
    RUN apt-get install -y libglib2.0-0 \
        libnss3 \
        libnspr4 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libcups2 \
        libdrm2 \
        libdbus-1-3 \
        libxkbcommon0 \
        libatspi2.0-0 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxrandr2 \
        libgbm1 \
        libpango-1.0-0 \
        libcairo2 \
        libasound2    

    USER workshop

    # Ownership of the end-to-end tests and their dependencies should probably
    # be owned by the user that will execute them
    RUN mkdir -p /home/myapp/tests
    COPY tests/package.json /home/myapp/tests/package.json
    COPY tests/e2e /home/myapp/tests/e2e
    WORKDIR /home/myapp/tests
    RUN npm install && \
        npx playwright install chromium 
    ```

1.  Then in your container, make sure you run the tests from the directory where your package.json is located. For example, from a shell script you might do this:

    ```shell
    (cd "/home/myapp/tests" && \
        export SOME_VAR="blahblahblah" && \
        npx playwright test /home/myapp/tests/e2e/myapp.spec.js --config "$/home/myapp/tests/e2e/playwright.config.myapp.js --workers 3
    )
    ```

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

