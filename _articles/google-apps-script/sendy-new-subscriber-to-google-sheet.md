---
layout: page
title: "Google Apps Script: Insert a new Sendy Subscriber into Google Sheets"
---

Yes! You can set up a webhook in Sendy, so that you can add a new row into Google Sheets whenever you get a new mailing list subscriber.

**CAUTION:** If you're running a double opt-in list, **and** the user is using Google Mail, then the 'new subscriber' notification is sometimes sent **TWICE**: once when they click on the confirmation link, and once by Google itself (because it does some snooping on the link to check that it's safe.)

## Setup

To install, follow these steps.

### 1. Set up the script in Google Docs

1. Create a Google Sheet with 5 columns:

    - Date/Time

    - Trigger

    - Subscriber Name

    - List

    - Source URL (or a custom field of your choice)

2. Go to Tools &rarr; Script Editor.

3. Create the three files listed below:

    - _Function.gs_

    - _Interface.gs_

    - _Test.gs_

4. Save.

5. Deploy &rarr; New Deployment:

    - Type: Web app

    - Description: (anything you like)

    - Execute as: (you)

    - Who has access: Anyone

6. Click Deploy. You'll then need to authenticate to Google to allow the script to make changes to your spreadsheet.

7. You should get a URL to the Web app that usually looks like: _https://script.google.com/macros/s/.../exec_. Copy this URL to paste into Sendy.

**NOTE:** When you make any future updates to the script, you need to redeploy it. In Script Editor, click **Deploy** &rarr; Manage Deployments. Then, **Edit** the active deployment. select Version &rarr; New Version, to update the Deployment with the current version of the code, and click **Deploy.**

### 2. Increase the webhook field length in Sendy

You also need to increase Sendy's `rules.endpoint` db column size to 255 chars, because the Google Webhook URL is too long to fit in Sendy's default 100 character limit.

An example of how to do this:

```
$ sudo su -
$ mysql

mysql> use sendy;
mysql> select endpoint from rules;
mysql> alter table rules modify endpoint varchar(255);
```

### 3. Configure Sendy to trigger the Webhook

Once you've published the web app, configure a trigger in Sendy:

1. Log on to Sendy.

1. Organisation &rarr; Rules.

2. Create a new rule &rarr; On Subscribe &rarr; (Pick a list) &rarr; Trigger Webhook.

3. Paste in the URL to the Google Script (URL usually looks like: _https://script.google.com/macros/s/.../exec_)

Now Sendy will invoke the webhook whenever there's a new subscriber!

## Script source code

Here are the three files that make up this script.

### Function.gs

```js
/*
 * Adds a subscription 'event' into the spreadsheet.
 */
function registerSubscriptionEvent(trigger, name, listName, sourceUrl) {
  // Add the data into the sheet
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheets()[0];

  var now = new Date();

  sheet.appendRow([
    Utilities.formatDate(now, 'Etc/GMT', 'yyyy-MM-dd HH:mm:ss'),
    trigger,
    name,
    listName,
    '',
    sourceUrl]);
}
```

### Interface.gs

```js
function doPost(event) {

  // To invoke this function from Sendy,
  // 1. Add a new Custom Field to the list: "SourceURL"
  // 2. Rules > Create new rule > On Subscribe > Invoke Webhook > Paste URL to this script on google.com


  Logger.log("Received post data: %s", event.postData?.contents);

  registerSubscriptionEvent(
    event.parameter?.trigger,
    event.parameter?.name,
    event.parameter?.list_name

    // Any other custom fields you have, e.g.:
    , event.parameter?.SourceURL
  );

  return ContentService.createTextOutput('Thanks man');
}

function doGet() {
  return ContentService.createTextOutput('This service does not support GET. Bye!');
}
```

### Test.gs

This is just a test harness that you can use:

```js
function testDoPost() {
  var event = {
    postData: {
      contents: "trigger=subscribe&name=Horseface&email=mylovelyhorsetest%40gmail.com&list_id=yuMPn8Q9nHm0jpn65d763hZA&list_name=Lovely+Newsletter&list_url=https%3A%2F%2Fsendy.example.co.uk%2Fsubscribers%3Fi%3D2%26l%3D2&gravatar=https%3A%2F%2Fwww.gravatar.com%2Favatar%2Faaaaaaaaaa%3Fs%3D88%26d%3Dmm%26r%3Dg"
    }
  };

  doPost(event);

}
```