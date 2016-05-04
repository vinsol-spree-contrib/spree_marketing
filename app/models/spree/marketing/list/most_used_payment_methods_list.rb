module Spree
  module Marketing
    class MostUsedPaymentMethodsList < List

      include Spree::Marketing::ActsAsMultiList

      # Constants
      ENTITY_KEY = 'payment_method_id'
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

      def self.name_text payment_method_id
        humanized_name + "_" + payment_method_name(payment_method_id)
      end
      private_class_method :name_text

      def self.payment_method_name payment_method_id
        Spree::PaymentMethod.find_by(id: payment_method_id).name.downcase.gsub(" ", "_")
      end
      private_class_method :payment_method_name

      def self.data
        Spree::Payment.joins(:payment_method, :order)
                      .where(state: :completed)
                      .group("spree_payment_methods.id")
                      .order("COUNT(spree_orders.id) DESC")
                      .limit(MOST_USED_PAYMENT_METHODS_COUNT)
                      .pluck(:payment_method_id)
      end
      private_class_method :data
    end
  end
end
