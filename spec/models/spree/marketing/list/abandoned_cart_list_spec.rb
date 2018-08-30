require 'spec_helper'

describe Spree::Marketing::List::AbandonedCart, type: :model do
  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:registered_user_complete_order) { create(:completed_order_with_totals, user_id: second_user.id) }
  let(:line_item) { create(:line_item) }
  let!(:registered_user_incomplete_order) { create(:order, user_id: first_user.id, item_count: 1) }

  describe 'constants' do
    it 'NAME_TEXT equals to name representation for list' do
      expect(Spree::Marketing::List::AbandonedCart::NAME_TEXT).to eq 'Abandoned Cart'
    end
    it 'AVAILABLE_REPORTS equals to array of reports for this list type' do
      expect(Spree::Marketing::List::AbandonedCart::AVAILABLE_REPORTS).to eq [:purchases_by]
    end
  end

  describe 'methods' do
    describe '#user_ids' do
      context 'with incomplete order' do
        it { expect(Spree::Marketing::List::AbandonedCart.new.user_ids).to include first_user.id }
        it { expect(Spree::Marketing::List::AbandonedCart.new.user_ids).to_not include second_user.id }
      end

      context 'user is not registered' do
        let!(:guest_user_incomplete_order) { create(:order, user_id: nil, email: 'spree@example.com') }

        it { expect(Spree::Marketing::List::AbandonedCart.new.send(:users_data).keys).to_not include guest_user_incomplete_order.email }
        it { expect(Spree::Marketing::List::AbandonedCart.new.send(:users_data).keys).to include registered_user_incomplete_order.email }
      end

      context 'when there are no items in the cart' do
        let(:user_with_with_zero_items_in_cart) { create(:user) }
        let!(:registered_user_incomplete_order_with_no_items) { create(:order, user: user_with_with_zero_items_in_cart, item_count: 0) }

        it 'returns user ids which will not include users with zero items in cart' do
          expect(Spree::Marketing::List::AbandonedCart.new.user_ids).to_not include user_with_with_zero_items_in_cart.id
        end
      end
    end
  end
end
