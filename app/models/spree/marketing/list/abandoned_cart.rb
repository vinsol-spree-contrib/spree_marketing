module Spree
  module Marketing
    class List
      class AbandonedCart < Spree::Marketing::List

        # Constants
        NAME_TEXT = 'Abandoned Cart'
        AVAILABLE_REPORTS = [:purchases_by]

        def user_ids
          # FIXME: There is a case where guest user has an incomplete order and we
          # might have his email if he has processed address state successfully
          # right now we are leaving that case.
          Spree::Order.incomplete
                      .of_registered_users
                      .where.not(item_count: 0)
                      .uniq
                      .pluck(:user_id)
        end

      end
    end
  end
end
