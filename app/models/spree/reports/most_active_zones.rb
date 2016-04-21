module Spree
  module Reports
    class MostActiveZones < Base
      def query
        Spree::Order.includes(ship_address: :state)
                    .group("spree_states.id")
                    .order("COUNT(spree_orders.id) DESC")
                    .references(:ship_address)
                    .limit(@count)
                    .map { |order| order.ship_address.state }
      end
    end
  end
end
