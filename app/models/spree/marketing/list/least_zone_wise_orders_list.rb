module Spree
  module Marketing
    class LeastZoneWiseOrdersList < List

      include Spree::Marketing::ActsAsMultiList

      # Constants
      NAME_TEXT = 'Cold Zone'
      ENTITY_KEY = 'entity_id'
      ENTITY_TYPE = 'Spree::State'
      TIME_FRAME = 1.month
      LEAST_ZONE_WISE_ORDER_COUNT = 5
      AVAILABLE_REPORTS = [:purchases_by]

      def user_ids
        # FIXME: what if state id is not available, only country id is available. Should we use only zones.
        # If yes then how?
        # Also leaving cases for guest users
        Spree::Order.joins(ship_address: :state)
                    .of_registered_users
                    .where('spree_states.id = ?', entity_id)
                    .where('spree_orders.completed_at >= :time_frame', time_frame: computed_time)
                    .group(:user_id)
                    .order('COUNT(spree_orders.id)')
                    .pluck('spree_orders.user_id')
      end

      def self.data
        Spree::Order.joins(ship_address: :state)
                    .group('spree_states.id')
                    .order('COUNT(spree_orders.id)')
                    .limit(LEAST_ZONE_WISE_ORDER_COUNT)
                    .pluck(:state_id)
      end
      private_class_method :data

    end
  end
end
