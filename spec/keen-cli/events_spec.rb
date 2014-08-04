require 'spec_helper'

describe KeenCli::CLI do

  def start(str=nil)
    KeenCli::CLI.start(str ? str.split(" ") : [])
  end

  describe 'events:add' do
    it 'should accept JSON events from a data param' do
      stub_request(:post, "https://api.keen.io/3.0/projects/#{Keen.project_id}/events").
        with(:body => "{\"minecraft-deaths\":[{\"foo\":1}]}").
        to_return(:body => { :created => true }.to_json)
      _, options = start 'events:add --collection minecraft-deaths --data {"foo":1}'
      expect(_).to eq(1)
    end

    it 'should accept JSON events from a file param' do
      stub_request(:post, "https://api.keen.io/3.0/projects/#{Keen.project_id}/events").
        with(:body => "{\"minecraft-deaths\":[{\"foo\":1},{\"foo\":2},{\"foo\":3}]}").
        to_return(:body => { :created => true }.to_json)
      _, options = start "events:add --collection minecraft-deaths --file #{File.expand_path('../../fixtures/events.json', __FILE__)}"
      expect(_).to eq(3)
    end

    it 'should accept JSON events from a file param in CSV format' do
      stub_request(:post, "https://api.keen.io/3.0/projects/#{Keen.project_id}/events").
        with(:body => "{\"minecraft-deaths\":[{\"foo\":1},{\"foo\":2},{\"foo\":3}]}").
        to_return(:body => { :created => true }.to_json)
      _, options = start "events:add --collection minecraft-deaths --csv --file #{File.expand_path('../../fixtures/events.csv', __FILE__)}"
      expect(_).to eq(4)
    end

  end

end
