require 'http'
require 'thor'
require 'keen'
require 'json'

require 'keen-cli/utils'

module KeenCli

  class CLI < Thor

    def self.shared_options
      option :project, :aliases => ['-p']
      option :"master-key", :aliases => ['-k']
      option :"read-key", :aliases => ['-r']
      option :"write-key", :aliases => ['-w']
    end

    def self.data_options
      option :data, :aliases => ['-d']
    end

    def self.collection_options
      option :collection, :aliases => ['-c']
    end

    def self.query_options
      self.collection_options
      option :"analysis-type", :aliases => ['-a']
      option :"group-by", :aliases => ['-g']
      option :"target-property", :aliases => ['-y']
      option :interval, :aliases => ['-i']
      option :timeframe, :aliases => ['-t']
      option :filters, :aliases => ['-f']
      option :percentile
    end

    desc 'version', 'Print the keen-cli version'
    map %w(-v --version) => :version

    def version
      "keen-cli version #{KeenCli::VERSION}".tap do |s|
        puts s
      end
    end

    desc 'project:show', 'Show the current project'
    map 'project:show' => :project_show
    shared_options

    def project_show
      Utils.process_options!(options)
      response = HTTP.get(
        "https://api.keen.io/3.0/projects/#{Keen.project_id}?api_key=#{Keen.master_key}")
      JSON.pretty_generate(JSON.parse(response.to_s)).tap do |s| puts s end
    end

    desc 'project:collections', 'Show the current project\'s collections'
    map 'project:collections' => :project_collections
    shared_options

    def project_collections
      Utils.process_options!(options)
      Keen.event_collections.tap do |collections|
        puts JSON.pretty_generate(collections)
      end
    end

    desc 'project:open', 'Open the current project'
    map 'project:open' => :project_open
    shared_options

    def project_open
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.project_id}".tap do |project_url|
        `open #{project_url}`
      end
    end

    desc 'project:workbench', 'Open the current project\'s workbench'
    map 'project:workbench' => :project_workbench
    shared_options

    def project_workbench
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.project_id}/workbench".tap do |project_url|
        `open #{project_url}`
      end
    end

    desc 'queries:run', 'Run a query'
    map 'queries:run' => :queries_run
    shared_options
    query_options
    def queries_run

      Utils.process_options!(options)

      # convert dashes
      q_options = options.inject({}) do |memo, element|
        if ['analysis-type', 'group-by', 'target-property'].include?(element.first)
          memo[element.first.sub('-', '_')] = element.last
        else
          memo[element.first] = element.last
        end
        memo
      end

      collection = Utils.get_collection_name(options)

      Keen.send(q_options["analysis_type"], collection, q_options).tap do |result|
        if result.is_a?(Hash) || result.is_a?(Array)
          puts JSON.pretty_generate(result)
        else
          puts result
        end
      end
    end

    desc 'events:add', 'Add an event'
    map 'events:add' => :events_add

    shared_options
    data_options
    collection_options

    def events_add

      events = []

      if $stdin.tty?
        events.push(options[:data] || {})
      else
        ARGV.clear
        ARGF.each_line do |line|
          events.push(line)
        end
      end

      events = events.map do |event|
        begin
          JSON.parse(event)
        rescue
          begin
            Utils.parse_data_as_querystring(event)
          rescue
            event
          end
        end
      end

      collection = Utils.get_collection_name(options)

      if events.length > 1

        Keen.publish_batch(collection => events).tap do |result|
          puts JSON.pretty_generate(result)
        end

      else

        Keen.publish(collection, events.first).tap do |result|
          puts JSON.pretty_generate(result)
        end

      end

    end

  end

end
