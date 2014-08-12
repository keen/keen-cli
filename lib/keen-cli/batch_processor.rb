module KeenCli

  class BatchProcessor

    # defaults
    DEFAULT_BATCH_SIZE = 1000
    DEFAULT_CSV_OPTIONS = { :converters => :all }

    # public options, set in constructor
    attr_accessor :collection
    attr_accessor :batch_size
    attr_accessor :params
    attr_accessor :csv
    attr_accessor :csv_options
    attr_accessor :pretty
    attr_accessor :silent

    # internal state tracking
    attr_accessor :size
    attr_accessor :events
    attr_accessor :total_size

    def initialize(collection, options={})
      self.collection = collection
      self.batch_size = options[:'batch-size'] || DEFAULT_BATCH_SIZE
      self.csv = options[:csv]
      self.params = options[:params]
      self.csv_options = DEFAULT_CSV_OPTIONS.merge(options[:csv_options] || {})
      self.events = []
      self.pretty = options[:pretty]
      self.silent = options[:silent]
      self.total_size = 0
      self.reset
    end

    def add(line)

      # if we're in CSV mode and don't have headers let's try and set them
      if self.csv && !self.csv_options.has_key?(:headers)

        set_headers(line)
        return

      end

      if self.csv

        csv_row = CSV.parse_line(line, self.csv_options)
        raise "Could not parse! #{line}" unless csv_row

        csv_event = row_to_hash(csv_row)
        add_event_and_flush_if_necessary(csv_event)

      elsif self.params

        querystring_event = Utils.parse_data_as_querystring(line)
        add_event_and_flush_if_necessary(querystring_event)

      else

        json_object = JSON.parse(line)

        # if it's an array, lets iterate over and flush as necessary
        if json_object.is_a?(Array)
          json_object.each do |json_event|
            add_event_and_flush_if_necessary(json_event)
          end
        else
          add_event_and_flush_if_necessary(json_object)
        end

      end

    end

    def flush
      publish_batch(self.collection, self.events) if self.size > 0
      reset
    end

    def reset
      self.size = 0
      self.events.clear
    end

    private

    def add_event_and_flush_if_necessary(event)
      self.events.push(event)
      self.size += 1
      self.total_size += 1
      self.flush if self.size >= self.batch_size
    end

    def set_headers(line)
      csv_row = CSV.parse_line(line, self.csv_options)
      self.csv_options[:headers] = csv_row.to_a
    end

    def publish_batch(collection, events)
      batches = {}
      batches[collection] = events
      Keen.publish_batch(batches).tap do |result|
        Utils.out_json(result, :pretty => self.pretty, :silent => self.silent)
      end
    end

    def row_to_hash(csv_row)
      naive_hash = csv_row.to_hash
      naive_hash.map do |main_key, main_value|
        main_key.to_s.split('.').reverse.inject(main_value) do |value, key|
          {key => value}
        end
      end.inject(&:deep_merge)
    end

  end

end
