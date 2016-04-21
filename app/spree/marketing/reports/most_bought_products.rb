module Spree
  module Marketing
    module Reports
      class MostBoughtProducts < Base
        def query
          Spree::InventoryUnit.includes(variant: :product)
                              .group("spree_variants.id")
                              .order("COUNT(spree_inventory_units.id) DESC")
                              .references(:variant)
                              .limit(count)
                              .map { |inventory_unit| inventory_unit.variant.product }
        end

        def count
          10
        end
      end
    end
  end
end
