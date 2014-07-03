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
    ENV['KEEN_PROJECT_ID'] = project_id
    ENV['KEEN_MASTER_KEY'] = master_key
    ENV['KEEN_READ_KEY'] = read_key
    ENV['KEEN_WRITE_KEY'] = write_key
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
  end

  describe 'project:collections' do
    it 'prints the project\'s collections' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/events"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'project:collections'
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
  end
end
