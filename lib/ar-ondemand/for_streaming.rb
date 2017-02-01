require 'active_support/concern'
require 'ar-ondemand/for_reading'

module ActiveRecord
  module OnDemand
    module Streaming
      extend ::ActiveSupport::Concern

      module ClassMethods
        def for_streaming(options = {})
          options[:batch_size] ||= 50_000
          fr = options.delete(:for_reading)

          # TODO Clean this up after dropping support for Rails 3
          if ActiveRecord::VERSION::MAJOR == 3
            s = self.respond_to?(:to_sql) ? self : self.scoped
          else
            s = self.respond_to?(:to_sql) ? self : self.all
          end

          ::Enumerator.new do |n|
            s.send(fr ? :for_reading : :find_in_batches, options) do |b|
              b.each { |r| n << r }
            end
          end
        end
      end
    end
  end
end

::ActiveRecord::Base.send     :include, ::ActiveRecord::OnDemand::Streaming
::ActiveRecord::Relation.send :include, ::ActiveRecord::OnDemand::Streaming::ClassMethods
