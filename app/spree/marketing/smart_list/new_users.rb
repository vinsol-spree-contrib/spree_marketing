module Spree
  module Marketing
    module SmartList
      class NewUsers < Base
        def query
          super.where("created_at >= :time_frame", time_frame: computed_time_frame)
        end
      end
    end
  end
end
