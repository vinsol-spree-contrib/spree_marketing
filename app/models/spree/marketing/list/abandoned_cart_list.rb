module Spree
  module Marketing
    class AbandonedCartList < List

      # Constants
      NAME_PRESENTER = "Abandoned Cart"
      TOOLTIP_CONTENT = "View the contact list of users who have abandoned the cart"

      def user_ids
        # FIXME: There is a case where guest user has an incomplete order and we
        # might have his email if he has processed address state successfully
        # right now we are leaving that case.
        Spree::Order.incomplete
                    .of_registered_users
                    .uniq
                    .pluck(:user_id)
      end
    end
  end
end
