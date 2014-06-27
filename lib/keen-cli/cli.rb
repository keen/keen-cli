require 'http'
require 'thor'
require 'keen'
require 'json'

module KeenCli

  class CLI < Thor

    desc 'version', 'Print the keen-cli version'
    map %w(-v --version) => :version

    def version
      "keen-cli version #{KeenCli::VERSION}".tap do |s|
        puts s
      end
    end

    desc 'project:show', 'Show the current project'
    map 'project:show' => :project_show

    def project_show
      response = HTTP.get(
        "https://api.keen.io/3.0/projects/#{Keen.project_id}?api_key=#{Keen.master_key}")
      JSON.pretty_generate(JSON.parse(response.to_s)).tap do |s| puts s end
    end

    desc 'project:open', 'Open the current project'
    map 'project:open' => :project_open

    def project_open
      "https://keen.io/project/#{Keen.project_id}".tap do |project_url|
        `open #{project_url}`
      end
    end

  end

end
