require 'spec_helper'

module KeenCli

  describe BatchProcessor do

    let(:batch_processor) { BatchProcessor.new('signups') }

    describe 'new' do

      it 'defaults batch size to 1000' do
        expect(batch_processor.batch_size).to eq(1000)
      end

      it 'sets total size to 0' do
        expect(batch_processor.total_size).to eq(0)
      end

      it 'sets the collection' do
        expect(batch_processor.collection).to eq('signups')
      end

      it 'sets the pretty output' do
        batch_processor = BatchProcessor.new('signups', :pretty => true)
        expect(batch_processor.pretty).to eq(true)
      end

      it 'sets the silent output' do
        batch_processor = BatchProcessor.new('signups', :silent => true)
        expect(batch_processor.silent).to eq(true)
      end

      it 'sets csv and merges csv options with defaults' do
        csv_processor = BatchProcessor.new('signups', :csv => true, :csv_options => { :headers => ['foo'] })
        expect(csv_processor.csv).to eq(true)
        expect(csv_processor.csv_options).to eq(
          :headers => ['foo'], :converters => :all)
      end

    end

    describe 'conversion' do

      let(:batch_processor) { BatchProcessor.new('signups') }

      it 'converts a JSON string to a hash' do
        batch_processor.add('{ "apple": "sauce", "banana": "pancakes" }')
        expect(batch_processor.events.first).to eq({
          "apple" => "sauce",
          "banana" => "pancakes"
        })
      end

      it 'converts a JSON array to a series of hashes' do
        batch_processor.add('[{ "apple": "sauce", "banana": "pancakes" }]')
        expect(batch_processor.events.first).to eq({
          "apple" => "sauce",
          "banana" => "pancakes"
        })
      end

      it 'converts a param string to a hash' do
        batch_processor.params = true
        batch_processor.add('apple=sauce&banana=pancakes')
        expect(batch_processor.events.first).to eq({
          "apple" => "sauce",
          "banana" => "pancakes"
        })
      end

      it 'converts a csv line to a hash' do
        batch_processor.csv = true
        batch_processor.csv_options[:headers] = ['apple', 'banana']
        batch_processor.add('sauce,pancakes')
        expect(batch_processor.events.first).to eq({
          "apple" => "sauce",
          "banana" => "pancakes"
        })
      end

      it 'converts a csv line with dotted properties to nested hashes' do
        batch_processor.csv = true
        batch_processor.csv_options[:headers] = ['keen.timestamp', 'apple.date', 'apple.banana.cherry', 'apple.banana.walnut']
        batch_processor.add('2012-08-09,pudding,smoothie,butter')
        expect(batch_processor.events.first).to eq({
          "apple" => {
            "date" => "pudding",
            "banana" => {
              "cherry" => "smoothie",
              "walnut" => "butter"
            }
          },
          "keen" => {
            "timestamp" => "2012-08-09"
          }
        })
      end

      it 'deals with quoted csv values' do
        batch_processor.csv = true
        batch_processor.csv_options[:headers] = ['keen.timestamp', 'apple.date', 'apple.banana.cherry', 'apple.banana.walnut']
        batch_processor.add('"2012-08-09, blah","blah pudding",smoothie,"b,u,tter"')
        expect(batch_processor.events.first).to eq({
          "apple" => {
            "date" => "blah pudding",
            "banana" => {
              "cherry" => "smoothie",
              "walnut" => "b,u,tter"
            }
          },
          "keen" => {
            "timestamp" => "2012-08-09, blah"
          }
        })

      end

      it 'deals with quoted csv headers' do
        batch_processor.csv = true
        batch_processor.add('"keen.timestamp","apple.date","apple.banana.cherry","apple.banana.walnut"')
        expect(batch_processor.csv_options[:headers]).to eq(["keen.timestamp", "apple.date", "apple.banana.cherry", "apple.banana.walnut"])
      end

    end

    describe 'add' do

      let(:batch_processor) { BatchProcessor.new('signups', :silent => true) }

      it 'starts empty' do
        expect(batch_processor.size).to eq(0)
        expect(batch_processor.events).to be_empty
      end

      it 'adds events to an array up to batch size and increments count' do
        batch_processor.add('{ "apple": "sauce", "banana": "pancakes" }')
        expect(batch_processor.size).to eq(1)
        expect(batch_processor.total_size).to eq(1)
        expect(batch_processor.events.first).to eq({
          "apple" => "sauce",
          "banana" => "pancakes"
        })
      end

      it 'flushes at the batch size' do
        stub_request(:post, "https://api.keen.io/3.0/projects/#{Keen.project_id}/events").
          with(:body => "{\"signups\":[{\"apple\":\"sauce\",\"banana\":\"pancakes\"},{\"apple\":\"sauce\",\"banana\":\"pancakes\"}]}").
          to_return(:status => 200, :body => { "signups" => [{ "created" => true }] }.to_json)
        batch_processor.batch_size = 2
        batch_processor.add('{ "apple": "sauce", "banana": "pancakes" }')
        expect(batch_processor.size).to eq(1)
        expect(batch_processor.total_size).to eq(1)
        batch_processor.add('{ "apple": "sauce", "banana": "pancakes" }')
        expect(batch_processor.size).to eq(0)
        expect(batch_processor.total_size).to eq(2)
        expect(batch_processor.events).to be_empty
      end

    end

    describe 'flush' do

      let(:batch_processor) { BatchProcessor.new('signups') }

      it 'does not flush if there are no events' do
        batch_processor.size = 0
        batch_processor.flush
      end

    end

  end

end
