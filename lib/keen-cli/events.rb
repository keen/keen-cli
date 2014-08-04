module KeenCli

  class CLI < Thor

    def self.data_options
      option :data, :aliases => ['-d']
    end

    def self.file_options
      option :file, :aliases => ['-f']
      option :csv
    end

    desc 'events:add', 'Add one or more events and print the result'
    map 'events:add' => :events_add

    shared_options
    data_options
    file_options
    collection_options

    def events_add

      events = []
      collection = Utils.get_collection_name(options)

      if options[:csv]

        data = File.read(options[:file])
        csv = CSV.new(data, :headers => true, :header_converters => :symbol, :converters => :all)
        events = csv.to_a.map {|row| row.to_hash }

      else

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

      end

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
