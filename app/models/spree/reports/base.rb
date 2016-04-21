module Spree
  module Reports
    class Base
      attr_reader :count

      def initialize count = 5
        @count = count
      end

      def query
        []
      end
    end
  end
end
