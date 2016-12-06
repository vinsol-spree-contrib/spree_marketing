require 'spec_helper'

describe Spree::Marketing::List::MostDiscountedOrders, type: :model do

  let!(:user_having_6_completed_orders_with_promotion) { create(:user_with_completed_orders, :with_promotion, orders_count: 6) }

  describe 'Constants' do
    it 'NAME_TEXT equals to name representation for list' do
      expect(Spree::Marketing::List::MostDiscountedOrders::NAME_TEXT).to eq 'Discount Seekers'
    end
    it 'TIME_FRAME equals to time frame used in filtering of users for list' do
      expect(Spree::Marketing::List::MostDiscountedOrders::TIME_FRAME).to eq 1.month
    end
    it 'MINIMUM_COUNT equals to the minimum count of orders required by a single user' do
      expect(Spree::Marketing::List::MostDiscountedOrders::MINIMUM_COUNT).to eq 5
    end
    it 'AVAILABLE_REPORTS equals to array of reports for this list type' do
      expect(Spree::Marketing::List::MostDiscountedOrders::AVAILABLE_REPORTS).to eq [:cart_additions_by, :purchases_by, :product_views_by]
    end
  end

  describe 'methods' do
    describe '#user_ids' do
      context 'when there are users having less than 5 orders' do
        let(:user_having_4_completed_orders_with_promotion) { create(:user_with_completed_orders, :with_promotion, orders_count: 4) }

        it 'includes users having more than 5 completed orders with promotion' do
          expect(Spree::Marketing::List::MostDiscountedOrders.new.user_ids).to include user_having_6_completed_orders_with_promotion.id
        end
        it "doesn't include users having less than 5 completed orders with promotion" do
          expect(Spree::Marketing::List::MostDiscountedOrders.new.user_ids).to_not include user_having_4_completed_orders_with_promotion.id
        end
      end

      context 'when user is not registered' do
        let(:guest_user_email) { 'spree@example.com' }
        let!(:guest_user_order) { create_list(:order_with_promotion, 6, user_id: nil, email: guest_user_email) }

        it "doesn't include guest users having completed orders with promotion" do
          expect(Spree::Marketing::List::MostDiscountedOrders.new.send(:users_data).keys).to_not include guest_user_email
        end
      end

      context 'when orders are completed before TIME_FRAME' do
        let(:timestamp) { Time.current - 2.months }
        let(:user_having_6_old_completed_orders_with_promotion) { create(:user) }
        let!(:orders) { create_list(:order_with_promotion, 6, :with_custom_completed_at, completed_at: timestamp, user: user_having_6_old_completed_orders_with_promotion) }

        it "doesn't include users having more than 5 completed orders with promotion completed before time frame" do
          expect(Spree::Marketing::List::MostDiscountedOrders.new.user_ids).to_not include user_having_6_old_completed_orders_with_promotion.id
        end
        it 'includes users having more than 5 completed orders with promotion completed after time frame' do
          expect(Spree::Marketing::List::MostDiscountedOrders.new.user_ids).to include user_having_6_completed_orders_with_promotion.id
        end
      end
    end
  end

end
