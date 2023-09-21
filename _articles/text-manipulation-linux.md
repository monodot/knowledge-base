---
layout: page
title: Text manipulation in Linux
---

## Common commands

- `awk` - pattern scanning and processing language
- `sed` - stream editor
- `tac` - concatenate and print files in reverse

## sed

_sed_ is a stream editor. It's useful for manipulating text in files, or as part of a pipeline.

### Replace a string in a file

```shell
sed -i 's/old/new/g' file.txt
```


## Cookbook

### Deduplicating lines in a file which have the same column value

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

### Looping over a username:password list and creating a command for each

Useful for performing the same action repeatedly, e.g. perform an HTTP request, test an app, etc.

If you have a list of usernames/passwords like this:

```
john:mypass
jane:password123
jacob:thankyougoodnight
```

You can use `read` and a `while` loop to generate some commands like this - this example runs a _Playwright_ test for each user:

```shell
while IFS=":" read -r username password
do
    APPLICATION_URL="https://$username.grafana.net" USERNAME="$username" PASSWORD="$password" npx playwright test my-app-test.spec.js
done <<< "$LOGINS"
```

[ifs]: https://www.gnu.org/software/bash/manual/html_node/Word-Splitting.html
[google-cloud]: {% link _articles/google-cloud.md %}
