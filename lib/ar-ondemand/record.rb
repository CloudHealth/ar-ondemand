module ActiveRecord
  module OnDemand
    class Record
      attr_reader :changes

      def initialize(record, model, defaults)
        @record = record
        @model = model
        @defaults = defaults
        @changes = {}
      end

      def is_readonly?
        @defaults.nil?
      end

      def method_missing(meth, *args, &block)
        key = meth.to_s
        if @record.include? key
          @changes.include?(key) ? @changes[key] : @record[key]
        elsif key.end_with?('=') && @record.include?(key[0...-1])
          raise ActiveRecord::ReadOnlyRecord if is_readonly?
          key = key[0...-1]
          unless key == 'id'
            if @record[key] != args[0]
              return if @record[key] == 1 && args[0] == true
              return if @record[key] == 0 && args[0] == false
              return if args[0].is_a?(Time) && !@record[key].blank? && @record[key].to_time.to_i == args[0].to_i
              @changes[key] = args[0]
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
        # logger.debug "Loading model to store changes: #{@changes}"
        rec = @model.allocate.init_with('attributes' => @record)
        @changes.each_pair do |key, val|
          next if key == 'id'
          rec[key] = val
        end
        rec.save
        @changes.clear
        rec
      end
    end
  end
end
