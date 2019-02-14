module Spree
  module Marketing
    class List
      class AbandonedCart < Spree::Marketing::List
        # Constants
        NAME_TEXT = 'Abandoned Cart'
        AVAILABLE_REPORTS = [:purchases_by].freeze

        def users
          order_emails = Spree::Order.incomplete.where.not(item_count: 0).distinct.pluck(:email).compact.uniq

          registered_users = User.where(email: order_emails)

          user_emails = registered_users.pluck(:email)
          unregistered_emails = order_emails - user_emails

          unregistered_users = unregistered_emails.map{|email| User.new(email: email) }

          registered_users.to_a + unregistered_users
        end
      end
    end
  end
end
