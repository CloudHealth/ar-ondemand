module ActiveRecord
  module OnDemand
    class FastEnumeration

      def initialize(model, result_set)
        @result_set = result_set

        result_set.columns.each_with_index do |name, index|
          self.define_singleton_method(name) {
            raise "Not accessible outside of enumeration" if @row.nil?
            @row[index]
          }
        end
      end

      def each
        @result_set.rows.each do |r|
          @row = r
          yield(self)
          nil
        end
      ensure
        @row = nil
      end

      def inject(inj)
        @result_set.rows.each do |r|
          @row = r
          inj = yield(inj, self)
        end
        inj
      ensure
        @row = nil
      end

      def size
        @result_set.rows.size
      end

    end
  end
end
