require 'rspec'
require 'rspec/core'
require 'rspec/expectations'
require 'active_support'
require 'active_record'
require 'simplecov'
require 'simplecov-console'
require 'simplecov-json'
require 'simplecov-rcov'

SimpleCov.formatters = [
  SimpleCov::Formatter::Console,
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
  SimpleCov::Formatter::RcovFormatter
]

SimpleCov.start do
  add_filter '/spec'
end

I18n.enforce_available_locales = false

Dir['spec/support/**/*.rb'].sort.each { |f| load f }

require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.find_definitions

Dir['spec/app/models/*.rb'].sort.each { |f| load f }
