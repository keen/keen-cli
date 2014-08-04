# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "keen-cli/version"

Gem::Specification.new do |s|
  s.name        = "keen-cli"
  s.version     = KeenCli::VERSION
  s.authors     = ["Josh Dzielak"]
  s.email       = "josh@keen.io"
  s.homepage    = "https://github.com/keenlabs/keen-cli"
  s.summary     = "Command line interface to Keen IO"
  s.description = "Record events and run queries from the comfort of your command line"
  s.license     = "MIT"

  s.add_dependency "keen", ">= 0.8.6"
  s.add_dependency "thor"
  s.add_dependency "dotenv"

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'debugger'
  s.add_development_dependency 'webmock'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
