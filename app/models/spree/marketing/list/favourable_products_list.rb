module Spree
  module Marketing
    class FavourableProductsList < List

      include Spree::Marketing::ActsAsMultiList

      # Constants
      NAME_TEXT = 'Most Selling Products'
      ENTITY_KEY = 'entity_id'
      ENTITY_TYPE = 'Spree::Product'
      TIME_FRAME = 1.month
      FAVOURABLE_PRODUCT_COUNT = 10
      AVAILABLE_REPORTS = [:cart_additions_by, :purchases_by, :product_views_by]

      def user_ids
        # FIXME: There might be a case where a guest user have placed an order
        # And we also have his email but we are leaving those emails for now.
        Spree::Order.joins(line_items: { variant: :product })
                    .of_registered_users
                    .where('spree_orders.completed_at >= :time_frame', time_frame: computed_time)
                    .where('spree_products.id = ?', entity_id)
                    .group(:user_id)
                    .pluck(:user_id)
      end

      def self.data
        Spree::InventoryUnit.joins(variant: :product)
                            .group("spree_products.id")
                            .order("COUNT(spree_inventory_units.id) DESC")
                            .limit(FAVOURABLE_PRODUCT_COUNT)
                            .pluck(:product_id)
      end
      private_class_method :data
    end
  end
end
