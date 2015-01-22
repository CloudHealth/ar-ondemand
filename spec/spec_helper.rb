require 'rspec'
require 'rspec/core'
require 'rspec/expectations'
require 'active_support'
require 'active_record'

I18n.enforce_available_locales = false

Dir['spec/support/**/*.rb'].sort.each { |f| load f }

require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions

Dir['spec/app/models/*.rb'].sort.each { |f| load f }
