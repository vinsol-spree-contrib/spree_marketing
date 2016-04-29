require "spec_helper"

describe Spree::Marketing::LeastActiveUsersList, type: :model do

  let!(:user_with_6_page_events) { create(:user_with_page_events, page_events_count: 6) }

  describe "Constants" do
    it { expect(Spree::Marketing::LeastActiveUsersList::MAXIMUM_PAGE_EVENT_COUNT).to eq 5 }
  end

  describe "methods" do
    describe "#user_ids" do
      context "user having greater than and less than 5 page events" do
        let!(:user_with_4_page_events) { create(:user_with_page_events, page_events_count: 4) }

        it { expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to_not include user_with_6_page_events.id }
        it { expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to include user_with_4_page_events.id }
      end

      context "with guest user" do
        let!(:guest_user_page_events) { create_list(:marketing_page_event, actor_id: nil, actor_type: nil) }

        xit { expect(Spree::Marketing::LeastActiveUsersList.new.send :emails) }
      end

      context "with page events of other user type page events" do
        let(:other_user_type_id) { 9 }
        let(:other_user_type_page_events) { create_list(:marketing_page_event, 3, actor_id: other_user_type_id, actor_type: nil) }

        it { expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include other_user_type_id }
      end

      context "where page event is done before TIME FRAME" do
        let(:timestamp) { Time.current - 10.days }
        let!(:user_with_4_old_page_events) { create(:user_with_page_events, page_events_count: 4, created_at: timestamp) }

        it { expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include user_with_4_old_page_events.id }
      end
    end
  end

end
