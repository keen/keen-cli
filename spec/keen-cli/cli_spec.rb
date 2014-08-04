require 'spec_helper'

describe KeenCli::CLI do

  let(:project_id) { Keen.project_id }
  let(:master_key) { Keen.master_key }
  let(:read_key) { Keen.read_key }
  let(:write_key) { Keen.write_key }

  def start(str=nil)
    KeenCli::CLI.start(str ? str.split(" ") : [])
  end

  it 'prints help by default' do
    _, options = start
    expect(_).to be_empty
  end

  it 'prints version info if -v is used' do
    _, options = start "-v"
    expect(_).to match /version/
  end

  describe 'projects:describe' do
    it 'gets the project' do
      url = "https://api.keen.io/3.0/projects/#{project_id}"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'projects:describe'
      expect(_).to eq("fake" => "response")
    end

    it 'uses the project id param if present' do
      url = "https://api.keen.io/3.0/projects/GGGG"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'projects:describe --project GGGG'
      expect(_).to eq("fake" => "response")
    end
  end

  describe 'projects:collections' do
    it 'prints the project\'s collections' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/events"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'projects:collections'
      expect(_).to eq("fake" => "response")
    end

    it 'uses the project id param if present' do
      url = "https://api.keen.io/3.0/projects/GGGG/events"
      stub_request(:get, url).to_return(:body => { :fake => "response" }.to_json)
      _, options = start 'projects:collections --project GGGG'
      expect(_).to eq("fake" => "response")
    end
  end
end
