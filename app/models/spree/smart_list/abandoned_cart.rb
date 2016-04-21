module Spree
  module SmartList
    class AbandonedCart < Base

      def initialize time_frame, list_uid = nil
        @time_frame = time_frame
        @list_uid = list_uid
      end

      def query
        Spree::Order.includes(:user)
                    .where(completed_at: nil)
                    .where("spree_orders.updated_at >= :time_frame", time_frame: computed_time_frame)
                    .where.not(user_id: nil)
                    .map { |order| order.user }
      end

    end
  end
end
