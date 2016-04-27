require "spec_helper"

describe Spree::Marketing::LeastZoneWiseOrdersList, type: :model do

  let(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let(:state) { create(:state) }
  let(:address) { create(:address, state: state) }
  let!(:order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }

  describe "methods" do
    context "#self.state_name" do
      it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :state_name, state.id).to eq "alabama" }
    end

    context "#self.name_text" do
      it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :name_text, state.id).to eq "least_zone_wise_orders_list_alabama" }
    end

    context "#self.data" do
      it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :data).to include state.id }
    end

    context "#user_ids" do
      it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: state.id).user_ids).to include first_user.id }
      it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: state.id).user_ids).to_not include second_user.id }
    end
  end

end
