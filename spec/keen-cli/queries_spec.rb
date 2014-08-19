require 'spec_helper'

describe KeenCli::CLI do

  let(:project_id) { Keen.project_id }
  let(:master_key) { Keen.master_key }
  let(:read_key) { Keen.read_key }
  let(:write_key) { Keen.write_key }

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
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&group_by=%5B%22foo%22%5D&target_property=bar"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --collection minecraft-deaths --group-by foo --target-property bar'
      expect(_).to eq(10)
    end

    it 'allows comma-delimited group by fields' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&group_by=%5B%22%5C%22foo%22,%22bar%5C%22%22%5D&target_property=bar"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --collection minecraft-deaths --group-by "foo,bar" --target-property bar'
      expect(_).to eq(10)
    end

    it 'parses filters as JSON' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&filters=%5B%7B%22property_name%22%3A%22enemy%22%2C%22operator%22%3A%22eq%22%2C%22property_value%22%3A%22creeper%22%7D%5D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      filters = '[{"property_name":"enemy","operator":"eq","property_value":"creeper"}]'
      _, options = start "queries:run --analysis-type count --collection minecraft-deaths --filters #{filters}"
      expect(_).to eq(10)
    end

    it 'accepts extraction-specific properties' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/extraction?event_collection=minecraft-deaths&property_names=%5B%22foo%22,%22bar%22%5D&latest=1&email=bob@bob.io"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type extraction --collection minecraft-deaths --property-names foo,bar --latest 1 --email bob@bob.io'
      expect(_).to eq(10)
    end

    it 'converts comma-delimited property names to an array' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/extraction?event_collection=minecraft-deaths&property_names=%5B%22foo%22,%22bar%22%5D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type extraction --collection minecraft-deaths --property-names foo,bar'
      expect(_).to eq(10)
    end

    it 'uses a data option to take in query JSON' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --analysis-type count --collection minecraft-deaths --data {"event_collection":"minecraft-deaths"}'
      expect(_).to eq(10)
    end

    it 'converts a start parameter into an absolute timeframe' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&timeframe=%7B%22start%22:%222014-07-06T12:00:00Z%22%7D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --collection minecraft-deaths --analysis-type count --start 2014-07-06T12:00:00Z'
      expect(_).to eq(10)
    end

    it 'converts an end parameter into an absolute timeframe' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&timeframe=%7B%22end%22:%222014-07-06T12:00:00Z%22%7D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --collection minecraft-deaths --analysis-type count --end 2014-07-06T12:00:00Z'
      expect(_).to eq(10)
    end

    it 'converts start and end parameters into an absolute timeframe' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&timeframe=%7B%22start%22:%222014-07-06T12:00:00Z%22,%22end%22:%222014-07-08T12:00:00Z%22%7D"
      stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
      _, options = start 'queries:run --collection minecraft-deaths --analysis-type count --start 2014-07-06T12:00:00Z --end 2014-07-08T12:00:00Z'
      expect(_).to eq(10)
    end

  end

  describe 'queries:url' do

    it 'should return the url instead of running the query' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&api_key=#{Keen.read_key}"
      _, options = start 'queries:url --analysis-type count --collection minecraft-deaths'
      expect(_).to eq(url)
    end

    it 'should not include the api key if excluded' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths"
      _, options = start 'queries:url --analysis-type count --collection minecraft-deaths --exclude-api-key'
      expect(_).to eq(url)
    end

  end

  describe 'spark format' do

    it 'should emit interval results as numbers' do
      url = "https://api.keen.io/3.0/projects/#{project_id}/queries/count?event_collection=minecraft-deaths&timeframe=last_2_minutes&interval=minutely"
      stub_request(:get, url).to_return(:body => { :result => [{ value: 10 }, { value: 20 }] }.to_json)
      _ = start 'queries:run --collection minecraft-deaths --analysis-type count --timeframe last_2_minutes --interval minutely --spark'
      expect(_).to eq("10 20")
    end

  end

  describe "queries:run aliases" do
    KeenCli::CLI::ANALYSIS_TYPES.each do |analysis_type|
      describe analysis_type do
        it "aliases to queries run, passing along the #{analysis_type} analysis type" do
          underscored_analysis_type = analysis_type.sub('-', '_')
          url = "https://api.keen.io/3.0/projects/#{project_id}/queries/#{underscored_analysis_type}?event_collection=minecraft-deaths"
          stub_request(:get, url).to_return(:body => { :result => 10 }.to_json)
          _, options = start "#{analysis_type} --collection minecraft-deaths"
          expect(_).to eq(10)
        end
      end
    end
  end

end
