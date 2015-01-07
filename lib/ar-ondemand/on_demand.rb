require 'active_support/concern'
require 'ar-ondemand/result'
require 'ar-ondemand/record'

module ActiveRecord
  module OnDemand
    class Result < ResultSet
      include ::Enumerable

      def initialize(model, results, key_column, defaults)
        super(model, results)

        raise "Key column cannot be blank." if key_column.blank?
        raise "Defaults cannot be empty." if defaults.empty?

        @key_column = key_column.to_s
        @defaults = defaults

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
    end

    module Extension
      extend ::ActiveSupport::Concern

      module ClassMethods
        def on_demand(keys, defaults = {})
          results = ::ActiveRecord::Base.connection.exec_query self.where(defaults).to_sql
          ::ActiveRecord::OnDemand::Result.new self, results, keys, defaults
        end
      end
    end
  end
end

::ActiveRecord::Base.send(:include, ::ActiveRecord::OnDemand::Extension)
