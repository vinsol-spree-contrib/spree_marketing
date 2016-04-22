module Spree
  module Marketing
    module SmartList
      class MostUsedPaymentMethodList < BaseList

        TIME_FRAME = 1.month
        MINIMUM_COUNT = 5
        MOST_USED_PAYMENT_METHODS_COUNT = 5

        def intialize payment_method_id, list_uid = nil
          @payment_method_id = payment_method_id
          super(TIME_FRAME, list_uid)
        end

        def user_ids
          Spree::Order.joins(payments: :payment_method)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time)
                      .where("spree_payment_methods.id = ?", @payment_method_id)
                      .where.not(user_id: nil)
                      .group(:user_id)
                      .having("COUNT(spree_orders.id) > ?", MINIMUM_COUNT)
                      .order("COUNT(spree_orders.id) DESC")
                      .pluck(:user_id)
        end

        # def self.process
        #   Reports::MostUsedPaymentMethod.new.query.each do |payment_method|

        #   end
        # end

        def data
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
end
