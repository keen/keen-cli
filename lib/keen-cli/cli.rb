require 'thor'
require 'keen'
require 'json'
require 'csv'

require 'keen-cli/utils'

require 'keen-cli/shared'

require 'keen-cli/projects'
require 'keen-cli/events'
require 'keen-cli/queries'

module KeenCli

  class CLI < Thor

    desc 'version', 'Print the keen-cli version'
    map %w(-v --version) => :version

    shared_options

    def version
      "keen-cli version #{KeenCli::VERSION}".tap do |s|
        Utils.out(s, options)
      end
    end

  end

end
