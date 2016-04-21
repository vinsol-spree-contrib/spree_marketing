module Spree
  module Marketing
    module SmartList
      class MostUsedPaymentMethod < Base

        TIME_FRAME = 1.month

        def intialize payment_method_id, list_uid = nil
          @payment_method_id = payment_method_id
          super(TIME_FRAME, list_uid)
        end

        def query
          Spree::Order.includes(:user, payments: :payment_method)
                      .where("spree_orders.completed_at >= :time_frame", time_frame: computed_time_frame)
                      .where("spree_payment_methods.id = ?", @payment_method_id)
                      .where.not(user_id: nil)
                      .group(:email)
                      .having("COUNT(spree_orders.id) > ?", 1)
                      .order("COUNT(spree_orders.id)")
                      .references(:payments)
                      .map { |order| order.user }
        end

        def self.process
          Reports::MostUsedPaymentMethod.new.query.each do |payment_method|

          end
        end
      end
    end
  end
end
