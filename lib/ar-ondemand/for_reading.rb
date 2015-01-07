require 'active_support/concern'
require 'ar-ondemand/result'
require 'ar-ondemand/record'

module ActiveRecord
  module OnDemand
    module ForReadingExtension
      extend ::ActiveSupport::Concern

      def for_reading
        results = ::ActiveRecord::Base.connection.exec_query self.to_sql
        ::ActiveRecord::OnDemand::ResultSet.new self.arel.engine, results
      end
    end
  end
end

::ActiveRecord::Relation.send(:include, ::ActiveRecord::OnDemand::ForReadingExtension)
