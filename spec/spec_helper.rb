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

def start(str=nil)
  arry = str ? str.split(" ") : []
  arry.push("--silent")
  KeenCli::CLI.start(arry)
end
