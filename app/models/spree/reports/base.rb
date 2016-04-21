module Spree
  module Reports
    class Base
      def initialize count
        @count = count
      end

      def query
      end
    end
  end
end
