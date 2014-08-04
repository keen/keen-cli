module KeenCli

  class CLI < Thor

    desc 'project:describe', 'Print information about a project'
    map 'project:describe' => :project_describe
    shared_options

    def project_describe
      Utils.process_options!(options)
      Keen.project_info.tap do |info|
        puts JSON.pretty_generate(info)
      end
    end

    desc 'project:collections', 'Print information about a project\'s collections'
    map 'project:collections' => :project_collections
    shared_options

    def project_collections
      Utils.process_options!(options)
      Keen.event_collections.tap do |collections|
        puts JSON.pretty_generate(collections)
      end
    end

    desc 'project:open', 'Open a project\'s overview page in a browser'
    map 'project:open' => :project_open
    shared_options

    def project_open
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.project_id}".tap do |project_url|
        `open #{project_url}`
      end
    end

    desc 'project:workbench', 'Open a project\'s workbench page in a browser'
    map 'project:workbench' => :project_workbench
    shared_options

    def project_workbench
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.project_id}/workbench".tap do |project_url|
        `open #{project_url}`
      end
    end

  end

end

