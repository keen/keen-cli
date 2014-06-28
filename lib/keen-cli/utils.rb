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

      def get_collection_name(options)
        options["collection"] || ENV['KEEN_COLLECTION_NAME']
      end

      def parse_data_as_querystring(query)
        keyvals = query.split('&').inject({}) do |result, q| 
          k,v = q.split('=')
          if !v.nil?
             result.merge({k => v})
          elsif !result.key?(k)
            result.merge({k => true})
          else
            result
          end
        end
        keyvals
      end

    end

  end

end
