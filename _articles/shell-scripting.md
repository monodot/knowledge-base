---
layout: page
title: Shell scripting
---

## Templates

### Simple bash script with positional arguments

```bash
#!/bin/env bash

# This script does something
# Usage: ./myscript.sh arg1 arg2

# Exit on error
set -e

# Exit on unset variable
set -u

# Print commands as they are executed
set -x

# Set variables
myArg1=$1
mySecondArg=$2

# Do stuff
echo "Hello world, $myArg1, $mySecondArg"
```

### Variables with values from positional arguments

```bash
local my_first_arg=${1:-default_value}
local my_second_arg=${2:-default_value}
```

## Cookbook

### Working with variables

#### Sourcing some variables from an external script

```
source /path/to/myscript.sh
```

#### Default values for variables

Using a default value of `example.com` if `REMOTE_URL` isn't set:

```
someVar="http://${REMOTE_URL:-example.com}"
```

#### Test if a variable is not null

```
if [ -z "${sslProvider}" ] ; then
  # Do stuff
fi
```

#### Receiving simple command-line arguments

```
myArg1=$1
mySecondArg=$2
```

### Editing files

#### Replacing a placeholders in a file

Replace the file "in-place" (`-i` switch):

```
sed -i "s/\${BROKER_IP}/$BROKER_IP/g" myfile.txt
```

### Loops

#### While loop (do something forever)

```
while true ; do time curl $GATEWAY_URL ; sleep .1 ; done
```

### Arrays

#### Converting a comma-separated list into an array

```
IFS=',' read -a thingies <<< "apples,bananas,cats,meow"
# thingies is now an array
```

### Functions

#### Defining a custom function

```
function my_function_name() {
   # stuff goes here
}
```
