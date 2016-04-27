require "spec_helper"

describe Spree::Marketing::MostDiscountedOrdersList, type: :model do

  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let(:promotion) { create(:promotion_with_order_adjustment) }
  let!(:first_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: first_user.id) }
  let!(:second_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: first_user.id) }
  let!(:third_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: first_user.id) }
  let!(:fourth_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: first_user.id) }
  let!(:fifth_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: first_user.id) }
  let!(:sixth_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: first_user.id) }

  describe "Constants" do
    it { expect(Spree::Marketing::MostDiscountedOrdersList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::MostDiscountedOrdersList::MINIMUM_COUNT).to eq 5 }
  end

  describe "methods" do
    describe "#user_ids" do
      context "orders shuld be greater than 5" do
        let!(:seventh_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: second_user.id) }

        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to_not include second_user.id }
      end

      context "guest user order" do
        let(:guest_user_email) { "spree@example.com" }
        let!(:guest_user_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: nil, email: guest_user_email) }

        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.send :emails).to_not include guest_user_email }
      end

      context "completed at before TIME_FRAME" do
        let(:old_completed_order) { create(:completed_order_with_totals, promotions: [promotion], user_id: second_user.id) }
        before { old_completed_order.update_columns(completed_at: Time.current - 2.month) }

        it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to_not include second_user.id }
      end
    end
  end

end
