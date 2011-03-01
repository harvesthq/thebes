require 'rubygems'
require 'bundler/setup'

require 'thebes' # and any other gems you need

FileUtils.mkdir_p 'tmp'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = false
  config.before :all do

    # Fetch a database configuration.
    #
    db_config = YAML.load( ERB.new( IO.read(
      File.join(File.dirname(__FILE__), 'support/database.yml')
    ) ).result )['test']

    # Write a sphinx configuation for test mode.
    #
    generator = Thebes::ConfigWriter.new \
      File.join(File.dirname(__FILE__), 'support'),
      'test.sphinx.conf'
    generator.build \
      File.join(File.dirname(__FILE__), 'support/test.sphinx.conf'),
      db_config

    # Give Riddle a dummy configuration so we can use it to
    # control searchd.
    #
    r_config = Riddle::Configuration.new
    r_config.searchd.pid_file = 'tmp/searchd.pid'
    r_config.searchd.log = 'tmp/searchd.log'

    # Create a Riddle controller.
    #
    @sphinx = Riddle::Controller.new \
      r_config,
      File.join(File.dirname(__FILE__), 'support/test.sphinx.conf')

    # Build an initial index.
    #
    @sphinx.index

    # Start searchd.
    #
    @sphinx.start

  end
  config.after :each do
    ActiveRecord::Base.connection.execute('SHOW TABLES;').each do |table|
      # Or whatever you think is appropriate.
      next if table.index('schema_migrations') or table.index('roles')
      ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
    end
  end
  config.after :all do

    # Stop searchd after specs run.
    #
    @sphinx.stop

  end
end

RSpec::Matchers.define :define_constant do |expected|
  match { |actual| actual.const_defined?(expected) }
end
