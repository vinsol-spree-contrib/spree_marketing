module Spree
  module Marketing
    class FavourableProductsList < List

      include Spree::Marketing::ActsAsMultiList

      # Constants
      ENTITY_KEY = 'product_id'
      TIME_FRAME = 1.month
      FAVOURABLE_PRODUCT_COUNT = 10
      NAME_PRESENTER = "Most Selling Products"
      TOOLTIP_CONTENT = "View the contact list of users who are part of the purchase family for top 10 most selling products"

      attr_accessor :product_id

      def user_ids
        # FIXME: There might be a case where a guest user have placed an order
        # And we also have his email but we are leaving those emails for now.
        Spree::Order.joins(line_items: { variant: :product })
                    .of_registered_users
                    .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time)
                    .where("spree_products.id = ?", @product_id)
                    .group(:user_id)
                    .pluck(:user_id)
      end

      def self.product_name product_id
        Spree::Product.find_by(id: product_id).name.downcase.gsub(" ", "_")
      end
      private_class_method :product_name

      def self.name_text product_id
        humanized_name + "_" + product_name(product_id)
      end
      private_class_method :name_text

      def self.data
        Spree::InventoryUnit.joins(variant: :product)
                            .group("spree_variants.id")
                            .order("COUNT(spree_inventory_units.id) DESC")
                            .limit(FAVOURABLE_PRODUCT_COUNT)
                            .pluck(:product_id)
      end
      private_class_method :data
    end
  end
end
