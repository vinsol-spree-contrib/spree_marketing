module Spree
  module Marketing
    module List
      class FavourableProductsList < Spree::Marketing::List

        TIME_FRAME = 1.month
        FAVOURABLE_PRODUCT_COUNT = 10

        attr_accessor :product_id

        def time_frame
          @time_frame ||= TIME_FRAME
        end

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

        # def self.process
        #   # Reports::MostBoughtProducts.new.query.each do
        #     # self.new()
        #   # end
        # end

        def data
          Spree::InventoryUnit.joins(variant: :product)
                              .group("spree_variants.id")
                              .order("COUNT(spree_inventory_units.id) DESC")
                              .limit(FAVOURABLE_PRODUCT_COUNT)
                              .pluck(:product_id)
        end
      end
    end
  end
end
