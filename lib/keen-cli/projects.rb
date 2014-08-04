module KeenCli

  class CLI < Thor

    desc 'projects:describe', 'Print information about a project'
    map 'projects:describe' => :projects_describe
    shared_options

    def projects_describe
      Utils.process_options!(options)
      Keen.project_info.tap do |info|
        Utils.print_json(info, options)
      end
    end

    desc 'projects:collections', 'Print information about a project\'s collections'
    map 'projects:collections' => :projects_collections
    shared_options

    def projects_collections
      Utils.process_options!(options)
      Keen.event_collections.tap do |collections|
        Utils.print_json(collections, options)
      end
    end

    desc 'projects:open', 'Open a project\'s overview page in a browser'
    map 'projects:open' => :projects_open
    shared_options

    def projects_open
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.projects_id}".tap do |projects_url|
        `open #{projects_url}`
      end
    end

    desc 'projects:workbench', 'Open a project\'s workbench page in a browser'
    map 'projects:workbench' => :projects_workbench
    shared_options

    def projects_workbench
      Utils.process_options!(options)
      "https://keen.io/project/#{Keen.project_id}/workbench".tap do |project_url|
        `open #{project_url}`
      end
    end

  end

end
