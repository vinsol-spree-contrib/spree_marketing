module Spree
  module SmartList
    class LeastZoneWiseOrders < Base
      def initialize zone_id, list_uid = nil
        @zone_id = zone
        @list_uid = list_uid
        @time_frame = 1.month
      end

      def query
        Spree::Order.includes(:user, ship_address: [:country, :state])
                    .where.not(user_id: nil)
                    .where("spree_states.id = ?", @state_id)
                    .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time_frame)
                    .group(:email)
                    .order("COUNT(spree_orders.id)")
                    .references(:ship_address)
                    .map { |order| order.user }
      end
    end
  end
end
