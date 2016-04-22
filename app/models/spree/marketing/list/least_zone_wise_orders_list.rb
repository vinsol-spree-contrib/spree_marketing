module Spree
  module Marketing
    class LeastZoneWiseOrdersList < List

      # Constants
      TIME_FRAME = 1.month
      LEAST_ZONE_WISE_ORDER_COUNT = 5

      attr_accessor :state_id

      def user_ids
        # FIXME: what if state id is not available, only country id is available. Should we use only zones.
        # If yes then how?
        # Also leaving cases for guest users
        Spree::Order.joins(ship_address: :state)
                    .of_registered_users
                    .where("spree_states.id = ?", @state_id)
                    .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time)
                    .group(:user_id)
                    .order("COUNT(spree_orders.id)")
                    .pluck("spree_orders.user_id")
      end

      def self.generate
        data.each do |state_id|
          new(state_id: state_id).generate(self.class.humanize + Spree::State.find_by(id: product_id).name.downcase.gsub(" ", "_"))
        end
      end

      def self.data
        Spree::Order.joins(ship_address: :state)
          .group("spree_states.id")
          .order("COUNT(spree_orders.id)")
          .limit(MOST_ZONE_WISE_ORDER_COUNT)
          .pluck(:state_id)
      end
    end
  end
end
