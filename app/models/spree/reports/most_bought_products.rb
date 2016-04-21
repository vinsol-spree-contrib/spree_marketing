module Spree
  module Reports
    class MostBoughtProducts < Base
      def initialize count = 10
        @count = count
      end

      def query
        Spree::InventoryUnit.includes(variant: :product)
                            .group("spree_variants.id")
                            .order("COUNT(spree_inventory_units.id) DESC")
                            .references(:variant)
                            .limit(@count)
                            .map { |inventory_unit| inventory_unit.variant.product }
      end
    end
  end
end
