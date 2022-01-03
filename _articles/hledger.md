---
layout: page
title: hledger
---

The plaintext accounting software.

{% include toc.html %}

## Client applications

### hledger-web

This is a webby interface onto an hledger file. Install and run:

```
dnf install -y hledger-web
hledger-web
```

### hledger-ui

This is an _ncurses_ style terminal interface for managing an hledger file. To run the UI from the command line:

```
EDITOR=vim hledger-ui
```

Or, run the UI in a container with _podman_:

```
podman run --rm -e HLEDGER_JOURNAL_FILE=/data/ledger-2021.journal -v "$(pwd):/data:Z" -p 5000:5000 dastapov/hledger
```

## Examples

How I do things.

### Example header

To set some common settings, at the top of the hledger file:

```
; set a default commodity display style
D £ 1,000.00

; Declare top level accounts, setting their types and display order;
; Replace these account names with yours; it helps commands like bs and is detect them.
account Assets       ; type:A, things I own
account Liabilities  ; type:L, things I owe
account Equity       ; type:E, net worth or "total investment"; equal to A - L
account Revenues     ; type:R, inflow categories; part of E, separated for reporting
account Expenses     ; type:X, outflow categories; part of E, separated for reporting

alias amex = Liabilities:Credit Card:Amex
alias tsb = Liabilities:Credit Card:TSB
```

### Salary and Tax

Recorded as a positive amount into my "current account" asset, and a negative amount from _Income_:

```
2020-09-25 WILLY WONKA LTD  ;
    Assets:Current Account               £ 1,200.00
    Income:Willy Wonka:Salary           £ -2,000.00
    Income:Willy Wonka:Bonus            £    -50.00
    Expenses:Tax:PAYE                      £ 500.00
    Expenses:Tax:National Insurance        £ 150.00
    Expenses:Tax:PSE AE                    £ 200.00
```

## Cookbook

Some tips and tricks I've learned when working with _hledger_.

### Set up an environment

If you're going to be running lots of _hledger_ commands, set `LEDGER_FILE` to point to your current ledger file, so you don't need to specify it with every command:

```
export LEDGER_FILE=$(pwd)/my-ledger-2021.journal
```

### Closing a financial year and starting a new one

Use the `hledger close` command (I usually go with the UK tax year, which runs from 6th April to 5th April the following year):

```
$ hledger close -e 2021-04-05

$ hledger close -f 2021.journal --end 2021-04-06 assets liabilities --open  >> 2022.journal  # add 2022's first transaction
$ hledger close -f 2021.journal --end 2021-04-06 assets liabilities --close >> 2021.journal  # add 2021's last transaction
```

### Get most recent transaction dates

When importing new records from a bank, you might want to check first which is the most recent transaction date; e.g. to find the most recent _Amex_ transaction:

```
hledger print "Amex" -Ocsv | tail -n 1
```

### Add a transaction manually

```
hledger add
```

### Importing transactions

Import transactions from a bank:

```
tac $FD_FILE | head -n-1 | hledger import -f ledger-2021.journal --rules-file mybank.csv.rules -
```

### Show register of transactions

The register shows all the details of transactions:

```
$ hledger register
2020/01/02 Tesco Store London               Expenses:Groceries                      17.72         17.72
                                            Li:Credit Card:Amex Gold               -17.72             0
2020/01/02 Pure London                      Expenses:Groceries                       2.40          2.40
                                            Li:Credit Card:Amex Gold                -2.40             0
```

### Show pending transactions

Show uncleared transactions (e.g. I use this for expense transactions which are awaiting reimbursement):

```
hledger register -P
```

### Print transactions after a certain date

To print transactions since a date, in valid hledger journal format:

```
hledger print --begin=2020/04/06
```

### Show balances as of a given date (useful for reconciling)

Show balances up to 2015-01-01:

```
hledger bal date:-2015/01/01
```

### Print transaction register in tabular format

Useful output for reconciling:

```
$ hledger reg MyBank
2020-09-26 Exmouth Coffee Company          Liabilities:Credit Card:MyBank       £ -2.50     £ -703.30
2020-09-28 DIRECT DEBIT PAYMENT -          Liabilities:Credit Card:MyBank      £ 442.72     £ -260.58
2020-09-28 Spotify UK                      Liabilities:Credit Card:MyBank       £ -9.99     £ -270.57
2020-10-01 Google GSuite                   Liabilities:Credit Card:MyBank       £ -4.97     £ -275.54
```

### Print transaction register between given dates (including _historical_ balance info)

```
hledger register current --historical date:2020/09/20-2020/10/19
```

### Print all credit card transactions (except payments) in a statement period

Useful to reconcile against the credit card statement and find out exactly how much you spent in a given month (statement period):

```
hledger register amex date:2021/11/16-2021/12/15
```

## Reports

Monthly report showing all categories under _"Expenses"_ by month:

```
hledger balance -MA --depth 2 Expenses
```

Show **income and expense statement** for this year:

```
hledger incomestatement -MA -b $YEAR
```

## Rules

### Sample hledger rules file for First Direct

Export a CSV from First Direct, then:

```
# skip the first CSV line (headings)
#skip 1

# define the fields to use from each CSV record
fields   date, description, amount

# prepend £ to CSV amounts
# currency £

# date is in UK/Ireland format
date-format  %d/%m/%Y

# always set the transaction FROM lloyds card TO uncategorised
account1 Assets:Current Account
account2 Expenses:Uncategorised

if VIRGIN MEDIA
  account2 Expenses:Home:Internet
if TV LICENCE
  account2 Expenses:Home:TV
if RENT COMPANY
  account2 Expenses:Home:Rent
```

## Troubleshooting

### well-formed but invalid date when importing a CSV

Problem with hledger 1.18.1:

- `hledger import` expects the import file to end with `.csv`. If it does not, _hledger_ seems to ignore your custom CSV rules file.
- Workaround: make sure the file you are importing is in a physical file on disk, and that it ends with `.csv`.
- Example command: `hledger import --rules-file fd.rules --dry-run --debug=9 $CSV_FILE.modded.csv`

