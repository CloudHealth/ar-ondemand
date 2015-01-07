# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require File.dirname(__FILE__) + '/lib/ar-ondemand/version'

Gem::Specification.new do |s|
  s.name        = 'ar-ondemand'
  s.version     = ::ActiveRecord::OnDemand::VERSION
  s.date        = '2015-01-06'
  s.summary     = 'ActiveRecord On-demand'
  s.description = 'Raw DB Results'
  s.authors     = ['Steve Frank']
  s.email       = %w(steve@cloudhealthtech.com lardcanoe@gmail.com)
  s.homepage    = 'https://github.com/CloudHealth/ar-ondemand'

  s.files       = `git ls-files`.split("\n")

  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_paths = %w(lib)
end