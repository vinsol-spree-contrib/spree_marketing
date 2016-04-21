module Spree
  module Marketing
    module SmartList
      class MostDiscountedOrders < Base

        TIME_FRAME = 1.month

        def initialize list_uid = nil
          super(TIME_FRAME, list_uid)
        end

        def query
          Spree::Order.includes(:user)
                      .joins(:promotions)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time_frame)
                      .group(:email)
                      .having("COUNT(spree_orders.id) > ?", 1)
                      .where.not(user_id: nil)
                      .order("COUNT(spree_orders.id)")
                      .map { |order| order.user }
        end
      end
    end
  end
end
