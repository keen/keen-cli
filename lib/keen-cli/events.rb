require 'keen-cli/batch_processor'

module KeenCli

  class CLI < Thor

    def self.events_options
      option :csv
      option :params
      option :'batch-size', type: :numeric
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
        :'batch-size' => options[:'batch-size'])

      if data = options[:data]
        batch_processor.add(data)
      end

      if file = options[:file]
        File.readlines(file).each do |line|
          batch_processor.add(line)
        end
      end

      if !$stdin.tty?
        ARGV.clear
        ARGF.each_line do |line|
          batch_processor.add(line)
        end
      end

      if $stdin.tty? && data.nil? && file.nil?
        batch_processor.add("{}")
      end

      batch_processor.flush

      batch_processor.total_size

    end

  end

end
