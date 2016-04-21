module Spree
  module SmartList
    class MostUsedPaymentMethod < Base

      def intialize payment_method_id, list_uid = nil
        @payment_method_id = payment_method_id
        @time_frame = 1.month
        @list_uid = list_uid
      end

      def query
        Spree::Order.includes(:user, payments: :payment_method)
                    .where("spree_orders.completed_at >= :time_frame", time_frame: Time.current - time_frame)
                    .where("spree_payment_methods.id = ?", @payment_method_id)
                    .where.not(user_id: nil)
                    .group(:email)
                    .having("COUNT(spree_orders.id) > ?", 1)
                    .order("COUNT(spree_orders.id)")
                    .references(:payments)
                    .map { |order| order.user }
      end

    end
  end
end
