---
layout: page
title: Ruby
---

{% include toc.html %}

## Concepts and ecosystem

### Rubygems

Rubygems is a package manager for Ruby. It provides a standard format for distributing Ruby programs and libraries (in a self-contained format called a "gem"), a tool designed to easily manage the installation of gems, and a server for distributing them.

### Bundler

Bundler is a tool that manages gem dependencies for Ruby projects. It can manage any gem available in RubyGems format, including Rails and plugins. It can manage local gems, git repositories with subdirectories containing gems, and gems on remote gem servers.

## Installation and configuration

### Managing versions with `rvm`

[RVM is a command-line tool][rvm] which allows you to easily install, manage, and work with multiple ruby environments from interpreters to sets of gems.

RVM will install ruby into `~/.rvm`, e.g. `~/.rvm/rubies/ruby-2.6.3/bin/ruby`.

Update rvm to latest stable version:

    $ rvm get stable

List rubies installed:

    $ rvm list

    rvm rubies

    =* ruby-2.3.0 [ x86_64 ]

    # => - current
    # =* - current && default
    #  * - default

List known rubies:

    $ rvm list known

#### Install a new ruby

Install a new ruby - this may do things like installing requirements and compiling ruby from source:

    $ rvm install 2.6
    $ rvm --default use 2.6

Any installed gems are tied to a particular version of ruby. So, to reinstall gems against the new ruby version (assuming you're using `bundler` to manage dependencies):

    $ gem install bundler
    $ BUNDLE_GEMFILE=/path/to/your/Gemfile bundle install --system
    $ BUNDLE_GEMFILE=/path/to/your/Gemfile bundle install   # OR to install gems locally

### Fedora: Managing versions with `rubypick`

RubyPick is the Fedora Ruby manager.

Install Ruby:

    $ sudo dnf install ruby

### Mac: Managing versions with `rbenv` and Homebrew

Homebrew can be used to install Ruby and related tools, using the following formulae:

- `ruby-build` - Install various Ruby versions and implementations. If you need a specific version of Ruby, then upgrade ruby-build first using `brew update && brew upgrade ruby-build`
- `rbenv` - Manages global and local versions of Ruby in use

#### Using rbenv

To list the versions installed:

    $ rbenv versions
      system
    * 2.3.0 (set by /Users/tdonohue/.rbenv/version)

To **set** the version of Ruby used in a local directory:

    $ rbenv

To **install** a version of Ruby (if the desired version is missing from the list, do a `brew upgrade ruby-build` first):

    $ rbenv install 2.3.1

- Note that changing versions means that any _gems_ installed -- such as `jekyll` or `bundle` -- will also need to be installed in the new version.

# Concepts and tools

**gems** are packages for Ruby. Some of the common ones:

- **jekyll** - CLI tool for building static websites
- **bundler** - provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed

## Developing with Ruby

### Methods 

#### Methods with named arguments

Ruby 2.1 introduced _required keyword arguments_, which are defined with a trailing colon. [^3]

This method `write` has 3 required keyword arguments, `file`, `data` and `mode`. [^2]

```
def write(file:, data:, mode: "ascii")
end
```

It can be called like this:

```
write(data: 123, file: "test.txt")
```

### Cheatsheet

- `:foo` - identifier with a colon in front of it. This references a _symbol_ named foo. Symbols are unlike strings, in that they are immutable. [^1]

#### Logging

```ruby
require 'logger'

STDOUT.sync = true  # optional
LOGGER = Logger.new(STDOUT)
LOGGER.info("HENLO HENLO")
```

### Debugging with a REPL

You can start a REPL session while your program is running, to inspect/print variables, etc.

Just add the following lines where you want the REPL session to start:

```
require 'irb'
binding.irb

# Ctrl+D to exit the REPL, or do this to terminate the process completely:
exec ("kill -9 #{$$}")
```

## Package management with `gem`

`gem` is used to install packaged Ruby stuff. It's used to install things like Asciidoctor, for example.

- On Fedora, system gems are installed into `/usr/share/gems`.

To list currently installed packages:

    $ gem list --local

To upgrade/update a package:

    $ gem update asciidoctor-pdf

To uninstall a package:

    $ gem uninstall bundler

Many Ruby gems can also be found as RPMs with the `rubygem-` prefix, e.g.:

    $ sudo dnf install rubygem-concurrent-ruby...


## Dependency management with `bundler`

Bundler uses a _Gemfile_ to manage Ruby dependencies.

Manpages for bundle install:

    $ man bundle-install

Initialise a new project and create a `Gemfile`:

    $ cd my-project && bundle init

Add a Gem to the project:

    $ bundle add <gem-name>

Install dependencies into a local application path:

    $ bundle install --path vendor/bundle

Install dependencies into the system Rubygems location:

    $ bundle install --system

To list all the requirements (gems) for an application:

    $ bundle check

To update all dependencies to the latest version allowed:

    $ bundle update
    $ bundle update <gem-name>


## Troubleshooting

_"sass-embedded-1.63.6-x86_64-linux-musl requires rubygems version >= 3.3.22, which is incompatible with the current version, 3.1.2"_:

- Make sure you're using _rbenv_'s bundler, and not your system bundler.
- `gem install bundler`
- `eval "$(rbenv init -)"`


[rvm]: https://rvm.io/

[^1]: https://stackoverflow.com/questions/6337897/what-is-the-colon-operator-in-ruby
[^2]: https://www.rubyguides.com/2018/06/rubys-method-arguments/
[^3]: https://thoughtbot.com/blog/ruby-2-keyword-arguments
