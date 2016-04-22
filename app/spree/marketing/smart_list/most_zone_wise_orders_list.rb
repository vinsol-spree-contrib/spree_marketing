module Spree
  module Marketing
    module SmartList
      class MostZoneWiseOrdersList < BaseList

        TIME_FRAME = 1.month
        MOST_ZONE_WISE_ORDERS_COUNT = 5

        def initialize state_id, list_uid = nil
          @state_id = state_id
          super(TIME_FRAME, list_uid)
        end

        def user_ids
          Spree::Order.joins(ship_address: [:country, :state])
                      .where.not(user_id: nil)
                      .where("spree_states.id = ?", @state_id)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time_frame)
                      .group(:user_id)
                      .order("COUNT(spree_orders.id) DESC")
                      .pluck(:user_id)
        end

        # def self.process
        #   Reports::MostActiveZones.new.query.each do |state|

        #   end
        # end

        def data
          Spree::Order.joins(ship_address: :state)
            .group("spree_states.id")
            .order("COUNT(spree_orders.id) DESC")
            .limit(MOST_ZONE_WISE_ORDERS_COUNT)
            .pluck(:state_id)
        end
      end
    end
  end
end
