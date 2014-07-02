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
Commands:
  keen events:add           # Add one or more events and print the result
  keen help [COMMAND]       # Describe available commands or one specific command
  keen project:collections  # Print information about a project's collections
  keen project:describe     # Print information about a project
  keen project:open         # Open a project's overview page in a browser
  keen project:workbench    # Open a project's workbench page in a browser
  keen queries:run          # Run a query and print the result
  keen version              # Print the keen-cli version
```

You should see information about available commands.

If `keen` can't be found there might be an issue with your Ruby installation. If you're using [rbenv](https://github.com/sstephenson/rbenv) try running `rbenv rehash` after installation.

### Environment configuration

Most keen-cli commands require the presence of a project and one or more API keys to do meaningful actions. By default, keen-cli attempts to find these in the process environment or a `.env` file in the current directory. This is the same heuristic that [keen-gem](https://github.com/keenlabs/keen-gem) uses and is based on [dotenv](https://github.com/bkeepers/dotenv).

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
$ keen project:describe --project XXXXXXXXXXXXXXX
```

Similar overrides are available for specifiying API keys: `--master-key`, `--read-key` and `--write-key`.

For example:

``` shell
$ keen project:describe --project XXXXXXXXXXXXXXX --master-key AAAAAAAAAAAAAA
```

Shorter aliases exist as well: `-p` for project, `-k` for master key, `-r` for read key, and `-w` for write key.

``` shell
$ keen project:describe -p XXXXXXXXXXXXXXX -k AAAAAAAAAAAAAA
```

### Usage

keen-cli has a variety of commands, and most are namespaced for clarity.

* `version` - Print version information

##### Projects

* `project:open` - Open the Project Overview page in a browser
* `project:workbench` - Open the Project Workbench page in a browser
* `project:describe` - Get data about the project. Uses the [project row resource](https://keen.io/docs/api/reference/#project-row-resource).
* `project:collections` - Get schema information about the project's collections. Uses the [event resource](https://keen.io/docs/api/reference/#event-resource).

##### Events

`events:add` - Add an event.

Parameters:

+ `--collection` (alias `-c`): The collection to add the event to. Alternately you can set `KEEN_COLLECTION_NAME` on the environment if you're working with the same collection frequently.
+ `--data` (alias `-d`). The properties of the event. The value can be JSON or key=value pairs delimited by & (just like a query string). Data can also be piped in via STDIN.

Various examples:

``` shell
# create an empty event
$ keen events:add --collection cli-tests

# use the shorter form of collection
$ keen events:add -c cli-tests

# add a blank event to a collection specified in the .env file:
# KEEN_COLLECTION_NAME=cli-tests
$ keen events:add

# create an event from JSON
$ keen events:add -c cli-tests -d "{ \"username\" : \"dzello\", \"zsh\": 1 }"

# create an event from key value pairs
$ keen events:add -c cli-tests -d "username=dzello&zsh=1"

# pipe in events as JSON
$ echo "{ \"username\" : \"dzello\", \"zsh\": 1 }" | keen events:add -c cli-tests

# pipe in events in querystring format
$ echo "username=dzello&zsh=1" | keen events:add -c cli-test

# pipe in events from a file of newline delimited json
# { "username" : "dzello", "zsh" : 1 }
# { "username" : "dkador", "zsh" : 1 }
# { "username" : "gphat", "zsh" : 1 }
$ cat events.json | keen events:add -c cli-test
```

##### Queries

`queries:run` - Runs a query and prints the result in pretty JSON.

Parameters:

+ `--collection` (alias -c) – The collection name to query against. Can also be set on the environment via `KEEN_COLLECTION_NAME`
+ `--analysis-type` (alias -a)
+ `--group-by` (alias -g)
+ `--target-property` (alias -y)
+ `--timeframe` (alias -t)
+ `--interval` (alias -i)
+ `--filters` (alias -f)
+ `--percentile`

Some examples:

``` shell
# run a count
$ keen queries:run --collection cli-tests --analysis-type count
1000

# run a count with collection name from .env
# KEEN_COLLECTION_NAME=cli-tests
$ keen queries:run --analysis-type count
1000

# run a count with a group by
$ keen queries:run --collection cli-tests --analysis-type count --group-by username
[
  {
    "username": "dzello",
    "result": 1000
  }
]

# run a query with a timeframe, target property, group by, and interval
$ keen queries:run --collection cli-tests --analysis-type median --target-property value --group-by cohort --timeframe last_24_hours --interval hourly

{
  "timeframe": {
    "start": "2014-06-27T01:00:00.000Z",
    "end": "2014-06-27T02:00:00.000Z"
  },
  "value": [
  ...
  ...
  ...
```

### Changelog

+ 0.1.2 – Change `project:show` to `project:describe`
+ 0.1.1 – Add `project:collections`
+ 0.1.0 - Initial version

### Contributing

keen-cli is open source, and contributions are very welcome!

Running the tests with:

```
$ bundle exec rake spec
```
