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

      data = nil

      if $stdin.tty?
        data = options[:data]
      else
        ARGV.clear
        ARGF.each_line do |line|
          data += line
        end
      end

      # setup a holder for query options
      q_options = {}

      # if data is provided, parse it and merge it
      unless data.nil?
        data_options = JSON.parse(data)
        q_options.merge!(data_options)
      end

      collection = Utils.get_collection_name(options)
      raise "No collection given!" unless collection

      analysis_type = analysis_type || options[:"analysis-type"]
      raise "No analysis type given!" unless analysis_type

      # copy query options in intelligently
      q_options[:group_by] = options[:"group-by"]
      q_options[:target_property] = options[:"target-property"]
      q_options[:interval] = options[:interval]
      q_options[:timeframe] = options[:timeframe]
      q_options[:filters] = options[:filters]
      q_options[:percentile] = options[:percentile]
      q_options[:latest] = options[:latest]
      q_options[:email] = options[:email]

      if property_names = options[:"property-names"]
        q_options[:property_names] = property_names.split(",")
      end

      if start_time = options[:start]
        q_options[:timeframe] = { :start => start_time }
      end

      if end_time = options[:end]
        q_options[:timeframe] = q_options[:timeframe] || {}
        q_options[:timeframe][:end] = end_time
      end

     q_options.delete_if { |k, v| v.nil? }

      Keen.send(analysis_type, collection, q_options).tap do |result|
        if result.is_a?(Hash) || result.is_a?(Array)
          Utils.print_json(result, options)
        else
          puts result
        end
      end
    end

    ANALYSIS_TYPES = %w(average count count-unique extraction median minimum maximum sum percentile select-unique)

    ANALYSIS_TYPES.each do |analysis_type|
      underscored_analysis_type = analysis_type.sub('-', '_')
      desc analysis_type, "Alias for queries:run -a #{underscored_analysis_type}"
      map analysis_type => method_name = "queries_run_#{underscored_analysis_type}"
      shared_options
      query_options
      data_options
      self.send(:define_method, method_name) { queries_run(underscored_analysis_type) }
    end
  end

end
