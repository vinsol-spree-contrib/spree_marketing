require "spec_helper"

describe Spree::Marketing::LeastActiveUsersList, type: :model do

  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:first_page_event) { create(:marketing_page_event, actor_id: first_user.id) }
  let!(:second_page_event) { create(:marketing_page_event, actor_id: first_user.id) }
  let!(:third_page_event) { create(:marketing_page_event, actor_id: first_user.id) }
  let!(:fourth_page_event) { create(:marketing_page_event, actor_id: first_user.id) }
  let!(:fifth_page_event) { create(:marketing_page_event, actor_id: first_user.id) }
  let!(:sixth_page_event) { create(:marketing_page_event, actor_id: first_user.id) }

  describe "methods" do
    context "#user_ids" do
      it { expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to_not include first_user.id }
      it { expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to include second_user.id }
    end
  end

end
