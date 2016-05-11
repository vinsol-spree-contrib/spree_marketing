module Spree
  module Marketing
    class MostZoneWiseOrdersList < List

      include Spree::Marketing::ActsAsMultiList

      # Constants
      NAME_TEXT = 'Hot Zone'
      ENTITY_KEY = 'entity_id'
      ENTITY_TYPE = 'Spree::State'
      TIME_FRAME = 1.month
      MOST_ZONE_WISE_ORDERS_COUNT = 5
      AVAILABLE_REPORTS = [:purchases_by]

      def user_ids
        # FIXME: There are some countries which do not have states, we are leaving those cases for now.
        Spree::Order.joins(bill_address: :state)
                    .of_registered_users
                    .where('spree_states.id = ?', entity_id)
                    .where('spree_orders.completed_at >= :time_frame', time_frame: computed_time)
                    .group(:user_id)
                    .order('COUNT(spree_orders.id) DESC')
                    .pluck(:user_id)
      end

      def self.data
        Spree::Order.joins(bill_address: :state)
          .group('spree_states.id')
          .order('COUNT(spree_orders.id) DESC')
          .limit(MOST_ZONE_WISE_ORDERS_COUNT)
          .pluck(:state_id)
      end
      private_class_method :data

    end
  end
end
