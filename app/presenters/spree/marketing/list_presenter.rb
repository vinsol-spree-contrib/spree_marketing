module Spree
  module Marketing
    class ListPresenter

      VIEW_NAMES_HASH = {
        'AbandonedCartList' => {
          tooltip_content: 'View the contact list of users who have abandoned the cart',
          description: 'Users who have abandoned the cart'
        },
        'FavourableProductsList' => {
          tooltip_content: 'View the contact list of users who are part of the purchase family for top 10 most selling products',
          description: 'Users who are part of the purchase family for top 10 most selling products'
        },
        'LeastActiveUsersList' => {
          tooltip_content: 'View the contact list of users corresponding to least activities',
          description: 'Users corresponding to least activities'
        },
        'LeastZoneWiseOrdersList' => {
          tooltip_content: 'View the contact list of users in 5 lowest ordering Zone',
          description: 'Users in 5 lowest ordering Zone'
        },
        'MostActiveUsersList' => {
          tooltip_content: 'View the contact list of users corresponding to most activities',
          description: 'Users corresponding to most activities'
        },
        'MostDiscountedOrdersList' => {
          tooltip_content: 'View the contact list of users who are part of the purchase family mostly for discounted orders',
          description: 'Users who are part of the purchase family mostly for discounted orders'
        },
        'MostSearchedKeywordsList' => {
          tooltip_content: 'View the contact list of users corresponding to top 5 keywords',
          description: 'Users corresponding to top 5 keywords'
        },
        'MostUsedPaymentMethodsList' => {
          tooltip_content: 'View the contact list of users corresponding to most used payment methods',
          description: 'Users corresponding to most used payment methods'
        },
        'MostZoneWiseOrdersList' => {
          tooltip_content: 'View the contact list of users in 5 most ordering Zone',
          description: 'Users in 5 most ordering Zone'
        },
        'NewUsersList' => {
          tooltip_content: 'View the contact list of users who have signed up in last week',
          description: 'Users who have signed up in last week'
        }
      }

      def initialize list
        @list = list
      end

      def sub_list_name
        @list.entity_name || 'Contacts'
      end

      def description
        VIEW_NAMES_HASH[@list.class.to_s.demodulize][:description]
      end
    end
  end
end
