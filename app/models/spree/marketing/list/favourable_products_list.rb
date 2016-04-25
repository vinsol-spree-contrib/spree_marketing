module Spree
  module Marketing
    class FavourableProductsList < List

      # Constants
      TIME_FRAME = 1.month
      FAVOURABLE_PRODUCT_COUNT = 10

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

      def self.generator
        lists = []
        data.each do |product_id|
          list = find_by(name: name_text(product_id))
          if list
            list.update_list
          else
            list = new(product_id: product_id).generate(name_text(product_id))
          end
          lists << list
        end
        ListCleanupJob.perform_later self.where.not(uid: lists.map(:uid))
      end

      def self.name_text product_id
        humanized_name + "_" + product_name(product_id)
      end

      def self.data
        Spree::InventoryUnit.joins(variant: :product)
                            .group("spree_variants.id")
                            .order("COUNT(spree_inventory_units.id) DESC")
                            .limit(FAVOURABLE_PRODUCT_COUNT)
                            .pluck(:product_id)
      end
    end
  end
end
