require "spec_helper"

describe Spree::Order, type: :model do

  let(:guest_user_order) { create(:order, user_id: nil) }
  let(:registered_user_order) { create(:order) }

  describe "Scopes" do
    it { expect(Spree::Order.of_registered_users).to include registered_user_order }
    it { expect(Spree::Order.of_registered_users).to_not include guest_user_order }
  end

end
