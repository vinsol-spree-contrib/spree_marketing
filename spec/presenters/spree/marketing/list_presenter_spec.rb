require 'spec_helper'

describe Spree::Marketing::ListPresenter do
  let(:list) { create(:abandoned_cart, name: 'abandoned_cart') }
  let(:product_name) { 'Sample Product' }
  let(:product) { create(:product, name: product_name) }
  let(:multilist) { create(:favourable_products, entity: product, name: "favourable_products_list_#{product_name}") }
  let(:list_presenter) { Spree::Marketing::ListPresenter.new list }
  let(:multilist_presenter) { Spree::Marketing::ListPresenter.new multilist }
  let(:view_names_hash) do
    {
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
    }
  end

  describe 'Constant' do
    it 'VIEW_NAMES_HASH stores view names of lists' do
      expect(Spree::Marketing::ListPresenter::VIEW_NAMES_HASH).to eq view_names_hash
    end
  end

  describe 'methods' do
    describe '#initialize' do
      it 'sets list as an instance variable' do
        expect((Spree::Marketing::ListPresenter.new list).instance_variable_get(:@list)).to eq list
      end
    end

    describe '#name' do
      context 'when list is of multilist type' do
        it 'returns product name' do
          expect(multilist_presenter.sub_list_name).to eq product_name
        end
      end

      context 'when list is of single list type' do
        it 'returns List name' do
          expect(list_presenter.sub_list_name).to eq list.name
        end
      end
    end

    describe '#description' do
      it 'provides description for list' do
        expect((Spree::Marketing::ListPresenter.new list).description).to eq view_names_hash['AbandonedCart'][:description]
      end
    end
  end
end
