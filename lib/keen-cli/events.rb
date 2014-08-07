require 'keen-cli/batch_processor'

module KeenCli

  class CLI < Thor

    def self.events_options
      option :csv
      option :params
      option :'batch-size'
    end

    desc 'events:add', 'Add one or more events and print the result'
    map 'events:add' => :events_add

    shared_options
    data_options
    file_options
    collection_options
    events_options

    def events_add

      Utils.process_options!(options)

      collection = Utils.get_collection_name(options)

      batch_processor = BatchProcessor.new(collection,
        :csv => options[:csv],
        :params => options[:params],
        :pretty => options[:pretty],
        :silent => options[:silent],
        :batch_size => options[:'batch-size'])

      total_events = 0

      if data = options[:data]
        batch_processor.add(data)
        total_events += 1
      end

      if file = options[:file]
        File.readlines(file).each do |line|
          batch_processor.add(line)
          total_events += 1
        end
      end

      if !$stdin.tty?
        ARGV.clear
        ARGF.each_line do |line|
          batch_processor.add(line)
          total_events += 1
        end
      end

      if $stdin.tty? && data.nil? && file.nil?
        batch_processor.add("{}")
        total_events += 1
      end

      batch_processor.flush

      total_events

    end

  end

end
