require 'spec_helper'

describe KeenCli::CLI do

  let(:project_id) { Keen.project_id }
  let(:master_key) { Keen.master_key }
  let(:read_key) { Keen.read_key }
  let(:write_key) { Keen.write_key }

  it 'prints version info if -v is used' do
    _, options = start "-v"
    expect(_).to match /version/
  end

end
