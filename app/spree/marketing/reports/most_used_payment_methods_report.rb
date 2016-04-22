module Spree
  module Marketing
    module Reports
      class MostUsedPaymentMethodsReport < BaseReport
        def required_data
          Spree::Payment.joins(:payment_method, :order)
                        .where(state: :completed)
                        .group("spree_payment_methods.id")
                        .order("COUNT(spree_orders.id) DESC")
                        .limit(@count)
                        .pluck(:payment_method_id)
        end
      end
    end
  end
end
