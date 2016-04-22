module Spree
  module Marketing
    module Reports
      class MostActiveZonesReport < BaseReport
        def required_data
          Spree::Order.joins(ship_address: :state)
                      .group("spree_states.id")
                      .order("COUNT(spree_orders.id) DESC")
                      .limit(@count)
                      .pluck(:state_id)
        end
      end
    end
  end
end
