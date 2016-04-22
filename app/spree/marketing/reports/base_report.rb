module Spree
  module Marketing
    module Reports
      class BaseReport

        DEFAULT_COUNT_VALUE = 5

        def initialize count = nil
          @count = count || DEFAULT_COUNT_VALUE
        end

        def required_data
          raise ::NotImplementedError, 'You must implement emails method for this smart list.'
        end
      end
    end
  end
end
