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

    desc 'docs', 'Open the full Keen IO documentation in a browser'
    map %w(--docs) => :docs

    shared_options
    option :reference

    def docs
      docs_url = options[:reference] ? 'https://keen.io/docs/api/reference/' :
                                       'https://keen.io/docs'
      docs_url.tap do |url|
        `open #{url}`
      end
    end

  end

end
