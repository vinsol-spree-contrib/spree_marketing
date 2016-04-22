module Spree
  module Marketing
    module SmartList
      class LeastZoneWiseOrdersList < BaseList

        TIME_FRAME = 1.month
        LEAST_ZONE_WISE_ORDER_COUNT = 5
        MAXIMUM_ORDER_COUNT = 5

        def initialize state_id, list_uid = nil
          @state_id = state_id
          super(TIME_FRAME, list_uid)
        end

        def user_ids
          # what if state id is not available, only country id is available. Should we use only zones.
          # If yes then how?
          # Also leaving cases for guest users
          Spree::Order.joins(ship_address: :state)
                      .where.not(user_id: nil)
                      .where("spree_states.id = ?", @state_id)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time_frame)
                      .group(:user_id)
                      .having("COUNT(spree_orders.id) < :maximum_count", maximum_count: MAXIMUM_ORDER_COUNT)
                      .order("COUNT(spree_orders.id)")
                      .pluck("spree_orders.user_id")
        end

        # def self.process
        #   # Reports::MostActiveZones.new.query.each do |zone|

        #   # end
        # end

        def data
          Spree::Order.joins(ship_address: :state)
            .group("spree_states.id")
            .order("COUNT(spree_orders.id)")
            .limit(MOST_ZONE_WISE_ORDER_COUNT)
            .pluck(:state_id)
        end
      end
    end
  end
end
