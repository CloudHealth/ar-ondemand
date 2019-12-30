# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require File.dirname(__FILE__) + '/lib/ar-ondemand/version'

Gem::Specification.new do |s|
  s.name        = 'ar-ondemand'
  s.version     = ::ArOnDemand::VERSION
  s.summary     = 'ActiveRecord On-demand'
  s.description = 'Fast access to database results without the memory overhead of ActiveRecord objects'
  s.authors     = ['Steve Frank']
  s.email       = %w(steve@cloudhealthtech.com lardcanoe@gmail.com)
  s.homepage    = 'https://github.com/CloudHealth/ar-ondemand'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split("\n")

  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_paths = %w(lib)

  s.add_dependency 'activesupport', '>= 3.2.22'
  s.add_dependency 'activerecord',  '>= 3.2.22'

  s.add_development_dependency 'bundler', '>= 1.14'
  s.add_development_dependency 'rake', '>= 12.0'
end
