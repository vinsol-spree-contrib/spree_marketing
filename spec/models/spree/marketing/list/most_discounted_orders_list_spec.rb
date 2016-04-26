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

  describe "methods" do
    context "#user_ids" do
      it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to include first_user.id }
      it { expect(Spree::Marketing::MostDiscountedOrdersList.new.user_ids).to_not include second_user.id }
    end
  end

end
