source 'https://rubygems.org'

gemspec

group :test, :development do
  if RUBY_ENGINE == 'jruby'
    gem 'activerecord-jdbc-adapter'
  else
    gem 'sqlite3', '~> 1.3', '< 1.4'
  end

  gem 'rake'
  gem 'rspec'
  gem 'factory_bot'
  gem 'pry'
  gem 'rspec_junit_formatter', '0.3.0'
  gem 'simplecov'
  gem 'simplecov-console'
  gem 'simplecov-json'
  gem 'simplecov-rcov'
end
