require "spec_helper"

describe Spree::Marketing::LeastActiveUsersList, type: :model do

  let!(:first_user) { create(:user) }
  let!(:second_user) { create(:user) }
  let!(:first_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:second_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:third_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:fourth_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:fifth_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:sixth_page_event) { create(:page_event, actor_id: first_user.id) }
  let!(:seventh_page_event) { create(:page_event, actor_id: second_user.id) }

  describe "methods" do
    describe "#user_ids" do
      context "user having less than 5 page events" do
        it { expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to_not include first_user.id }
        it { expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to include second_user.id }
      end

      context "only registered users" do
        let!(:guest_user_page_event) { create(:page_event, actor_id: nil, actor_type: nil) }

        xit { expect(Spree::Marketing::LeastActiveUsersList.new.send :emails) }
      end

      context "other user type page events" do
        let(:other_user_type_id) { 9 }
        let!(:other_type_user_page_event) { create(:page_event, actor_id: other_user_type_id, actor_type: nil) }
        let!(:first_other_type_user_page_event) { create(:page_event, actor_id: other_user_type_id, actor_type: nil) }
        let!(:second_other_type_user_page_event) { create(:page_event, actor_id: other_user_type_id, actor_type: nil) }
        let!(:third_other_type_user_page_event) { create(:page_event, actor_id: other_user_type_id, actor_type: nil) }
        let!(:fourth_other_type_user_page_event) { create(:page_event, actor_id: other_user_type_id, actor_type: nil) }
        let!(:fifth_other_type_user_page_event) { create(:page_event, actor_id: other_user_type_id, actor_type: nil) }
        let!(:sixth_other_type_user_page_event) { create(:page_event, actor_id: other_user_type_id, actor_type: nil) }

        it { expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include other_user_type_id }
      end

      context "where page event is before TIME FRAME" do
        let!(:first_old_page_event) { create(:page_event, actor_id: second_user.id, created_at: Time.current - 10.days) }
        let!(:second_old_page_event) { create(:page_event, actor_id: second_user.id, created_at: Time.current - 10.days) }
        let!(:third_old_page_event) { create(:page_event, actor_id: second_user.id, created_at: Time.current - 10.days) }
        let!(:fourth_old_page_event) { create(:page_event, actor_id: second_user.id, created_at: Time.current - 10.days) }
        let!(:fifth_old_page_event) { create(:page_event, actor_id: second_user.id, created_at: Time.current - 10.days) }
        let!(:sixth_old_page_event) { create(:page_event, actor_id: second_user.id, created_at: Time.current - 10.days) }

        it { expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to include second_user.id }
      end
    end
  end

end
