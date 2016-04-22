module Spree
  module Marketing
    module SmartList
      class FavourableProductsList < BaseList

        TIME_FRAME = 1.month
        MINIMUM_COUNT = 1

        def initialize product_id, list_uid = nil
          @product_id = product_id
          super(TIME_FRAME, list_uid)
        end

        def user_ids
          # There might be a case where a guest user have placed an order
          # And we also have his email but we are leaving those emails for now.
          Spree::Order.joins(line_items: { variant: :product })
                      .where.not(user_id: nil)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time_frame)
                      .where("spree_products.id = ?", @product_id)
                      .group(:user_id)
                      .having("COUNT(spree_orders.id) > ?", MINIMUM_COUNT)
                      .pluck(:user_id)
        end

        # def self.process
        #   # Reports::MostBoughtProducts.new.query.each do
        #     # self.new()
        #   # end
        # end
      end
    end
  end
end
