module ActiveRecord
  module OnDemand
    class ResultSet
      include ::Enumerable

      CACHED_READONLY_CLASSES ||= {}

      def initialize(model, results, options = {})
        @model = model
        @results = results
        @column_types = Hash[@model.columns.map { |x| [x.name, x] }]
        determine_type_cast_method
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

      def determine_type_cast_method
        _, col = @column_types.first
        return if col.nil?
        @type_cast = if col.respond_to?(:type)
                       # Rails 5+
                       :type
                     elsif col.respond_to?(:type_cast)
                       # Rails 3
                       :type_cast
                     elsif col.respond_to?(:type_cast_from_database)
                       # Rails 4.2 renamed type_cast into type_cast_from_database
                       # This is not documented in their upgrade docs or release notes.
                       # See https://github.com/rails/rails/commit/d24e640
                       :type_cast_from_database
                     else
                       raise 'Unable to determine type cast method for column'
                     end
      end

      def convert_to_hash(rec)
        # TODO: Is using HashWithIndifferentAccess[] more efficient?
        h = HashWithIndifferentAccess.new
        @col_indexes.each_pair do |k, v|
          h[k] = cast_value k, rec[v]
        end
        h
      end

      def convert_to_struct(klass, rec)
        vals = []
        @col_indexes.each_pair do |k, v|
          vals << cast_value(k, rec[v])
        end
        klass.new(*vals)
      end

      def cast_value(k, v)
        return v unless @column_types[k]
        if @type_cast == :type
          t = @column_types[k].type
          t.is_a?(::Symbol) ? v : t.cast(v)
        elsif @type_cast == :type_cast
          @column_types[k].type_cast v
        else
          @column_types[k].type_cast_from_database v
        end
      end
    end
  end
end
