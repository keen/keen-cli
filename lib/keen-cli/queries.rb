module KeenCli

  class CLI < Thor

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
  end

end
