module Spree
  module Marketing
    module Reports
      class MostBoughtProductsReport < BaseReport

        DEFAULT_COUNT_VALUE = 10

        def initialize count = nil
          super(count || DEFAULT_COUNT_VALUE)
        end

        def required_data
          Spree::InventoryUnit.joins(variant: :product)
                              .group("spree_variants.id")
                              .order("COUNT(spree_inventory_units.id) DESC")
                              .limit(@count)
                              .pluck(:product_id)
        end
      end
    end
  end
end
