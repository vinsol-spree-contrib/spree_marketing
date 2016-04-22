module Spree
  module Marketing
    class MostUsedPaymentMethodList < List

      # Constants
      TIME_FRAME = 1.month
      MINIMUM_COUNT = 5
      MOST_USED_PAYMENT_METHODS_COUNT = 5

      attr_accessor :payment_method_id

      def user_ids
        Spree::Order.joins(payments: :payment_method)
                    .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time)
                    .where("spree_payment_methods.id = ?", @payment_method_id)
                    .of_registered_users
                    .group(:user_id)
                    .having("COUNT(spree_orders.id) > ?", MINIMUM_COUNT)
                    .order("COUNT(spree_orders.id) DESC")
                    .pluck(:user_id)
      end

      def self.generate
        data.each do |payment_method_id|
          new(payment_method_id: payment_method_id).generate(self.class.humanize + Spree::PaymentMethod.find_by(id: payment_method_id).name.downcase.gsub(" ", "_"))
        end
      end

      def self.data
        Spree::Payment.joins(:payment_method, :order)
                      .where(state: :completed)
                      .group("spree_payment_methods.id")
                      .order("COUNT(spree_orders.id) DESC")
                      .limit(MOST_USED_PAYMENT_METHODS_COUNT)
                      .pluck(:payment_method_id)
      end
    end
  end
end
