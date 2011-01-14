require 'thebes'
require 'rails'

module Thebes

  class Railtie < Rails::Railtie
    
    rake_tasks do
      load "#{File.dirname(__FILE__)}/../../railties/thebes.rake"
    end

    generators do
      load "#{File.dirname(__FILE__)}/../../railties/sphinx_config_generator.rb"
    end

    initializer "thebes.initialize" do |app|

      config_file = File.join(Rails.root, 'config', 'sphinx_servers.yml')
      if File.exists?(config_file)
        config = YAML.load(ERB.new(IO.read(config_file)).result)[Rails.env.to_s]
        if config['sphinx_api']
          Thebes::Query.servers = config['sphinx_api']
        end
        if config['sphinxql']
          Thebes::Sphinxql::Client.servers = config['sphinxql']
        end
      end

    end

  end

end
