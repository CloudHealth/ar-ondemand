source 'http://rubygems.org'

gemspec

group :test, :development do
  if RUBY_ENGINE == 'jruby'
    gem 'activerecord-jdbc-adapter'
  else
    gem 'sqlite3'
  end

  gem 'rspec'
  gem 'factory_girl'
  gem 'pry'
end
