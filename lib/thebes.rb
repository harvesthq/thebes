require 'active_record'
require File.dirname(__FILE__)+'/thebes/config_writer'
require File.dirname(__FILE__)+'/thebes/query'
require File.dirname(__FILE__)+'/thebes/sphinx_search'
require File.dirname(__FILE__)+'/thebes/sphinxql/client'
require File.dirname(__FILE__)+'/thebes/sphinxql/query'
require File.dirname(__FILE__)+'/thebes/railtie' if defined?(Rails::Railtie)

module Thebes
end

require 'zlib'
ActiveRecord::Base.class_eval do

  def self.to_crc32
    Zlib.crc32(self.name)
  end

end
