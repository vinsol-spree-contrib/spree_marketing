require "spec_helper"

describe Spree::Marketing::LeastZoneWiseOrdersList, type: :model do

  let(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let(:state) { create(:state) }
  let(:entity_key) { state.id }
  let(:entity_name) { state.name.downcase.gsub(" ", "_") }
  let(:address) { create(:address, state: state) }
  let!(:order) { create(:completed_order_with_totals, ship_address: address, user_id: first_user.id) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::LeastZoneWiseOrdersList

  describe "Constants" do
    it { expect(Spree::Marketing::LeastZoneWiseOrdersList::ENTITY_KEY).to eq 'state_id' }
    it { expect(Spree::Marketing::LeastZoneWiseOrdersList::TIME_FRAME).to eq 1.month }
    it { expect(Spree::Marketing::LeastZoneWiseOrdersList::LEAST_ZONE_WISE_ORDER_COUNT).to eq 5 }
  end

  describe "methods" do
    context ".state_name" do
      it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :state_name, state.id).to eq "alabama" }
    end

    context ".name_text" do
      it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :name_text, state.id).to eq "least_zone_wise_orders_list_alabama" }
    end

    describe ".data" do
      context "method flow" do
        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :data).to include state.id }
      end

      context "limit to LEAST_ZONE_WISE_ORDER_COUNT" do
        before { Spree::Marketing::LeastZoneWiseOrdersList::LEAST_ZONE_WISE_ORDER_COUNT = 1 }
        let(:other_state) { create(:state, name: "Other State") }
        let(:other_address) { create(:address, state: other_state) }
        let!(:order_in_other_state) { create(:completed_order_with_totals, ship_address: other_address, user_id: second_user.id) }

        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :data).to include state.id }
        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.send :data).to_not include other_state.id }
      end
    end

    context "#user_ids" do
      context "method flow" do
        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: state.id).user_ids).to include first_user.id }
        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: state.id).user_ids).to_not include second_user.id }
      end

      context "order by guest user" do
        let(:guest_user_email) { "spree@example.com" }
        let!(:guest_user_completed_order) { create(:completed_order_with_totals, user_id: nil, ship_address: address, email: guest_user_email) }

        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: state.id).send :emails).to_not include guest_user_email }
      end

      context "completed before TIME_FRAME" do
        let!(:old_completed_order) { create(:completed_order_with_totals, user_id: second_user.id, ship_address: address) }
        before { old_completed_order.update_columns(completed_at: Time.current - 2.month) }

        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: state.id).user_ids).to_not include second_user.id }
      end

      context "only given state is considered" do
        let(:other_state) { create(:state, name: "Other State") }
        let(:other_address) { create(:address, state: other_state) }
        let!(:order_in_other_state) { create(:completed_order_with_totals, ship_address: other_address, user_id: second_user.id) }

        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: other_state.id).user_ids).to include second_user.id }
        it { expect(Spree::Marketing::LeastZoneWiseOrdersList.new(state_id: other_state.id).user_ids).to_not include first_user.id }
      end
    end
  end

end
