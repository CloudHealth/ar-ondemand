module ActiveRecord
  module OnDemand
    class ResultSet
      include ::Enumerable

      def initialize(model, results)
        @model = model
        @results = results
        @column_types = Hash[@model.columns.map { |x| [x.name, x] }]
        @col_indexes = HashWithIndifferentAccess[@results.columns.each_with_index.map { |x, i| [x,i] }]
      end

      def ids
        id_col = @col_indexes[:id]
        @results.rows.map { |r| r[id_col] }
      end

      def length
        @results.rows.length
      end
      alias_method :count, :length
      alias_method :size, :length

      def each
        @results.rows.each do |row|
          yield ::ActiveRecord::OnDemand::Record.new(convert_to_hash(row), @model, nil)
        end
      end

      def first
        row = @results.rows.first
        return nil if row.nil?
        ::ActiveRecord::OnDemand::Record.new convert_to_hash(row), @model, nil
      end

      def last
        row = @results.rows.last
        return nil if row.nil?
        ::ActiveRecord::OnDemand::Record.new convert_to_hash(row), @model, nil
      end

      protected

      def convert_to_hash(rec)
        # TODO: Is using HashWithIndifferentAccess[] more efficient?
        h = {}
        @col_indexes.each_pair do |k, v|
          h[k] = @column_types[k].type_cast rec[v]
        end
        h.with_indifferent_access
      end
    end
  end
end
