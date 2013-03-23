# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'koda-content/version'

Gem::Specification.new do |s|
  s.name        = "koda-content"
  s.version     = Koda::Content::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Marcel du Prez", "Derek Ekins"]
  s.email       = ["marceldupr@gmail.com", "derek@spathi.com"]
  s.homepage    = "https://github.com/KodaFramework"
  s.summary     = "Koda Content - restful json and and media store"
  s.description = "Koda Content - restful json and and media store"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency 'mongo'
  s.add_dependency 'mongoid'
  s.add_dependency 'sinatra'
  s.add_dependency 'rack-methodoverride-with-params'
  s.add_dependency 'sinatra-jsonp'

  s.add_dependency 'bson_ext'
  s.add_dependency 'shared-mime-info'
  s.add_dependency 'dalli'
  s.add_dependency 'json'
  #s.add_dependency 'multi_json', '>= 1.5'

  s.add_development_dependency 'rspec', '>= 2.8'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'shotgun'
  s.add_development_dependency 'watchr'
  s.add_development_dependency 'rake'

  s.files        = Dir.glob("{lib}/**/*")
  #s.executables  = ['bundle']
  s.require_path = 'lib'
end