require 'rubygems'
require 'bundler/setup'

require 'thebes' # and any other gems you need

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
end

RSpec::Matchers.define :define_constant do |expected|
  match { |actual| actual.const_defined?(expected) }
end
