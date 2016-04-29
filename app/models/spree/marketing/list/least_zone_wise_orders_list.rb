module Spree
  module Marketing
    class LeastZoneWiseOrdersList < List

      include Spree::Marketing::ActsAsMultiList

      # Constants
      ENTITY_KEY = 'state_id'
      TIME_FRAME = 1.month
      LEAST_ZONE_WISE_ORDER_COUNT = 5
      NAME_PRESENTER = "Cold Zone"
      TOOLTIP_CONTENT = "View the contact list of users in 5 lowest ordering Zone"

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

      def self.state_name state_id
        Spree::State.find_by(id: state_id).name.downcase.gsub(" ", "_")
      end
      private_class_method :state_name

      def self.name_text state_id
        humanized_name + "_" + state_name(state_id)
      end
      private_class_method :name_text

      def self.data
        Spree::Order.joins(ship_address: :state)
          .group("spree_states.id")
          .order("COUNT(spree_orders.id)")
          .limit(LEAST_ZONE_WISE_ORDER_COUNT)
          .pluck(:state_id)
      end
      private_class_method :data
    end
  end
end
