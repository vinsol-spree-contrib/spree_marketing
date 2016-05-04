module Spree
  module Marketing
    class ListPresenter

      VIEW_NAMES_HASH = {
        'AbandonedCartList' => {
          tooltip_content: 'View the contact list of users who have abandoned the cart'
        },
        'FavourableProductsList' => {
          tooltip_content: 'View the contact list of users who are part of the purchase family for top 10 most selling products'
        },
        'LeastActiveUsersList' => {
          tooltip_content: 'View the contact list of users corresponding to least activities'
        },
        'LeastZoneWiseOrdersList' => {
          tooltip_content: 'View the contact list of users in 5 lowest ordering Zone'
        },
        'MostActiveUsersList' => {
          tooltip_content: 'View the contact list of users corresponding to most activities'
        },
        'MostDiscountedOrdersList' => {
          tooltip_content: 'View the contact list of users who are part of the purchase family mostly for discounted orders'
        },
        'MostSearchedKeywordsList' => {
          tooltip_content: 'View the contact list of users corresponding to top 10 keywords'
        },
        'MostUsedPaymentMethodsList' => {
          tooltip_content: 'View the contact list of users corresponding to most used payment methods'
        },
        'MostZoneWiseOrdersList' => {
          tooltip_content: 'View the contact list of users in 5 most ordering Zone'
        },
        'NewUsersList' => {
          tooltip_content: 'View the contact list of users who have signed up in last week'
        }
      }

      def initialize list
        @list = list
      end

      def sub_list_name
        @list.entity_name || 'Contacts'
      end

    end
  end
end
