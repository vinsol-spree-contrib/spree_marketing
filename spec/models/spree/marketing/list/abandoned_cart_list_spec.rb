require "spec_helper"

describe Spree::Marketing::AbandonedCartList, type: :model do

  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:registered_user_complete_order) { create(:completed_order_with_totals, user_id: second_user.id) }
  let!(:registered_user_incomplete_order) { create(:order, user_id: first_user.id) }

  describe "methods" do
    describe "#user_ids" do
      context "with incomplete order" do
        it { expect(Spree::Marketing::AbandonedCartList.new.user_ids).to include first_user.id }
        it { expect(Spree::Marketing::AbandonedCartList.new.user_ids).to_not include second_user.id }
      end

      context "user is not registered" do
        let!(:guest_user_incomplete_order) { create(:order, user_id: nil, email: "spree@example.com") }

        it { expect(Spree::Marketing::AbandonedCartList.new.send :emails).to_not include guest_user_incomplete_order.email  }
        it { expect(Spree::Marketing::AbandonedCartList.new.send :emails).to include registered_user_incomplete_order.email  }
      end
    end
  end

end
