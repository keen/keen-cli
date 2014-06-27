require 'spec_helper'

describe KeenCli::CLI do
  it 'prints help by default' do
    _, options = KeenCli::CLI.start
    expect(_).to be_empty
  end

  it 'prints version info if -v is used' do
    _, options = KeenCli::CLI.start(%w[-v])
    expect(_).to match /version/
  end

  describe 'project:show' do
    it 'gets the project' do
      _, options = KeenCli::CLI.start(%w[project:show])
      expect(_).to match /\/3.0\/projects\/#{Keen.project_id}\/events/
    end
  end
end
