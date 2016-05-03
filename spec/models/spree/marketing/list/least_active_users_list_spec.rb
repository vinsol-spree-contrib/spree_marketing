require "spec_helper"

describe Spree::Marketing::LeastActiveUsersList, type: :model do

  let!(:user_with_6_page_events) { create(:user_with_page_events, page_events_count: 6) }

  describe "Constants" do
    it "user should have lesser page events than MAXIMUM_PAGE_EVENT_COUNT" do
      expect(Spree::Marketing::LeastActiveUsersList::MAXIMUM_PAGE_EVENT_COUNT).to eq 5
    end
  end

  describe "methods" do
    describe "#user_ids" do
      context "when there are users having greater 5 page events" do
        let!(:user_with_4_page_events) { create(:user_with_page_events, page_events_count: 4) }

        it "return user ids which include users who have less than 5 page events" do
          expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to_not include user_with_6_page_events.id
        end
        it "return user ids which doesn't include users who have more than 5 page events" do
          expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to include user_with_4_page_events.id
        end
      end

      context "when there are page events of guest users" do
        let!(:guest_user_page_events) { create_list(:marketing_page_event, 1, actor: nil) }

        it "return user ids which doesn't include guest users" do
          expect(Spree::Marketing::LeastActiveUsersList.new.user_ids).to_not include nil
        end
      end

      context "when there are page events of users other than Spree.user_class type" do
        let(:other_user_type_id) { 9 }
        let(:other_user_type_page_events) { create_list(:marketing_page_event, 3, actor_id: other_user_type_id, actor_type: nil) }

        it "return user ids which doesn't include users other than Spree.user_class type" do
          expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include other_user_type_id
        end
      end

      context "when there are page events which are created before TIME FRAME" do
        let(:timestamp) { Time.current - 10.days }
        let!(:user_with_4_old_page_events) { create(:user_with_page_events, page_events_count: 4, created_at: timestamp) }

        it "return user ids which doesn't include users who have page events before time frame" do
          expect(Spree::Marketing::LeastActiveUsersList.new.send :user_ids).to_not include user_with_4_old_page_events.id
        end
      end
    end
  end

end
