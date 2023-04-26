---
layout: page
title: Text manipulation in Linux
---

## Common commands

- `awk`
- `tac` - concatenate and print files in reverse

## Cookbook

### Deduplicating a file

Remove duplicate lines in a file, where **values in one column are the same**, whilst preserving order. For example, removing duplicate properties in a key/value property file (e.g. a Java `.properties` file). Either keep the **first** occurrence of the duplicate column line:

    awk -F'=' '!seen[$1]++' foo.properties

...or keep the **last occurrence** of the duplicate column line:

    tac foo.properties | awk -F'=' '!seen[$1]++' | tac

### Looping over a CSV and extracting some values

If you have a CSV and you want to use the fields in each line as arguments for a command, you can use the [IFS (internal field separator) variable][ifs] to split the line into fields:

```shell
cat > users.csv <<EOF
tom,henlo
david,cheese
EOF

cat users.csv | while IFS=, read -r username password ; do echo $username has a password of $password; done
```

There's an example of this in the [Google Cloud][google-cloud] page.

### Checking if the first part of an email address is longer than N

```shell
cat > emails.txt <<EOF
blah@example.com
EOF

awk -F'@' '{ if (length($1) > 10) { print $1 } }' emails.txt
awk -F'@' '(length($1) > 10)' emails.txt
```

[ifs]: https://www.gnu.org/software/bash/manual/html_node/Word-Splitting.html
[google-cloud]: {% link _articles/google-cloud.md %}
