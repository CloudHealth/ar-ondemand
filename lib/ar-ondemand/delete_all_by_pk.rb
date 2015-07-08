require 'active_support/concern'

module ActiveRecord
  module OnDemand
    module DeleteAllByPkExtension
      extend ::ActiveSupport::Concern

      # Use this instead of delete_all to perform a delete using the PK of the table, which prevents a complete table scan that locks it
      # Based on find_in_batches function
      def delete_all_by_pk(options = {})
        relation = self

        unless arel.orders.blank? && arel.taken.blank?
          ActiveRecord::Base.logger.warn("Scoped order and limit are ignored, it's forced to be batch order and batch size")
        end

        if (finder_options = options.except(:start, :batch_size)).present?
          raise "You can't specify an order, it's forced to be #{batch_order_delete_all_by_pk}" if options[:order].present?
          raise "You can't specify a limit, it's forced to be the batch_size"  if options[:limit].present?

          relation = apply_finder_options(finder_options)
        end

        start = options.delete(:start)
        batch_size = options.delete(:batch_size)

        relation = relation.reorder(batch_order_delete_all_by_pk).limit(batch_size) if batch_size
        records = query_delete_all_by_pk(start ? relation.where(table[primary_key].gteq(start)) : relation)

        while records.any?
          records_size = records.size
          primary_key_offset = records.last

          self.unscoped.where(id: records).delete_all

          break if batch_size.nil? || records_size < batch_size

          records = query_delete_all_by_pk relation.where(table[primary_key].gt(primary_key_offset))
        end
      end

      private

      def query_delete_all_by_pk(ar)
        results = ::ActiveRecord::Base.connection.exec_query ar.select([table[primary_key]]).to_sql
        results.rows.flatten
      end

      def batch_order_delete_all_by_pk
        "#{quoted_table_name}.#{quoted_primary_key} ASC"
      end
    end
  end
end

::ActiveRecord::Relation.send(:include, ::ActiveRecord::OnDemand::DeleteAllByPkExtension)
