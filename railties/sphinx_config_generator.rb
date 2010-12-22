require 'rails/generators'

class SphinxConfigGenerator < Rails::Generators::Base

  source_root "#{File.dirname(__FILE__)}/../templates/"
  
  def copy_config_defaults
    copy_file 'sphinx.conf.erb', 'config/sphinx.conf.erb'
    copy_file 'sphinx.yml', 'config/sphinx.yml'
    copy_file 'riddle.yml', 'config/riddle.yml'
  end

end
