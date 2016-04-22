module Spree
  module Marketing
    module List
      class LeastZoneWiseOrdersList < Spree::Marketing::List

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

        def time_frame
          @time_frame ||= TIME_FRAME
        end
      end
    end
  end
end
