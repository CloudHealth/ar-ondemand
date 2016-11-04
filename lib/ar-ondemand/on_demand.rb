require 'active_support/concern'
require 'ar-ondemand/result'
require 'ar-ondemand/record'

module ActiveRecord
  module OnDemand
    class Result < ResultSet
      include ::Enumerable

      def initialize(model, results, key_column, defaults)
        super(model, results)

        raise 'Key column cannot be blank.' if key_column.blank?
        raise 'Defaults cannot be empty.' if defaults.empty?

        @key_column = key_column.to_s
        @defaults = defaults

        @key_index = @col_indexes[@key_column]
        raise "Unknown index #{key_column}" if @key_index.nil?

        @has_any_assets = !ids.empty? || @model.unscoped.where(@defaults).exists?
        @new_params = @defaults.dup
        @new_params[@key_column.to_sym] = nil
        @results_to_hash = @results.rows.inject({}) do |h, row|
          raise "Duplicate key found for result set: #{row[@key_index]}" if h.has_key? row[@key_index]
          h[row[@key_index]] = row
          h
        end

        self
      end

      def [](key)
        raise 'Search key cannot be blank.' if key.blank?
        rec = @results_to_hash[key]
        if rec.nil?
          rec = if @has_any_assets
                  @model.unscoped
                    .where(@defaults.merge(@key_column => key))
                    .first_or_initialize
                else
                  @new_params[@key_column.to_sym] = key
                  @model.new @new_params
                end

          unless rec.persisted?
            # These are not getting initialized for some reason, so set using what is passed in
            @defaults.each_pair do |k, v|
              next unless v.is_a?(::ActiveRecord::Base)
              meth = k.to_s
              next unless meth.end_with? '_id'
              rec.send("#{meth[0...-3]}=", v)
            end
            # This helps prevent a lookup into the db when we know there couldn't be any data yet
            @model.reflections.select { |_, v| v.macro == :has_and_belongs_to_many }.keys.each do |r|
              rec.send("#{r}=", [])
            end
          end

          rec
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
