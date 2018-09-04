module Spree
  module Marketing
    class ListPresenter
      VIEW_NAMES_HASH = {
        'AbandonedCart' => {
          tooltip_content: Spree.t('marketing.lists.abandoned_cart.tooltip_content'),
          description: Spree.t('marketing.lists.abandoned_cart.description')
        },
        'FavourableProducts' => {
          tooltip_content: Spree.t('marketing.lists.favourable_products.tooltip_content'),
          description: Spree.t('marketing.lists.favourable_products.description')
        },
        'LeastActiveUsers' => {
          tooltip_content: Spree.t('marketing.lists.least_active.tooltip_content'),
          description: Spree.t('marketing.lists.least_active.description')
        },
        'LeastZoneWiseOrders' => {
          tooltip_content: Spree.t('marketing.lists.cold_zone.tooltip_content'),
          description: Spree.t('marketing.lists.cold_zone.description')
        },
        'MostActiveUsers' => {
          tooltip_content: Spree.t('marketing.lists.most_active.tooltip_content'),
          description: Spree.t('marketing.lists.most_active.description')
        },
        'MostDiscountedOrders' => {
          tooltip_content: Spree.t('marketing.lists.most_discounted_orders.tooltip_content'),
          description: Spree.t('marketing.lists.most_discounted_orders.description')
        },
        'MostSearchedKeywords' => {
          tooltip_content: Spree.t('marketing.lists.most_searched_keywords.tooltip_content'),
          description: Spree.t('marketing.lists.most_searched_keywords.description')
        },
        'MostUsedPaymentMethods' => {
          tooltip_content: Spree.t('marketing.lists.most_used_payment_methods.tooltip_content'),
          description: Spree.t('marketing.lists.most_used_payment_methods.description')
        },
        'MostZoneWiseOrders' => {
          tooltip_content: Spree.t('marketing.lists.hot_zone.tooltip_content'),
          description: Spree.t('marketing.lists.hot_zone.description')
        },
        'NewUsers' => {
          tooltip_content: Spree.t('marketing.lists.new_users.tooltip_content'),
          description: Spree.t('marketing.lists.new_users.description')
        }
      }.freeze

      def initialize(list)
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
