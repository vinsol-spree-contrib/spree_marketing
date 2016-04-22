module Spree
  module Marketing
    module SmartList
      class AbandonedCartList < BaseList
        def user_ids
          # FIXME: There is a case where guest user has an incomplete order and we
          # might have his email if he has processed address state successfully
          # right now we are leaving that case.
          Spree::Order.incomplete
                      .where("spree_orders.updated_at >= :time_frame", time_frame: computed_time)
                      .of_registered_users
                      .uniq
                      .pluck(:user_id)
        end
      end
    end
  end
end
