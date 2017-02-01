require 'active_support/concern'
require 'ar-ondemand/fast_enumeration'

module ActiveRecord
  module OnDemand
    module EnumerationReading
      extend ::ActiveSupport::Concern

      module ClassMethods
        def for_enumeration_reading
          query_for_enumeration_reading self
        end

        private
        def query_for_enumeration_reading(ar)

          # TODO Clean this up after dropping support for Rails 3
          if ActiveRecord::VERSION::MAJOR == 3
            ar = ar.scoped unless ar.respond_to?(:to_sql)
          else
            ar = ar.all unless ar.respond_to?(:to_sql)
          end

          ::ActiveRecord::OnDemand::FastEnumeration.new(ar.arel.engine, ::ActiveRecord::Base.connection.exec_query(ar.to_sql))
        end

      end
    end
  end
end

::ActiveRecord::Base.send     :include, ::ActiveRecord::OnDemand::EnumerationReading
::ActiveRecord::Relation.send :include, ::ActiveRecord::OnDemand::EnumerationReading::ClassMethods
