module ActiveRecord
  module OnDemand
    class ForReadingResult
      include ::Enumerable

      def initialize(model, results)
        @model = model
        @column_types = Hash[@model.columns.map { |x| [x.name, x] }]
        @results = results
        @col_indexes = Hash[@results.columns.each_with_index.map { |x,i| [x,i] }].with_indifferent_access
      end

      def ids
        id_col = @col_indexes[:id]
        @results.rows.map { |r| r[id_col] }
      end

      def length
        @results.rows.length
      end
      alias_method :count, :length

      def each
        @results.rows.each do |row|
          yield ::ActiveRecord::OnDemand::Record.new(convert_to_hash(row), @model, nil)
        end
      end

      private

      def convert_to_hash(rec)
        h = {}
        @col_indexes.each_pair do |k, v|
          h[k] = @column_types[k].type_cast rec[v]
        end
        h.with_indifferent_access
      end
    end

    module ForReadingExtension
      extend ::ActiveSupport::Concern

      def for_reading
        results = ::ActiveRecord::Base.connection.exec_query self.to_sql
        ::ActiveRecord::OnDemand::ForReadingResult.new self.arel.engine, results
      end
    end
  end
end

::ActiveRecord::Relation.send(:include, ::ActiveRecord::OnDemand::ForReadingExtension)
