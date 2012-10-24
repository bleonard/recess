require 'rubygems'
require 'bundler/setup'
require 'rspec'

require 'recess'

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.order = 'random'
end
