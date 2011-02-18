require 'rubygems'
require 'bundler/setup'

require 'thebes' # and any other gems you need

FileUtils.mkdir_p 'tmp'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = true
  config.before :all do
    config = YAML.load(ERB.new(IO.read(File.join(File.dirname(__FILE__), 'support/database.yml'))).result)['test']
    generator = Thebes::ConfigWriter.new(File.join(File.dirname(__FILE__), 'support'), 'test.sphinx.conf')
    generator.build File.join(File.dirname(__FILE__), 'support/test.sphinx.conf'), config

    riddle_config = Riddle::Configuration.new
    riddle_config.searchd.pid_file = 'tmp/searchd.pid'
    riddle_config.searchd.log = 'tmp/searchd.log'
    @sphinx = Riddle::Controller.new \
      riddle_config,
      File.join(File.dirname(__FILE__), 'support/test.sphinx.conf')
    @sphinx.start
    @sphinx.index
  end
  config.after :all do
    @sphinx.stop
  end
end

RSpec::Matchers.define :define_constant do |expected|
  match { |actual| actual.const_defined?(expected) }
end
