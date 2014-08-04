require 'rspec'
require 'webmock/rspec'

require File.expand_path("../../lib/keen-cli", __FILE__)

RSpec.configure do |config|

  config.before(:each) do
    Keen.project_id = 'AAAAAAA'
    Keen.read_key = 'DDDDDD'
    Keen.write_key = 'BBBBBB'
    Keen.master_key = 'CCCCCC'
  end

end
