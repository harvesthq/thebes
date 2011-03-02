# -*- Mode:Ruby; encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "thebes/version"

Gem::Specification.new do |s|
  s.name        = "thebes"
  s.version     = Thebes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matthew Beale"]
  s.email       = ["matt.beale@madhatted.com"]
  s.homepage    = "https://github.com/harvesthq/thebes"
  s.summary     = %q{Thebes is a thin binding layer for Rails and Sphinx via Riddle and Mysql2.}
  s.description = %q{Thebes is a thin binding layer for Rails and Sphinx via Riddle and Mysql2. Thebes expects you to write Sphinx configuration files by hand and have a rich understanding of Sphinx, but provides configuration files and templates to ease the process.}

  s.add_dependency "riddle"
  s.add_dependency "mysql2"
  s.add_dependency "actionpack", ">= 3.0.3"
  s.add_dependency "activerecord", ">= 3.0.3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "genspec"
  s.add_development_dependency "mocha"

  # s.rubyforge_project = "thebes"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
