module Spree
  module Marketing
    module SmartList
      class MostDiscountedOrdersList < BaseList

        TIME_FRAME = 1.month
        MINIMUM_COUNT = 5

        def initialize list_uid = nil
          super(TIME_FRAME, list_uid)
        end

        def user_ids
          # FIXME: there is a case where guest user email is available but we are leaving that now.
          Spree::Order.joins(:promotions)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time)
                      .group(:user_id)
                      .having("COUNT(spree_orders.id) > ?", MINIMUM_COUNT)
                      .where.not(user_id: nil)
                      .order("COUNT(spree_orders.id) DESC")
                      .pluck(:user_id)
        end
      end
    end
  end
end
