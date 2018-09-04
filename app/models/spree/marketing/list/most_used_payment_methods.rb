module Spree
  module Marketing
    class List
      class MostUsedPaymentMethods < Spree::Marketing::List
        include Spree::Marketing::ActsAsMultiList

        # Constants
        NAME_TEXT = 'Most Used Payment Methods'
        ENTITY_KEY = 'entity_id'
        ENTITY_TYPE = 'Spree::PaymentMethod'
        TIME_FRAME = 1.month
        MINIMUM_COUNT = 5
        MOST_USED_PAYMENT_METHODS_COUNT = 5
        AVAILABLE_REPORTS = [:purchases_by].freeze

        def user_ids
          Spree::Order.joins(payments: :payment_method)
                      .where('spree_orders.completed_at >= :time_frame', time_frame: computed_time)
                      .where('spree_payment_methods.id = ?', entity_id)
                      .of_registered_users
                      .group(:user_id)
                      .having('COUNT(spree_orders.id) > ?', MINIMUM_COUNT)
                      .order(Arel.sql("COUNT(spree_orders.id) DESC"))
                      .pluck(:user_id)
        end

        def self.data
          Spree::Payment.joins(:payment_method, :order)
                        .where('spree_orders.completed_at >= :time_frame', time_frame: computed_time)
                        .where(state: :completed)
                        .group('spree_payment_methods.id')
                        .order(Arel.sql("COUNT(spree_orders.id) DESC"))
                        .limit(MOST_USED_PAYMENT_METHODS_COUNT)
                        .pluck(:payment_method_id)
        end
        private_class_method :data
      end
    end
  end
end
