require 'spec_helper'

describe Spree::Marketing::List::NewUsers, type: :model do
  let!(:new_user) { create(:user)                                     }
  let!(:old_user) { create(:user, created_at: Time.current - 10.days) }

  describe 'Constants' do
    it 'NAME_TEXT equals to name representation for list' do
      expect(Spree::Marketing::List::NewUsers::NAME_TEXT).to eq 'New Users'
    end
    it 'AVAILABLE_REPORTS equals to array of method names for reports' do
      expect(Spree::Marketing::List::NewUsers::AVAILABLE_REPORTS).to eq %i[log_ins_by cart_additions_by purchases_by product_views_by]
    end
  end

  describe 'methods' do
    context '#emails' do
      it { expect(Spree::Marketing::List::NewUsers.new.send(:users_data).keys).to include new_user.email }
      it { expect(Spree::Marketing::List::NewUsers.new.send(:users_data).keys).to_not include old_user.email }
    end
  end
end
