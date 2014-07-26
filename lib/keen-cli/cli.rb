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

    def self.file_options
      option :file, :aliases => ['-f']
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
      option :"property-names"
      option :latest
      option :email
      option :start, :aliases => ['s']
      option :end, :aliases => ['e']
    end

    desc 'version', 'Print the keen-cli version'
    map %w(-v --version) => :version

    def version
      "keen-cli version #{KeenCli::VERSION}".tap do |s|
        puts s
      end
    end

    desc 'project:describe', 'Print information about a project'
    map 'project:describe' => :project_describe
    shared_options

    def project_describe
      Utils.process_options!(options)
      Keen.project_info.tap do |info|
        puts JSON.pretty_generate(info)
      end
    end

    desc 'project:collections', 'Print information about a project\'s collections'
    map 'project:collections' => :project_collections
    shared_options

    def project_collections
      Utils.process_options!(options)
      Keen.event_collections.tap do |collections|
        puts JSON.pretty_generate(collections)
      end
    end

    desc 'project:open', 'Open a project\'s overview page in a browser'
    map 'project:open' => :project_open
    shared_options

    def project_open
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.project_id}".tap do |project_url|
        `open #{project_url}`
      end
    end

    desc 'project:workbench', 'Open a project\'s workbench page in a browser'
    map 'project:workbench' => :project_workbench
    shared_options

    def project_workbench
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.project_id}/workbench".tap do |project_url|
        `open #{project_url}`
      end
    end

    desc 'queries:run', 'Run a query and print the result'
    map 'queries:run' => :queries_run
    shared_options
    query_options
    data_options
    def queries_run(analysis_type=nil)

      Utils.process_options!(options)

      # work with a new set of options
      q_options = {}

      data = nil

      if $stdin.tty?
        data = options[:data]
      else
        ARGV.clear
        ARGF.each_line do |line|
          data = line
        end
      end

      # if data is provided, parse it and merge it
      unless data.nil?
        data_options = JSON.parse(data)
        q_options.merge!(data_options)
      end

      # convert dashes to underscores, and merge all into q_options
      q_options.merge!(options.inject({}) do |memo, element|
        if ['analysis-type', 'group-by', 'target-property', 'property-names'].include?(element.first)
          memo[element.first.sub('-', '_')] = element.last
        else
          memo[element.first] = element.last
        end
        memo
      end)

      collection = Utils.get_collection_name(q_options)
      analysis_type = analysis_type || q_options["analysis_type"]

      # delete fields that shouldn't be passed to keen-gem as options
      q_options.delete("collection")
      q_options.delete("event_collection")
      q_options.delete("data")
      q_options.delete("analysis_type")

      if property_names = q_options.delete("property_names")
        q_options[:property_names] = property_names.split(",")
      end

      if start_time = q_options.delete("start")
        q_options[:timeframe] = { :start => start_time }
      end

      if end_time = q_options.delete("end")
        q_options[:timeframe] = q_options[:timeframe] || {}
        q_options[:timeframe][:end] = end_time
      end

      raise "No analysis type given!" unless analysis_type
      raise "No collection given!" unless collection

      Keen.send(analysis_type, collection, q_options).tap do |result|
        if result.is_a?(Hash) || result.is_a?(Array)
          puts JSON.pretty_generate(result)
        else
          puts result
        end
      end
    end

    ANALYSIS_TYPES = %w(average count count-unique extraction median minimum maximum sum percentile select-unique)

    ANALYSIS_TYPES.each do |analysis_type|
      underscored_analysis_type = analysis_type.sub('-', '_')
      desc analysis_type, "Alias for queries:run -c #{underscored_analysis_type}"
      map analysis_type => method_name = "queries_run_#{underscored_analysis_type}"
      shared_options
      query_options
      data_options
      self.send(:define_method, method_name) { queries_run(underscored_analysis_type) }
    end

    desc 'events:add', 'Add one or more events and print the result'
    map 'events:add' => :events_add

    shared_options
    data_options
    file_options
    collection_options

    def events_add

      events = []

      if $stdin.tty?
        if data = options[:data]
          events.push(data)
        elsif file = options[:file]
          File.readlines(file).each do |line|
            events.push(line)
          end
        else
          events.push({})
        end
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
