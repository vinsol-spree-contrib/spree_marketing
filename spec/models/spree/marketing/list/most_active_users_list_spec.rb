require 'spec_helper'

describe Spree::Marketing::MostActiveUsersList, type: :model do

  let!(:user_with_6_page_events) { create(:user_with_page_events, page_events_count: 6) }

  describe 'Constants' do
    it 'NAME_TEXT equals to name representation for list' do
      expect(Spree::Marketing::MostActiveUsersList::NAME_TEXT).to eq 'Most Active Users'
    end
    it 'user should have more page events than MINIMUM_PAGE_EVENT_COUNT' do
      expect(Spree::Marketing::MostActiveUsersList::MINIMUM_PAGE_EVENT_COUNT).to eq 5
    end
    it 'AVAILABLE_REPORTS equals to array of reports for this list type' do
      expect(Spree::Marketing::MostActiveUsersList::AVAILABLE_REPORTS).to eq [:cart_additions_by, :purchases_by, :product_views_by]
    end
  end

  describe 'methods' do
    describe '#user_ids' do
      context 'when there are users having less than 5 page events' do
        let!(:user_with_4_page_events) { create(:user_with_page_events, page_events_count: 4) }

        it 'return user ids which include users having more than 5 page events' do
          expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to include user_with_6_page_events.id
        end
        it "return user ids which doesn't include users having less than 5 page events" do
          expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to_not include user_with_4_page_events.id
        end
      end

      context 'when there are page events of guest users' do
        let!(:guest_user_page_event) { create_list(:marketing_page_event, 6, actor: nil) }

        it "return user ids which doesn't include guest users" do
          expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to_not include nil
        end
      end

      context 'when there are page events of users other than Spree.user_class type' do
        let(:other_user_type_id) { 9 }
        let!(:other_user_type_page_events) { create_list(:marketing_page_event, 6, actor_id: other_user_type_id, actor_type: nil) }

        it "return user ids which doesn't include users other than Spree.user_class type" do
          expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to_not include other_user_type_id
        end
      end

      context 'when page events are created before TIME FRAME' do
        let(:timestamp) { Time.current - 10.days }
        let!(:user_with_6_old_page_events) { create(:user_with_page_events, page_events_count: 6, created_at: timestamp) }

        it 'return user ids which include users having page events created after time frame' do
          expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to include user_with_6_page_events.id
        end
        it "return user ids which doesn't include users having page events created before time frame" do
          expect(Spree::Marketing::MostActiveUsersList.new.user_ids).to_not include user_with_6_old_page_events.id
        end
      end
    end
  end

end
