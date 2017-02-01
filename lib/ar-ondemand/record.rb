module ActiveRecord
  module OnDemand
    class Record
      #TODO: include ::ActiveModel::Dirty
      attr_reader :changes

      def initialize(record, model, defaults)
        @record = record
        @model = model
        @defaults = defaults
        @changes = {}

        # Memoizing Rails 4.2 capability here for performance purposes. See
        # `#save` method for more details
        # TODO Remove when dropping Rails 3 support
        @model_instantiate = @model.respond_to?(:instantiate)
      end

      def is_readonly?
        @defaults.nil?
      end

      def method_missing(meth, *args, &block)
        key = meth.to_s
        if @record.include? key
          @changes.include?(key) ? @changes[key] : @record[key]
        elsif key.end_with?('=') && (@record.include?(key[0...-1]) || @record.include?("#{key[0...-1]}_id"))
          raise ActiveRecord::ReadOnlyRecord if is_readonly?
          key = key[0...-1]
          unless key == 'id'
            val = args[0]
            passing_in_model = false
            # Support `model.foo_bar=<instance>` along with `model.foo_bar_id=<int>`
            if @record.include?("#{key}_id")
              passing_in_model = true
              key_model = key
              key = "#{key}_id"
              val_model = val
              val = val.id unless val.nil?
            end
            if @record[key] != val
              return if @record[key] == 1 && val == true
              return if @record[key] == 0 && val == false
              return if val.is_a?(Time) && !@record[key].blank? && @record[key].to_time.to_i == val.to_i
              @changes[key] = val
              @changes[key_model] = val_model if passing_in_model
            else
              # If they changed it, then reverted back, remove from @changes
              @changes.delete key
            end
          end
        elsif key.end_with?('?') && @record.include?(key[0...-1])
          key = key[0...-1]
          v = @changes.include?(key) ? @changes[key] : @record[key]
          return false if v.nil?
          return false if v === 0 || v === false
          return false if v.respond_to?(:blank?) && v.blank?
          true
        elsif key.end_with?('_changed?') && @record.include?(key[0...-9])
          @changes.include?(key[0...-9])
        else
          super
        end
      end

      def has_attribute?(attr)
        @record.include? attr
      end

      def save
        raise ActiveRecord::ReadOnlyRecord if is_readonly?
        return nil if @changes.empty?

        # `@model.allocate.init_with` breaks in Rails 4.2. Construction has been
        # replaced with `instantiate` (see http://stackoverflow.com/q/20409650/1935861
        # and https://github.com/rails/rails/blob/31a95ed/activerecord/lib/active_record/persistence.rb#L56-L70).
        # TODO Remove when dropping Rails 3 support
        if @model_instantiate
          rec = @model.instantiate(@record)
        else
          rec = @model.allocate.init_with('attributes' => @record)
        end
        @changes.each_pair do |key, val|
          next if key == 'id'
          rec.send("#{key}=".to_sym, val)
        end
        rec.save
        @changes.clear
        rec
      end
    end
  end
end
