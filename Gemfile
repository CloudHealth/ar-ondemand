source 'https://rubygems.org'

gemspec

# TODO: Update this pin to to ~0.11.0. when we upgrade to Ruby > 2.4
gem 'simplecov-html', '0.10.2'

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
  gem 'docile', '~> 1.3.5'
end
