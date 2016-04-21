module Spree
  module SmartList
    class NewUsers < Base
      def initialize list_uid = nil
        @list_uid = list_uid
      end

      def query
        super.where("created_at >= :time_frame", time_frame: Time.current - time_frame)
      end
    end
  end
end
