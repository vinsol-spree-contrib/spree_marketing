module Spree
  module Marketing
    class ListPresenter

      VIEW_NAMES_HASH = {
        'AbandonedCartList' => {
          tooltip_content: Spree.t('marketing.lists.abandoned_cart.tooltip_content'),
          description: Spree.t('marketing.lists.abandoned_cart.description')
        },
        'FavourableProductsList' => {
          tooltip_content: Spree.t('marketing.lists.favourable_products.tooltip_content'),
          description: Spree.t('marketing.lists.favourable_products.description')
        },
        'LeastActiveUsersList' => {
          tooltip_content: Spree.t('marketing.lists.least_active.tooltip_content'),
          description: Spree.t('marketing.lists.least_active.description')
        },
        'LeastZoneWiseOrdersList' => {
          tooltip_content: Spree.t('marketing.lists.cold_zone.tooltip_content'),
          description: Spree.t('marketing.lists.cold_zone.description')
        },
        'MostActiveUsersList' => {
          tooltip_content: Spree.t('marketing.lists.most_active.tooltip_content'),
          description: Spree.t('marketing.lists.most_active.description')
        },
        'MostDiscountedOrdersList' => {
          tooltip_content: Spree.t('marketing.lists.most_discounted_orders.tooltip_content'),
          description: Spree.t('marketing.lists.most_discounted_orders.description')
        },
        'MostSearchedKeywordsList' => {
          tooltip_content: Spree.t('marketing.lists.most_searched_keywords.tooltip_content'),
          description: Spree.t('marketing.lists.most_searched_keywords.description')
        },
        'MostUsedPaymentMethodsList' => {
          tooltip_content: Spree.t('marketing.lists.most_used_payment_methods.tooltip_content'),
          description: Spree.t('marketing.lists.most_used_payment_methods.description')
        },
        'MostZoneWiseOrdersList' => {
          tooltip_content: Spree.t('marketing.lists.hot_zone.tooltip_content'),
          description: Spree.t('marketing.lists.hot_zone.description')
        },
        'NewUsersList' => {
          tooltip_content: Spree.t('marketing.lists.new_users.tooltip_content'),
          description: Spree.t('marketing.lists.new_users.description')
        }
      }

      def initialize list
        @list = list
      end

      def sub_list_name
        @list.entity_name || @list.name
      end

      def description
        VIEW_NAMES_HASH[@list.class.to_s.demodulize][:description]
      end
    end
  end
end
