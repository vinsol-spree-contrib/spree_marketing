require "spec_helper"

describe Spree::Marketing::MostActiveUsersList, type: :model do

  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:first_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:second_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:third_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:fourth_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:fifth_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:sixth_page_event) { create(:page_event, actor_id: first_user.id) }

  describe "methods" do
    context "#user_ids" do
      it { expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to include first_user.id }
      it { expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to_not include second_user.id }
    end
  end

end
