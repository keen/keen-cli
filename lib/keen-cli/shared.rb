module KeenCli

  class CLI < Thor

    def self.shared_options
      option :project, :aliases => ['-p']
      option :"master-key", :aliases => ['-k']
      option :"read-key", :aliases => ['-r']
      option :"write-key", :aliases => ['-w']
    end

    def self.collection_options
      option :collection, :aliases => ['-c']
    end

    def self.data_options
      option :data, :aliases => ['-d']
    end

    def self.file_options
      option :file, :aliases => ['-f']
    end

  end

end
