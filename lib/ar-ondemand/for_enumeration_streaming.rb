require 'active_support/concern'
require 'ar-ondemand/fast_enumeration'

module ActiveRecord
  module OnDemand
    module EnumerationStreaming
      extend ::ActiveSupport::Concern

      module ClassMethods
        def for_enumeration_streaming(options = {})
          query_for_enumeration_streaming self, options
        end

        private
        def query_for_enumeration_streaming(ar, options)
          options[:batch_size] ||= 50_000
          options[:id_column] ||= 'id'
          ::Enumerator.new do |eblock|
            start_id = 0
            loop do
              batch = ar.where("#{options[:id_column]} > #{start_id}").order(options[:id_column]).limit(options[:batch_size]).for_enumeration_reading
              break if batch.size == 0
              batch.each do |r|
                eblock << r
                start_id = r.id
              end
            end
          end
        end
      end
    end
  end
end

::ActiveRecord::Base.send     :include, ::ActiveRecord::OnDemand::EnumerationStreaming
::ActiveRecord::Relation.send :include, ::ActiveRecord::OnDemand::EnumerationStreaming::ClassMethods

