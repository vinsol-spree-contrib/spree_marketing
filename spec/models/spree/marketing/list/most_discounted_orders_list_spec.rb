require "spec_helper"

describe Spree::Marketing::MostDiscountedOrdersList, type: :model do

  let!(:user_having_6_completed_orders_with_given_promotion) { create(:user_with_completed_orders, :with_promotion, orders_count: 6) }

  describe "Constants" do
    it { expect(Spree::Marketing::MostDiscountedOrdersList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::MostDiscountedOrdersList::MINIMUM_COUNT).to eq 5 }
  end

  describe "methods" do
    describe "#user_ids" do
      context "when there are greater than or less than 5 orders" do
        let(:user_having_4_completed_orders_with_given_promotion) { create(:user_with_completed_orders, :with_promotion, orders_count: 4) }

        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to include user_having_6_completed_orders_with_given_promotion.id }
        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to_not include user_having_4_completed_orders_with_given_promotion.id }
      end

      context "when user is not registered" do
        let(:guest_user_email) { "spree@example.com" }
        let!(:guest_user_order) { create_list(:order_with_promotion, 6, user_id: nil, email: guest_user_email) }

        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.send :emails).to_not include guest_user_email }
      end

      context "when orders are completed before TIME_FRAME" do
        let(:timestamp) { Time.current - 2.months }
        let(:user_having_6_old_completed_orders_with_given_promotion) { create(:user) }
        let!(:orders) { create_list(:order_with_promotion, 6, :with_custom_completed_at, completed_at: timestamp, user: user_having_6_old_completed_orders_with_given_promotion) }

        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to_not include user_having_6_old_completed_orders_with_given_promotion.id }
        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to include user_having_6_completed_orders_with_given_promotion.id }
      end
    end
  end

end
