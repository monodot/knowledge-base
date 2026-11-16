---
layout: page
title: Google Sheets
---

Spreadsheeting webapp.

## Cookbook

### Highlight entire row based on cell value

This allows you to change the background colour of an entire row, based on the value in one specific cell in the row:

1.  Go to Conditional Formatting > Add a rule
2.  Apply to range: **A-Z**
3.  Format cells if **Custom formula is** : **=$C1="Completed"** (assuming your 'status' column lives in Column C), then format to **green**
4.  Add another rule for the remaining values (e.g. "blocked" is _red_, etc.)
