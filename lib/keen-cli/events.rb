require 'keen-cli/batch_processor'

module KeenCli

  class CLI < Thor

    def self.batch_options
      option :csv
      option :'batch-size'
      option :pretty
    end

    desc 'events:add', 'Add one or more events and print the result'
    map 'events:add' => :events_add

    shared_options
    data_options
    file_options
    collection_options
    batch_options

    def events_add

      collection = Utils.get_collection_name(options)

      batch_processor = BatchProcessor.new(collection,
        :csv => options[:csv],
        :pretty => options[:pretty],
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

      batch_processor.flush

      total_events

    end

  end

end
