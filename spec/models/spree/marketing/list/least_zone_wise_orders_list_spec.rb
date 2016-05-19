require 'spec_helper'

describe Spree::Marketing::LeastZoneWiseOrdersList, type: :model do

  let(:state_name) { 'alabama' }
  let(:state) { create(:state, name: state_name) }
  let(:entity_id) { state.id }
  let(:entity_name) { state.name.downcase.gsub(' ', '_') }
  let!(:user_with_completed_orders_with_billing_address_having_given_state) { create(:user_with_completed_orders, :with_given_billing_state, state: state, orders_count: 3) }

  it_behaves_like 'acts_as_multilist', Spree::Marketing::LeastZoneWiseOrdersList

  describe 'Constants' do
    it 'NAME_TEXT equals to name representation for list' do
      expect(Spree::Marketing::LeastZoneWiseOrdersList::NAME_TEXT).to eq 'Cold Zone'
    end
    it 'ENTITY_KEY equals to entity attribute for list' do
      expect(Spree::Marketing::LeastZoneWiseOrdersList::ENTITY_KEY).to eq 'entity_id'
    end
    it 'ENTITY_TYPE equals to type of entity for list' do
      expect(Spree::Marketing::LeastZoneWiseOrdersList::ENTITY_TYPE).to eq 'Spree::State'
    end
    it 'TIME_FRAME equals to time frame used in filtering of users for list' do
      expect(Spree::Marketing::LeastZoneWiseOrdersList::TIME_FRAME).to eq 1.month
    end
    it 'LEAST_ZONE_WISE_ORDER_COUNT equals to count of keywords to be used for data for lists' do
      expect(Spree::Marketing::LeastZoneWiseOrdersList::LEAST_ZONE_WISE_ORDER_COUNT).to eq 5
    end
    it 'AVAILABLE_REPORTS equals to array of reports for this list type' do
      expect(Spree::Marketing::LeastZoneWiseOrdersList::AVAILABLE_REPORTS).to eq [:purchases_by]
    end
  end

  describe 'methods' do

    describe '.data' do
      context 'method flow' do
        it 'includes entity state id' do
          expect(Spree::Marketing::LeastZoneWiseOrdersList.send :data).to include state.id
        end
      end

      context 'limit to LEAST_ZONE_WISE_ORDER_COUNT' do
        let(:second_state) { create(:state, name: 'State 2') }
        let(:third_state) { create(:state, name: 'State 3') }
        let(:fourth_state) { create(:state, name: 'State 4') }
        let(:fifth_state) { create(:state, name: 'State 5') }
        let(:sixth_state) { create(:state, name: 'State 6') }
        let!(:orders_in_second_state) { create_list(:order_with_given_billing_state, 1, state: second_state) }
        let!(:orders_in_third_state) { create_list(:order_with_given_billing_state, 1, state: third_state) }
        let!(:orders_in_fourth_state) { create_list(:order_with_given_billing_state, 1, state: fourth_state) }
        let!(:orders_in_fifth_state) { create_list(:order_with_given_billing_state, 1, state: fifth_state) }
        let!(:orders_in_sixth_state) { create_list(:order_with_given_billing_state, 6, state: sixth_state) }

        it 'includes top 5 states where least number of orders are placed' do
          expect(Spree::Marketing::LeastZoneWiseOrdersList.send :data).to include *[state.id, second_state.id, third_state.id, fourth_state.id, fifth_state.id]
        end
        it "doesn't include state which is not included in top 5 states with least number of orders" do
          expect(Spree::Marketing::LeastZoneWiseOrdersList.send :data).to_not include sixth_state.id
        end
      end
    end

    describe '#user_ids' do
      let(:params) { { entity_id: state.id, entity_type: 'Spree::State' } }

      context 'with orders not having selected state' do
        let(:user_with_order_in_other_state) { create(:user) }
        let(:other_state) { create(:state, name: 'Other state') }
        let!(:orders_in_other_state) { create_list(:order_with_given_billing_state, 1, state: other_state, user_id: user_with_order_in_other_state.id) }

        it 'include users with orders in the entity zone' do
          expect(Spree::Marketing::LeastZoneWiseOrdersList.new(params).user_ids).to include user_with_completed_orders_with_billing_address_having_given_state.id
        end
        it "doesn't include the users which do not have order in entity state" do
          expect(Spree::Marketing::LeastZoneWiseOrdersList.new(params).user_ids).to_not include user_with_order_in_other_state.id
        end
      end

      context 'when user is not registered' do
        let(:guest_user_email) { 'spree@example.com' }
        let!(:guest_user_orders) { create_list(:order_with_given_billing_state, 1, user_id: nil, email: guest_user_email, state: state) }

        it "doesn't include guest users who have ordered in the entity state" do
          expect(Spree::Marketing::LeastZoneWiseOrdersList.new(params).send(:users_data).keys).to_not include guest_user_email
        end
      end

      context 'when orders are completed before TIME_FRAME' do
        let(:timestamp) { Time.current - 2.months }
        let(:user_having_old_completed_orders_in_given_state) { create(:user) }
        let!(:old_completed_orders) { create_list(:order_with_given_billing_state, 1, :with_custom_completed_at, user_id: user_having_old_completed_orders_in_given_state.id, state: state, completed_at: timestamp) }

        it "doesn't include users who have orders in entity state completed before time frame" do
          expect(Spree::Marketing::LeastZoneWiseOrdersList.new(params).send :user_ids).to_not include user_having_old_completed_orders_in_given_state.id
        end
      end
    end
  end

end
