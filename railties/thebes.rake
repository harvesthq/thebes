namespace :thebes do

  desc "Build the sphinx config files"
  task :build do
    unless File.exists?(File.join(Rails.root, 'config', 'sphinx.yml'))
      raise 'No config file present, please create a config/sphinx.yml'
    end
    config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'sphinx.yml'))).result)[Rails.env.to_s]
    generator = Thebes::ConfigWriter.new(File.join(Rails.root, 'config'))
    config.each do |file, conf|
      if file[0].chr != '/'
        file = File.join(Rails.root, 'config', file)
      end
      generator.build file, (conf || {})
    end
  end

end
