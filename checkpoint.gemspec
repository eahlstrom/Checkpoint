# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "checkpoint/version"

Gem::Specification.new do |s|
  s.name        = "checkpoint"
  s.version     = Checkpoint::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Erik Ahlström"
  s.email       = "ea@negahok.se"
  s.homepage    = "http://github.com/eahlstrom/checkpoint"
  s.summary     = "checkpoint firewall rulebase simulator"
  s.description = "lib to simulate and test firewall rulebase"

  s.rubygems_version   = "1.3.7"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [ "README.markdown" ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_runtime_dependency 'libxml-ruby', '>= 1.1'
end
