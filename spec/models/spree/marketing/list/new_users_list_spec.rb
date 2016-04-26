require "spec_helper"

describe Spree::Marketing::NewUsersList, type: :model do

  let!(:new_user) { create(:user) }
  let!(:old_user) { create(:user, created_at: Time.current - 10.days) }

  describe "methods" do
    context "#emails" do
      it { expect(Spree::Marketing::NewUsersList.new.send :emails).to include new_user.email }
      it { expect(Spree::Marketing::NewUsersList.new.send :emails).to_not include old_user.email }
    end
  end

end
