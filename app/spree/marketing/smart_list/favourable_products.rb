module Spree
  module Marketing
    module SmartList
      class FavourableProducts < Base
        def initialize product_id, list_uid = nil
          @list_uid = list_uid
          @time_frame = 1.month
          @product_id = product_id
        end

        def query
          Spree::Order.includes(:user, line_items: { variant: :product })
                      .where.not(user_id: nil)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time_frame)
                      .where("spree_products.id = ?", @product_id)
                      .group(:email)
                      .having("COUNT(spree_orders.id) > ?", 1)
                      .order("COUNT(spree_orders.id)")
                      .references(:line_items)
                      .map { |order| order.user }
        end

        def self.process
          # Reports::MostBoughtProducts.new.query.each do
            # self.new()
          # end
        end
      end
    end
  end
end
