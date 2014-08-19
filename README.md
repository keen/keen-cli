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
  keen average               # Alias for queries:run -a average
  keen count                 # Alias for queries:run -a count
  keen count-unique          # Alias for queries:run -a count_unique
  keen docs                  # Open the full Keen IO documentation in a browser
  keen events:add            # Add one or more events and print the result
  keen extraction            # Alias for queries:run -a extraction
  keen help [COMMAND]        # Describe available commands or one specific command
  keen maximum               # Alias for queries:run -a maximum
  keen median                # Alias for queries:run -a median
  keen minimum               # Alias for queries:run -a minimum
  keen percentile            # Alias for queries:run -a percentile
  keen projects:collections  # Print information about a project's collections
  keen projects:describe     # Print information about a project
  keen projects:open         # Open a project's overview page in a browser
  keen projects:workbench    # Open a project's workbench page in a browser
  keen queries:run           # Run a query and print the result
  keen queries:url           # Print the URL for a query
  keen select-unique         # Alias for queries:run -a select_unique
  keen sum                   # Alias for queries:run -a sum
  keen version               # Print the keen-cli version
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
$ keen projects:describe --project XXXXXXXXXXXXXXX
```

Similar overrides are available for specifiying API keys: `--master-key`, `--read-key` and `--write-key`.

For example:

``` shell
$ keen projects:describe --project XXXXXXXXXXXXXXX --master-key AAAAAAAAAAAAAA
```

Shorter aliases exist as well: `-p` for project, `-k` for master key, `-r` for read key, and `-w` for write key.

``` shell
$ keen projects:describe -p XXXXXXXXXXXXXXX -k AAAAAAAAAAAAAA
```

### Usage

keen-cli has a variety of commands, and most are namespaced for clarity.

* `version` - Print version information.
* `docs` - Open the full [Keen IO docs](https://keen.io/docs) in a browser window. Pass `--reference` to go straight to the [API Technical Reference](https://keen.io/docs/api/reference/).

##### Projects

* `projects:open` - Open the Project Overview page in a browser
* `projects:workbench` - Open the Project Workbench page in a browser
* `projects:describe` - Get data about the project. Uses the [project row resource](https://keen.io/docs/api/reference/#project-row-resource).
* `projects:collections` - Get schema information about the project's collections. Uses the [event resource](https://keen.io/docs/api/reference/#event-resource).

##### Events

`events:add` - Add an event.

Parameters:

+ `--collection`, `-c`: The collection to add the event to. Alternately you can set `KEEN_COLLECTION_NAME` on the environment if you're working with the same collection frequently.
+ `--batch-size`: Batch size of events posted to Keen, defaults to 1000.

Input source parameters:

+ `--data`, `-d`: Pass an event body on the command line. Make sure to use quotes where necessary.
+ `--file`, `-f`: The name of a file containing events.

You can also pass input via `STDIN`.

If not otherwise specified, the format of data from any source is assumed to be newline-delimited JSON. CSV and query string-like input is also supported. The associated params:

+ `--csv`: Specify CSV format. The first line must contain column names. Column names containing `.`, such as `keen.timestamp`, will be converted to nested properties.
+ `--params`: Specify "params" format. Params format looks like `property1=value1&property2=value` etc.

Various examples:

``` shell
# add an empty event
$ keen events:add --collection signups

# use the shorter form of collection
$ keen events:add -c signups

# add a blank event to a collection specified in a .env file:
# KEEN_COLLECTION_NAME=signups
$ keen events:add

# add an event from JSON using the --data parameter
$ keen events:add -c signups --data "{ \"username\" : \"dzello\", \"city\": \"San Francisco\" }"

# add an event from key value pairs
$ keen events:add -c signups -data "username=dzello&city=SF" --params

# pipe in events as JSON
$ echo "{ \"username\" : \"dzello\", \"city\": \"San Francisco\" }" | keen events:add -c signups

# add events from a file that contains newline delimited json:
# { "username" : "dzello", "city" : "San Francisco" }
# { "username" : "KarlTheFog", "city" : "San Francisco" }
# { "username" : "polarvortex", "city" : "Chicago" }
$ keen events:add --file events.json

# add events from a file that contains an array of JSON objects
# [{ "apple" : "sauce" }, { "banana" : "pudding" }, { "cherry" : "pie" }]
$ keen events:add --file events.json

# add events from a file in CSV format. the first row must be column names:
# username, city
# dzello, San Francisco
# KarlTheFog, San Francisco
# polarvortex, Chicago
$ keen events:add --file events.csv --csv
```

##### Queries

`queries:run` - Runs a query and prints the result

Parameters:

+ `--collection`, `-c`: – The collection to query against. Can also be set on the environment via `KEEN_COLLECTION_NAME`.
+ `--analysis-type`, `-a`: The analysis type for the query. Only needed when not using a query command alias.
+ `--group-by`, `-g`: A group by for the query. Multiple fields seperated by comma are supported.
+ `--target-property`, `-y`: A target property for the query.
+ `--timeframe`, `-t`: A relative timeframe, e.g. `last_60_minutes`.
+ `--start`, `-s`: The start time of an absolute timeframe.
+ `--end`, `-e`: The end time of an absolute timeframe.
+ `--interval`, `-i`: The interval for a series query.
+ `--filters`, `-f`: A set of filters for the query, passed as JSON.
+ `--percentile`: The percentile value (e.g. 99) for a percentile query.
+ `--property-names`: A comma-separated list of property names. Extractions only.
+ `--latest`: Number of latest events to retrieve. Extractions only.
+ `--email`: Send extraction results via email, asynchronously. Extractions only.
+ `--spark`: Format output for [spark](https://github.com/holman/spark) ▁▂▃▅▇. Interval and timeframe fields required. Set this flag and pipe output to `spark` to visualize output.

Input source parameters:
+ `--data`, `-d`: Specify query parameters as JSON instead of query params.

You can also pass input via `STDIN`.

Some examples:

``` shell
# run a count
$ keen queries:run --collection signups --analysis-type count
1000

# run a count with collection name from .env
# KEEN_COLLECTION_NAME=signups
$ keen queries:run --analysis-type count
1000

# run a count with a group by
$ keen queries:run --collection signups --analysis-type count --group-by username
[
  {
    "username": "dzello",
    "result": 1000
  }
]

# run a query with a timeframe, target property, group by, and interval
$ keen queries:run --collection signups --analysis-type count_unique --target-property age --group-by source --timeframe last_24_hours --interval hourly

{
  "timeframe": {
    "start": "2014-06-27T01:00:00.000Z",
    "end": "2014-06-27T02:00:00.000Z"
  },
  "value": [
  ...
  ...
  ...

# run a query with an absolute timeframe
$ keen queries:run --analysis-type count --start 2014-07-01T00:00:00Z --end 2014-07-31T23:59:59Z
1000

# run an extraction with specific property names
$ keen queries:run --collection minecraft-deaths --analysis-type extraction --property-names player,enemy
[
  {
    "player": "dzello",
    "enemy": "creeper"
  },
  {
    "player": "dkador",
    "enemy": "creeper"
  }
]

# run a query using JSON to specify parameters
$ echo "{ \"event_collection\" : \"minecraft-deaths\", \"target_property\": \"level\" }" | keen queries:run -a average
```

**Query URL Generation**

Run `keen` with no arguments to see the full list of aliases.

`queries:url` - Generates the URL of a query, but does not run it.

The same parameters apply as `queries:run`, in addition to one extra.

+ `--exclude-api-key`: Prevent the API key query param from being included in the output
 
**Query Aliases**

For each type of analysis (e.g. count, average, extraction, etc.) there is an alias that can be used
instead of `queries:run`. The command name is simply the type of analysis, using a dash to delimit words.
Here are a few examples:

``` shell
$ keen count -c logins
1000
$ keen minimum -c cpu-checks -y iowait
0.17
```

### Global parameters

Parameters that apply to most commands include:

+ `--pretty`: Prettify API response JSON. Defaults to true, set `--pretty=false` to prevent
+ `--silent`: Silence any output. Defaults to false.

### Changelog

+ 0.2.0 - Add support for [spark](https://github.com/holman/spark) ▁▂▃▅▇
+ 0.1.9 - Supports JSON-encoded filters and comma-seperated multiple group by
+ 0.1.8 - Inputted lines can also be arrays of JSON objects. `--batch-size` param is now properly recognized.
+ 0.1.7 - Add docs command
+ 0.1.6 - Big refactoring to make importing events much cleaner and batching happen automatically. Also adds `queries:url`.
+ 0.1.5 – Support adding events from files with `--file`. Optionally add from CSV with `--csv`.
+ 0.1.4 – Support absolute timeframes via `--start` and `--end` flags
+ 0.1.3 – Add querying via JSON. Add query aliases. Add support for extraction fields.
+ 0.1.2 – Change `project:show` to `project:describe`
+ 0.1.1 – Add `project:collections`
+ 0.1.0 - Initial version

### Contributing

keen-cli is open source, and contributions are very welcome!

Running the tests with:

```
$ bundle exec rake spec
```
