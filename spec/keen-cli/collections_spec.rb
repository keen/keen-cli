require 'spec_helper'

describe KeenCli::CLI do

  describe 'collections:delete' do

    it 'deletes the collection' do
      stub_request(:delete, "https://api.keen.io/3.0/projects/#{Keen.project_id}/events/minecraft-deaths").
        to_return(:status => 204, :body => "")
      _, options = start 'collections:delete --collection minecraft-deaths'
      expect(_).to eq(true)
    end

  end

end
