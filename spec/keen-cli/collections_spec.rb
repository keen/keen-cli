require 'spec_helper'

describe KeenCli::CLI do

  describe 'collections:delete' do

    it 'deletes the collection' do
      stub_request(:delete, "https://api.keen.io/3.0/projects/#{Keen.project_id}/events/minecraft-deaths").
        to_return(:status => 204, :body => "")
      _, options = start 'collections:delete --collection minecraft-deaths --force'
      expect(_).to eq(true)
    end

    it 'deletes the collection with filters' do
      filters = '[{"property_name":"enemy","operator":"eq","property_value":"creeper"}]'
      stub_request(:delete, "https://api.keen.io/3.0/projects/#{Keen.project_id}/events/minecraft-deaths?filters=%5B%7B%22property_name%22%3A%22enemy%22%2C%22operator%22%3A%22eq%22%2C%22property_value%22%3A%22creeper%22%7D%5D").
        to_return(:status => 204, :body => "")
      _, options = start "collections:delete --collection minecraft-deaths --filters #{filters} --force"
      expect(_).to eq(true)
    end

  end

end
