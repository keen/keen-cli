module KeenCli

  class Utils

    class << self

      def process_options!(options)

        if project_id = options[:project]
          Keen.project_id = project_id
        end

        if master_key = options[:"master-key"]
          Keen.master_key = master_key
        end

        if read_key = options[:"read-key"]
          Keen.read_key = read_key
        end

        if write_key = options[:"write-key"]
          Keen.write_key = write_key
        end

      end

    end

  end

end
