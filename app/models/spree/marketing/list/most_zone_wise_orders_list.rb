module Spree
  module Marketing
    class MostZoneWiseOrdersList < List

      # Constants
      TIME_FRAME = 1.month
      MOST_ZONE_WISE_ORDERS_COUNT = 5

      attr_accessor :state_id

      def user_ids
        # FIXME: There are some countries which do not have states, we are leaving those cases for now.
        Spree::Order.joins(ship_address: :state)
                    .of_registered_users
                    .where("spree_states.id = ?", @state_id)
                    .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time)
                    .group(:user_id)
                    .order("COUNT(spree_orders.id) DESC")
                    .pluck(:user_id)
      end

      def self.generate
        data.each do |state_id|
          new(state_id: state_id).generate(self.class.humanize + self.state_name(state_id))
        end
      end

      def self.update
        data.each do |state_id|
          Spree::Marketing::List.where(type: self).find_by(name: self.name.humanize + state_name(state_id)).update_list
        end
      end

      def state_name state_id
        Spree::State.find_by(id: state_id).name.downcase.gsub(" ", "_")
      end

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
