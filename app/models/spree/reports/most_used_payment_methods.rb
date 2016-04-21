module Spree
  module Reports
    class MostUsedPaymentMethods < Base
      def query
        Spree::Payment.includes(:payment_method, :order)
                      .where(state: :completed)
                      .group("spree_payment_methods.id")
                      .order("COUNT(spree_orders.id) DESC")
                      .limit(count)
                      .map { |payment| payment.payment_method }
      end
    end
  end
end
