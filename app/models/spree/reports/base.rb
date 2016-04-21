module Spree
  module Reports
    class Base
      def initialize count = 5
        @count = count
      end

      def query
        []
      end
    end
  end
end
