ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Migration.suppress_messages do
  load 'spec/db/schema.rb'
  load 'spec/db/seeds.rb'
end

require 'shoulda'
require 'shoulda/matchers/integrations/rspec'

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
