require 'active_support/concern'
require 'ar-ondemand/result'
require 'ar-ondemand/record'

module ActiveRecord
  module OnDemand
    module ForReadingExtension
      extend ::ActiveSupport::Concern

      # Ripped from the find_in_batches function, but customized to return an ::ActiveRecord::OnDemand::ResultSet
      def for_reading(options = {})
        return query(self) if options.empty?

        relation = self

        unless arel.orders.blank? && arel.taken.blank?
          ActiveRecord::Base.logger.warn("Scoped order and limit are ignored, it's forced to be batch order and batch size")
        end

        if (finder_options = options.except(:start, :batch_size)).present?
          raise "You can't specify an order, it's forced to be #{batch_order_for_reading}" if options[:order].present?
          raise "You can't specify a limit, it's forced to be the batch_size"  if options[:limit].present?

          relation = apply_finder_options(finder_options)
        end

        start = options.delete(:start)
        batch_size = options.delete(:batch_size) || 1000

        relation = relation.reorder(batch_order_for_reading).limit(batch_size)
        records = query_for_reading(start ? relation.where(table[primary_key].gteq(start)) : relation)

        while records.any?
          records_size = records.size
          primary_key_offset = records.last.id

          yield records

          break if records_size < batch_size

          if primary_key_offset
            records = query_for_reading relation.where(table[primary_key].gt(primary_key_offset))
          else
            raise "Primary key not included in the custom select clause"
          end
        end
      end

      private

      def query_for_reading(ar)
        results = ::ActiveRecord::Base.connection.exec_query ar.to_sql
        ::ActiveRecord::OnDemand::ResultSet.new self.arel.engine, results
      end

      def batch_order_for_reading
        "#{quoted_table_name}.#{quoted_primary_key} ASC"
      end
    end
  end
end

::ActiveRecord::Relation.send(:include, ::ActiveRecord::OnDemand::ForReadingExtension)
