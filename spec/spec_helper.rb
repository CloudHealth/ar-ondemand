require 'rspec'
require 'rspec/core'
require 'rspec/expectations'
require 'active_support'
require 'active_record'

I18n.enforce_available_locales = false

Dir['spec/support/**/*.rb'].sort.each { |f| load f }

require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

FactoryBot.find_definitions

Dir['spec/app/models/*.rb'].sort.each { |f| load f }
