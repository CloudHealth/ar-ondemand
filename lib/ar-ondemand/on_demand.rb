module ActiveRecord
  module OnDemand
    class Result
      include ::Enumerable

      def initialize(model, key_column, defaults, results)
        raise "Key column cannot be blank." if key_column.blank?
        raise "Defaults cannot be empty." if defaults.empty?

        @model = model
        @key_column = key_column.to_s
        @defaults = defaults
        @column_types = Hash[@model.columns.map { |x| [x.name, x] }]

        @results = results
        @col_indexes = Hash[@results.columns.each_with_index.map { |x,i| [x,i] }].with_indifferent_access
        @key_index = @col_indexes[@key_column]
        raise "Unknown index #{key_column}" if @key_index.nil?

        @find_by_method = "find_or_initialize_by_#{(@defaults.keys + [@key_column]).join('_and_')}"
        @has_any_assets = !ids.empty? || @model.unscoped.where(@defaults).exists?
        @new_params = @defaults.dup
        @new_params[@key_column.to_sym] = nil
      end

      def [](key)
        raise "Search key cannot be blank." if key.blank?
        rec = @results.rows.find { |x| x[@key_index] == key }
        if rec.nil?
          if @has_any_assets
            args = @defaults.values + [key]
            @model.unscoped.send(@find_by_method, *args)
          else
            @new_params[@key_column.to_sym] = key
            @model.new @new_params
          end
        else
          ::ActiveRecord::OnDemand::Record.new convert_to_hash(rec), @model, @defaults
        end
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
          yield ::ActiveRecord::OnDemand::Record.new(convert_to_hash(row), @model, @defaults)
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

    module Extension
      extend ::ActiveSupport::Concern

      module ClassMethods
        def on_demand(keys, defaults = {})
          results = ::ActiveRecord::Base.connection.exec_query self.where(defaults).to_sql
          ::ActiveRecord::OnDemand::Result.new self, keys, defaults, results
        end
      end
    end
  end
end

::ActiveRecord::Base.send(:include, ::ActiveRecord::OnDemand::Extension)
