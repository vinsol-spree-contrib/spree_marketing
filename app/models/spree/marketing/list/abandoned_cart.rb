module Spree
  module Marketing
    class List
      class AbandonedCart < Spree::Marketing::List
        # Constants
        NAME_TEXT = 'Abandoned Cart'
        AVAILABLE_REPORTS = [:purchases_by].freeze

        private

          def users
            order_emails = Spree::Order.incomplete.where.not(item_count: 0).distinct.pluck(:email).compact.uniq

            all_users(order_emails)
          end

      end
    end
  end
end
