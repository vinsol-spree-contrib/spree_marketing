require "spec_helper"

describe Spree::Marketing::MostZoneWiseOrdersList, type: :model do

  let(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let(:state) { create(:state) }
  let(:entity_key) { state.id }
  let(:entity_name) { state.name.downcase.gsub(" ", "_") }
  let(:address) { create(:address, state: state) }
  let!(:first_order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }
  let!(:second_order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }
  let!(:third_order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }
  let!(:fourth_order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }
  let!(:fifth_order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }
  let!(:sixth_order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::MostZoneWiseOrdersList

  describe "Constants" do
    it { expect(Spree::Marketing::MostZoneWiseOrdersList::ENTITY_KEY).to eq 'state_id' }
    it { expect(Spree::Marketing::MostZoneWiseOrdersList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::MostZoneWiseOrdersList::MOST_ZONE_WISE_ORDERS_COUNT).to eq 5 }
  end

  describe "methods" do
    context "#self.state_name" do
      it { expect(Spree::Marketing::MostZoneWiseOrdersList.send :state_name, state.id).to eq "alabama" }
    end

    context "#self.name_text" do
      it { expect(Spree::Marketing::MostZoneWiseOrdersList.send :name_text, state.id).to eq "most_zone_wise_orders_list_alabama" }
    end

    describe "#self.data" do
      context "method flow" do
        it { expect(Spree::Marketing::MostZoneWiseOrdersList.send :data).to include state.id }
      end

      context "limit to MOST_ZONE_WISE_ORDERS_COUNT" do
        let(:other_state) { create(:state, name: "Other state") }
        let(:other_address) { create(:address, state: other_state) }
        let!(:order_in_other_state) { create(:completed_order_with_totals, ship_address: other_address, user_id: second_user.id) }

        before { Spree::Marketing::MostZoneWiseOrdersList::MOST_ZONE_WISE_ORDERS_COUNT = 1 }

        it { expect(Spree::Marketing::MostZoneWiseOrdersList.send :data).to include state.id }
        it { expect(Spree::Marketing::MostZoneWiseOrdersList.send :data).to_not include other_state.id }
      end
    end

    context "#user_ids" do
      context "not having other state order" do
        let(:other_state) { create(:state, name: "Other state") }
        let(:other_address) { create(:address, state: other_state) }
        let!(:order_in_other_state) { create(:completed_order_with_totals, ship_address: other_address, user_id: second_user.id) }

        it { expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).user_ids).to_not include second_user.id }
      end

      context "guest user order" do
        let(:guest_user_email) { "spree@example.com" }
        let!(:guest_user_order) { create(:completed_order_with_totals, user_id: nil, email: guest_user_email, ship_address: address) }

        it { expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).send :emails).to_not include guest_user_email }
      end

      context "completed at before TIME_FRAME" do
        let!(:old_completed_order) { create(:completed_order_with_totals, user_id: second_user.id, ship_address: address) }
        before { old_completed_order.update_columns(completed_at: Time.current - 2.month) }

        it { expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).send :user_ids).to_not include second_user.id }
      end
    end
  end

end
