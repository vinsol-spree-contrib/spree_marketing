require 'spec_helper'

describe Spree::Marketing::FavourableProductsList, type: :model do

  let(:user_with_orders_having_given_product) { create(:user) }
  let(:product) { create(:product, name: 'Ruby On Rails Tote') }
  let(:entity_id) { product.id }
  let(:entity_name) { product.name }
  let!(:orders_having_given_product) { create_list(:order_with_given_product, 2, user: user_with_orders_having_given_product, product: product) }

  it_behaves_like 'acts_as_multilist', Spree::Marketing::FavourableProductsList

  describe 'Constants' do
    it 'NAME_TEXT equals to name representation for list' do
      expect(Spree::Marketing::FavourableProductsList::NAME_TEXT).to eq 'Most Selling Products'
    end
    it 'ENTITY_KEY equals to entity attribute for list' do
      expect(Spree::Marketing::FavourableProductsList::ENTITY_KEY).to eq 'entity_id'
    end
    it 'ENTITY_TYPE equals to type of entity for list' do
      expect(Spree::Marketing::FavourableProductsList::ENTITY_TYPE).to eq 'Spree::Product'
    end
    it 'TIME_FRAME equals to time frame used in filtering of users for list' do
      expect(Spree::Marketing::FavourableProductsList::TIME_FRAME).to eq 1.month
    end
    it 'FAVOURABLE_PRODUCT_COUNT equals to count of products to be used for data for lists' do
      expect(Spree::Marketing::FavourableProductsList::FAVOURABLE_PRODUCT_COUNT).to eq 10
    end
    it 'AVAILABLE_REPORTS equals to array of reports for this list type' do
      expect(Spree::Marketing::FavourableProductsList::AVAILABLE_REPORTS).to eq [:cart_additions_by, :purchases_by, :product_views_by]
    end
  end

  describe 'methods' do

    describe '.data' do
      context 'method flow' do
        it 'includes the entity product id' do
          expect(Spree::Marketing::FavourableProductsList.send :data).to include product.id
        end
      end

      context 'limit to constant FAVOURABLE_PRODUCT_COUNT' do
        let(:second_product) { create(:product, name: 'Product 2') }
        let(:third_product) { create(:product, name: 'Product 3') }
        let(:fourth_product) { create(:product, name: 'Product 4') }
        let(:fifth_product) { create(:product, name: 'Product 5') }
        let(:sixth_product) { create(:product, name: 'Product 6') }
        let(:seventh_product) { create(:product, name: 'Product 7') }
        let(:eighth_product) { create(:product, name: 'Product 8') }
        let(:ninth_product) { create(:product, name: 'Product 9') }
        let(:tenth_product) { create(:product, name: 'Product 10') }
        let(:eleventh_product) { create(:product, name: 'Product 11') }

        let!(:orders_having_second_product) { create_list(:order_with_given_product, 2, product: second_product) }
        let!(:orders_having_third_product) { create_list(:order_with_given_product, 2, product: third_product) }
        let!(:orders_having_fourth_product) { create_list(:order_with_given_product, 2, product: fourth_product) }
        let!(:orders_having_fifth_product) { create_list(:order_with_given_product, 2, product: fifth_product) }
        let!(:orders_having_sixth_product) { create_list(:order_with_given_product, 2, product: sixth_product) }
        let!(:orders_having_seventh_product) { create_list(:order_with_given_product, 2, product: seventh_product) }
        let!(:orders_having_eighth_product) { create_list(:order_with_given_product, 2, product: eighth_product) }
        let!(:orders_having_ninth_product) { create_list(:order_with_given_product, 2, product: ninth_product) }
        let!(:orders_having_tenth_product) { create_list(:order_with_given_product, 2, product: tenth_product) }
        let!(:orders_having_eleventh_product) { create_list(:order_with_given_product, 1, product: eleventh_product) }

        it 'includes the top 10 most bought products' do
          expect(Spree::Marketing::FavourableProductsList.send :data).to include *[product.id, second_product.id, third_product.id, fourth_product.id, fifth_product.id, sixth_product.id, seventh_product.id, eighth_product.id, ninth_product.id, tenth_product.id]
        end
        it "doesn't include the product which is not in top 10 most bought products" do
          expect(Spree::Marketing::FavourableProductsList.send :data).to_not include eleventh_product.id
        end
      end

      context 'with old completed orders of other product' do
        let(:other_product) { create(:product, name: 'Other Product') }
        let(:timestamp) { Time.current - 2.month }
        let!(:old_orders_of_other_product) { create_list(:order_with_given_product, 2, :with_custom_completed_at, product: other_product, completed_at: timestamp) }

        it 'returns product ids which will not include products having orders before time frame' do
          expect(Spree::Marketing::FavourableProductsList.send :data).to_not include other_product.id
        end
      end
    end

    describe '#user_ids' do
      let(:list_param) { { entity_id: product.id, entity_type: 'Spree::Product' } }

      context 'method flow' do
        let!(:user_with_no_orders) { create(:user) }

        it 'includes the users who have ordered the entity product' do
          expect(Spree::Marketing::FavourableProductsList.new(list_param).user_ids).to include user_with_orders_having_given_product.id
        end
        it "doesn't include the users who haven't ordered the entity product" do
          expect(Spree::Marketing::FavourableProductsList.new(list_param).user_ids).to_not include user_with_no_orders.id
        end
      end

      context 'when user is not registered' do
        let(:guest_user_email) { 'spree@example.com' }
        let!(:guest_user_complete_order) { create(:order_with_given_product, product: product, email: guest_user_email, user_id: nil) }

        it "doesn't include guest users who have ordered the entity product" do
          expect(Spree::Marketing::FavourableProductsList.new(list_param).send(:users_data).keys).to_not include guest_user_complete_order.email
        end
      end

      context 'when order is completed before TIME_FRAME' do
        let(:registered_user) { create(:user) }
        let(:timestamp) { Time.current - 2.months }
        let!(:registered_user_old_complete_order) { create(:order_with_given_product, :with_custom_completed_at, user: registered_user, product: product, completed_at: timestamp) }

        it "doesn't include users who have ordered the entity product before time frame" do
          expect(Spree::Marketing::FavourableProductsList.new(list_param).user_ids).to_not include registered_user.id
        end
      end

      context 'when other product orders also exists' do
        let(:user_with_order_having_other_product) { create(:user) }
        let(:other_product) { create(:product, name: 'Sample') }
        let!(:other_product_order) { create(:order_with_given_product, product: other_product, user_id: user_with_order_having_other_product.id) }

        it "doesn't include users who haven't entity product" do
          expect(Spree::Marketing::FavourableProductsList.new(list_param).user_ids).to_not include user_with_order_having_other_product.id
        end
        it 'includes users who have ordered the entity product' do
          expect(Spree::Marketing::FavourableProductsList.new(list_param).user_ids).to include user_with_orders_having_given_product.id
        end
      end
    end
  end

end
