# keen-cli

[![Build Status](https://travis-ci.org/keenlabs/keen-cli.svg?branch=master)](https://travis-ci.org/keenlabs/keen-cli)

A command line interface for the Keen IO analytics API.

### Installation

keen-cli is built with Ruby, so you'll need a working Ruby 1.9+ environment to use it. You can find Ruby installation instructions [here](https://www.ruby-lang.org/en/installation/).

Install the gem:

``` shell
$ gem install keen-cli
```

Verify the `keen` command is in your path by running it:

``` shell
$ keen
Commands:
  keen help [COMMAND]  # Describe available commands or one specific command
  keen project:open    # Open the current project
  keen project:show    # Show the current project
  keen version         # Print the keen-cli version
```

You should see information about available commands.

If `keen` can't be found there might be an issue with your Ruby installation. If you're using [rbenv](https://github.com/sstephenson/rbenv) try running `rbenv rehash` after installation.

### Environment configuration

Most keen-cli functions require the presence of a project and one or more API keys to do meaningful actions. By default, keen-cli attempts to find these in the process environment or a `.env` file in the current directory. This is the same heuristic that [keen-gem](https://github.com/keenlabs/keen-gem) uses.

An example .env file looks like this:

```
KEEN_PROJECT_ID=aaaaaaaaaaaaaaa
KEEN_MASTER_KEY=xxxxxxxxxxxxxxx
KEEN_WRITE_KEY=yyyyyyyyyyyyyyy
KEEN_READ_KEY=zzzzzzzzzzzzzzz
```

If you run `keen` from a directory with this .env file, it will assume the project in context is the one specified by `KEEN_PROJECT_ID`.

To override the project context use the `--project` option:

``` shell
$ keen project:show --project XXXXXXXXXXXXXXX
```

Similar overrides are available for specifiying API keys: `--master-key`, `--read-key` and `--write-key`.

For example:

``` shell
$ keen project:show --project XXXXXXXXXXXXXXX --master-key AAAAAAAAAAAAAA
```

Shorter aliases exist as well: `-p` for project, `-k` for master key, `-r` for read key, and `-w` for write key.

``` shell
$ keen project:show -p XXXXXXXXXXXXXXX -k AAAAAAAAAAAAAA
```

### Usage

keen-cli has a variety of commands, and most are namespaced for clarity.

* `version` - Print version information
* `project:open` - Open the Project Overview page in a browser
* `project:show` - Get data about the project, uses the [project row resource](https://keen.io/docs/api/reference/#project-row-resource).


### Contributing

keen-cli is open source, and contributions are very welcome!

Running the tests with:

```
$ bundle exec rake spec
```
