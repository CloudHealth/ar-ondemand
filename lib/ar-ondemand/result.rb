module ActiveRecord
  module OnDemand
    class ResultSet
      include ::Enumerable

      CACHED_READONLY_CLASSES ||= {}

      def initialize(model, results, options = {})
        @model = model
        @results = results
        @column_types = Hash[@model.columns.map { |x| [x.name, x] }]
        @col_indexes = HashWithIndifferentAccess[@results.columns.each_with_index.map { |x, i| [x,i] }]
        @raw = options.delete :raw
        @readonly = options.delete :readonly
        @readonly_klass = @readonly ? create_readonly_class : nil
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
        @results.rows.each { |row| yield result_to_record(row) }
      end

      def first
        result_to_record @results.rows.first
      end

      def last
        result_to_record @results.rows.last
      end

      protected

      def result_to_record(row)
        return nil if row.nil?
        return row if @raw
        if @readonly
          convert_to_struct @readonly_klass, row
        else
          ::ActiveRecord::OnDemand::Record.new convert_to_hash(row), @model, nil
        end
      end

      def create_readonly_class
        attrs = @col_indexes.keys.map(&:to_sym)
        return CACHED_READONLY_CLASSES[attrs] if CACHED_READONLY_CLASSES[attrs]
        CACHED_READONLY_CLASSES[attrs] = ::Struct.new(*attrs)
      end

      def convert_to_hash(rec)
        # TODO: Is using HashWithIndifferentAccess[] more efficient?
        h = {}
        @col_indexes.each_pair do |k, v|
          if @column_types[k]
            # Rails 4.2 renamed type_cast into type_cast_from_database
            # This is not documented in their upgrade docs or release notes.
            # See https://github.com/rails/rails/commit/d24e640
            if @column_types[k].respond_to?(:type_cast)
              h[k] = @column_types[k].type_cast rec[v]
            else
              h[k] = @column_types[k].type_cast_from_database rec[v]
            end
          else
            h[k] = rec[v]
          end
        end
        h.with_indifferent_access
      end

      def convert_to_struct(klass, rec)
        vals = []
        @col_indexes.each_pair do |k, v|
          # Rails 4.2 renamed type_cast into type_cast_from_database
          # This is not documented in their upgrade docs or release notes.
          # See https://github.com/rails/rails/commit/d24e640
          if @column_types[k].respond_to?(:type_cast)
            vals << @column_types[k].type_cast(rec[v])
          else
            vals << @column_types[k].type_cast_from_database(rec[v])
          end
        end
        klass.new(*vals)
      end
    end
  end
end
