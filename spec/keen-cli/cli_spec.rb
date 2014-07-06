require 'spec_helper'

describe KeenCli::CLI do

  let(:project_id) { 'AAAAAAA' }
  let(:master_key) { 'DDDDDD' }
  let(:read_key) { 'BBBBBB' }
  let(:write_key) { 'CCCCCC' }

  def start(str=nil)
    KeenCli::CLI.start(str ? str.split(" ") : [])
  end

  before do
    Keen.project_id = project_id
    Keen.read_key = read_key
    Keen.write_key = write_key
    Keen.master_key = master_key
  end

  it 'prints help by default' do
    _, options = start
    expect(_).to be_empty
  end

  it 'prints version info if -v is used' do
    _, options = start "-v"
    expect(_).to match /version/
  end

  describe 'project:describe' do
    it 'gets the project' do
      url = "https://api.keen.io/3.0/projects/#{project_id}"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:describe'
      expect(_).to eq("fake" => "response")
    end

    it 'uses the project id param if present' do
      url = "https://api.keen.io/3.0/projects/GGGG"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:describe --project GGGG'
      expect(_).to eq("fake" => "response")
    end
  end

  describe 'project:collections' do
    it 'prints the project\'s collections' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/events"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:collections'
      expect(_).to eq("fake" => "response")
    end

    it 'uses the project id param if present' do
      url = "https://api.keen.io/3.0/projects/GGGG/events"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:collections --project GGGG'
      expect(_).to eq("fake" => "response")
    end
  end

  describe 'queries:run' do
    it 'runs the query using certain params' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --collection minecraft-deaths'
      expect(_).to eq(10)
    end

    it 'runs the query using aliased params' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run -a count -c minecraft-deaths'
      expect(_).to eq(10)
    end

    it 'converts dashes to underscores for certain properties' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&group_by=foo&target_property=bar"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --collection minecraft-deaths --group-by foo --target-property bar'
      expect(_).to eq(10)
    end

    it 'uses a data option to take in query JSON' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --data {"event_collection":"minecraft-deaths"}'
      expect(_).to eq(10)
    end
  end
end
