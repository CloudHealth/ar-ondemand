module ActiveRecord
  module OnDemand
    class FastEnumeration

      def initialize(model, result_set)
        @result_set = result_set

        result_set.columns.each_with_index do |name, index|
          self.define_singleton_method(name) { @row[index] }
        end
      end

      def each
        @result_set.rows.each do |r|
          yield(with_row(r))
          nil
        end
      end

      def inject(inj)
        @result_set.rows.each do |r|
          inj = yield(inj, with_row(r))
        end
        inj
      end

      private

      def with_row(row)
        @row = row
        self
      end

    end
  end
end
