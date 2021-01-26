---
layout: page
title: hledger
---

Some tips and tricks I've found useful for working with hledger.

Show the register of transactions:

    $ hledger register
    2020/01/02 Tesco Store London               Expenses:Groceries                      17.72         17.72
                                                Li:Credit Card:Amex Gold               -17.72             0
    2020/01/02 Pure London                      Expenses:Groceries                       2.40          2.40
                                                Li:Credit Card:Amex Gold                -2.40             0

Show pending transactions (uncleared, e.g. awaiting expense repayment):

    hledger register -P

Print transactions after a certain date, in valid hledger journal format:

    hledger print --begin=2020/04/06

