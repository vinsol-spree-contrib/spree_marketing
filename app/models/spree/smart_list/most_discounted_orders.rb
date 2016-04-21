module Spree
  module SmartList
    class MostDiscountedOrders < Base
      def initialize list_uid = nil
        @list_uid = list_uid
        @time_frame = 1.month
      end

      def query
        Spree::Order.includes(:user)
                    .joins(:promotions)
                    .where("spree_orders.completed_at >= :time_frame", time_frame: Time.current - time_frame)
                    .group(:email)
                    .having("COUNT(spree_orders.id) > ?", 1)
                    .where.not(user_id: nil)
                    .order("COUNT(spree_orders.id)")
                    .map { |order| order.user }
      end
    end
  end
end
