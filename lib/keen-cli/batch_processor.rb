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

    def initialize(collection, options={})
      self.collection = collection
      self.batch_size = options[:batch_size] || DEFAULT_BATCH_SIZE
      self.csv = options[:csv]
      self.params = options[:params]
      self.csv_options = DEFAULT_CSV_OPTIONS.merge(options[:csv_options] || {})
      self.events = []
      self.pretty = options[:pretty]
      self.silent = options[:silent]
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

        hash = csv_row.to_hash

      elsif self.params

        hash = Utils.parse_data_as_querystring(line)

      else

        hash = JSON.parse(line)

      end

      self.events.push(hash)
      self.size += 1

      self.flush if self.size >= self.batch_size

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

  end

end
