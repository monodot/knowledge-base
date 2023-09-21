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

## Fixtures

Fixtures are a way of defining reusable code that can be run before or after Playwright tests. They can be used to set up a test environment, or to clean up after a test.

### Example: defining two fixtures to use in tests

Here we define a fixture, `wettySession`, which will log in to a web terminal, run the tests, and then log out. 

```js
// fixtures.js
import { test, expect } from '@playwright/test';

const wettytest = test.extend({
    // Define a fixture. Whenever this is referenced in a test,
    // it will basically wrap the test with a login and a logout.
    wettySession: async ({ page }, use ) => {
        console.log(`Logging in to ${process.env.WETTY_URL} as ${process.env.USERNAME}`);
        await page.goto(process.env.WETTY_URL);
    
        await page.keyboard.type(process.env.USERNAME, {delay: 100});
        await page.keyboard.press("Enter");
        await page.keyboard.type(process.env.PASSWORD, {delay: 100});
        await page.keyboard.press("Enter");
    
        await use(page); // Now run the tests we've been told to do

        // Log out of the web terminal
        await page.keyboard.press("Control+D");
        await page.close();
    }

});

const _wettytest = wettytest;
export { _wettytest as wettytest };
```

Then in your test, use the `wettySession` fixture, instead of the usual `page` one:

```js
// myapp.spec.js
const { wettytest } = require('./fixtures');

wettytest('can get list of nodes in the user\'s k8s cluster', async ({ wettySession }) => {
    await wettySession.keyboard.type("echo henlo", {delay: 100});
    await wettySession.keyboard.press("Enter");
});
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

