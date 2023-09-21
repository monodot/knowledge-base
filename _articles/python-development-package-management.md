---
layout: page
title: Python development and package management
lede: Python has a few different tools for managing packages and virtual environments.
---

## Tools

Python is often used in conjunction with a few different tools:

*   [pyenv](https://github.com/pyenv/pyenv) -- Python version manager.\
    <i>pyenv</i> can install and manage multiple versions of Python itself on your computer. Useful if a program needs a different version of Python than the one that comes with your OS.

*   [pipenv](https://pipenv.pypa.io/en/latest/) -- Python virtualenv management tool.\
    Pipenv automatically creates and manages a <i>virtualenv</i> for your projects, adding and removing packages from your `Pipfile` as you install/uninstall packages.

## Using PyPI

PyPI is the Python Package Index.

Don't install anything from PyPI as root. Use a virtual environment:

    sudo yum install python-setuptools python-virtualenv
    virtualenv /opt/myapp
    source /opt/myapp/bin/activate
    # Now install anything from PyPI into this virtual environment

(Fedora) To install a Python3 PyPI package into your home directory:

    pip3 install --user my-package-name

## Using pip

If a python upgrade has messed up `pip`, then you can run `pip` against a specific version of Python:

    python3.5 -m pip <command> <args>

You can also edit the `pip` script and modify the shebang line at the top:

    #!/usr/local/opt/python3/bin/python3.6

## Setuptools

Setuptools is a way of installing Python packages.

They will usually be installed into `~/.local/bin`.

## Packages

### Weasyprint

```
pip3 install --user weasyprint
```


