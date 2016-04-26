require "spec_helper"

describe Spree::Marketing::AbandonedCartList, type: :model do

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let!(:registered_user_complete_order) { create(:completed_order_with_totals, user_id: user2.id) }
  let!(:registered_user_incomplete_order) { create(:order, user_id: user1.id) }
  let!(:guest_user_incomplete_order) { create(:order, user_id: nil) }

  describe "methods" do
    context "#user_ids" do
      it { expect(Spree::Marketing::AbandonedCartList.new.user_ids).to include user1.id }
      it { expect(Spree::Marketing::AbandonedCartList.new.user_ids).to_not include user2.id }
    end
  end

end
