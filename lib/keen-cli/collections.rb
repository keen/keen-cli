module KeenCli

  class CLI < Thor

    def self.delete_options
      self.collection_options
      option :timeframe, :aliases => ['-t']
      option :filters, :aliases => ['-f']
      option :start, :aliases => ['s']
      option :end, :aliases => ['e']
      option :force, :type => :boolean, :default => false
    end

    desc 'collections:delete', 'Delete events from a collection'
    map 'collections:delete' => :collections_delete

    shared_options
    delete_options

    def collections_delete

      Utils.process_options!(options)

      collection = Utils.get_collection_name(options)

      unless options[:force]
        puts "WARNING! This is a delete request. Please re-enter the collection name to confirm."
        confirmation = $stdin.gets.chomp!
        unless confirmation == collection
          Utils.out "Confirmation failed!", options
          return false
        end
      end

      q_options = {}
      q_options[:timeframe] = options[:timeframe]

      if start_time = options[:start]
        q_options[:timeframe] = { :start => start_time }
      end

      if filters = options[:filters]
        q_options[:filters] = JSON.parse(filters)
      end

      if end_time = options[:end]
        q_options[:timeframe] = q_options[:timeframe] || {}
        q_options[:timeframe][:end] = end_time
      end

      q_options.delete_if { |k, v| v.nil? }

      Keen.delete(collection, q_options).tap do |result|
        Utils.out(result, options)
      end

    end

  end

end
